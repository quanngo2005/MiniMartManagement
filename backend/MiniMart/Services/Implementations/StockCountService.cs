using AutoMapper;
using AutoMapper.QueryableExtensions;
using Microsoft.EntityFrameworkCore;
using MiniMart.DTOs;
using MiniMart.Models;
using MiniMart.Models.Enums;
using MiniMart.Repositories.Interfaces;
using MiniMart.Services.Interfaces;
using MiniMart.Shared.Exceptions;
using MiniMart.Shared.Utils;
using Microsoft.Extensions.Logging;

namespace MiniMart.Services.Implementations
{
    public class StockCountService : IStockCountService
    {
        private readonly IStockCountRepository _stockCountRepository;
        private readonly INotificationService _notificationService;
        private readonly ILogger<StockCountService> _logger;
        private readonly IMapper _mapper;

        public StockCountService(
            IStockCountRepository stockCountRepository,
            INotificationService notificationService,
            ILogger<StockCountService> logger,
            IMapper mapper)
        {
            _stockCountRepository = stockCountRepository;
            _notificationService = notificationService;
            _logger = logger;
            _mapper = mapper;
        }

        public IQueryable<StockCountListDto> GetAllQueryable()
        {
            return _stockCountRepository.GetAllQueryable()
                .ProjectTo<StockCountListDto>(_mapper.ConfigurationProvider);
        }

        public async Task<StockCountDetailDto?> GetDetailByIdAsync(int id)
        {
            var stockCount = await _stockCountRepository.GetDetailByIdAsync(id);
            return stockCount == null ? null : _mapper.Map<StockCountDetailDto>(stockCount);
        }

        public async Task<StockCountDetailDto> CreateAsync(CreateStockCountDto createDto, int employeeId)
        {
            if (!await _stockCountRepository.EmployeeExistsAsync(employeeId))
            {
                throw new DomainException("Current employee does not exist.", StatusCodes.Status422UnprocessableEntity);
            }

            if (await _stockCountRepository.HasCountingStockCountAsync())
            {
                throw new DomainException(
                    "A stock count is already in progress. Complete or submit it before creating another.",
                    StatusCodes.Status409Conflict);
            }

            var categoryIds = await ValidateCreateScopeAsync(createDto.Scope, createDto.CategoryIds);
            if (createDto.Scope == StockCountScope.Category)
            {
                foreach (var categoryId in categoryIds)
                {
                    var categoryProducts = await _stockCountRepository.GetActiveProductsForScopeAsync(
                        StockCountScope.Category,
                        new[] { categoryId });

                    if (categoryProducts.Count == 0)
                    {
                        throw new DomainException(
                            $"Category with ID {categoryId} has no active products.",
                            StatusCodes.Status400BadRequest);
                    }
                }
            }

            var products = await _stockCountRepository.GetActiveProductsForScopeAsync(createDto.Scope, categoryIds);
            if (createDto.Scope != StockCountScope.Selected && products.Count == 0)
            {
                throw new DomainException("The selected scope has no active products.", StatusCodes.Status400BadRequest);
            }

            var createdAt = HanoiTime.Now;
            for (var attempt = 0; attempt < 2; attempt++)
            {
                var stockCount = _mapper.Map<StockCount>(createDto);
                stockCount.StockCountCode = await _stockCountRepository.GenerateStockCountCodeAsync(createdAt);
                stockCount.Status = StockCountStatus.Draft;
                stockCount.CreatedAt = createdAt;
                stockCount.CreatedByEmployeeId = employeeId;
                stockCount.Categories = categoryIds
                    .Select(categoryId => new StockCountCategory { CategoryId = categoryId })
                    .ToList();
                stockCount.Lines = products
                    .Select(product => new StockCountLine
                    {
                        ProductId = product.ProductId,
                        SnapshotQuantity = product.StockQuantity
                    })
                    .ToList();

                try
                {
                    await _stockCountRepository.CreateAsync(stockCount);
                    return (await GetDetailByIdAsync(stockCount.StockCountId))!;
                }
                catch (DbUpdateException) when (attempt == 0)
                {
                    // The unique code index is the collision guard; generate and retry once.
                }
                catch (DbUpdateException)
                {
                    throw new DomainException(
                        "Could not allocate a unique stock-count code. Reload and retry.",
                        StatusCodes.Status409Conflict);
                }
            }

            throw new InvalidOperationException("Stock-count creation retry exhausted unexpectedly.");
        }

