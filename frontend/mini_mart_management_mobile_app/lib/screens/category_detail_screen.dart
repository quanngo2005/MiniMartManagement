import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:mini_mart_management_mobile_app/config/api_config.dart';
import 'package:mini_mart_management_mobile_app/models/category.dart';
import 'package:mini_mart_management_mobile_app/models/tax_rate.dart';
import 'package:mini_mart_management_mobile_app/providers/category_provider.dart';
import 'package:mini_mart_management_mobile_app/services/http_client_factory.dart';
import 'package:mini_mart_management_mobile_app/widgets/feedback/loading_overlay.dart';
import 'package:mini_mart_management_mobile_app/widgets/layout/mini_mart_app_bar.dart';
import 'package:provider/provider.dart';

class CategoryDetailScreen extends StatefulWidget {
  const CategoryDetailScreen({this.categoryId, super.key});

  final int? categoryId;

  @override
  State<CategoryDetailScreen> createState() => _CategoryDetailScreenState();
}

class _CategoryDetailScreenState extends State<CategoryDetailScreen> {
  final _formKey = GlobalKey<FormState>();
  final _codeController = TextEditingController();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _orderController = TextEditingController(text: '0');

  bool _loading = true;
  bool _saving = false;
  bool _status = true;
  int? _parentCategoryId;
  int? _taxRateId;
  List<TaxRate> _taxRates = [];

  bool get _isNew => widget.categoryId == null;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  @override
  void dispose() {
    _codeController.dispose();
    _nameController.dispose();
    _descriptionController.dispose();
    _orderController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    await _fetchTaxRates();

    final provider = context.read<CategoryProvider>();
    if (provider.categories.isEmpty) await provider.fetchAll();
    if (!mounted) return;

    Category? category;
    for (final item in provider.categories) {
      if (item.categoryId == widget.categoryId) category = item;
    }
    if (!_isNew && category == null) {
      Navigator.pop(context);
      return;
    }
    if (category != null) {
      _codeController.text = category.categoryCode;
      _nameController.text = category.categoryName;
      _descriptionController.text = category.description ?? '';
      _orderController.text = category.displayOrder.toString();
      _parentCategoryId = category.parentCategoryId;
      _taxRateId = category.taxRateId;
      _status = category.status;
    }
    if (_taxRateId == null && _taxRates.isNotEmpty) {
      _taxRateId = _taxRates.first.taxRateId;
    }
    setState(() => _loading = false);
  }

  Future<void> _fetchTaxRates() async {
    try {
      final client = createConfiguredClient();
      final response = await client.get(
        ApiConfig.uri('/api/taxrates'),
        headers: {'Accept': 'application/json'},
      );
      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        List list = decoded is List ? decoded : (decoded['data'] ?? decoded['Data'] ?? []);
        _taxRates = list
            .whereType<Map<String, dynamic>>()
            .map(TaxRate.fromJson)
            .toList();
      }
    } catch (_) {}
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    final data = <String, dynamic>{
      'categoryCode': _codeController.text.trim(),
      'categoryName': _nameController.text.trim(),
      'description': _descriptionController.text.trim().isEmpty
          ? null
          : _descriptionController.text.trim(),
      'displayOrder': int.tryParse(_orderController.text.trim()) ?? 0,
      'parentCategoryId': _parentCategoryId,
      'taxRateId': _taxRateId,
      'status': _status,
    };
    final provider = context.read<CategoryProvider>();
    final error = _isNew
        ? await provider.create(data)
        : await provider.update(widget.categoryId!, data);
    if (!mounted) return;
    setState(() => _saving = false);
    if (error == null) {
      Navigator.pop(context, true);
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MiniMartAppBar.secondary(
        title: _isNew ? 'Thêm danh mục' : 'Chỉnh sửa danh mục',
      ),
      body: SafeArea(
        child: _loading
            ? const LoadingOverlay()
            : Form(
                key: _formKey,
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
                  children: [
                    _textField(
                      controller: _codeController,
                      label: 'Mã danh mục',
                      hint: 'Ví dụ: RAU_CU',
                    ),
                    const SizedBox(height: 12),
                    _textField(
                      controller: _nameController,
                      label: 'Tên danh mục',
                      hint: 'Ví dụ: Rau củ',
                    ),
                    const SizedBox(height: 12),
                    _textField(
                      controller: _descriptionController,
                      label: 'Mô tả',
                      required: false,
                      maxLines: 3,
                    ),
                    const SizedBox(height: 12),
                    _buildParentField(context),
                    const SizedBox(height: 12),
                    _buildTaxRateField(),
                    const SizedBox(height: 12),
                    _textField(
                      controller: _orderController,
                      label: 'Thứ tự hiển thị',
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 8),
                    SwitchListTile.adaptive(
                      contentPadding: EdgeInsets.zero,
                      value: _status,
                      onChanged: (value) => setState(() => _status = value),
                      title: const Text('Đang hoạt động'),
                    ),
                    const SizedBox(height: 20),
                    FilledButton.icon(
                      onPressed: _saving ? null : _save,
                      icon: _saving
                          ? const SizedBox.square(
                              dimension: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Icon(Icons.save_outlined),
                      label: Text(_saving ? 'Đang lưu...' : 'Lưu danh mục'),
                    ),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildTaxRateField() {
    return DropdownButtonFormField<int>(
      initialValue: _taxRates.any((t) => t.taxRateId == _taxRateId) ? _taxRateId : null,
      decoration: const InputDecoration(labelText: 'Thuế suất *'),
      items: [
        for (final tax in _taxRates)
          DropdownMenuItem<int>(
            value: tax.taxRateId,
            child: Text('${tax.rate.toInt()}% — ${tax.description}'),
          ),
      ],
      onChanged: (value) => setState(() => _taxRateId = value),
      validator: (value) => value == null ? 'Chọn thuế suất' : null,
    );
  }

  Widget _buildParentField(BuildContext context) {
    final categories = context
        .watch<CategoryProvider>()
        .categories
        .where((item) => item.categoryId != widget.categoryId)
        .toList();
    return DropdownButtonFormField<int?>(
      initialValue:
          categories.any((item) => item.categoryId == _parentCategoryId)
          ? _parentCategoryId
          : null,
      decoration: const InputDecoration(labelText: 'Danh mục cha'),
      items: [
        const DropdownMenuItem<int?>(value: null, child: Text('Không có')),
        for (final category in categories)
          DropdownMenuItem<int?>(
            value: category.categoryId,
            child: Text(category.categoryName),
          ),
      ],
      onChanged: (value) => setState(() => _parentCategoryId = value),
    );
  }

  Widget _textField({
    required TextEditingController controller,
    required String label,
    String? hint,
    bool required = true,
    int maxLines = 1,
    TextInputType? keyboardType,
    ValueChanged<String>? onChanged,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      onChanged: onChanged,
      decoration: InputDecoration(labelText: label, hintText: hint),
      validator: required
          ? (value) => value == null || value.trim().isEmpty
                ? 'Không được để trống'
                : null
          : null,
    );
  }
}
