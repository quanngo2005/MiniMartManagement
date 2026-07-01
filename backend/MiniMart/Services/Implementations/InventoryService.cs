using AutoMapper;
using AutoMapper.QueryableExtensions;
using MiniMart.DTOs;
using MiniMart.Models;
using MiniMart.Models.Enums;
using MiniMart.Repositories.RepoInterface;
using MiniMart.Services.Interfaces;
using MiniMart.Shared.Exceptions;

namespace MiniMart.Services
{
    public class InventoryService : IInventoryService
    {
        private readonly IInventoryTransactionRepository _inventoryTransactionRepository;
        private readonly IBatchRepository _batchRepository;
        private readonly IMapper _mapper;

        public InventoryService(
            IInventoryTransactionRepository inventoryTransactionRepository,
            IBatchRepository batchRepository,
            IMapper mapper)
        {
            _inventoryTransactionRepository = inventoryTransactionRepository;
            _batchRepository = batchRepository;
            _mapper = mapper;
        }

        public IQueryable<InventoryTransactionDto> GetAllInventoryTransactionsQueryable()
        {
            return _inventoryTransactionRepository
                .GetAllInventoryTransactionsQueryable()
                .ProjectTo<InventoryTransactionDto>(_mapper.ConfigurationProvider);
        }

        public async Task<InventoryTransactionDto?> GetInventoryTransactionByIdAsync(int id)
        {
            var inventoryTransaction = await _inventoryTransactionRepository.GetInventoryTransactionByIdAsync(id);
            return inventoryTransaction == null ? null : _mapper.Map<InventoryTransactionDto>(inventoryTransaction);
        }

        public async Task<InventoryTransactionDto> CreateInventoryTransactionAsync(CreateInventoryTransactionDto createDto)
        {
            await ValidateReferencesAsync(createDto.ProductId, createDto.BatchId, createDto.EmployeeId);

            var product = await _inventoryTransactionRepository.GetProductByIdAsync(createDto.ProductId)
                ?? throw new DomainException("Product ID does not exist.", StatusCodes.Status422UnprocessableEntity);

            var stockDelta = GetSignedQuantity(createDto.TransactionType, createDto.Quantity);
            var previousStock = product.StockQuantity;
            var currentStock = previousStock + stockDelta;
            EnsureStockIsValid(currentStock);
            await EnsureBatchStockIsValidAsync(createDto.BatchId, stockDelta);

            await _inventoryTransactionRepository.AdjustProductStockAsync(createDto.ProductId, stockDelta);
            if (createDto.BatchId.HasValue)
            {
                await _batchRepository.AdjustBatchRemainingQuantityAsync(createDto.BatchId.Value, stockDelta);
            }

            var inventoryTransaction = _mapper.Map<InventoryTransaction>(createDto);
            inventoryTransaction.PreviousStock = previousStock;
            inventoryTransaction.CurrentStock = currentStock;

            var created = await _inventoryTransactionRepository.CreateInventoryTransactionAsync(inventoryTransaction);
            var createdWithDetails = await _inventoryTransactionRepository.GetInventoryTransactionByIdAsync(created.InventoryTransactionId);
            return _mapper.Map<InventoryTransactionDto>(createdWithDetails ?? created);
        }

        private async Task ValidateReferencesAsync(int productId, int? batchId, int employeeId)
        {
            if (!await _inventoryTransactionRepository.ProductExistsAsync(productId))
            {
                throw new DomainException("Product ID does not exist.", StatusCodes.Status422UnprocessableEntity);
            }

            if (!await _inventoryTransactionRepository.EmployeeExistsAsync(employeeId))
            {
                throw new DomainException("Employee ID does not exist.", StatusCodes.Status422UnprocessableEntity);
            }

            if (batchId.HasValue && !await _batchRepository.BatchExistsAsync(batchId.Value))
            {
                throw new DomainException("Batch ID does not exist.", StatusCodes.Status422UnprocessableEntity);
            }
        }

        private async Task EnsureBatchStockIsValidAsync(int? batchId, int quantityDelta)
        {
            if (!batchId.HasValue)
            {
                return;
            }

            var batch = await _batchRepository.GetBatchByIdAsync(batchId.Value)
                ?? throw new DomainException("Batch ID does not exist.", StatusCodes.Status422UnprocessableEntity);

            if (batch.QuantityRemaining + quantityDelta < 0)
            {
                throw new DomainException("Batch remaining quantity cannot be negative.", StatusCodes.Status422UnprocessableEntity);
            }
        }

        private static int GetSignedQuantity(InventoryTransactionType transactionType, int quantity)
        {
            if (transactionType == InventoryTransactionType.Adjustment)
            {
                if (quantity == 0)
                {
                    throw new DomainException("Adjustment quantity must not be zero.");
                }

                return quantity;
            }

            if (quantity <= 0)
            {
                throw new DomainException("Quantity must be greater than zero.");
            }

            return transactionType switch
            {
                InventoryTransactionType.Import => quantity,
                InventoryTransactionType.OrderReturn => quantity,
                InventoryTransactionType.Sale => -quantity,
                InventoryTransactionType.ReturnToSupplier => -quantity,
                InventoryTransactionType.Damage => -quantity,
                _ => throw new DomainException("Unsupported inventory transaction type.")
            };
        }

        private static void EnsureStockIsValid(int stock)
        {
            if (stock < 0)
            {
                throw new DomainException("Inventory stock cannot be negative.", StatusCodes.Status422UnprocessableEntity);
            }
        }
    }
}