        public async Task<StockCountDetailDto> StartAsync(int id, byte[] rowVersion)
        {
            if (rowVersion.Length == 0)
            {
                throw new DomainException("A stock-count row version is required.", StatusCodes.Status400BadRequest);
            }

            var stockCount = await _stockCountRepository.GetTrackedByIdAsync(id)
                ?? throw new DomainException($"Stock count with ID {id} not found.", StatusCodes.Status404NotFound);

            ValidateTransition(stockCount, StockCountStatus.Counting);
            _stockCountRepository.ApplyOriginalRowVersion(stockCount, rowVersion);
            stockCount.Status = StockCountStatus.Counting;
            stockCount.StartedAt = HanoiTime.Now;

            try
            {
                await _stockCountRepository.SaveChangesAsync();
            }
            catch (DbUpdateConcurrencyException)
            {
                throw new DomainException("The stock count was changed by another user. Reload and retry.", StatusCodes.Status409Conflict);
            }

            return (await GetDetailByIdAsync(id))!;
        }

        public async Task<StockCountDetailDto> CancelDraftAsync(int id, byte[] rowVersion)
        {
            if (rowVersion.Length == 0)
            {
                throw new DomainException("A stock-count row version is required.", StatusCodes.Status400BadRequest);
            }

            var stockCount = await _stockCountRepository.GetTrackedByIdAsync(id)
                ?? throw new DomainException($"Stock count with ID {id} not found.", StatusCodes.Status404NotFound);

            EnsureStatus(stockCount, StockCountStatus.Draft);
            _stockCountRepository.ApplyOriginalRowVersion(stockCount, rowVersion);
            stockCount.Status = StockCountStatus.Cancelled;

            try
            {
                await _stockCountRepository.SaveChangesAsync();
            }
            catch (DbUpdateConcurrencyException)
            {
                throw new DomainException("The stock count was changed by another user. Reload and retry.", StatusCodes.Status409Conflict);
            }

            return (await GetDetailByIdAsync(id))!;
        }

        public async Task<StockCountDetailDto> AddLinesAsync(int id, AddStockCountLinesDto addDto)
        {
            if (addDto.StockCountRowVersion.Length == 0)
            {
                throw new DomainException("A stock-count row version is required.", StatusCodes.Status400BadRequest);
            }

            var productIds = addDto.ProductIds.Distinct().ToList();
            if (productIds.Count == 0)
            {
                throw new DomainException("At least one product is required.", StatusCodes.Status400BadRequest);
            }

            var stockCount = await _stockCountRepository.GetTrackedByIdAsync(id)
                ?? throw new DomainException($"Stock count with ID {id} not found.", StatusCodes.Status404NotFound);

            EnsureStatus(stockCount, StockCountStatus.Counting);
            if (stockCount.Scope != StockCountScope.Selected)
            {
                throw new DomainException(
                    "Products can be added only to selected-product stock counts.",
                    StatusCodes.Status409Conflict);
            }
            var existingProductIds = stockCount.Lines
                .Select(line => line.ProductId)
                .ToHashSet();
            var missingProductIds = productIds
                .Where(productId => !existingProductIds.Contains(productId))
                .ToList();

            if (missingProductIds.Count == 0)
            {
                return (await GetDetailByIdAsync(id))!;
            }

            var products = await _stockCountRepository.GetActiveProductsByIdsAsync(missingProductIds);
            if (products.Count != missingProductIds.Count)
            {
                throw new DomainException("One or more products do not exist or are inactive.", StatusCodes.Status422UnprocessableEntity);
            }

            _stockCountRepository.ApplyOriginalRowVersion(stockCount, addDto.StockCountRowVersion);
            _stockCountRepository.TouchForLineEdit(stockCount);
            foreach (var product in products)
            {
                stockCount.Lines.Add(new StockCountLine
                {
                    ProductId = product.ProductId,
                    SnapshotQuantity = product.StockQuantity
                });
            }

            try
            {
                await _stockCountRepository.SaveChangesAsync();
            }
            catch (DbUpdateConcurrencyException)
            {
                throw new DomainException("The stock count was changed by another user. Reload and retry.", StatusCodes.Status409Conflict);
            }
            catch (DbUpdateException)
            {
                throw new DomainException("The stock count was changed by another user. Reload and retry.", StatusCodes.Status409Conflict);
            }

            return (await GetDetailByIdAsync(id))!;
        }

