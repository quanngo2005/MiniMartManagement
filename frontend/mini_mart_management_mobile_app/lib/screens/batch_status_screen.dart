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
      backgroundColor: AppColors.backgroundSlate,
      appBar: _buildAppBar(),
      body: RefreshIndicator(
        onRefresh: () => context.read<BatchProvider>().loadBatches(),
        child: _buildBody(provider, batches),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: AppColors.surfaceBright,
      foregroundColor: AppColors.primary,
      elevation: 0,
      scrolledUnderElevation: 0,
      titleSpacing: widget.onMenuTap == null ? null : 0,
      leading: widget.onMenuTap == null
          ? null
          : IconButton(
              onPressed: widget.onMenuTap,
              tooltip: 'Mở menu',
              icon: const Icon(Icons.menu_rounded),
            ),
      title: const Text('Quản lý hạn sử dụng'),
      bottom: const PreferredSize(
        preferredSize: Size.fromHeight(1),
        child: Divider(height: 1, color: AppColors.outlineVariant),
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

    return CustomScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
          sliver: SliverToBoxAdapter(
            child: _ExpiryDashboard(batches: batches),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
          sliver: SliverToBoxAdapter(child: _buildSearchField()),
        ),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
          sliver: SliverToBoxAdapter(child: _buildSectionHeader(batches)),
        ),
        if (provider.errorMessage != null)
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            sliver: SliverToBoxAdapter(
              child: ErrorBanner(
                message: provider.errorMessage!,
                onRetry: provider.loadBatches,
              ),
            ),
          ),
        if (batches.isEmpty)
          const SliverFillRemaining(
            hasScrollBody: false,
            child: EmptyState(
              message: 'Không tìm thấy lô hàng cần theo dõi.',
              icon: Icons.event_busy_outlined,
            ),
          )
        else
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
            sliver: SliverList.separated(
              itemCount: batches.length,
              separatorBuilder: (_, _) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final batch = batches[index];
                return _ExpiryBatchCard(
                  batch: batch,
                  isDisposing: provider.isDisposing,
                  onDispose: _canDispose(batch)
                      ? () => _confirmDispose(batch)
                      : null,
                );
              },
            ),
          ),
      ],
    );
  }

  Widget _buildSearchField() {
    return TextField(
      onChanged: (value) => setState(() => _query = value.trim()),
      textInputAction: TextInputAction.search,
      decoration: const InputDecoration(
        prefixIcon: Icon(Icons.search_rounded),
        hintText: 'Tìm SKU, mã lô hoặc tên sản phẩm...',
      ),
    );
  }

  Widget _buildSectionHeader(List<Batch> batches) {
    return Row(
      children: [
        Expanded(
          child: Text(
            'Danh sách lô hàng',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        TextButton.icon(
          onPressed: () => _showProductFilter(batches),
          icon: const Icon(Icons.filter_list_rounded, size: 18),
          label: Text(_productId == null ? 'Lọc' : 'Đang lọc'),
        ),
      ],
    );
  }

  List<Batch> _filteredBatches(List<Batch> batches) {
    final query = _query.toLowerCase();
    final filtered = batches.where((batch) {
      final matchesProduct = _productId == null || batch.productId == _productId;
      final matchesQuery = query.isEmpty ||
          batch.batchCode.toLowerCase().contains(query) ||
          batch.productName.toLowerCase().contains(query) ||
          batch.productCode.toLowerCase().contains(query);
      return matchesProduct && matchesQuery;
    }).toList();
    filtered.sort((first, second) => first.expiryDate.compareTo(second.expiryDate));
    return filtered;
  }

  Future<void> _showProductFilter(List<Batch> batches) async {
    final products = <int, String>{
      for (final batch in batches) batch.productId: batch.productName,
    }.entries.toList()..sort((first, second) => first.value.compareTo(second.value));
    final selection = await showModalBottomSheet<_ProductFilterSelection>(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const ListTile(
              leading: Icon(Icons.filter_list_rounded),
              title: Text('Lọc theo sản phẩm'),
            ),
            ListTile(
              selected: _productId == null,
              title: const Text('Tất cả sản phẩm'),
              onTap: () => Navigator.pop(
                context,
                const _ProductFilterSelection.clear(),
              ),
            ),
            ...products.map(
              (product) => ListTile(
                selected: _productId == product.key,
                title: Text(product.value),
                onTap: () => Navigator.pop(
                  context,
                  _ProductFilterSelection.product(product.key),
                ),
              ),
            ),
          ],
        ),
      ),
    );
    if (!mounted || selection == null) return;
    setState(() => _productId = selection.productId);
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

class _ExpiryDashboard extends StatelessWidget {
  const _ExpiryDashboard({required this.batches});

  final List<Batch> batches;

  @override
  Widget build(BuildContext context) {
    final criticalBatches = batches.where(_isCritical).length;
    final warningBatches = batches.where(_isWarning).length;

    return Row(
      children: [
        Expanded(
          child: _ExpiryMetricCard(
            icon: Icons.emergency_rounded,
            label: 'Hết hạn trong ≤ 7 ngày',
            value: '$criticalBatches',
            color: AppColors.statusError,
            backgroundColor: AppColors.errorContainer,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _ExpiryMetricCard(
            icon: Icons.warning_amber_rounded,
            label: 'Cần lưu ý (≤ 30 ngày)',
            value: '$warningBatches',
            color: AppColors.statusWarning,
            backgroundColor: AppColors.warningContainer,
          ),
        ),
      ],
    );
  }
}

class _ProductFilterSelection {
  const _ProductFilterSelection.clear() : productId = null;

  const _ProductFilterSelection.product(this.productId);

