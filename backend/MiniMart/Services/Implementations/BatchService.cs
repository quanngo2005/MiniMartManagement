using AutoMapper;
using AutoMapper.QueryableExtensions;
using Microsoft.EntityFrameworkCore;
using MiniMart.DTOs;
using MiniMart.Models;
using MiniMart.Models.Enums;
using MiniMart.Repositories.RepoInterface;
using MiniMart.Services.Interfaces;
using MiniMart.Shared.Exceptions;
using MiniMart.Shared.Utils;

namespace MiniMart.Services
{
    public class BatchService : IBatchService
    {
        private readonly IBatchRepository _batchRepository;
        private readonly IInventoryTransactionRepository _inventoryTransactionRepository;
        private readonly IProductStockAdjuster _productStockAdjuster;
        private readonly IMapper _mapper;

        public BatchService(
            IBatchRepository batchRepository,
            IInventoryTransactionRepository inventoryTransactionRepository,
            IProductStockAdjuster productStockAdjuster,
            IMapper mapper)
        {
            _batchRepository = batchRepository;
            _inventoryTransactionRepository = inventoryTransactionRepository;
            _productStockAdjuster = productStockAdjuster;
            _mapper = mapper;
        }

        public IQueryable<BatchDto> GetAllBatchesQueryable()
        {
            return _batchRepository
                .GetAllBatchesQueryable()
                .ProjectTo<BatchDto>(_mapper.ConfigurationProvider);
        }

        public async Task<BatchDto?> GetBatchByIdAsync(int id)
        {
            var batch = await _batchRepository.GetBatchByIdAsync(id);
            return batch == null ? null : _mapper.Map<BatchDto>(batch);
        }

        public async Task<InventoryTransactionDto> DisposeExpiredBatchAsync(
            int batchId,
            int employeeId)
        {
            if (!await _inventoryTransactionRepository.EmployeeExistsAsync(employeeId))
            {
                throw new DomainException(
                    "Employee ID does not exist.",
                    StatusCodes.Status422UnprocessableEntity);
            }

            for (var attempt = 0; attempt < 2; attempt++)
            {
                try
                {
                    return await DisposeExpiredBatchOnceAsync(batchId, employeeId);
                }
                catch (DbUpdateConcurrencyException) when (attempt == 0)
                {
                    // Reload the tracked batch and product once before reporting a conflict.
                }
            }

            throw new DomainException(
                "Batch data was updated by another operation. Please refresh and try again.",
                StatusCodes.Status409Conflict);
        }

        private async Task<InventoryTransactionDto> DisposeExpiredBatchOnceAsync(
            int batchId,
            int employeeId)
        {
            InventoryTransaction? disposedTransaction = null;
            await _batchRepository.ExecuteInTransactionAsync(async () =>
            {
                var batch = await _batchRepository.GetBatchByIdAsync(batchId)
                    ?? throw new DomainException(
                        "Batch ID does not exist.",
                        StatusCodes.Status404NotFound);

                if (batch.ExpiryDate.Date >= HanoiTime.Now.Date)
                {
                    throw new DomainException(
                        "Only expired batches can be disposed.",
                        StatusCodes.Status422UnprocessableEntity);
                }

                if (batch.QuantityRemaining <= 0)
                {
                    throw new DomainException(
                        "Batch has no remaining quantity to dispose.",
                        StatusCodes.Status422UnprocessableEntity);
                }

                var product = batch.Product
                    ?? throw new DomainException(
                        "Batch product does not exist.",
                        StatusCodes.Status422UnprocessableEntity);
                var disposalQuantity = batch.QuantityRemaining;
                var previousStock = product.StockQuantity;
                if (previousStock < disposalQuantity)
                {
                    throw new DomainException(
                        "Product stock is insufficient for this batch disposal.",
                        StatusCodes.Status409Conflict);
                }

                await _batchRepository.AdjustBatchRemainingQuantityAsync(
                    batch.BatchId,
                    -disposalQuantity);

                await _productStockAdjuster.AdjustAsync(product.ProductId, -disposalQuantity);

                disposedTransaction = await _inventoryTransactionRepository
                    .CreateInventoryTransactionAsync(new InventoryTransaction
                    {
                        TransactionType = InventoryTransactionType.Damage,
                        Quantity = disposalQuantity,
                        PreviousStock = previousStock,
                        CurrentStock = previousStock - disposalQuantity,
                        Note = $"Disposed expired batch {batch.BatchCode}.",
                        ProductId = product.ProductId,
                        BatchId = batch.BatchId,
                        EmployeeId = employeeId,
                    });
            });

            return _mapper.Map<InventoryTransactionDto>(disposedTransaction!);
        }
    }
}