        public async Task<StockCountDetailDto> UpdateLinesAsync(int id, UpdateStockCountLinesDto updateDto)
        {
            if (updateDto.StockCountRowVersion.Length == 0)
            {
                throw new DomainException("A stock-count row version is required.", StatusCodes.Status400BadRequest);
            }

            if (updateDto.Lines.Count == 0)
            {
                throw new DomainException("At least one stock-count line is required.", StatusCodes.Status400BadRequest);
            }

            var submittedLineIds = updateDto.Lines.Select(line => line.StockCountLineId).ToList();
            if (submittedLineIds.Distinct().Count() != submittedLineIds.Count)
            {
                throw new DomainException("Each stock-count line can be submitted only once per batch.", StatusCodes.Status400BadRequest);
            }

            if (updateDto.Lines.Any(line => line.RowVersion.Length == 0))
            {
                throw new DomainException("A row version is required for every stock-count line.", StatusCodes.Status400BadRequest);
            }

            var stockCount = await _stockCountRepository.GetTrackedByIdAsync(id)
                ?? throw new DomainException($"Stock count with ID {id} not found.", StatusCodes.Status404NotFound);

            EnsureStatus(stockCount, StockCountStatus.Counting);
            var linesById = stockCount.Lines.ToDictionary(line => line.StockCountLineId);
            var invalidLineIds = submittedLineIds.Where(lineId => !linesById.ContainsKey(lineId)).ToList();
            if (invalidLineIds.Count > 0)
            {
                throw new DomainException(
                    $"The following lines do not belong to stock count {id}: {string.Join(", ", invalidLineIds)}.",
                    StatusCodes.Status400BadRequest);
            }

            _stockCountRepository.ApplyOriginalRowVersion(stockCount, updateDto.StockCountRowVersion);
            _stockCountRepository.TouchForLineEdit(stockCount);

            foreach (var updateLine in updateDto.Lines)
            {
                var line = linesById[updateLine.StockCountLineId];
                _mapper.Map(updateLine, line);
                _stockCountRepository.ApplyOriginalRowVersion(line, updateLine.RowVersion);
            }

            try
            {
                await _stockCountRepository.SaveChangesAsync();
            }
            catch (DbUpdateConcurrencyException)
            {
                throw new StockCountLineConcurrencyException(submittedLineIds);
            }

            return (await GetDetailByIdAsync(id))!;
        }

        public async Task<StockCountDetailDto> SubmitAsync(int id, byte[] rowVersion)
        {
            if (rowVersion.Length == 0)
            {
                throw new DomainException("A stock-count row version is required.", StatusCodes.Status400BadRequest);
            }

            var stockCount = await _stockCountRepository.GetTrackedByIdAsync(id)
                ?? throw new DomainException($"Stock count with ID {id} not found.", StatusCodes.Status404NotFound);

            ValidateTransition(stockCount, StockCountStatus.PendingApproval);
            if (stockCount.Lines.Count == 0)
            {
                throw new DomainException("At least one product must be added before submission.", StatusCodes.Status400BadRequest);
            }
            var uncountedLineIds = stockCount.Lines
                .Where(line => line.ActualQuantity is null)
                .Select(line => line.StockCountLineId)
                .ToList();
            if (uncountedLineIds.Count > 0)
            {
                throw new DomainException(
                    $"All lines must be counted before submission. Uncounted line IDs: {string.Join(", ", uncountedLineIds)}.",
                    StatusCodes.Status400BadRequest);
            }

            _stockCountRepository.ApplyOriginalRowVersion(stockCount, rowVersion);
            stockCount.Status = StockCountStatus.PendingApproval;
            stockCount.SubmittedAt = HanoiTime.Now;

            try
            {
                await _stockCountRepository.SaveChangesAsync();
            }
            catch (DbUpdateConcurrencyException)
            {
                throw new DomainException("The stock count was changed by another user. Reload and retry.", StatusCodes.Status409Conflict);
            }

            try
            {
                await _notificationService.SendToRoleAsync(
                    "Manager",
                    "Phiếu kiểm kê mới cần duyệt",
                    $"Phiếu kiểm kê {stockCount.StockCountCode} đã được gửi để duyệt.",
                    new Dictionary<string, string>
                    {
                        { "type", "stock_count_request" },
                        { "stockCountId", stockCount.StockCountId.ToString() }
                    });
            }
            catch (Exception ex)
            {
                _logger.LogWarning(ex, "Failed to send stock_count_request notification for StockCountId {StockCountId}", stockCount.StockCountId);
            }

            return (await GetDetailByIdAsync(id))!;
        }

