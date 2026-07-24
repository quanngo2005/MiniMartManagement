import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:mini_mart_management_mobile_app/models/product.dart';
import 'package:mini_mart_management_mobile_app/providers/category_provider.dart';
import 'package:mini_mart_management_mobile_app/providers/product_provider.dart';
import 'package:mini_mart_management_mobile_app/providers/supplier_provider.dart';
import 'package:mini_mart_management_mobile_app/theme/app_colors.dart';

class ProductDetailScreen extends StatefulWidget {
  const ProductDetailScreen({this.product, super.key});

  final Product? product;

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  final _formKey = GlobalKey<FormState>();

  late final _codeCtrl = TextEditingController(
    text: widget.product?.productCode ?? '',
  );
  late final _barcodeCtrl = TextEditingController(
    text: widget.product?.barcode ?? '',
  );
  late final _nameCtrl = TextEditingController(
    text: widget.product?.productName ?? '',
  );
  late final _priceCtrl = TextEditingController(
    text: widget.product != null
        ? widget.product!.sellingPrice.toInt().toString()
        : '',
  );
  late final _stockCtrl = TextEditingController(
    text: widget.product?.stockQuantity.toString() ?? '0',
  );
  late final _minStockCtrl = TextEditingController(
    text: widget.product?.minimumStock.toString() ?? '0',
  );
  late final _descCtrl = TextEditingController(
    text: widget.product?.description ?? '',
  );
  late final _imageUrlCtrl = TextEditingController(
    text: widget.product?.imageUrl ?? '',
  );
  late final _categoryCtrl = TextEditingController(
    text: widget.product?.categoryId?.toString() ?? '',
  );
  late final _supplierCtrl = TextEditingController(
    text: widget.product?.supplierId?.toString() ?? '',
  );

  late bool _status;
  bool _isEditing = false;
  bool _isSaving = false;

  bool get _isNew => widget.product == null;

