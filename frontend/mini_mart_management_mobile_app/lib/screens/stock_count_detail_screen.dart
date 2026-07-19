import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mini_mart_management_mobile_app/core/api_exception.dart';
import 'package:mini_mart_management_mobile_app/models/product_lookup.dart';
import 'package:mini_mart_management_mobile_app/models/scanned_product.dart';
import 'package:mini_mart_management_mobile_app/models/stock_count.dart';
import 'package:mini_mart_management_mobile_app/providers/auth_provider.dart';
import 'package:mini_mart_management_mobile_app/providers/inventory_provider.dart';
import 'package:mini_mart_management_mobile_app/providers/inventory_lookup_provider.dart';
import 'package:mini_mart_management_mobile_app/providers/stock_count_provider.dart';
import 'package:mini_mart_management_mobile_app/screens/barcode_scanner_screen.dart';
import 'package:mini_mart_management_mobile_app/theme/app_colors.dart';
import 'package:mini_mart_management_mobile_app/widgets/feedback/loading_overlay.dart';
import 'package:mini_mart_management_mobile_app/widgets/layout/mini_mart_app_bar.dart';
import 'package:provider/provider.dart';

class StockCountDetailScreen extends StatefulWidget {
  const StockCountDetailScreen({
    this.stockCountId,
    this.createScope = StockCountScope.selected,
    this.categoryIds = const [],
    super.key,
  });
  final int? stockCountId;
  final StockCountScope createScope;
  final List<int> categoryIds;
  @override
  State<StockCountDetailScreen> createState() => _StockCountDetailScreenState();
}

class _StockCountDetailScreenState extends State<StockCountDetailScreen> {
  StockCount? _count;
  Map<int, int?> _actualQuantities = {};
  final Map<int, TextEditingController> _quantityControllers = {};
  final _productSearchController = TextEditingController();
  bool _initializing = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  Future<void> _load() async {
    try {
      final provider = context.read<StockCountProvider>();
      final count = widget.stockCountId == null
          ? await provider.createAndStart(
              widget.createScope,
              categoryIds: widget.categoryIds,
            )
          : await provider.getDetail(widget.stockCountId!);
      if (!mounted) return;
      _setCount(count);
      if (count.scope == StockCountScope.selected) {
        await context.read<InventoryLookupProvider>().loadLookups();
      }
    } on ApiException catch (error) {
      if (mounted) _message(error.message);
    } finally {
      if (mounted) setState(() => _initializing = false);
    }
  }

  void _setCount(StockCount count, {Map<int, int?>? preservedQuantities}) =>
      setState(() {
        _count = count;
        _actualQuantities = {
          for (final line in count.lines)
            line.stockCountLineId:
                preservedQuantities != null &&
                    preservedQuantities.containsKey(line.stockCountLineId)
                ? preservedQuantities[line.stockCountLineId]
                : line.actualQuantity,
        };
        for (final line in count.lines) {
          _quantityController(line.stockCountLineId).text =
              _actualQuantities[line.stockCountLineId]?.toString() ?? '';
        }
      });

  @override
  void dispose() {
    for (final controller in _quantityControllers.values) {
      controller.dispose();
    }
    _productSearchController.dispose();
    super.dispose();
  }

  TextEditingController _quantityController(int lineId) =>
      _quantityControllers.putIfAbsent(lineId, TextEditingController.new);

  void _changeQuantity(int lineId, int delta) {
    final current = _actualQuantities[lineId];
    if (delta < 0 && (current == null || current == 0)) return;
    final next = (current ?? 0) + delta;
    setState(() => _actualQuantities[lineId] = next);
    _quantityController(lineId).text = next.toString();
  }

  bool get _isCounting => _count?.status == StockCountStatus.counting;
  bool get _isManager {
    final user = context.read<AuthProvider>().currentUser;
    return user != null &&
        (user.roleId == 1 ||
            user.roleId == 5 ||
            user.roleName.toLowerCase() == 'manager' ||
            user.roleName.toLowerCase() == 'quản lý');
  }