        public async Task<StockCountDetailDto> ApproveAsync(int id, byte[] rowVersion, int reviewerEmployeeId)
        {
            if (rowVersion.Length == 0)
            {
                throw new DomainException("A stock-count row version is required.", StatusCodes.Status400BadRequest);
            }

            if (!await _stockCountRepository.EmployeeExistsAsync(reviewerEmployeeId))
            {
                throw new DomainException("Current employee does not exist.", StatusCodes.Status422UnprocessableEntity);
            }

            int createdByEmployeeId = 0;
            string stockCountCode = string.Empty;
            int stockCountId = 0;

            await _stockCountRepository.ExecuteInTransactionAsync(async () =>
            {
                var stockCount = await _stockCountRepository.GetTrackedByIdAsync(id)
                    ?? throw new DomainException($"Stock count with ID {id} not found.", StatusCodes.Status404NotFound);

                createdByEmployeeId = stockCount.CreatedByEmployeeId;
                stockCountCode = stockCount.StockCountCode;
                stockCountId = stockCount.StockCountId;

                ValidateTransition(stockCount, StockCountStatus.Closed);
                _stockCountRepository.ApplyOriginalRowVersion(stockCount, rowVersion);

                var driftedLines = stockCount.Lines
                    .Where(line => line.Product.StockQuantity != line.SnapshotQuantity)
                    .Select(line => new StockCountStockDriftDto
                    {
                        StockCountLineId = line.StockCountLineId,
                        ProductId = line.ProductId,
                        SnapshotQuantity = line.SnapshotQuantity,
                        CurrentQuantity = line.Product.StockQuantity
                    })
                    .ToList();
                if (driftedLines.Count > 0)
                {
                    throw new StockCountStockDriftException(driftedLines);
                }

                var varianceLines = stockCount.Lines
                    .Where(line => line.ActualQuantity.HasValue && line.ActualQuantity.Value != line.SnapshotQuantity)
                    .ToList();
                var productIds = varianceLines.Select(line => line.ProductId).Distinct().ToList();
                var batches = (await _stockCountRepository.GetTrackedBatchesForProductsAsync(productIds)).ToList();
                var adjustmentBatches = new List<Batch>();
                var inventoryTransactions = new List<InventoryTransaction>();
                var approvedAt = HanoiTime.Now;

                foreach (var line in varianceLines)
                {
                    var product = line.Product;
                    var variance = line.ActualQuantity!.Value - line.SnapshotQuantity;
                    var productBatches = batches.Where(batch => batch.ProductId == line.ProductId).ToList();
                    var runningStock = product.StockQuantity;

                    if (variance < 0)
                    {
                        var quantityToDeduct = -variance;
                        // Reconciliation deliberately includes expired-but-undisposed batches:
                        // cached ProductStock counts them as on-hand, so shortage allocation must too.
                        // Disposal of expired stock is a separate explicit workflow (POST /api/batches/{id}/dispose-expired).
                        // Do NOT reuse GetSellableBatchesForProductsAsync here — that pool intentionally
                        // excludes expired stock for order fulfillment and must stay that way.
                        var eligibleBatches = productBatches
                            .Where(batch => batch.Status && batch.QuantityRemaining > 0)
                            .OrderBy(batch => batch.ExpiryDate)
                            .ThenBy(batch => batch.Receipt?.ImportDate ?? DateTime.MaxValue)
                            .ThenBy(batch => batch.BatchId)
                            .ToList();

                        if (eligibleBatches.Sum(batch => batch.QuantityRemaining) < quantityToDeduct)
                        {
                            throw new DomainException(
                                $"Eligible batch stock cannot cover the negative variance for stock-count line {line.StockCountLineId}.",
                                StatusCodes.Status409Conflict);
                        }

                        foreach (var batch in eligibleBatches)
                        {
                            var deducted = Math.Min(batch.QuantityRemaining, quantityToDeduct);
                            batch.QuantityRemaining -= deducted;
                            batch.Status = batch.QuantityRemaining > 0;
                            runningStock -= deducted;
                            quantityToDeduct -= deducted;
                            inventoryTransactions.Add(CreateAdjustmentTransaction(
                                line,
                                batch,
                                -deducted,
                                runningStock + deducted,
                                runningStock,
                                reviewerEmployeeId));

                            if (quantityToDeduct == 0)
                            {
                                break;
                            }
                        }
                    }
                    else
                    {
                        var cost = GetAdjustmentCost(productBatches);
                        var adjustmentBatch = new Batch
                        {
                            BatchCode = $"{stockCount.StockCountCode}-ADJ-{line.StockCountLineId}",
                            ManufactureDate = approvedAt.Date,
                            ExpiryDate = approvedAt.Date.AddYears(1),
                            ImportPrice = cost,
                            QuantityImported = variance,
                            QuantityRemaining = variance,
                            Quantity = variance,
                            TotalPrice = cost * variance,
                            Status = true,
                            Provenance = BatchProvenance.StockCountAdjustment,
                            ProductId = line.ProductId
                        };

                        adjustmentBatches.Add(adjustmentBatch);
                        productBatches.Add(adjustmentBatch);
                        batches.Add(adjustmentBatch);
                        runningStock += variance;
                        inventoryTransactions.Add(CreateAdjustmentTransaction(
                            line,
                            adjustmentBatch,
                            variance,
                            runningStock - variance,
                            runningStock,
                            reviewerEmployeeId));
                    }

                    product.StockQuantity = productBatches
                        .Where(batch => !batch.IsDeleted && batch.Status)
                        .Sum(batch => batch.QuantityRemaining);
                }

                _stockCountRepository.AddBatches(adjustmentBatches);
                _stockCountRepository.AddInventoryTransactions(inventoryTransactions);
                stockCount.Status = StockCountStatus.Closed;
                stockCount.ReviewedByEmployeeId = reviewerEmployeeId;
                stockCount.ReviewedAt = approvedAt;

                await _stockCountRepository.SaveChangesAsync();
            });

            try
            {
                await _notificationService.SendToUserAsync(
                    createdByEmployeeId,
                    "Phiếu kiểm kê đã được duyệt",
                    $"Phiếu kiểm kê {stockCountCode} đã được phê duyệt và điều chỉnh tồn kho.",
                    new Dictionary<string, string>
                    {
                        { "type", "stock_count_response" },
                        { "status", "approved" },
                        { "stockCountId", stockCountId.ToString() }
                    });
            }
            catch (Exception ex)
            {
                _logger.LogWarning(ex, "Failed to send stock_count_response (approved) notification for StockCountId {StockCountId}", stockCountId);
            }

            return (await GetDetailByIdAsync(id))!;
        }

