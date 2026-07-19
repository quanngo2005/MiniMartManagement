import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mini_mart_management_mobile_app/models/category.dart';
import 'package:mini_mart_management_mobile_app/models/tax_rate.dart';
import 'package:mini_mart_management_mobile_app/providers/category_provider.dart';
import 'package:mini_mart_management_mobile_app/repositories/category_repository.dart';
import 'package:mini_mart_management_mobile_app/services/category_service.dart';
import 'package:mini_mart_management_mobile_app/theme/app_colors.dart';

class CategoryManagementScreen extends StatelessWidget {
  const CategoryManagementScreen({this.onMenuTap, super.key});

  final VoidCallback? onMenuTap;

  static Widget withProvider({VoidCallback? onMenuTap}) {
    return ChangeNotifierProvider(
      create: (_) => CategoryProvider(
        CategoryRepository(CategoryService()),
      )..fetchAll(),
      child: CategoryManagementScreen(onMenuTap: onMenuTap),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.surfaceContainerLowest,
        titleSpacing: 0,
        leading: onMenuTap != null
            ? IconButton(onPressed: onMenuTap, icon: const Icon(Icons.menu_rounded))
            : null,
        title: Text(
          'Danh mục sản phẩm',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: AppColors.surfaceContainerLowest,
                fontWeight: FontWeight.w700,
              ),
        ),
      ),
      body: const _CategoryBody(),
    );
  }
}

// ── Body ─────────────────────────────────────────────────────────────────────

class _CategoryBody extends StatefulWidget {
  const _CategoryBody();
  @override
  State<_CategoryBody> createState() => _CategoryBodyState();
}

class _CategoryBodyState extends State<_CategoryBody> {
  final _searchController = TextEditingController();
  String _search = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<CategoryProvider>();

    if (provider.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (provider.error != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(provider.error!, style: const TextStyle(color: Colors.red)),
            const SizedBox(height: 12),
            FilledButton(
              onPressed: () => context.read<CategoryProvider>().fetchAll(),
              child: const Text('Thử lại'),
            ),
          ],
        ),
      );
    }

    final filtered = provider.categories
        .where((c) => c.name.toLowerCase().contains(_search.toLowerCase()))
        .toList();

    return Column(
      children: [
        _SearchBar(
          controller: _searchController,
          onChanged: (v) => setState(() => _search = v),
          onAdd: () => _showForm(context, provider),
        ),
        Expanded(
          child: filtered.isEmpty
              ? const Center(child: Text('Không có danh mục nào.'))
              : ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: filtered.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (ctx, i) => _CategoryTile(
                    category: filtered[i],
                    onEdit: () => _showForm(ctx, provider, category: filtered[i]),
                    onDelete: () => _confirmDelete(ctx, provider, filtered[i]),
                  ),
                ),
        ),
      ],
    );
  }

  void _showForm(BuildContext context, CategoryProvider provider, {Category? category}) {
    showDialog<void>(
      context: context,
      builder: (_) => ChangeNotifierProvider.value(
        value: provider,
        child: _CategoryFormDialog(category: category),
      ),
    );
  }

  void _confirmDelete(BuildContext context, CategoryProvider provider, Category category) {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Xóa danh mục'),
        content: Text('Bạn chắc chắn muốn xóa "${category.name}"?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Hủy')),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              Navigator.pop(ctx);
              final error = await provider.delete(category.id);
              if (!context.mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Text(error ?? 'Đã xóa "${category.name}"'),
                backgroundColor: error != null ? Colors.red : Colors.green,
              ));
            },
            child: const Text('Xóa'),
          ),
        ],
      ),
    );
  }
}

// ── Search bar ───────────────────────────────────────────────────────────────

class _SearchBar extends StatelessWidget {
  const _SearchBar({required this.controller, required this.onChanged, required this.onAdd});

  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(bottom: BorderSide(color: AppColors.borderGray)),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Text('Danh mục',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: AppColors.primary, fontWeight: FontWeight.w700)),
              ),
              FilledButton.icon(
                onPressed: onAdd,
                icon: const Icon(Icons.add_rounded),
                label: const Text('Thêm'),
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.surfaceContainerLowest,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          TextField(
            controller: controller,
            onChanged: onChanged,
            decoration: const InputDecoration(
              prefixIcon: Icon(Icons.search_rounded),
              hintText: 'Tìm kiếm danh mục...',
            ),
          ),
        ],
      ),
    );
  }
}

// ── Category tile ─────────────────────────────────────────────────────────────

