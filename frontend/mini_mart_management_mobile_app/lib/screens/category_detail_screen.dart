import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mini_mart_management_mobile_app/models/category.dart'
    as product_category;
import 'package:mini_mart_management_mobile_app/providers/category_provider.dart';
import 'package:mini_mart_management_mobile_app/theme/app_colors.dart';
import 'package:mini_mart_management_mobile_app/widgets/feedback/loading_overlay.dart';

class CategoryDetailScreen extends StatefulWidget {
  const CategoryDetailScreen({this.categoryId, super.key});

  final int? categoryId;

  @override
  State<CategoryDetailScreen> createState() => _CategoryDetailScreenState();
}

class _CategoryDetailScreenState extends State<CategoryDetailScreen> {
  final _formKey = GlobalKey<FormState>();
  late final _codeCtrl = TextEditingController();
  late final _nameCtrl = TextEditingController();
  late final _descCtrl = TextEditingController();
  late final _orderCtrl = TextEditingController(text: '1');
  late final _parentCtrl = TextEditingController();
  late final _taxCtrl = TextEditingController(text: '4');
  bool _status = true;
  bool _isLoading = false;
  bool _isSaving = false;

  bool get _isNew => widget.categoryId == null;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (_isNew) return;
      setState(() => _isLoading = true);
      final provider = context.read<CategoryProvider>();
      if (provider.categories.isEmpty) {
        await provider.fetchAll();
      }
      product_category.Category? found;
      for (final category in provider.categories) {
        if (category.categoryId == widget.categoryId) {
          found = category;
          break;
        }
      }
      if (!mounted) return;
      _fillFields(found);
      setState(() => _isLoading = false);
    });
  }

  @override
  void dispose() {
    _codeCtrl.dispose();
    _nameCtrl.dispose();
    _descCtrl.dispose();
    _orderCtrl.dispose();
    _parentCtrl.dispose();
    _taxCtrl.dispose();
    super.dispose();
  }

  void _fillFields(product_category.Category? category) {
    _codeCtrl.text = category?.categoryCode ?? '';
    _nameCtrl.text = category?.categoryName ?? '';
    _descCtrl.text = category?.description ?? '';
    _orderCtrl.text = (category?.displayOrder ?? 1).toString();
    _parentCtrl.text = category?.parentCategoryId?.toString() ?? '';
    _taxCtrl.text = (category?.taxRateId ?? 4).toString();
    _status = category?.status ?? true;
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);
    final data = {
      'categoryCode': _codeCtrl.text.trim(),
      'categoryName': _nameCtrl.text.trim(),
      'description': _descCtrl.text.trim().isEmpty
          ? null
          : _descCtrl.text.trim(),
      'displayOrder': int.tryParse(_orderCtrl.text.trim()) ?? 1,
      'parentCategoryId': _parentCtrl.text.trim().isEmpty
          ? null
          : int.tryParse(_parentCtrl.text.trim()),
      'taxRateId': int.tryParse(_taxCtrl.text.trim()) ?? 4,
      'status': _status,
    };
    final provider = context.read<CategoryProvider>();
    final error = _isNew
        ? await provider.create(data)
        : await provider.update(widget.categoryId!, data);
    if (!mounted) return;
    setState(() => _isSaving = false);
    if (error == null) {
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(error)));
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: SafeArea(child: LoadingOverlay()));
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(_isNew ? 'Thêm Danh Mục' : 'Chi tiết Danh Mục'),
        backgroundColor: AppColors.surfaceContainerLowest,
        foregroundColor: AppColors.primary,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _field(_codeCtrl, 'Mã danh mục'),
                const SizedBox(height: 12),
                _field(_nameCtrl, 'Tên danh mục'),
                const SizedBox(height: 12),
                _field(_descCtrl, 'Mô tả', maxLines: 3),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(child: _field(_orderCtrl, 'Thứ tự', number: true)),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _field(_taxCtrl, 'Tax Rate ID', number: true),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                _field(_parentCtrl, 'Parent Category ID', number: true),
                const SizedBox(height: 4),
                _parentLookup(context),
                const SizedBox(height: 12),
                SwitchListTile(
                  value: _status,
                  onChanged: (value) => setState(() => _status = value),
                  title: const Text('Đang hoạt động'),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: _isSaving ? null : _save,
                    icon: _isSaving
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Icon(Icons.save_rounded),
                    label: const Text('Lưu'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _field(
    TextEditingController controller,
    String label, {
    int maxLines = 1,
    bool number = false,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: number ? TextInputType.number : TextInputType.text,
      decoration: InputDecoration(labelText: label),
      validator: (value) {
        if (label == 'Mô tả') return null;
        if (value == null || value.trim().isEmpty) return 'Không được trống';
        return null;
      },
    );
  }

  Widget _parentLookup(BuildContext context) {
    final id = int.tryParse(_parentCtrl.text.trim());
    if (id == null) return const SizedBox.shrink();
    final categories = context.watch<CategoryProvider>().categories;
    for (final category in categories) {
      if (category.categoryId == id) {
        return Align(
          alignment: Alignment.centerLeft,
          child: Text(
            'Danh mục cha: ${category.categoryName}',
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: AppColors.textMuted,
              fontStyle: FontStyle.italic,
            ),
          ),
        );
      }
    }
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        'Danh mục cha chưa tìm thấy',
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          color: AppColors.textMuted,
          fontStyle: FontStyle.italic,
        ),
      ),
    );
  }
}