        public async Task<StockCountDetailDto> RejectAsync(int id, RejectStockCountDto rejectDto, int reviewerEmployeeId)
        {
            if (string.IsNullOrWhiteSpace(rejectDto.Reason))
            {
                throw new DomainException("A rejection reason is required.", StatusCodes.Status400BadRequest);
            }

            if (rejectDto.RowVersion.Length == 0)
            {
                throw new DomainException("A stock-count row version is required.", StatusCodes.Status400BadRequest);
            }

            if (!await _stockCountRepository.EmployeeExistsAsync(reviewerEmployeeId))
            {
                throw new DomainException("Current employee does not exist.", StatusCodes.Status422UnprocessableEntity);
            }

            var stockCount = await _stockCountRepository.GetTrackedByIdAsync(id)
                ?? throw new DomainException($"Stock count with ID {id} not found.", StatusCodes.Status404NotFound);

            ValidateTransition(stockCount, StockCountStatus.Counting);
            _stockCountRepository.ApplyOriginalRowVersion(stockCount, rejectDto.RowVersion);
            stockCount.Status = StockCountStatus.Counting;
            stockCount.ReviewedByEmployeeId = reviewerEmployeeId;
            stockCount.ReviewedAt = HanoiTime.Now;
            stockCount.RejectionReason = rejectDto.Reason.Trim();

            try
            {
                await _stockCountRepository.SaveChangesAsync();
            }
            catch (DbUpdateConcurrencyException)
            {
                throw new DomainException("The stock count was changed by another user. Reload and retry.", StatusCodes.Status409Conflict);
            }

            try
            {
                await _notificationService.SendToUserAsync(
                    stockCount.CreatedByEmployeeId,
                    "Phiếu kiểm kê đã bị từ chối",
                    $"Phiếu kiểm kê {stockCount.StockCountCode} đã bị từ chối. Lý do: {stockCount.RejectionReason}",
                    new Dictionary<string, string>
                    {
                        { "type", "stock_count_response" },
                        { "status", "rejected" },
                        { "stockCountId", stockCount.StockCountId.ToString() },
                        { "reason", stockCount.RejectionReason }
                    });
            }
            catch (Exception ex)
            {
                _logger.LogWarning(ex, "Failed to send stock_count_response (rejected) notification for StockCountId {StockCountId}", stockCount.StockCountId);
            }

            return (await GetDetailByIdAsync(id))!;
        }

