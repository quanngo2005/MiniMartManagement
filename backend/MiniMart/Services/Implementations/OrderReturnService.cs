using AutoMapper;
using Microsoft.AspNetCore.Http;
using Microsoft.EntityFrameworkCore;
using MiniMart.Data;
using MiniMart.DTOs;
using MiniMart.Models;
using MiniMart.Models.Enums;
using MiniMart.Repositories.RepoInterface;
using MiniMart.Services.Interfaces;
using MiniMart.Shared.Exceptions;

namespace MiniMart.Services.Implementations
{
    public class OrderReturnService : IOrderReturnService
    {
        private readonly IOrderReturnRepository _orderReturnRepository;
        private readonly IOrderRepository _orderRepository;
        private readonly IShiftRepository _shiftRepository;
        private readonly IBatchRepository _batchRepository;
        private readonly IInventoryTransactionRepository _inventoryTransactionRepository;
        private readonly IProductRepository _productRepository;
        private readonly IMapper _mapper;

        public OrderReturnService(
            IOrderReturnRepository orderReturnRepository,
            IOrderRepository orderRepository,
            IShiftRepository shiftRepository,
            IBatchRepository batchRepository,
            IInventoryTransactionRepository inventoryTransactionRepository,
            IProductRepository productRepository,
            IMapper mapper)
        {
            _orderReturnRepository = orderReturnRepository;
            _orderRepository = orderRepository;
            _shiftRepository = shiftRepository;
            _batchRepository = batchRepository;
            _inventoryTransactionRepository = inventoryTransactionRepository;
            _productRepository = productRepository;
            _mapper = mapper;
        }

        public IQueryable<OrderReturnDto> GetAllOrderReturnsQueryable()
        {
            return _mapper.ProjectTo<OrderReturnDto>(_orderReturnRepository.GetAllQueryable());
        }

        public async Task<OrderReturnDto?> GetOrderReturnByIdAsync(int id)
        {
            var entity = await _orderReturnRepository.GetByIdAsync(id);
            return entity == null ? null : _mapper.Map<OrderReturnDto>(entity);
        }

