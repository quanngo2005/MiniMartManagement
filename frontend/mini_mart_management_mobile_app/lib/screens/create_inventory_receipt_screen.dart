import 'package:flutter/material.dart';
import 'package:mini_mart_management_mobile_app/models/employee_user.dart';
import 'package:mini_mart_management_mobile_app/models/product_lookup.dart';
import 'package:mini_mart_management_mobile_app/models/receipt.dart';
import 'package:mini_mart_management_mobile_app/models/scanned_product.dart';
import 'package:mini_mart_management_mobile_app/models/supplier.dart';
import 'package:mini_mart_management_mobile_app/providers/auth_provider.dart';
import 'package:mini_mart_management_mobile_app/providers/inventory_lookup_provider.dart';
import 'package:mini_mart_management_mobile_app/screens/barcode_scanner_screen.dart';
import 'package:mini_mart_management_mobile_app/theme/app_colors.dart';
import 'package:provider/provider.dart';

class CreateInventoryReceiptScreen extends StatefulWidget {
  const CreateInventoryReceiptScreen({super.key});

  @override
  State<CreateInventoryReceiptScreen> createState() =>
      _CreateInventoryReceiptScreenState();
}

class _CreateInventoryReceiptScreenState
    extends State<CreateInventoryReceiptScreen> {
  final _formKey = GlobalKey<FormState>();
  final _supplierSearchController = TextEditingController();
  final _productSearchController = TextEditingController();
  final _productSearchFocusNode = FocusNode();
  final _paidAmountController = TextEditingController(text: '0');
  final _noteController = TextEditingController();
  final List<_ReceiptProductDraft> _lines = [];

  Supplier? _selectedSupplier;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<InventoryLookupProvider>().loadLookups();
    });
  }

  @override
  void dispose() {
    _supplierSearchController.dispose();
    _productSearchController.dispose();
    _productSearchFocusNode.dispose();
    _paidAmountController.dispose();
    _noteController.dispose();
    for (final line in _lines) {
      line.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = context.select<AuthProvider, EmployeeUser?>(
      (provider) => provider.currentUser,
    );
    final lookupProvider = context.watch<InventoryLookupProvider>();
    final filteredSuppliers = _filterSuppliers(lookupProvider.suppliers);
    final filteredProducts = _filterProducts(lookupProvider.products);

    return Scaffold(
      appBar: _buildAppBar(context),
      body: SafeArea(
        bottom: false,
        child: Form(
          key: _formKey,
          child: CustomScrollView(
            slivers: [
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
                sliver: SliverList.list(
                  children: [
                    _buildSystemSection(context, currentUser),
                    const SizedBox(height: 12),
                    _buildSupplierSection(context, filteredSuppliers),
                    const SizedBox(height: 12),
                    _buildProductsSection(context, filteredProducts),
                    const SizedBox(height: 12),
                    _buildPaymentSection(context),
                    const SizedBox(height: 12),
                    _buildNoteSection(context),
                    if (lookupProvider.errorMessage != null) ...[
                      const SizedBox(height: 12),
                      _InlineMessage(message: lookupProvider.errorMessage!),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: _buildActionBar(context, currentUser),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: AppColors.surfaceBright,
      foregroundColor: AppColors.primary,
      title: Text(
        'Tạo phiếu nhập',
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
          color: AppColors.primary,
          fontWeight: FontWeight.w800,
        ),
      ),
      centerTitle: true,
    );
  }

  Widget _buildSystemSection(BuildContext context, EmployeeUser? currentUser) {
    return _FormPanel(
      title: 'Thông tin phiếu nhập',
      icon: Icons.receipt_long_outlined,
      children: [
        const _ReadOnlyField(
          label: 'Mã phiếu',
          value: 'Sẽ được tạo sau khi lưu',
          icon: Icons.auto_awesome_outlined,
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _ReadOnlyField(
                label: 'Ngày nhập',
                value: _formatDateTime(DateTime.now()),
              ),
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: _ReadOnlyField(
                label: 'Trạng thái',
                value: 'Chờ xử lý',
                icon: Icons.schedule_rounded,
                accentColor: AppColors.statusWarning,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        _ReadOnlyField(
          label: 'Nhân viên thực hiện',
          value: currentUser?.fullName ?? 'Chưa xác định',
          icon: Icons.badge_outlined,
        ),
      ],
    );
  }

  Widget _buildSupplierSection(
    BuildContext context,
    List<Supplier> suggestions,
  ) {
    return _FormPanel(
      title: 'Nhà cung cấp',
      icon: Icons.local_shipping_outlined,
      children: [
        TextFormField(
          controller: _supplierSearchController,
          decoration: const InputDecoration(
            labelText: 'Tìm hoặc nhập nhà cung cấp',
            prefixIcon: Icon(Icons.search_rounded),
          ),
          onChanged: (_) => setState(() {}),
          validator: (_) =>
              _selectedSupplier == null ? 'Vui lòng chọn nhà cung cấp' : null,
        ),
        if (suggestions.isNotEmpty) ...[
          const SizedBox(height: 8),
          _SupplierSuggestList(
            suppliers: suggestions,
            selectedSupplier: _selectedSupplier,
            onSelected: _selectSupplier,
          ),
        ],
        if (_selectedSupplier != null) ...[
          const SizedBox(height: 10),
          _SelectedSupplierBanner(supplier: _selectedSupplier!),
        ],
      ],
    );
  }

  Widget _buildProductsSection(
    BuildContext context,
    List<ProductLookup> suggestions,
  ) {
    return _FormPanel(
      title: 'Danh sách sản phẩm',
      icon: Icons.inventory_2_outlined,
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            onPressed: () => _productSearchFocusNode.requestFocus(),
            tooltip: 'Thêm sản phẩm',
            icon: const Icon(Icons.add_circle_outline_rounded),
          ),
          IconButton(
            onPressed: _openBarcodeScanner,
            tooltip: 'Quét mã vạch',
            icon: const Icon(Icons.qr_code_scanner_rounded),
          ),
        ],
      ),
      children: [
        TextFormField(
          controller: _productSearchController,
          focusNode: _productSearchFocusNode,
          decoration: const InputDecoration(
            labelText: 'Tìm sản phẩm theo tên, mã sản phẩm hoặc mã vạch',
            prefixIcon: Icon(Icons.search_rounded),
          ),
          onChanged: (_) => setState(() {}),
        ),
        if (suggestions.isNotEmpty) ...[
          const SizedBox(height: 8),
          _ProductSuggestList(products: suggestions, onSelected: _addProduct),
        ],
        if (_lines.isEmpty) ...[
          const SizedBox(height: 12),
          const _InlineMessage(message: 'Chưa có sản phẩm nào trong phiếu.'),
        ],
        for (final (index, line) in _lines.indexed) ...[
          const SizedBox(height: 12),
          _ReceiptProductCard(
            line: line,
            onChanged: () => setState(() {}),
            onRemove: () => _removeLine(line),
            title: 'Sản phẩm ${index + 1}',
          ),
        ],
      ],
    );
  }

  Widget _buildPaymentSection(BuildContext context) {
    final totalAmount = _totalAmount;
    final paidAmount = _readMoney(_paidAmountController.text);
    final debtAmount = (totalAmount - paidAmount)
        .clamp(0, double.infinity)
        .toDouble();

    return _FormPanel(
      title: 'Thanh toán',
      icon: Icons.payments_outlined,
      children: [
        Row(
          children: [
            Expanded(
              child: _AmountSummary(
                label: 'Tổng tiền hàng',
                value: _formatCurrency(totalAmount),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _AmountSummary(
                label: 'Còn nợ',
                value: _formatCurrency(debtAmount),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: _paidAmountController,
          decoration: const InputDecoration(labelText: 'Đã thanh toán'),
          keyboardType: TextInputType.number,
          onChanged: (_) => setState(() {}),
          validator: _moneyValidator,
        ),
      ],
    );
  }

  Widget _buildNoteSection(BuildContext context) {
    return _FormPanel(
      title: 'Ghi chú',
      icon: Icons.notes_outlined,
      children: [
        TextFormField(
          controller: _noteController,
          minLines: 3,
          maxLines: 5,
          decoration: const InputDecoration(hintText: 'Ghi chú cho phiếu nhập'),
        ),
      ],
    );
  }

  Widget _buildActionBar(BuildContext context, EmployeeUser? currentUser) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        border: Border(top: BorderSide(color: AppColors.borderGray)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.primary,
                    minimumSize: const Size(0, 48),
                    side: const BorderSide(color: AppColors.primary),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text('Hủy'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: FilledButton.icon(
                  onPressed: () => _submit(context, currentUser),
                  icon: const Icon(Icons.check_rounded),
                  label: const Text('Tạo phiếu'),
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: AppColors.surfaceContainerLowest,
                    minimumSize: const Size(0, 48),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<Supplier> _filterSuppliers(List<Supplier> suppliers) {
    final query = _supplierSearchController.text.trim().toLowerCase();
    if (query.isEmpty) return suppliers.take(3).toList(growable: false);

    return suppliers
        .where((supplier) {
          return supplier.supplierName.toLowerCase().contains(query) ||
              supplier.supplierCode.toLowerCase().contains(query) ||
              supplier.phoneNumber.toLowerCase().contains(query);
        })
        .take(5)
        .toList(growable: false);
  }

  List<ProductLookup> _filterProducts(List<ProductLookup> products) {
    final query = _productSearchController.text.trim().toLowerCase();
    if (query.isEmpty) return const [];

    return products
        .where((product) {
          return product.productName.toLowerCase().contains(query) ||
              product.productCode.toLowerCase().contains(query) ||
              product.barcode.toLowerCase().contains(query);
        })
        .take(5)
        .toList(growable: false);
  }

  void _selectSupplier(Supplier supplier) {
    setState(() {
      _selectedSupplier = supplier;
      _supplierSearchController.text = supplier.supplierName;
    });
  }

  void _addProduct(ProductLookup product) {
    if (_lines.any((line) => line.product.productId == product.productId)) {
      _productSearchController.clear();
      setState(() {});
      return;
    }

    setState(() {
      _lines.add(_ReceiptProductDraft(product));
      _productSearchController.clear();
    });
  }

  void _removeLine(_ReceiptProductDraft line) {
    setState(() {
      _lines.remove(line);
      line.dispose();
    });
  }

  Future<void> _openBarcodeScanner() async {
    final scannedList = await Navigator.of(context).push<List<ScannedProduct>>(
      MaterialPageRoute(builder: (_) => const BarcodeScannerScreen()),
    );
    if (scannedList == null || scannedList.isEmpty) return;

    setState(() {
      for (final entry in scannedList) {
        if (_lines.any((l) => l.product.productId == entry.product.productId)) {
          continue;
        }
        final draft = _ReceiptProductDraft(entry.product);
        draft.quantityController.text = entry.quantity.toString();
        _lines.add(draft);
      }
    });
  }

  void _submit(BuildContext context, EmployeeUser? currentUser) {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    if (currentUser == null) {
      _showActionSnackBar(context, 'Không xác định được nhân viên thực hiện.');
      return;
    }
    if (_selectedSupplier == null) {
      _showActionSnackBar(context, 'Vui lòng chọn nhà cung cấp.');
      return;
    }
    if (_lines.isEmpty) {
      _showActionSnackBar(context, 'Vui lòng thêm ít nhất một sản phẩm.');
      return;
    }
    if (_lines.any((line) => !line.manufactureDate.isBefore(line.expiryDate))) {
      _showActionSnackBar(context, 'Ngày sản xuất phải trước hạn sử dụng.');
      return;
    }

    final totalAmount = _totalAmount;
    final paidAmount = _readMoney(_paidAmountController.text);
    final receipt = CreateReceipt(
      receiptCode: '',
      importDate: DateTime.now(),
      totalAmount: totalAmount,
      paidAmount: paidAmount,
      debtAmount: (totalAmount - paidAmount).clamp(0, double.infinity),
      receiptStatus: ReceiptStatus.pending,
      note: _noteController.text.trim().isEmpty
          ? null
          : _noteController.text.trim(),
      supplierId: _selectedSupplier!.supplierId,
      employeeId: currentUser.employeeId,
      batchLines: _lines.map((line) => line.toReceiptBatchLine()).toList(),
    );

    Navigator.of(context).pop(receipt);
  }

  double get _totalAmount {
    return _lines.fold(0, (total, line) => total + line.lineTotal);
  }

  static String? _moneyValidator(String? value) {
    final parsed = _readMoney(value ?? '');
    if (parsed < 0) return 'Nhập số tiền hợp lệ';
    return null;
  }

  static double _readMoney(String value) {
    return double.tryParse(
          value.trim().replaceAll('.', '').replaceAll(',', ''),
        ) ??
        0;
  }

  static String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  static String _formatDateTime(DateTime date) {
    return '${_formatDate(date)} '
        '${date.hour.toString().padLeft(2, '0')}:'
        '${date.minute.toString().padLeft(2, '0')}';
  }

  static String _formatCurrency(double value) {
    final roundedValue = value.round().toString();
    final buffer = StringBuffer();
    for (var index = 0; index < roundedValue.length; index++) {
      final remaining = roundedValue.length - index;
      buffer.write(roundedValue[index]);
      if (remaining > 1 && remaining % 3 == 1) {
        buffer.write('.');
      }
    }
    return '$bufferđ';
  }

  void _showActionSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }
}

class _FormPanel extends StatelessWidget {
  const _FormPanel({
    required this.title,
    required this.icon,
    required this.children,
    this.trailing,
  });

  final String title;
  final IconData icon;
  final List<Widget> children;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        border: Border.all(color: AppColors.borderGray),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: AppColors.primary, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    title,
                    style: textTheme.titleSmall?.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                if (trailing != null) trailing!,
              ],
            ),
            const SizedBox(height: 12),
            ...children,
          ],
        ),
      ),
    );
  }
}

class _ReadOnlyField extends StatelessWidget {
  const _ReadOnlyField({
    required this.label,
    required this.value,
    this.icon,
    this.accentColor,
  });

  final String label;
  final String value;
  final IconData? icon;
  final Color? accentColor;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final color = accentColor ?? AppColors.textMuted;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: textTheme.labelSmall?.copyWith(
            color: AppColors.textMuted,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 6),
        DecoratedBox(
          decoration: BoxDecoration(
            color: AppColors.surfaceContainerLow,
            border: Border.all(color: AppColors.borderGray),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    value,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: textTheme.bodyMedium?.copyWith(
                      color: color,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                if (icon != null) ...[
                  const SizedBox(width: 8),
                  Icon(icon, size: 18, color: color),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _SupplierSuggestList extends StatelessWidget {
  const _SupplierSuggestList({
    required this.suppliers,
    required this.selectedSupplier,
    required this.onSelected,
  });

  final List<Supplier> suppliers;
  final Supplier? selectedSupplier;
  final ValueChanged<Supplier> onSelected;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        border: Border.all(color: AppColors.borderGray),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          for (final (index, supplier) in suppliers.indexed) ...[
            if (index > 0)
              const Divider(height: 1, color: AppColors.borderGray),
            ListTile(
              dense: true,
              leading: const Icon(
                Icons.storefront_outlined,
                color: AppColors.secondary,
              ),
              title: Text(supplier.supplierName),
              subtitle: Text(
                '${supplier.supplierCode} • ${supplier.phoneNumber}',
              ),
              trailing: selectedSupplier?.supplierId == supplier.supplierId
                  ? const Icon(Icons.check_circle, color: AppColors.secondary)
                  : null,
              onTap: () => onSelected(supplier),
            ),
          ],
        ],
      ),
    );
  }
}

class _SelectedSupplierBanner extends StatelessWidget {
  const _SelectedSupplierBanner({required this.supplier});

  final Supplier supplier;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.secondaryFixed.withValues(alpha: 0.28),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Row(
          children: [
            const Icon(Icons.verified_rounded, color: AppColors.secondary),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                'Đã chọn: ${supplier.supplierName}',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.secondary,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProductSuggestList extends StatelessWidget {
  const _ProductSuggestList({required this.products, required this.onSelected});

  final List<ProductLookup> products;
  final ValueChanged<ProductLookup> onSelected;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        border: Border.all(color: AppColors.borderGray),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          for (final (index, product) in products.indexed) ...[
            if (index > 0)
              const Divider(height: 1, color: AppColors.borderGray),
            ListTile(
              dense: true,
              leading: const Icon(
                Icons.inventory_2_outlined,
                color: AppColors.secondary,
              ),
              title: Text(product.productName),
              subtitle: Text('${product.productCode} • ${product.barcode}'),
              trailing: const Icon(Icons.add_rounded),
              onTap: () => onSelected(product),
            ),
          ],
        ],
      ),
    );
  }
}

class _ReceiptProductCard extends StatelessWidget {
  const _ReceiptProductCard({
    required this.line,
    required this.onChanged,
    required this.onRemove,
    required this.title,
  });

  final _ReceiptProductDraft line;
  final VoidCallback onChanged;
  final VoidCallback onRemove;
  final String title;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final invalidDates = !line.manufactureDate.isBefore(line.expiryDate);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        border: Border.all(color: AppColors.borderGray),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        line.product.productName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: textTheme.bodyMedium?.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${line.product.productCode} • ${line.product.barcode}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: textTheme.labelSmall?.copyWith(
                          color: AppColors.textMuted,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: onRemove,
                  tooltip: 'Xóa sản phẩm',
                  icon: const Icon(Icons.delete_outline_rounded),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: line.quantityController,
                    decoration: const InputDecoration(labelText: 'Số lượng'),
                    keyboardType: TextInputType.number,
                    onChanged: (_) => onChanged(),
                    validator: _positiveIntValidator,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    controller: line.importPriceController,
                    decoration: const InputDecoration(labelText: 'Giá nhập'),
                    keyboardType: TextInputType.number,
                    onChanged: (_) => onChanged(),
                    validator: _moneyValidator,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _AmountSummary(
                    label: 'Đơn giá',
                    value: _CreateInventoryReceiptScreenState._formatCurrency(
                      line.product.sellingPrice,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _AmountSummary(
                    label: 'Thành tiền',
                    value: _CreateInventoryReceiptScreenState._formatCurrency(
                      line.lineTotal,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _DateField(
                    label: 'Ngày sản xuất',
                    date: line.manufactureDate,
                    onTap: () => line.pickManufactureDate(context, onChanged),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _DateField(
                    label: 'Hạn sử dụng',
                    date: line.expiryDate,
                    onTap: () => line.pickExpiryDate(context, onChanged),
                  ),
                ),
              ],
            ),
            if (invalidDates) ...[
              const SizedBox(height: 8),
              Text(
                'Ngày sản xuất phải trước hạn sử dụng',
                style: textTheme.labelSmall?.copyWith(
                  color: AppColors.statusError,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  static String? _positiveIntValidator(String? value) {
    final parsed = int.tryParse(value?.trim() ?? '');
    if (parsed == null || parsed <= 0) return 'Nhập số lớn hơn 0';
    return null;
  }

  static String? _moneyValidator(String? value) {
    final parsed = _CreateInventoryReceiptScreenState._readMoney(value ?? '');
    if (parsed <= 0) return 'Nhập số tiền lớn hơn 0';
    return null;
  }
}

class _DateField extends StatelessWidget {
  const _DateField({
    required this.label,
    required this.date,
    required this.onTap,
  });

  final String label;
  final DateTime date;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          suffixIcon: const Icon(Icons.event_outlined),
        ),
        child: Text(_CreateInventoryReceiptScreenState._formatDate(date)),
      ),
    );
  }
}

class _AmountSummary extends StatelessWidget {
  const _AmountSummary({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: textTheme.labelSmall?.copyWith(
                color: AppColors.textMuted,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: textTheme.titleSmall?.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InlineMessage extends StatelessWidget {
  const _InlineMessage({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            const Icon(Icons.info_outline_rounded, color: AppColors.textMuted),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                message,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.textMuted,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ReceiptProductDraft {
  _ReceiptProductDraft(this.product)
    : manufactureDate = DateTime.now(),
      expiryDate = DateTime.now().add(const Duration(days: 180)),
      importPriceController = TextEditingController(
        text: product.sellingPrice.round().toString(),
      );

  final ProductLookup product;
  final quantityController = TextEditingController(text: '1');
  final TextEditingController importPriceController;
  DateTime manufactureDate;
  DateTime expiryDate;

  double get lineTotal {
    final quantity = int.tryParse(quantityController.text.trim()) ?? 0;
    final importPrice = _CreateInventoryReceiptScreenState._readMoney(
      importPriceController.text,
    );
    return quantity * importPrice;
  }

  ReceiptBatchLine toReceiptBatchLine() {
    return ReceiptBatchLine(
      productId: product.productId,
      barcode: product.barcode,
      batchCode:
          'LOT-${product.productCode}-${DateTime.now().millisecondsSinceEpoch}',
      manufactureDate: manufactureDate,
      expiryDate: expiryDate,
      importPrice: _CreateInventoryReceiptScreenState._readMoney(
        importPriceController.text,
      ),
      quantity: int.parse(quantityController.text.trim()),
    );
  }

  Future<void> pickManufactureDate(
    BuildContext context,
    VoidCallback onChanged,
  ) async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: manufactureDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (pickedDate == null) return;
    manufactureDate = pickedDate;
    onChanged();
  }

  Future<void> pickExpiryDate(
    BuildContext context,
    VoidCallback onChanged,
  ) async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: expiryDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (pickedDate == null) return;
    expiryDate = pickedDate;
    onChanged();
  }

  void dispose() {
    quantityController.dispose();
    importPriceController.dispose();
  }
}