  final int? productId;
}

class _ExpiryMetricCard extends StatelessWidget {
  const _ExpiryMetricCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
    required this.backgroundColor,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color color;
  final Color backgroundColor;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        border: Border.all(color: AppColors.borderGray),
        borderRadius: BorderRadius.circular(12),
      ),
      child: SizedBox(
        height: 108,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(icon, size: 17, color: color),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      label,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: AppColors.textDark,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
              const Spacer(),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    value,
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  DecoratedBox(
                    decoration: BoxDecoration(
                      color: backgroundColor,
                      borderRadius: BorderRadius.circular(99),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      child: Icon(icon, size: 14, color: color),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ExpiryBatchCard extends StatelessWidget {
  const _ExpiryBatchCard({
    required this.batch,
    required this.isDisposing,
    this.onDispose,
  });

  final Batch batch;
  final bool isDisposing;
  final VoidCallback? onDispose;

  @override
  Widget build(BuildContext context) {
    final state = _stateFor(batch);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        border: Border.all(color: AppColors.borderGray),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const _ProductPlaceholder(),
                const SizedBox(width: 12),
                Expanded(child: _buildDetails(context, state)),
              ],
            ),
            if (onDispose != null) ...[
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: isDisposing ? null : onDispose,
                  icon: const Icon(Icons.delete_outline_rounded),
                  label: const Text('Xuất hủy lô hết hạn'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.statusError,
                    side: const BorderSide(color: AppColors.statusError),
                    minimumSize: const Size.fromHeight(48),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildDetails(BuildContext context, _ExpiryState state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Text(
                batch.productName,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            const SizedBox(width: 8),
            _ExpiryBadge(batch: batch, state: state),
          ],
        ),
        const SizedBox(height: 2),
        Text(
          'SKU: ${batch.productCode} · Lô: ${batch.batchCode}',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
            color: AppColors.textMuted,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _BatchMetadata(
                icon: Icons.inventory_2_outlined,
                value: '${batch.quantityRemaining}',
                label: 'Tồn còn lại',
              ),
            ),
            Expanded(
              child: _BatchMetadata(
                icon: Icons.calendar_month_outlined,
                value: _formatDate(batch.expiryDate),
                label: 'Hạn sử dụng',
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _ProductPlaceholder extends StatelessWidget {
  const _ProductPlaceholder();

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(8),
      ),
      child: const SizedBox(
        width: 72,
        height: 72,
        child: Icon(Icons.inventory_2_outlined, color: AppColors.textMuted),
      ),
    );
  }
}

class _BatchMetadata extends StatelessWidget {
  const _BatchMetadata({
    required this.icon,
    required this.value,
    required this.label,
  });

  final IconData icon;
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppColors.textMuted),
        const SizedBox(width: 5),
        Flexible(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Text(
                label,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: AppColors.textMuted,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ExpiryBadge extends StatelessWidget {
  const _ExpiryBadge({required this.batch, required this.state});

  final Batch batch;
  final _ExpiryState state;

  @override
  Widget build(BuildContext context) {
    final (label, foregroundColor, backgroundColor) = switch (state) {
      _ExpiryState.expired => ('ĐÃ HẾT HẠN', AppColors.statusError, AppColors.errorContainer),
      _ExpiryState.critical => ('${_daysUntilExpiry(batch)} NGÀY', AppColors.statusError, AppColors.errorContainer),
      _ExpiryState.warning => ('${_daysUntilExpiry(batch)} NGÀY', AppColors.primary, AppColors.warningContainer),
      _ExpiryState.available => ('CÒN HÀNG', AppColors.secondary, AppColors.secondaryContainer),
      _ExpiryState.outOfStock => ('HẾT HÀNG', AppColors.textMuted, AppColors.surfaceContainerHigh),
      _ExpiryState.inactive => ('NGƯNG DÙNG', AppColors.textMuted, AppColors.surfaceContainerHigh),
    };

    return DecoratedBox(
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(99),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
        child: Text(
          label,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
            color: foregroundColor,
            fontWeight: FontWeight.w800,
            fontSize: 10,
          ),
        ),
      ),
    );
  }
}

enum _ExpiryState { expired, critical, warning, available, outOfStock, inactive }

_ExpiryState _stateFor(Batch batch) {
  if (!batch.status) return _ExpiryState.inactive;
  if (batch.quantityRemaining <= 0) return _ExpiryState.outOfStock;
  if (_isExpired(batch)) return _ExpiryState.expired;
  if (_daysUntilExpiry(batch) <= 7) return _ExpiryState.critical;
  if (_daysUntilExpiry(batch) <= 30) return _ExpiryState.warning;
  return _ExpiryState.available;
}

bool _isExpired(Batch batch) => DateUtils.dateOnly(batch.expiryDate).isBefore(
  DateUtils.dateOnly(DateTime.now()),
);

bool _isCritical(Batch batch) =>
    batch.status && batch.quantityRemaining > 0 && _daysUntilExpiry(batch) <= 7;

bool _isWarning(Batch batch) =>
    batch.status &&
    batch.quantityRemaining > 0 &&
    _daysUntilExpiry(batch) > 7 &&
    _daysUntilExpiry(batch) <= 30;

bool _canDispose(Batch batch) =>
    batch.status && batch.quantityRemaining > 0 && _isExpired(batch);

int _daysUntilExpiry(Batch batch) => DateUtils.dateOnly(
  batch.expiryDate,
).difference(DateUtils.dateOnly(DateTime.now())).inDays;

String _formatDate(DateTime value) =>
    '${value.day.toString().padLeft(2, '0')}/${value.month.toString().padLeft(2, '0')}/${value.year}';