        public async Task<OrderReturnDto> CreateOrderReturnAsync(CreateOrderReturnDto dto, int employeeId)
        {
            // 1. Check if Cashier is in an active shift
            var activeShift = await _shiftRepository.GetActiveShiftByCashierIdAsync(employeeId);
            if (activeShift == null)
            {
                throw new DomainException("Thu ngân hiện không trong ca làm việc nào. Vui lòng mở ca trước.", StatusCodes.Status400BadRequest);
            }

            // 2. Check if original order exists
            var order = await _orderRepository.GetAllOrdersQueryable()
                .Include(o => o.OrderDetails)
                    .ThenInclude(od => od.Product)
                .FirstOrDefaultAsync(o => o.OrderId == dto.OriginalOrderId);

            if (order == null)
            {
                throw new DomainException("Không tìm thấy hóa đơn gốc để hoàn trả.", StatusCodes.Status404NotFound);
            }

            // 3. Check if return request is within 48h limit
            var timeDiff = DateTime.Now - order.OrderDate;
            if (timeDiff.TotalHours > 48)
            {
                throw new DomainException("Hóa đơn đã quá hạn hoàn trả 48 giờ kể từ lúc mua.", StatusCodes.Status400BadRequest);
            }

            // 4. Validate items quantities and construct details
            decimal totalRefund = 0;
            var details = new List<OrderReturnDetail>();

            foreach (var itemDto in dto.Items)
            {
                var originalDetail = order.OrderDetails.FirstOrDefault(od => od.ProductId == itemDto.ProductId);
                if (originalDetail == null)
                {
                    throw new DomainException($"Sản phẩm ID {itemDto.ProductId} không có trong hóa đơn gốc.", StatusCodes.Status400BadRequest);
                }

                if (itemDto.Quantity <= 0)
                {
                    throw new DomainException("Số lượng sản phẩm hoàn trả phải lớn hơn 0.", StatusCodes.Status400BadRequest);
                }

                // Check already returned quantity from other returns of this order
                var alreadyReturnedQty = await _orderReturnRepository.GetAllQueryable()
                    .Where(r => r.OriginalOrderId == order.OrderId && r.Status != OrderReturnStatus.Rejected)
                    .SelectMany(r => r.OrderReturnDetails)
                    .Where(d => d.ProductId == itemDto.ProductId)
                    .SumAsync(d => d.Quantity);

                if (itemDto.Quantity + alreadyReturnedQty > originalDetail.Quantity)
                {
                    throw new DomainException($"Sản phẩm '{originalDetail.Product?.ProductName}' chỉ có thể trả tối đa {originalDetail.Quantity - alreadyReturnedQty} cái (đã trả {alreadyReturnedQty}/{originalDetail.Quantity} trước đó).", StatusCodes.Status400BadRequest);
                }

                var itemTotal = originalDetail.UnitPrice * itemDto.Quantity;
                totalRefund += itemTotal;

                details.Add(new OrderReturnDetail
                {
                    ProductId = itemDto.ProductId,
                    Quantity = itemDto.Quantity,
                    UnitPrice = originalDetail.UnitPrice,
                    TotalPrice = itemTotal
                });
            }

            if (details.Count == 0)
            {
                throw new DomainException("Không có sản phẩm nào được chọn để hoàn trả.", StatusCodes.Status400BadRequest);
            }

            // 5. Generate ReturnCode
            var count = await _orderReturnRepository.GetAllQueryable().CountAsync();
            var returnCode = $"RET-{DateTime.Now:yyyyMMdd}-{count + 1:D4}";

            var orderReturn = new OrderReturn
            {
                ReturnCode = returnCode,
                OriginalOrderId = order.OrderId,
                EmployeeId = employeeId,
                Reason = dto.Reason,
                RefundAmount = totalRefund,
                RefundMethod = (PaymentMethod)dto.RefundMethod,
                Status = OrderReturnStatus.Pending,
                Classify = dto.Classify,
                ImageEvidence = dto.ImageEvidence,
                ShiftId = activeShift.ShiftId,
                OrderReturnDetails = details
            };

            var created = await _orderReturnRepository.CreateAsync(orderReturn);
            
            // Reload database graph details to map to DTO properly
            var result = await _orderReturnRepository.GetByIdAsync(created.OrderReturnId);
            return _mapper.Map<OrderReturnDto>(result!);
        }