        public async Task<IReadOnlyList<int>> ValidateCreateScopeAsync(
            StockCountScope scope,
            IReadOnlyCollection<int> categoryIds)
        {
            var distinctCategoryIds = categoryIds.Distinct().ToList();

            if (scope == StockCountScope.Global)
            {
                if (distinctCategoryIds.Count != 0)
                {
                    throw new DomainException("Global stock counts must not include category IDs.", StatusCodes.Status400BadRequest);
                }

                return distinctCategoryIds;
            }

            if (scope == StockCountScope.Selected)
            {
                if (distinctCategoryIds.Count != 0)
                {
                    throw new DomainException("Selected-product stock counts must not include category IDs.", StatusCodes.Status400BadRequest);
                }

                return distinctCategoryIds;
            }

            if (scope != StockCountScope.Category || distinctCategoryIds.Count == 0)
            {
                throw new DomainException("Category stock counts require at least one category ID.", StatusCodes.Status400BadRequest);
            }

            foreach (var categoryId in distinctCategoryIds)
            {
                if (!await _stockCountRepository.CategoryExistsAsync(categoryId))
                {
                    throw new DomainException($"Category with ID {categoryId} not found.", StatusCodes.Status400BadRequest);
                }
            }

            return distinctCategoryIds;
        }

        public void ValidateTransition(StockCount stockCount, StockCountStatus targetStatus)
        {
            var isAllowed = (stockCount.Status, targetStatus) switch
            {
                (StockCountStatus.Draft, StockCountStatus.Counting) => true,
                (StockCountStatus.Counting, StockCountStatus.PendingApproval) => true,
                (StockCountStatus.PendingApproval, StockCountStatus.Closed) => true,
                (StockCountStatus.PendingApproval, StockCountStatus.Counting) => true,
                _ => false
            };

            if (!isAllowed)
            {
                throw new DomainException(
                    $"Cannot transition stock count from {stockCount.Status} to {targetStatus}.",
                    StatusCodes.Status409Conflict);
            }
        }

        private static void EnsureStatus(StockCount stockCount, StockCountStatus requiredStatus)
        {
            if (stockCount.Status != requiredStatus)
            {
                throw new DomainException(
                    $"Stock count must be {requiredStatus} but is {stockCount.Status}.",
                    StatusCodes.Status409Conflict);
            }
        }

        private static decimal GetAdjustmentCost(IReadOnlyCollection<Batch> batches)
        {
            var activeBatches = batches
                .Where(batch => !batch.IsDeleted && batch.Status && batch.QuantityRemaining > 0)
                .ToList();
            var activeQuantity = activeBatches.Sum(batch => batch.QuantityRemaining);
            if (activeQuantity > 0)
            {
                return activeBatches.Sum(batch => batch.ImportPrice * batch.QuantityRemaining) / activeQuantity;
            }

            return batches
                .Where(batch => !batch.IsDeleted)
                .OrderByDescending(batch => batch.Receipt?.ImportDate ?? batch.ManufactureDate)
                .ThenByDescending(batch => batch.BatchId)
                .Select(batch => batch.ImportPrice)
                .FirstOrDefault();
        }

        private static InventoryTransaction CreateAdjustmentTransaction(
            StockCountLine line,
            Batch batch,
            int quantity,
            int previousStock,
            int currentStock,
            int reviewerEmployeeId)
        {
            return new InventoryTransaction
            {
                TransactionType = InventoryTransactionType.Adjustment,
                Quantity = quantity,
                PreviousStock = previousStock,
                CurrentStock = currentStock,
                ReferenceType = ReferenceType.StockCount,
                ReferenceId = line.StockCountId,
                SubReferenceId = line.StockCountLineId,
                Note = "Stock-count adjustment.",
                ProductId = line.ProductId,
                Batch = batch,
                EmployeeId = reviewerEmployeeId
            };
        }
    }
}