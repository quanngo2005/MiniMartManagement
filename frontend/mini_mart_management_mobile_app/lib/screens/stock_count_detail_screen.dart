import 'package:flutter/material.dart';
import 'package:mini_mart_management_mobile_app/core/api_exception.dart';
import 'package:mini_mart_management_mobile_app/models/scanned_product.dart';
import 'package:mini_mart_management_mobile_app/models/stock_count.dart';
import 'package:mini_mart_management_mobile_app/providers/auth_provider.dart';
import 'package:mini_mart_management_mobile_app/providers/inventory_provider.dart';
import 'package:mini_mart_management_mobile_app/providers/stock_count_provider.dart';
import 'package:mini_mart_management_mobile_app/screens/barcode_scanner_screen.dart';
import 'package:mini_mart_management_mobile_app/theme/app_colors.dart';
import 'package:mini_mart_management_mobile_app/widgets/feedback/loading_overlay.dart';
import 'package:mini_mart_management_mobile_app/widgets/layout/mini_mart_app_bar.dart';
import 'package:provider/provider.dart';

class StockCountDetailScreen extends StatefulWidget {
  const StockCountDetailScreen({this.stockCountId, super.key});
  final int? stockCountId;
  @override State<StockCountDetailScreen> createState() => _StockCountDetailScreenState();
}

class _StockCountDetailScreenState extends State<StockCountDetailScreen> {
  StockCount? _count;
  Map<int, int?> _actualQuantities = {};
  bool _initializing = true;

  @override void initState() { super.initState(); WidgetsBinding.instance.addPostFrameCallback((_) => _load()); }

  Future<void> _load() async {
    try {
      final provider = context.read<StockCountProvider>();
      final count = widget.stockCountId == null ? await provider.createAndStart() : await provider.getDetail(widget.stockCountId!);
      if (mounted) _setCount(count);
    } on ApiException catch (error) { if (mounted) _message(error.message); }
    finally { if (mounted) setState(() => _initializing = false); }
  }

  void _setCount(StockCount count) => setState(() { _count = count; _actualQuantities = {for (final line in count.lines) line.stockCountLineId: line.actualQuantity}; });
  bool get _isCounting => _count?.status == StockCountStatus.counting;
  bool get _isManager { final user = context.read<AuthProvider>().currentUser; return user != null && (user.roleId == 1 || user.roleId == 5 || user.roleName.toLowerCase() == 'manager' || user.roleName.toLowerCase() == 'quản lý'); }
  List<StockCountLine> get _updatedLines => _count!.lines.map((line) => StockCountLine(stockCountLineId: line.stockCountLineId, productId: line.productId, productCode: line.productCode, productName: line.productName, snapshotQuantity: line.snapshotQuantity, actualQuantity: _actualQuantities[line.stockCountLineId], variance: null, note: line.note, rowVersion: line.rowVersion)).toList(growable: false);

  Future<void> _openBarcodeScanner() async {
    final scanned = await Navigator.of(context).push<List<ScannedProduct>>(MaterialPageRoute(builder: (_) => const BarcodeScannerScreen()));
    if (!mounted || scanned == null) return;
    setState(() { for (final product in scanned) { final line = _count!.lines.where((line) => line.productId == product.product.productId).firstOrNull; if (line != null) _actualQuantities[line.stockCountLineId] = (_actualQuantities[line.stockCountLineId] ?? 0) + product.quantity; } });
  }

