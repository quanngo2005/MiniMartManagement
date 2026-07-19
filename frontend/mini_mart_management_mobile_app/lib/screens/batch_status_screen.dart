import 'package:flutter/material.dart';
import 'package:mini_mart_management_mobile_app/models/batch.dart';
import 'package:mini_mart_management_mobile_app/providers/batch_provider.dart';
import 'package:mini_mart_management_mobile_app/theme/app_colors.dart';
import 'package:mini_mart_management_mobile_app/widgets/feedback/empty_state.dart';
import 'package:mini_mart_management_mobile_app/widgets/feedback/error_banner.dart';
import 'package:mini_mart_management_mobile_app/widgets/feedback/loading_overlay.dart';
import 'package:provider/provider.dart';

class BatchStatusScreen extends StatefulWidget {
  const BatchStatusScreen({this.onMenuTap, super.key});

  final VoidCallback? onMenuTap;

  @override
  State<BatchStatusScreen> createState() => _BatchStatusScreenState();
}

class _BatchStatusScreenState extends State<BatchStatusScreen> {
  String _query = '';
  int? _productId;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => context.read<BatchProvider>().loadBatches(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<BatchProvider>();
    final batches = _filteredBatches(provider.batches);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.surfaceBright,
        foregroundColor: AppColors.primary,
        leading: widget.onMenuTap == null
            ? null
            : IconButton(
                onPressed: widget.onMenuTap,
                icon: const Icon(Icons.menu_rounded),
              ),
        title: const Text('Trạng thái lô hàng'),
      ),
      body: RefreshIndicator(
        onRefresh: () => context.read<BatchProvider>().loadBatches(),
        child: _buildBody(provider, batches),
      ),
    );
  }

  Widget _buildBody(BatchProvider provider, List<Batch> batches) {
    if (provider.isLoading && provider.batches.isEmpty) {
      return const LoadingOverlay();
    }
    if (provider.errorMessage != null && provider.batches.isEmpty) {
      return ErrorBanner(
        message: provider.errorMessage!,
        onRetry: provider.loadBatches,
      );
    }

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      children: [
        TextField(
          onChanged: (value) => setState(() => _query = value.trim()),
          decoration: const InputDecoration(
            prefixIcon: Icon(Icons.search_rounded),
            hintText: 'Tìm mã lô, sản phẩm hoặc mã sản phẩm',
          ),
        ),
        const SizedBox(height: 12),
        _buildProductFilter(provider.batches),
        const SizedBox(height: 16),
        _BatchSummary(batches: batches),
        const SizedBox(height: 16),
        if (provider.errorMessage != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: ErrorBanner(
              message: provider.errorMessage!,
              onRetry: provider.loadBatches,
            ),
          ),
        if (batches.isEmpty)
          const SizedBox(
            height: 360,
            child: EmptyState(
              message: 'Không tìm thấy lô hàng.',
              icon: Icons.inventory_2_outlined,
            ),
          )
        else
          ...batches.map(
            (batch) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _BatchStatusCard(
                batch: batch,
                isDisposing: provider.isDisposing,
                onDispose: _isExpired(batch) &&
                        batch.status &&
                        batch.quantityRemaining > 0
                    ? () => _confirmDispose(batch)
                    : null,
              ),
            ),
          ),
      ],
    );
  }

  List<Batch> _filteredBatches(List<Batch> batches) {
    final query = _query.toLowerCase();
    return batches.where((batch) {
      final matchesProduct = _productId == null || batch.productId == _productId;
      final matchesQuery = query.isEmpty ||
          batch.batchCode.toLowerCase().contains(query) ||
          batch.productName.toLowerCase().contains(query) ||
          batch.productCode.toLowerCase().contains(query);
      return matchesProduct && matchesQuery;
    }).toList(growable: false);
  }

  Widget _buildProductFilter(List<Batch> batches) {
    final products = <int, String>{
      for (final batch in batches) batch.productId: batch.productName,
    }.entries.toList()..sort((a, b) => a.value.compareTo(b.value));

    return DropdownButtonFormField<int?>(
      value: _productId,
      isExpanded: true,
      decoration: const InputDecoration(
        labelText: 'Lọc theo sản phẩm',
        prefixIcon: Icon(Icons.inventory_2_outlined),
      ),
      items: [
        const DropdownMenuItem<int?>(
          value: null,
          child: Text('Tất cả sản phẩm'),
        ),
        ...products.map(
          (product) => DropdownMenuItem<int?>(
            value: product.key,
            child: Text(product.value, overflow: TextOverflow.ellipsis),
          ),
        ),
      ],
      onChanged: (value) => setState(() => _productId = value),
    );
  }

  Future<void> _confirmDispose(Batch batch) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xác nhận xuất hủy'),
        content: Text(
          'Hủy toàn bộ ${batch.quantityRemaining} sản phẩm của lô '
          '${batch.batchCode} (${batch.productName}) vì đã hết hạn?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Không'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Xuất hủy'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    final provider = context.read<BatchProvider>();
    final succeeded = await provider.disposeExpiredBatch(batch.batchId);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          succeeded
              ? 'Đã xuất hủy lô ${batch.batchCode}.'
              : provider.errorMessage ?? 'Không thể xuất hủy lô hàng.',
        ),
      ),
    );
  }
}

