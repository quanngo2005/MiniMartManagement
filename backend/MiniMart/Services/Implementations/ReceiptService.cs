using AutoMapper;
using AutoMapper.QueryableExtensions;
using Microsoft.AspNetCore.Http;
using Microsoft.EntityFrameworkCore;
using MiniMart.DTOs;
using MiniMart.Models;
using MiniMart.Models.Enums;
using MiniMart.Repositories.RepoInterface;
using MiniMart.Services.Interfaces;
using MiniMart.Shared.Exceptions;

namespace MiniMart.Services.Implementations
{
    public class ReceiptService : IReceiptService
    {
        private readonly IReceiptRepository _receiptRepository;
        private readonly IProductRepository _productRepository;
        private readonly IBatchRepository _batchRepository;
        private readonly IInventoryTransactionRepository _inventoryTransactionRepository;
        private readonly IMapper _mapper;

        public ReceiptService(
            IReceiptRepository receiptRepository,
            IProductRepository productRepository,
            IBatchRepository batchRepository,
            IInventoryTransactionRepository inventoryTransactionRepository,
            IMapper mapper)
        {
            _receiptRepository = receiptRepository;
            _productRepository = productRepository;
            _batchRepository = batchRepository;
            _inventoryTransactionRepository = inventoryTransactionRepository;
            _mapper = mapper;
        }

        public IQueryable<ReceiptDto> GetAllReceiptsQueryable()
        {
            return _receiptRepository
                .GetAllReceiptsQueryable()
                .ProjectTo<ReceiptDto>(_mapper.ConfigurationProvider);
        }

        public async Task<ReceiptDto?> GetReceiptByIdAsync(int id)
        {
            var receipt = await _receiptRepository.GetReceiptByIdAsync(id);
            return receipt == null ? null : _mapper.Map<ReceiptDto>(receipt);
        }

        public async Task<ReceiptDto> CreateReceiptAsync(CreateReceiptDto createDto, int employeeId)
        {
            if (!await _receiptRepository.SupplierExistsAsync(createDto.SupplierId))
                throw new DomainException("Supplier ID does not exist.", StatusCodes.Status422UnprocessableEntity);

            if (!await _receiptRepository.EmployeeExistsAsync(employeeId))
                throw new DomainException("Employee ID does not exist.", StatusCodes.Status422UnprocessableEntity);

            var importDate = GetVietnamNow();
            var receipt = _mapper.Map<Receipt>(createDto);
            receipt.ReceiptCode = GenerateReceiptCode(importDate);
            receipt.CreatedAt = importDate;
            receipt.ImportDate = importDate;
            receipt.EmployeeId = employeeId;
            receipt.ReceiptStatus = ReceiptStatus.Pending;

            if (createDto.BatchLines != null && createDto.BatchLines.Count > 0)
            {
                for (var i = 0; i < createDto.BatchLines.Count; i++)
                {
                    var batch = await BuildBatchFromLineAsync(createDto.BatchLines[i], receipt, importDate, i + 1);
                    receipt.Batches.Add(batch);
                }
            }

            ApplyServerCalculatedTotals(receipt, createDto.PaidAmount);

            var created = await _receiptRepository.CreateReceiptAsync(receipt);
            var createdWithDetails = await _receiptRepository.GetReceiptByIdAsync(created.ReceiptId);
            return _mapper.Map<ReceiptDto>(createdWithDetails ?? created);
        }

        public async Task<ReceiptDto> UpdateReceiptAsync(int id, UpdateReceiptDto updateDto)
        {
            var existing = await _receiptRepository.GetReceiptByIdAsync(id);
            if (existing == null)
                throw new DomainException($"Receipt with ID {id} not found.", StatusCodes.Status404NotFound);

            if (existing.ReceiptStatus != ReceiptStatus.Pending)
                throw new DomainException("Only pending receipts can be updated.", StatusCodes.Status422UnprocessableEntity);

            if (!await _receiptRepository.SupplierExistsAsync(updateDto.SupplierId))
                throw new DomainException("Supplier ID does not exist.", StatusCodes.Status422UnprocessableEntity);

            var receiptCode = existing.ReceiptCode;
            var importDate = existing.ImportDate;
            var employeeId = existing.EmployeeId;
            var status = existing.ReceiptStatus;
            _mapper.Map(updateDto, existing);
            existing.ReceiptId = id;
            existing.ReceiptCode = receiptCode;
            existing.ImportDate = importDate;
            existing.EmployeeId = employeeId;
            existing.ReceiptStatus = status;

            await _receiptRepository.DeleteBatchesByReceiptIdAsync(id);
            existing.Batches.Clear();

            if (updateDto.BatchLines != null && updateDto.BatchLines.Count > 0)
            {
                for (var i = 0; i < updateDto.BatchLines.Count; i++)
                {
                    var batch = await BuildBatchFromLineAsync(updateDto.BatchLines[i], existing, importDate, i + 1);
                    existing.Batches.Add(batch);
                }
            }

            ApplyServerCalculatedTotals(existing, updateDto.PaidAmount);

            var updated = await _receiptRepository.UpdateReceiptAsync(existing);
            if (updated == null)
                throw new DomainException($"Receipt with ID {id} not found.", StatusCodes.Status404NotFound);

            var updatedWithDetails = await _receiptRepository.GetReceiptByIdAsync(id);
            return _mapper.Map<ReceiptDto>(updatedWithDetails ?? updated);
        }

        public async Task DeleteReceiptAsync(int id)
        {
            var existing = await _receiptRepository.GetReceiptByIdAsync(id);
            if (existing == null)
                throw new DomainException($"Receipt with ID {id} not found.", StatusCodes.Status404NotFound);

            if (existing.ReceiptStatus != ReceiptStatus.Pending)
                throw new DomainException("Only pending receipts can be cancelled.", StatusCodes.Status422UnprocessableEntity);

            await _receiptRepository.CancelReceiptAsync(id);
        }