class _CategoryTile extends StatelessWidget {
  const _CategoryTile({required this.category, required this.onEdit, required this.onDelete});

  final Category category;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: const BorderSide(color: AppColors.borderGray),
      ),
      child: ListTile(
        leading: const Icon(Icons.category_outlined, color: AppColors.primary),
        title: Text(category.name, style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text(
          category.taxDescription.isNotEmpty
              ? category.taxDescription
              : 'Thuế: ${(category.taxRate * 100).toStringAsFixed(0)}%',
          style: const TextStyle(fontSize: 12),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.edit_outlined, size: 20),
              tooltip: 'Sửa',
              onPressed: onEdit,
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline, size: 20, color: Colors.red),
              tooltip: 'Xóa',
              onPressed: onDelete,
            ),
          ],
        ),
      ),
    );
  }
}

// ── Form dialog ───────────────────────────────────────────────────────────────

class _CategoryFormDialog extends StatefulWidget {
  const _CategoryFormDialog({this.category});
  final Category? category;
  @override
  State<_CategoryFormDialog> createState() => _CategoryFormDialogState();
}

class _CategoryFormDialogState extends State<_CategoryFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _codeCtrl;
  late final TextEditingController _nameCtrl;
  late final TextEditingController _descCtrl;
  int? _selectedTaxRateId;
  bool _saving = false;
  String? _error;

  bool get _isEdit => widget.category != null;

  @override
  void initState() {
    super.initState();
    final c = widget.category;
    _codeCtrl = TextEditingController();
    _nameCtrl = TextEditingController(text: c?.name ?? '');
    _descCtrl = TextEditingController(text: c?.description ?? '');
    _selectedTaxRateId = c?.taxRateId;
  }

  @override
  void dispose() {
    _codeCtrl.dispose();
    _nameCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final taxRates = context.watch<CategoryProvider>().taxRates;

    return AlertDialog(
      title: Text(_isEdit ? 'Sửa danh mục' : 'Thêm danh mục'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (!_isEdit) ...[
                TextFormField(
                  controller: _codeCtrl,
                  decoration: const InputDecoration(labelText: 'Mã danh mục *'),
                  validator: (v) =>
                      (v == null || v.trim().isEmpty) ? 'Nhập mã danh mục' : null,
                ),
                const SizedBox(height: 12),
              ],
              TextFormField(
                controller: _nameCtrl,
                decoration: const InputDecoration(labelText: 'Tên danh mục *'),
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Nhập tên danh mục' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _descCtrl,
                decoration: const InputDecoration(labelText: 'Mô tả'),
                maxLines: 2,
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<int>(
                value: _selectedTaxRateId,
                decoration: const InputDecoration(labelText: 'Thuế suất *'),
                items: {for (final t in taxRates) t.taxRateId: t}
                    .values
                    .map((t) => DropdownMenuItem(value: t.taxRateId, child: Text(t.label)))
                    .toList(),
                onChanged: (v) => setState(() => _selectedTaxRateId = v),
                validator: (v) => v == null ? 'Chọn thuế suất' : null,
              ),
              if (_error != null) ...[
                const SizedBox(height: 12),
                Text(_error!, style: const TextStyle(color: Colors.red, fontSize: 13)),
              ],
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _saving ? null : () => Navigator.pop(context),
          child: const Text('Hủy'),
        ),
        FilledButton(
          onPressed: _saving ? null : () => _submit(context),
          child: _saving
              ? const SizedBox(
                  width: 16, height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                )
              : Text(_isEdit ? 'Lưu' : 'Tạo'),
        ),
      ],
    );
  }

  Future<void> _submit(BuildContext context) async {
    if (!_formKey.currentState!.validate()) return;
    setState(() { _saving = true; _error = null; });

    final provider = context.read<CategoryProvider>();
    final data = <String, dynamic>{
      if (!_isEdit) 'categoryCode': _codeCtrl.text.trim(),
      'name': _nameCtrl.text.trim(),
      if (_descCtrl.text.trim().isNotEmpty) 'description': _descCtrl.text.trim(),
      'taxRateId': _selectedTaxRateId,
    };

    final error = _isEdit
        ? await provider.update(widget.category!.id, data)
        : await provider.create(data);

    if (!mounted) return;
    setState(() => _saving = false);

    if (error != null) {
      setState(() => _error = error);
      return;
    }

    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(_isEdit ? 'Đã cập nhật danh mục.' : 'Đã tạo danh mục.'),
      backgroundColor: Colors.green,
    ));
  }
}