  @override
  void initState() {
    super.initState();
    _status = widget.product?.status ?? true;
    _isEditing = _isNew;
    _imageUrlCtrl.addListener(() {
      if (mounted) setState(() {});
    });
    _categoryCtrl.addListener(() {
      if (mounted) setState(() {});
    });
    _supplierCtrl.addListener(() {
      if (mounted) setState(() {});
    });
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;
      final categoryProvider = context.read<CategoryProvider>();
      final supplierProvider = context.read<SupplierProvider>();
      if (categoryProvider.categories.isEmpty) {
        await categoryProvider.fetchAll();
      }
      if (supplierProvider.suppliers.isEmpty) {
        await supplierProvider.fetchSuppliers();
      }
    });
  }

  @override
  void dispose() {
    _codeCtrl.dispose();
    _barcodeCtrl.dispose();
    _nameCtrl.dispose();
    _priceCtrl.dispose();
    _stockCtrl.dispose();
    _minStockCtrl.dispose();
    _descCtrl.dispose();
    _imageUrlCtrl.dispose();
    _categoryCtrl.dispose();
    _supplierCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);

    final data = {
      'productCode': _codeCtrl.text.trim(),
      'barcode': _barcodeCtrl.text.trim(),
      'productName': _nameCtrl.text.trim(),
      'sellingPrice': double.tryParse(_priceCtrl.text) ?? 0,
      'stockQuantity': int.tryParse(_stockCtrl.text) ?? 0,
      'minimumStock': int.tryParse(_minStockCtrl.text) ?? 0,
      'description': _descCtrl.text.trim().isEmpty
          ? null
          : _descCtrl.text.trim(),
      'imageUrl': _imageUrlCtrl.text.trim().isEmpty
          ? null
          : _imageUrlCtrl.text.trim(),
      'status': _status,
      'categoryId': int.tryParse(_categoryCtrl.text) ?? 0,
      'supplierId': int.tryParse(_supplierCtrl.text) ?? 0,
    };

    final provider = context.read<ProductProvider>();
    final ok = _isNew
        ? await provider.create(data)
        : await provider.update(widget.product!.productId, data);

    if (!mounted) return;
    setState(() => _isSaving = false);

    if (ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _isNew ? 'Đã tạo sản phẩm thành công.' : 'Đã cập nhật sản phẩm.',
          ),
          backgroundColor: AppColors.secondary,
        ),
      );
      if (_isNew) {
        Navigator.pop(context);
      } else {
        setState(() => _isEditing = false);
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(provider.error ?? 'Đã xảy ra lỗi.'),
          backgroundColor: AppColors.statusError,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundSlate,
      appBar: _buildAppBar(context),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (!_isNew) _buildStatusBadge(),
                if (!_isNew) const SizedBox(height: 16),
                _buildSection('Thông tin cơ bản', [
                  _field(_nameCtrl, 'Tên sản phẩm *', validator: _req),
                  _field(_codeCtrl, 'Mã SKU *', validator: _req),
                  _field(_barcodeCtrl, 'Barcode *', validator: _req),
                ]),
                const SizedBox(height: 16),
                _buildSection('Giá & Kho', [
                  _field(
                    _priceCtrl,
                    'Giá bán (VND) *',
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    validator: _req,
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: _field(
                          _stockCtrl,
                          'Tồn kho',
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _field(
                          _minStockCtrl,
                          'Tồn kho tối thiểu',
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                          ],
                        ),
                      ),
                    ],
                  ),
                ]),
                const SizedBox(height: 16),
                _buildSection('Danh mục & NCC', [
                  _categorySelector(context),
                  _supplierSelector(context),
                ]),
                const SizedBox(height: 16),
                _buildSection('Mô tả', [
                  _field(_descCtrl, 'Mô tả sản phẩm', maxLines: 3),
                  _field(_imageUrlCtrl, 'Image URL', validator: null),
                  if (_imageUrlCtrl.text.trim().isNotEmpty)
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.network(
                        _imageUrlCtrl.text.trim(),
                        height: 160,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (_, _, _) => Container(
                          height: 160,
                          width: double.infinity,
                          color: AppColors.surfaceContainerHigh,
                          alignment: Alignment.center,
                          child: const Icon(Icons.broken_image_outlined),
                        ),
                      ),
                    ),
                ]),
                if (_isEditing) ...[
                  const SizedBox(height: 16),
                  _buildStatusToggle(),
                  const SizedBox(height: 24),
                  _buildSaveButton(),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: AppColors.surfaceContainerLowest,
      foregroundColor: AppColors.primary,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_rounded),
        onPressed: () => Navigator.pop(context),
      ),
      title: Text(
        _isNew ? 'Thêm sản phẩm' : 'Chi tiết sản phẩm',
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
          color: AppColors.primary,
          fontWeight: FontWeight.w800,
        ),
      ),
      actions: [
        if (!_isNew && !_isEditing)
          IconButton(
            icon: const Icon(Icons.edit_rounded),
            onPressed: () => setState(() => _isEditing = true),
            tooltip: 'Chỉnh sửa',
          ),
        if (_isEditing && !_isNew)
          TextButton(
            onPressed: () => setState(() => _isEditing = false),
            child: const Text('Huỷ'),
          ),
      ],
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Container(color: AppColors.borderGray, height: 1),
      ),
    );
  }

  Widget _buildStatusBadge() {
    final active = widget.product!.status;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: active
            ? AppColors.secondaryFixed.withValues(alpha: 0.4)
            : AppColors.errorContainer,
        borderRadius: BorderRadius.circular(99),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            active ? Icons.check_circle_rounded : Icons.cancel_rounded,
            size: 14,
            color: active ? AppColors.secondary : AppColors.statusError,
          ),
          const SizedBox(width: 4),
          Text(
            active ? 'Đang kinh doanh' : 'Ngừng kinh doanh',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: active ? AppColors.secondary : AppColors.statusError,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection(String title, List<Widget> children) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderGray),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                color: AppColors.textMuted,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 12),
            ...children.expand((w) => [w, const SizedBox(height: 12)]).toList()
              ..removeLast(),
          ],
        ),
      ),
    );
  }

  Widget _field(
    TextEditingController ctrl,
    String label, {
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
    String? Function(String?)? validator,
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: ctrl,
      enabled: _isEditing,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      maxLines: maxLines,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        filled: !_isEditing,
        fillColor: _isEditing ? null : AppColors.surfaceContainerLow,
      ),
    );
  }

  Widget _categorySelector(BuildContext context) {
    final categories = context.watch<CategoryProvider>().categories;
    final currentId = int.tryParse(_categoryCtrl.text.trim());

    return DropdownButtonFormField<int>(
      initialValue: categories.any((item) => item.categoryId == currentId)
          ? currentId
          : null,
      decoration: InputDecoration(
        labelText: 'Danh mục *',
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        filled: !_isEditing,
        fillColor: _isEditing ? null : AppColors.surfaceContainerLow,
      ),
      items: categories
          .map(
            (category) => DropdownMenuItem<int>(
              value: category.categoryId,
              child: Text(category.categoryName),
            ),
          )
          .toList(),
      onChanged: _isEditing
          ? (value) => setState(() {
              _categoryCtrl.text = value?.toString() ?? '';
            })
          : null,
      validator: (value) => value == null ? 'Chọn danh mục' : null,
    );
  }

  Widget _supplierSelector(BuildContext context) {
    final suppliers = context.watch<SupplierProvider>().suppliers;
    final currentId = int.tryParse(_supplierCtrl.text.trim());

    return DropdownButtonFormField<int>(
      initialValue: suppliers.any((item) => item.supplierId == currentId)
          ? currentId
          : null,
      decoration: InputDecoration(
        labelText: 'Nhà cung cấp *',
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        filled: !_isEditing,
        fillColor: _isEditing ? null : AppColors.surfaceContainerLow,
      ),
      items: suppliers
          .map(
            (supplier) => DropdownMenuItem<int>(
              value: supplier.supplierId,
              child: Text(supplier.supplierName),
            ),
          )
          .toList(),
      onChanged: _isEditing
          ? (value) => setState(() {
              _supplierCtrl.text = value?.toString() ?? '';
            })
          : null,
      validator: (value) => value == null ? 'Chọn nhà cung cấp' : null,
    );
  }

  Widget _buildStatusToggle() {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderGray),
      ),
      child: SwitchListTile(
        title: const Text(
          'Đang kinh doanh',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.primary,
          ),
        ),
        subtitle: Text(
          _status
              ? 'Sản phẩm hiển thị và có thể bán'
              : 'Sản phẩm ẩn khỏi bán hàng',
          style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
        ),
        value: _status,
        onChanged: (v) => setState(() => _status = v),
        activeThumbColor: AppColors.secondary,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  Widget _buildSaveButton() {
    return SizedBox(
      width: double.infinity,
      child: FilledButton.icon(
        onPressed: _isSaving ? null : _save,
        icon: _isSaving
            ? const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              )
            : const Icon(Icons.save_rounded),
        label: Text(_isNew ? 'Tạo sản phẩm' : 'Lưu thay đổi'),
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.surfaceContainerLowest,
          minimumSize: const Size(0, 52),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ),
    );
  }

  String? _req(String? v) =>
      (v == null || v.trim().isEmpty) ? 'Trường này không được trống' : null;
}