class _BatchSummary extends StatelessWidget {
  const _BatchSummary({required this.batches});

  final List<Batch> batches;

  @override
  Widget build(BuildContext context) {
    final totalQuantity = batches.fold<int>(
      0,
      (total, batch) => total + batch.quantityRemaining,
    );
    final sellableQuantity = batches
        .where(_isSellable)
        .fold<int>(0, (total, batch) => total + batch.quantityRemaining);
    final expiredQuantity = batches
        .where((batch) => _isExpired(batch))
        .fold<int>(0, (total, batch) => total + batch.quantityRemaining);

    return Row(
      children: [
        Expanded(
          child: _SummaryValue(label: 'Tổng tồn', value: '$totalQuantity'),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _SummaryValue(
            label: 'Có thể bán',
            value: '$sellableQuantity',
            color: AppColors.secondary,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _SummaryValue(
            label: 'Hết hạn',
            value: '$expiredQuantity',
            color: AppColors.statusError,
          ),
        ),
      ],
    );
  }
}

class _SummaryValue extends StatelessWidget {
  const _SummaryValue({required this.label, required this.value, this.color});

  final String label;
  final String value;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final valueColor = color ?? AppColors.primary;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        border: Border.all(color: AppColors.borderGray),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: Theme.of(
                context,
              ).textTheme.labelSmall?.copyWith(color: AppColors.textMuted),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: valueColor,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BatchStatusCard extends StatelessWidget {
  const _BatchStatusCard({
    required this.batch,
    required this.isDisposing,
    this.onDispose,
  });

  final Batch batch;
  final bool isDisposing;
  final VoidCallback? onDispose;

  @override
  Widget build(BuildContext context) {
    final status = _statusFor(batch);
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    batch.batchCode,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                _StatusBadge(status: status),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              batch.productName,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              'Mã SP: ${batch.productCode} · Phiếu: ${batch.receiptCode}',
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: AppColors.textMuted),
            ),
            const Divider(height: 24),
            Row(
              children: [
                Expanded(child: _Info(label: 'Tồn còn lại', value: '${batch.quantityRemaining}')),
                Expanded(child: _Info(label: 'Hạn dùng', value: _formatDate(batch.expiryDate))),
              ],
            ),
            if (onDispose != null) ...[
              const SizedBox(height: 12),
              Align(
                alignment: Alignment.centerRight,
                child: FilledButton.icon(
                  onPressed: isDisposing ? null : onDispose,
                  icon: const Icon(Icons.delete_outline_rounded),
                  label: const Text('Xuất hủy'),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  _BatchState _statusFor(Batch batch) {
    if (!batch.status) return _BatchState.inactive;
    if (_isExpired(batch)) return _BatchState.expired;
    if (batch.quantityRemaining <= 0) return _BatchState.outOfStock;
    return _BatchState.available;
  }

  String _formatDate(DateTime value) =>
      '${value.day.toString().padLeft(2, '0')}/${value.month.toString().padLeft(2, '0')}/${value.year}';
}

bool _isExpired(Batch batch) => DateUtils.dateOnly(batch.expiryDate).isBefore(
  DateUtils.dateOnly(DateTime.now()),
);

bool _isSellable(Batch batch) =>
    batch.status && !_isExpired(batch) && batch.quantityRemaining > 0;

class _Info extends StatelessWidget {
  const _Info({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(label, style: Theme.of(context).textTheme.labelSmall?.copyWith(color: AppColors.textMuted)),
      const SizedBox(height: 3),
      Text(value, style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.primary, fontWeight: FontWeight.w700)),
    ],
  );
}

enum _BatchState { available, outOfStock, expired, inactive }

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.status});

  final _BatchState status;

  @override
  Widget build(BuildContext context) {
    final (label, color) = switch (status) {
      _BatchState.available => ('Còn hàng', AppColors.secondary),
      _BatchState.outOfStock => ('Hết hàng', AppColors.statusError),
      _BatchState.expired => ('Hết hạn', AppColors.statusError),
      _BatchState.inactive => ('Ngưng dùng', AppColors.textMuted),
    };
    return DecoratedBox(
      decoration: BoxDecoration(color: color.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        child: Text(label, style: Theme.of(context).textTheme.labelSmall?.copyWith(color: color, fontWeight: FontWeight.w700)),
      ),
    );
  }
}