  List<StockCountLine> get _updatedLines => _count!.lines
      .map(
        (line) => StockCountLine(
          stockCountLineId: line.stockCountLineId,
          productId: line.productId,
          productCode: line.productCode,
          productName: line.productName,
          snapshotQuantity: line.snapshotQuantity,
          actualQuantity: _actualQuantities[line.stockCountLineId],
          variance: null,
          note: line.note,
          rowVersion: line.rowVersion,
        ),
      )
      .toList(growable: false);

  List<ProductLookup> _filterProducts(List<ProductLookup> products) {
    final query = _productSearchController.text.trim().toLowerCase();
    if (query.isEmpty) return const [];

    final existingProductIds = _count!.lines
        .map((line) => line.productId)
        .toSet();
    return products
        .where(
          (product) =>
              !existingProductIds.contains(product.productId) &&
              (product.productName.toLowerCase().contains(query) ||
                  product.productCode.toLowerCase().contains(query) ||
                  product.barcode.toLowerCase().contains(query)),
        )
        .take(5)
        .toList(growable: false);
  }

  Future<void> _addProduct(ProductLookup product) async {
    final currentQuantities = Map<int, int?>.from(_actualQuantities);
    try {
      final updated = await context.read<StockCountProvider>().addLines(
        _count!,
        [product.productId],
      );
      if (!mounted) return;
      _setCount(updated, preservedQuantities: currentQuantities);
      _productSearchController.clear();
    } on ApiException catch (error) {
      _message(error.message);
    }
  }

  Future<void> _openBarcodeScanner() async {
    final scanned = await Navigator.of(context).push<List<ScannedProduct>>(
      MaterialPageRoute(builder: (_) => const BarcodeScannerScreen()),
    );
    if (!mounted || scanned == null || scanned.isEmpty) return;

    final quantitiesByProductId = <int, int>{};
    for (final entry in scanned) {
      quantitiesByProductId.update(
        entry.product.productId,
        (quantity) => quantity + entry.quantity,
        ifAbsent: () => entry.quantity,
      );
    }

    final currentQuantities = Map<int, int?>.from(_actualQuantities);
    try {
      final updated = _count!.scope == StockCountScope.selected
          ? await context.read<StockCountProvider>().addLines(
              _count!,
              quantitiesByProductId.keys.toList(growable: false),
            )
          : _count!;
      if (!mounted) return;
      _setCount(updated, preservedQuantities: currentQuantities);
      setState(() {
        for (final line in _count!.lines) {
          final scannedQuantity = quantitiesByProductId[line.productId];
          if (scannedQuantity == null) continue;

          final quantity =
              (_actualQuantities[line.stockCountLineId] ?? 0) + scannedQuantity;
          _actualQuantities[line.stockCountLineId] = quantity;
          _quantityController(line.stockCountLineId).text = quantity.toString();
        }
      });
    } on ApiException catch (error) {
      _message(error.message);
    }
  }

  Future<void> _save() async {
    try {
      _setCount(
        await context.read<StockCountProvider>().saveLines(
          _count!,
          _updatedLines,
        ),
      );
      _message('Đã lưu số lượng kiểm kê.');
    } on ApiException catch (error) {
      _message(error.message);
    }
  }

  Future<void> _submit() async {
    try {
      final provider = context.read<StockCountProvider>();
      final saved = await provider.saveLines(_count!, _updatedLines);
      _setCount(await provider.submit(saved));
      _message('Đã gửi phiếu chờ duyệt.');
    } on ApiException catch (error) {
      _message(error.message);
    }
  }