  Future<void> _save() async { try { _setCount(await context.read<StockCountProvider>().saveLines(_count!, _updatedLines)); _message('Đã lưu số lượng kiểm kê.'); } on ApiException catch (error) { _message(error.message); } }
  Future<void> _submit() async { try { final saved = await context.read<StockCountProvider>().saveLines(_count!, _updatedLines); _setCount(await context.read<StockCountProvider>().submit(saved)); _message('Đã gửi phiếu chờ duyệt.'); } on ApiException catch (error) { _message(error.message); } }
  Future<void> _approve() async { try { _setCount(await context.read<StockCountProvider>().approve(_count!)); await context.read<InventoryProvider>().loadTransactions(); if (mounted) _message('Đã duyệt và tạo giao dịch điều chỉnh kho.'); } on ApiException catch (error) { _message(error.message); } }
  Future<void> _reject() async { final controller = TextEditingController(); final reason = await showDialog<String>(context: context, builder: (context) => AlertDialog(title: const Text('Từ chối phiếu kiểm kê'), content: TextField(controller: controller, autofocus: true, decoration: const InputDecoration(hintText: 'Lý do từ chối')), actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('Hủy')), FilledButton(onPressed: () => Navigator.pop(context, controller.text.trim()), child: const Text('Từ chối'))])); controller.dispose(); if (reason == null || reason.isEmpty) return; try { _setCount(await context.read<StockCountProvider>().reject(_count!, reason)); _message('Đã trả phiếu để kiểm kê lại.'); } on ApiException catch (error) { _message(error.message); } }
  void _message(String value) => ScaffoldMessenger.of(context)..hideCurrentSnackBar()..showSnackBar(SnackBar(content: Text(value)));

  @override Widget build(BuildContext context) {
    if (_initializing) return const Scaffold(body: LoadingOverlay());
    final count = _count; if (count == null) return Scaffold(appBar: MiniMartAppBar.secondary(title: 'Kiểm kê kho hàng'), body: const Center(child: Text('Không thể mở phiếu kiểm kê.')));
    final checked = _actualQuantities.values.whereType<int>().length;
    final variances = count.lines.where((line) { final actual = _actualQuantities[line.stockCountLineId]; return actual != null && actual != line.snapshotQuantity; }).length;
    return Scaffold(appBar: MiniMartAppBar.secondary(title: 'Kiểm kê kho hàng'), backgroundColor: AppColors.backgroundSlate, body: ListView(padding: const EdgeInsets.fromLTRB(16, 12, 16, 104), children: [_header(count), if (count.rejectionReason != null) _rejection(count.rejectionReason!), const SizedBox(height: 12), if (_isCounting) _scanner(), const SizedBox(height: 12), _summary(checked, variances, count.lines.length), const SizedBox(height: 18), Text('Danh sách sản phẩm', style: Theme.of(context).textTheme.titleMedium?.copyWith(color: AppColors.primary, fontWeight: FontWeight.w800)), const SizedBox(height: 8), ...count.lines.map((line) => _line(line))]), bottomNavigationBar: _actions(count));
  }

  Widget _header(StockCount count) => Card(child: ListTile(title: Text(count.stockCountCode, style: const TextStyle(fontWeight: FontWeight.w800, color: AppColors.primary)), subtitle: Text('${count.scope.label} · ${count.createdByEmployeeName}'), trailing: Chip(label: Text(count.status.label))));
  Widget _rejection(String reason) => Padding(padding: const EdgeInsets.only(top: 12), child: Card(color: AppColors.errorContainer, child: Padding(padding: const EdgeInsets.all(12), child: Text('Lý do từ chối: $reason'))));
  Widget _scanner() => Card(child: ListTile(leading: const Icon(Icons.qr_code_scanner_rounded), title: const Text('Quét mã vạch'), subtitle: const Text('Cập nhật số lượng thực tế'), onTap: _openBarcodeScanner));
  Widget _summary(int checked, int variance, int total) => Card(child: Padding(padding: const EdgeInsets.all(14), child: Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [Text('Đã kiểm\n$checked/$total', textAlign: TextAlign.center), Text('Chênh lệch\n$variance', textAlign: TextAlign.center)])));
  Widget _line(StockCountLine line) { final actual = _actualQuantities[line.stockCountLineId]; final variance = actual == null ? null : actual - line.snapshotQuantity; return Card(child: Padding(padding: const EdgeInsets.all(12), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(line.productName, style: const TextStyle(fontWeight: FontWeight.w700)), Text(line.productCode, style: const TextStyle(color: AppColors.textMuted)), const SizedBox(height: 8), Row(children: [Expanded(child: Text('Tồn: ${line.snapshotQuantity}')), Expanded(child: Text('CL: ${variance == null ? '—' : variance > 0 ? '+$variance' : variance}')), if (_isCounting) IconButton(onPressed: () => setState(() { final value = (actual ?? 0) - 1; if (value >= 0) _actualQuantities[line.stockCountLineId] = value; }), icon: const Icon(Icons.remove_circle_outline)), Text('${actual ?? '—'}'), if (_isCounting) IconButton(onPressed: () => setState(() => _actualQuantities[line.stockCountLineId] = (actual ?? 0) + 1), icon: const Icon(Icons.add_circle_outline))])]))); }
  Widget? _actions(StockCount count) { final action = switch (count.status) { StockCountStatus.counting => Row(children: [Expanded(child: OutlinedButton(onPressed: _save, child: const Text('Lưu'))), const SizedBox(width: 8), Expanded(child: FilledButton(onPressed: _submit, child: const Text('Gửi duyệt')))]), StockCountStatus.pendingApproval when _isManager => Row(children: [Expanded(child: OutlinedButton(onPressed: _reject, child: const Text('Từ chối'))), const SizedBox(width: 8), Expanded(child: FilledButton(onPressed: _approve, child: const Text('Duyệt')))]), _ => null }; return action == null ? null : SafeArea(child: Padding(padding: const EdgeInsets.all(16), child: action)); }
}
