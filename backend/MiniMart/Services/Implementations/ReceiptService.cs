using AutoMapper;
using AutoMapper.QueryableExtensions;
using Microsoft.AspNetCore.Http;
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

        public async Task<ReceiptDto> CreateReceiptAsync(CreateReceiptDto createDto)
        {
            if (!await _receiptRepository.SupplierExistsAsync(createDto.SupplierId))
                throw new DomainException("Supplier ID does not exist.", StatusCodes.Status422UnprocessableEntity);

            if (!await _receiptRepository.EmployeeExistsAsync(createDto.EmployeeId))
                throw new DomainException("Employee ID does not exist.", StatusCodes.Status422UnprocessableEntity);

            var receipt = _mapper.Map<Receipt>(createDto);
            receipt.ReceiptStatus = ReceiptStatus.Pending;

            if (createDto.BatchLines != null && createDto.BatchLines.Count > 0)
            {
                foreach (var line in createDto.BatchLines)
                {
                    var batch = await BuildBatchFromLineAsync(line, receipt);
                    receipt.Batches.Add(batch);
                }
            }

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

            if (!await _receiptRepository.EmployeeExistsAsync(updateDto.EmployeeId))
                throw new DomainException("Employee ID does not exist.", StatusCodes.Status422UnprocessableEntity);

            _mapper.Map(updateDto, existing);
            existing.ReceiptId = id;

            await _receiptRepository.DeleteBatchesByReceiptIdAsync(id);

            if (updateDto.BatchLines != null && updateDto.BatchLines.Count > 0)
            {
                foreach (var line in updateDto.BatchLines)
                {
                    var batch = await BuildBatchFromLineAsync(line, existing);
                    existing.Batches.Add(batch);
                }
            }

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

            foreach (var batch in existing.Batches)
            {
                var product = await _inventoryTransactionRepository.GetProductByIdAsync(batch.ProductId)
                    ?? throw new DomainException($"Product with ID {batch.ProductId} not found.", StatusCodes.Status422UnprocessableEntity);

                var previousStock = product.StockQuantity;
                var currentStock = previousStock + batch.QuantityImported;

                await _inventoryTransactionRepository.AdjustProductStockAsync(batch.ProductId, batch.QuantityImported);
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
            }

            await _receiptRepository.MarkReceiptAsCompletedAsync(id);

            var completed = await _receiptRepository.GetReceiptByIdAsync(id);
            return _mapper.Map<ReceiptDto>(completed!);
        }

        private async Task<Batch> BuildBatchFromLineAsync(ReceiptBatchLineDto line, Receipt receipt)
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

            if (string.IsNullOrWhiteSpace(line.BatchCode))
                throw new DomainException("BatchCode is required.", StatusCodes.Status400BadRequest);

            if (line.Quantity <= 0)
                throw new DomainException("Quantity must be greater than zero.", StatusCodes.Status422UnprocessableEntity);

            if (line.ExpiryDate <= line.ManufactureDate)
                throw new DomainException("Expiry date must be after manufacture date.", StatusCodes.Status422UnprocessableEntity);

            return new Batch
            {
                BatchCode = line.BatchCode,
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
    }
}