  Future<void> _approve() async {
    try {
      final stockCountProvider = context.read<StockCountProvider>();
      final inventoryProvider = context.read<InventoryProvider>();
      _setCount(await stockCountProvider.approve(_count!));
      await inventoryProvider.loadTransactions();
      if (mounted) _message('Đã duyệt và tạo giao dịch điều chỉnh kho.');
    } on ApiException catch (error) {
      _message(error.message);
    }
  }

  Future<void> _cancelDraft() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hủy phiếu kiểm kê nháp'),
        content: const Text(
          'Phiếu sẽ được lưu trong lịch sử với trạng thái đã hủy.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Không'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: AppColors.statusError),
            child: const Text('Hủy phiếu'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    try {
      await context.read<StockCountProvider>().cancelDraft(_count!);
      if (mounted) Navigator.of(context).pop();
    } on ApiException catch (error) {
      _message(error.message);
    }
  }

  Future<void> _reject() async {
    final controller = TextEditingController();
    final reason = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Từ chối phiếu kiểm kê'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(hintText: 'Lý do từ chối'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, controller.text.trim()),
            child: const Text('Từ chối'),
          ),
        ],
      ),
    );
    controller.dispose();
    if (reason == null || reason.isEmpty) return;
    try {
      if (!mounted) return;
      final provider = context.read<StockCountProvider>();
      _setCount(await provider.reject(_count!, reason));
      _message('Đã trả phiếu để kiểm kê lại.');
    } on ApiException catch (error) {
      _message(error.message);
    }
  }

  void _message(String value) => ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(content: Text(value)));

  @override
  Widget build(BuildContext context) {
    if (_initializing) return const Scaffold(body: LoadingOverlay());
    final count = _count;
    if (count == null) {
      return Scaffold(
        appBar: MiniMartAppBar.secondary(title: 'Kiểm kê kho hàng'),
        body: const Center(child: Text('Không thể mở phiếu kiểm kê.')),
      );
    }
    final checked = _actualQuantities.values.whereType<int>().length;
    final variances = count.lines.where((line) {
      final actual = _actualQuantities[line.stockCountLineId];
      return actual != null && actual != line.snapshotQuantity;
    }).length;
    return Scaffold(
      appBar: MiniMartAppBar.secondary(title: 'Kiểm kê kho hàng'),
      backgroundColor: AppColors.backgroundSlate,
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 104),
        children: [
          _header(count),
          if (count.rejectionReason != null) _rejection(count.rejectionReason!),
          const SizedBox(height: 12),
          if (_isCounting && count.scope == StockCountScope.selected)
            _productPicker(context.watch<InventoryLookupProvider>().products)
          else if (_isCounting)
            _scanner(),
          const SizedBox(height: 12),
          _summary(checked, variances, count.lines.length),
          const SizedBox(height: 18),
          Text(
            'Danh sách sản phẩm',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          ...count.lines.map((line) => _line(line)),
        ],
      ),
      bottomNavigationBar: _actions(count),
    );
  }

  Widget _header(StockCount count) => Card(
    child: ListTile(
      title: Text(
        count.stockCountCode,
        style: const TextStyle(
          fontWeight: FontWeight.w800,
          color: AppColors.primary,
        ),
      ),
      subtitle: Text('${count.scope.label} · ${count.createdByEmployeeName}'),
      trailing: Chip(label: Text(count.status.label)),
    ),
  );
  Widget _rejection(String reason) => Padding(
    padding: const EdgeInsets.only(top: 12),
    child: Card(
      color: AppColors.errorContainer,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Text('Lý do từ chối: $reason'),
      ),
    ),
  );
  Widget _scanner() => Card(
    child: ListTile(
      leading: const Icon(Icons.qr_code_scanner_rounded),
      title: const Text('Quét mã vạch'),
      subtitle: const Text('Cập nhật số lượng thực tế'),
      onTap: _openBarcodeScanner,
    ),
  );
  Widget _productPicker(List<ProductLookup> products) {
    final matches = _filterProducts(products);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            TextField(
              controller: _productSearchController,
              onChanged: (_) => setState(() {}),
              decoration: InputDecoration(
                labelText: 'Thêm sản phẩm kiểm kê',
                hintText: 'Tên, mã sản phẩm hoặc barcode',
                prefixIcon: const Icon(Icons.search_rounded),
                suffixIcon: IconButton(
                  onPressed: _openBarcodeScanner,
                  icon: const Icon(Icons.qr_code_scanner_rounded),
                  tooltip: 'Quét mã vạch',
                ),
              ),
            ),
            if (_productSearchController.text.trim().isNotEmpty) ...[
              const SizedBox(height: 8),
              if (matches.isEmpty)
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text('Không tìm thấy sản phẩm phù hợp.'),
                )
              else
                ...matches.map(
                  (product) => ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(product.productName),
                    subtitle: Text(
                      '${product.productCode} • ${product.barcode}',
                    ),
                    trailing: const Icon(Icons.add_circle_outline),
                    onTap: () => _addProduct(product),
                  ),
                ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _summary(int checked, int variance, int total) => Card(
    child: Padding(
      padding: const EdgeInsets.all(14),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Text('Đã kiểm\n$checked/$total', textAlign: TextAlign.center),
          Text('Chênh lệch\n$variance', textAlign: TextAlign.center),
        ],
      ),
    ),
  );
  Widget _line(StockCountLine line) {
    final actual = _actualQuantities[line.stockCountLineId];
    final variance = actual == null ? null : actual - line.snapshotQuantity;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              line.productName,
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
            Text(
              line.productCode,
              style: const TextStyle(color: AppColors.textMuted),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(child: Text('Tồn: ${line.snapshotQuantity}')),
                Expanded(
                  child: Text(
                    'CL: ${variance == null
                        ? '—'
                        : variance > 0
                        ? '+$variance'
                        : variance}',
                  ),
                ),
                if (_isCounting)
                  IconButton(
                    onPressed: () => _changeQuantity(line.stockCountLineId, -1),
                    icon: const Icon(Icons.remove_circle_outline),
                  ),
                SizedBox(
                  width: 88,
                  child: _isCounting
                      ? TextField(
                          controller: _quantityController(
                            line.stockCountLineId,
                          ),
                          keyboardType: TextInputType.number,
                          textAlign: TextAlign.center,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                          ],
                          decoration: const InputDecoration(
                            isDense: true,
                            hintText: '—',
                          ),
                          onChanged: (value) => setState(
                            () => _actualQuantities[line.stockCountLineId] =
                                value.isEmpty ? null : int.tryParse(value),
                          ),
                        )
                      : Text('${actual ?? '—'}', textAlign: TextAlign.center),
                ),
                if (_isCounting)
                  IconButton(
                    onPressed: () => _changeQuantity(line.stockCountLineId, 1),
                    icon: const Icon(Icons.add_circle_outline),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget? _actions(StockCount count) {
    final action = switch (count.status) {
      StockCountStatus.draft when _isManager => FilledButton(
        onPressed: _cancelDraft,
        style: FilledButton.styleFrom(backgroundColor: AppColors.statusError),
        child: const Text('Xóa phiếu nháp'),
      ),
      StockCountStatus.counting => Row(
        children: [
          Expanded(
            child: OutlinedButton(onPressed: _save, child: const Text('Lưu')),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: FilledButton(
              onPressed: _submit,
              child: const Text('Gửi duyệt'),
            ),
          ),
        ],
      ),
      StockCountStatus.pendingApproval when _isManager => Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: _reject,
              child: const Text('Từ chối'),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: FilledButton(
              onPressed: _approve,
              child: const Text('Duyệt'),
            ),
          ),
        ],
      ),
      _ => null,
    };
    return action == null
        ? null
        : SafeArea(
            child: Padding(padding: const EdgeInsets.all(16), child: action),
          );
  }
}