        public async Task<OrderReturnDto> ApproveOrderReturnAsync(int id, int managerId)
        {
            var orderReturn = await _orderReturnRepository.GetByIdAsync(id);
            if (orderReturn == null)
            {
                throw new DomainException("Không tìm thấy yêu cầu hoàn tiền.", StatusCodes.Status404NotFound);
            }

            if (orderReturn.Status != OrderReturnStatus.Pending)
            {
                throw new DomainException("Yêu cầu hoàn trả này đã được xử lý rồi.", StatusCodes.Status400BadRequest);
            }

            // Verify the linked shift is still active or valid
            if (orderReturn.ShiftId == null)
            {
                throw new DomainException("Yêu cầu hoàn tiền không liên kết với ca làm việc nào.", StatusCodes.Status400BadRequest);
            }

            var shift = await _shiftRepository.GetShiftByIdAsync(orderReturn.ShiftId.Value);
            if (shift == null)
            {
                throw new DomainException("Không tìm thấy ca làm việc liên kết để hoàn tiền.", StatusCodes.Status400BadRequest);
            }

            // Deduct RefundAmount from Shift.Revenue
            shift.Revenue -= orderReturn.RefundAmount;
            await _shiftRepository.UpdateShiftAsync(shift);

            // Handle Inventory Restocking based on Return Classification
            foreach (var detail in orderReturn.OrderReturnDetails)
            {
                var product = await _productRepository.GetByIdAsync(detail.ProductId);
                if (product == null) continue;

                int previousStock = product.StockQuantity;

                if (orderReturn.Classify == ReturnClassify.NoLongerNeeded)
                {
                    // 1. Restock Product.StockQuantity
                    await _inventoryTransactionRepository.AdjustProductStockAsync(detail.ProductId, detail.Quantity);

                    // 2. Restock oldest active batch
                    var oldestBatch = await _batchRepository.GetAllBatchesQueryable()
                        .Where(b => b.ProductId == detail.ProductId && !b.IsDeleted && b.ExpiryDate >= DateTime.Today)
                        .OrderBy(b => b.ExpiryDate)
                        .FirstOrDefaultAsync();

                    if (oldestBatch != null)
                    {
                        await _batchRepository.AdjustBatchRemainingQuantityAsync(oldestBatch.BatchId, detail.Quantity);
                    }

                    // 3. Log Inventory Transaction (Type OrderReturn = 6, ReferenceType OrderReturn = 5)
                    var invTx = new InventoryTransaction
                    {
                        TransactionType = InventoryTransactionType.OrderReturn,
                        Quantity = detail.Quantity,
                        PreviousStock = previousStock,
                        CurrentStock = previousStock + detail.Quantity,
                        ReferenceType = ReferenceType.OrderReturn,
                        ReferenceId = orderReturn.OrderReturnId,
                        Note = $"Khách trả hàng - Hóa đơn gốc: {orderReturn.OriginalOrder?.OrderCode}",
                        ProductId = detail.ProductId,
                        BatchId = oldestBatch?.BatchId,
                        EmployeeId = managerId
                    };
                    await _inventoryTransactionRepository.CreateInventoryTransactionAsync(invTx);
                }
                else if (orderReturn.Classify == ReturnClassify.ProductError)
                {
                    // For Product Error: Do not update product/batch quantities.
                    // Just log Damage type transaction for recording write-offs.
                    var invTx = new InventoryTransaction
                    {
                        TransactionType = InventoryTransactionType.Damage,
                        Quantity = detail.Quantity,
                        PreviousStock = previousStock,
                        CurrentStock = previousStock, // unchanged
                        ReferenceType = ReferenceType.OrderReturn,
                        ReferenceId = orderReturn.OrderReturnId,
                        Note = $"Hủy trực tiếp sản phẩm lỗi từ hóa đơn: {orderReturn.OriginalOrder?.OrderCode}",
                        ProductId = detail.ProductId,
                        EmployeeId = managerId
                    };
                    await _inventoryTransactionRepository.CreateInventoryTransactionAsync(invTx);
                }
            }

            orderReturn.Status = OrderReturnStatus.Approved;
            await _orderReturnRepository.UpdateAsync(orderReturn);

            return _mapper.Map<OrderReturnDto>(orderReturn);
        }

        public async Task<OrderReturnDto> RejectOrderReturnAsync(int id, RejectOrderReturnDto rejectDto)
        {
            var orderReturn = await _orderReturnRepository.GetByIdAsync(id);
            if (orderReturn == null)
            {
                throw new DomainException("Không tìm thấy yêu cầu hoàn tiền.", StatusCodes.Status404NotFound);
            }

            if (orderReturn.Status != OrderReturnStatus.Pending)
            {
                throw new DomainException("Yêu cầu hoàn trả này đã được xử lý rồi.", StatusCodes.Status400BadRequest);
            }

            orderReturn.Status = OrderReturnStatus.Rejected;
            orderReturn.Reason = $"{orderReturn.Reason} | Lý do từ chối: {rejectDto.Note}";
            await _orderReturnRepository.UpdateAsync(orderReturn);

            return _mapper.Map<OrderReturnDto>(orderReturn);
        }

        public async Task<object?> GetOrderDetailsForReturnAsync(string orderCode)
        {
            var order = await _orderRepository.GetAllOrdersQueryable()
                .Include(o => o.OrderDetails)
                    .ThenInclude(od => od.Product)
                .Include(o => o.Customer)
                .FirstOrDefaultAsync(o => o.OrderCode == orderCode);

            if (order == null) return null;

            return new
            {
                OrderId = order.OrderId,
                OrderCode = order.OrderCode,
                OrderDate = order.OrderDate,
                CustomerName = order.Customer?.FullName ?? "Khách vãng lai",
                CustomerId = order.CustomerId,
                FinalAmount = order.FinalAmount,
                Status = order.Status,
                Items = order.OrderDetails.Select(od => new
                {
                    ProductId = od.ProductId,
                    ProductName = od.Product?.ProductName ?? "",
                    ProductCode = od.Product?.ProductCode ?? "",
                    Barcode = od.Product?.Barcode ?? "",
                    Quantity = od.Quantity,
                    UnitPrice = od.UnitPrice,
                    TotalPrice = od.TotalPrice
                }).ToList()
            };
        }
    }
}