        public async Task<ReceiptDto> CompleteReceiptAsync(int id)
        {
            var existing = await _receiptRepository.GetReceiptByIdAsync(id);
            if (existing == null)
                throw new DomainException($"Receipt with ID {id} not found.", StatusCodes.Status404NotFound);

            if (existing.ReceiptStatus != ReceiptStatus.Pending)
                throw new DomainException("Only pending receipts can be completed.", StatusCodes.Status422UnprocessableEntity);

            try
            {
                await _receiptRepository.ExecuteInTransactionAsync(async () =>
                {
                    var stockByProductId = existing.Batches
                        .GroupBy(batch => batch.ProductId)
                        .ToDictionary(
                            group => group.Key,
                            group => group.First().Product.StockQuantity);

                    foreach (var batch in existing.Batches)
                    {
                        var previousStock = stockByProductId[batch.ProductId];
                        var currentStock = previousStock + batch.QuantityImported;

                        // The Batches trigger recalculates Product.StockQuantity from active batches.
                        // Updating the product here would double-count this import and leave its
                        // RowVersion stale for a later batch of the same product.
                        await _batchRepository.AdjustBatchRemainingQuantityAsync(batch.BatchId, batch.QuantityImported);

                        var transaction = new InventoryTransaction
                        {
                            TransactionType = InventoryTransactionType.Import,
                            Quantity = batch.QuantityImported,
                            PreviousStock = previousStock,
                            CurrentStock = currentStock,
                            ReferenceType = Models.Enums.ReferenceType.Receipt,
                            ReferenceId = existing.ReceiptId,
                            Note = $"Import from receipt {existing.ReceiptCode}",
                            ProductId = batch.ProductId,
                            BatchId = batch.BatchId,
                            EmployeeId = existing.EmployeeId
                        };

                        await _inventoryTransactionRepository.CreateInventoryTransactionAsync(transaction);
                        stockByProductId[batch.ProductId] = currentStock;
                    }

                    await _receiptRepository.MarkReceiptAsCompletedAsync(id);
                });
            }
            catch (DbUpdateConcurrencyException)
            {
                throw new DomainException(
                    "Inventory changed while completing this receipt. Reload and retry.",
                    StatusCodes.Status409Conflict);
            }

            var completed = await _receiptRepository.GetReceiptByIdAsync(id);
            return _mapper.Map<ReceiptDto>(completed!);
        }

        private async Task<Batch> BuildBatchFromLineAsync(
            ReceiptBatchLineDto line,
            Receipt receipt,
            DateTime receiptTimestamp,
            int lineNumber)
        {
            int productId;

            if (line.ProductId.HasValue)
            {
                productId = line.ProductId.Value;
                if (!await _receiptRepository.ProductExistsAsync(productId))
                    throw new DomainException($"Product with ID {productId} does not exist.", StatusCodes.Status422UnprocessableEntity);
            }
            else if (!string.IsNullOrWhiteSpace(line.Barcode))
            {
                var product = await _receiptRepository.GetActiveProductByBarcodeAsync(line.Barcode);
                if (product == null)
                    throw new DomainException($"No active product found with barcode '{line.Barcode}'.", StatusCodes.Status422UnprocessableEntity);
                productId = product.ProductId;
            }
            else
            {
                throw new DomainException("Each batch line must specify either ProductId or Barcode.", StatusCodes.Status400BadRequest);
            }

            if (line.Quantity <= 0)
                throw new DomainException("Quantity must be greater than zero.", StatusCodes.Status422UnprocessableEntity);

            if (line.ExpiryDate <= line.ManufactureDate)
                throw new DomainException("Expiry date must be after manufacture date.", StatusCodes.Status422UnprocessableEntity);

            return new Batch
            {
                BatchCode = string.IsNullOrWhiteSpace(line.BatchCode)
                    ? GenerateBatchCode(productId, receiptTimestamp, lineNumber)
                    : line.BatchCode,
                ProductId = productId,
                ManufactureDate = line.ManufactureDate,
                ExpiryDate = line.ExpiryDate,
                ImportPrice = line.ImportPrice,
                QuantityImported = line.Quantity,
                QuantityRemaining = 0,
                Quantity = line.Quantity,
                TotalPrice = line.ImportPrice * line.Quantity,
                Status = false,
                IsDeleted = false,
                ReceiptId = receipt.ReceiptId
            };
        }

        private static void ApplyServerCalculatedTotals(Receipt receipt, decimal paidAmount)
        {
            if (paidAmount < 0)
                throw new DomainException("Paid amount cannot be negative.", StatusCodes.Status422UnprocessableEntity);

            var totalAmount = receipt.Batches.Sum(batch => batch.ImportPrice * batch.QuantityImported);
            if (paidAmount > totalAmount)
                throw new DomainException("Paid amount cannot exceed total amount.", StatusCodes.Status422UnprocessableEntity);

            receipt.TotalAmount = totalAmount;
            receipt.PaidAmount = paidAmount;
            receipt.DebtAmount = totalAmount - paidAmount;
        }

        private static DateTime GetVietnamNow()
        {
            return DateTime.UtcNow.AddHours(7);
        }

        private static string GenerateReceiptCode(DateTime timestamp)
        {
            return $"PN-{timestamp:yyyyMMddHHmmssfff}";
        }

        private static string GenerateBatchCode(int productId, DateTime timestamp, int lineNumber)
        {
            return $"LOT-P{productId}-{timestamp:yyyyMMddHHmmssfff}-{lineNumber:D2}";
        }
    }
}
