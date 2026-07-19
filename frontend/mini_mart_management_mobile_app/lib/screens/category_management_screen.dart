import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mini_mart_management_mobile_app/models/category.dart';
import 'package:mini_mart_management_mobile_app/providers/category_provider.dart';
import 'package:mini_mart_management_mobile_app/repositories/category_repository.dart';
import 'package:mini_mart_management_mobile_app/screens/category_detail_screen.dart';
import 'package:mini_mart_management_mobile_app/services/category_service.dart';
import 'package:mini_mart_management_mobile_app/widgets/feedback/empty_state.dart';
import 'package:mini_mart_management_mobile_app/widgets/feedback/error_banner.dart';
import 'package:mini_mart_management_mobile_app/widgets/feedback/loading_overlay.dart';
import 'package:mini_mart_management_mobile_app/widgets/layout/mini_mart_app_bar.dart';
import 'package:mini_mart_management_mobile_app/theme/app_colors.dart';

class CategoryManagementScreen extends StatelessWidget {
  const CategoryManagementScreen({this.onMenuTap, super.key});

  final VoidCallback? onMenuTap;

  static Widget withProvider({VoidCallback? onMenuTap}) {
    return ChangeNotifierProvider(
      create: (_) =>
          CategoryProvider(CategoryRepository(CategoryService()))..fetchAll(),
      child: CategoryManagementScreen(onMenuTap: onMenuTap),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MiniMartAppBar.primary(
        title: 'Danh mục sản phẩm',
        onBrandTap: onMenuTap,
      ),
      body: const SafeArea(child: _CategoryBody()),
    );
  }
}

class _CategoryBody extends StatefulWidget {
  const _CategoryBody();

  @override
  State<_CategoryBody> createState() => _CategoryBodyState();
}

class _CategoryBodyState extends State<_CategoryBody> {
  final _searchController = TextEditingController();
  String _search = '';

  @override
  void initState() {
    super.initState();
    _searchController.addListener(
      () => setState(() => _search = _searchController.text.trim()),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<CategoryProvider>();

    if (provider.isLoading) {
      return const LoadingOverlay();
    }

    if (provider.error != null && provider.categories.isEmpty) {
      return ErrorBanner(
        message: provider.error!,
        onRetry: () => context.read<CategoryProvider>().fetchAll(),
      );
    }

    final filtered = provider.categories.where((category) {
      if (_search.isEmpty) return true;
      final query = _search.toLowerCase();
      return category.categoryName.toLowerCase().contains(query) ||
          category.categoryCode.toLowerCase().contains(query) ||
          (category.description?.toLowerCase().contains(query) ?? false);
    }).toList();

    return RefreshIndicator(
      onRefresh: () => context.read<CategoryProvider>().fetchAll(),
      child: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          SliverToBoxAdapter(child: _buildSearchHeader(context)),
          if (provider.error != null)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                child: ErrorBanner(
                  message: provider.error!,
                  onRetry: () => context.read<CategoryProvider>().fetchAll(),
                ),
              ),
            ),
          if (filtered.isEmpty)
            const SliverFillRemaining(
              hasScrollBody: false,
              child: EmptyState(
                message: 'Chưa có danh mục nào.',
                icon: Icons.category_outlined,
              ),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 96),
              sliver: SliverList.separated(
                itemCount: filtered.length,
                separatorBuilder: (_, _) => const SizedBox(height: 10),
                itemBuilder: (context, index) {
                  final category = filtered[index];
                  return _CategoryTile(
                    category: category,
                    taxLabel: _taxLabel(provider, category),
                    onEdit: () => _openDetail(context, category),
                    onDelete: () => _confirmDelete(context, category),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSearchHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Danh mục',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _searchController,
            decoration: const InputDecoration(
              prefixIcon: Icon(Icons.search_rounded),
              hintText: 'Tìm kiếm danh mục...',
            ),
          ),
        ],
      ),
    );
  }

  String _taxLabel(CategoryProvider provider, Category category) {
    final tax = provider.taxRates.firstWhere(
      (rate) => rate.taxRateId == category.taxRateId,
      orElse: () => provider.taxRates.isNotEmpty
          ? provider.taxRates.first
          : throw StateError('no tax rates'),
    );
    return tax.label;
  }

  void _openDetail(BuildContext context, Category category) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => CategoryDetailScreen(categoryId: category.categoryId),
      ),
    );
  }

  void _confirmDelete(BuildContext context, Category category) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Xóa danh mục'),
        content: Text('Bạn chắc chắn muốn xóa "${category.categoryName}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Hủy'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              Navigator.pop(dialogContext);
              final error = await context.read<CategoryProvider>().delete(
                category.categoryId,
              );
              if (!context.mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(error ?? 'Đã xóa "${category.categoryName}"'),
                  backgroundColor: error == null ? Colors.green : Colors.red,
                ),
              );
            },
            child: const Text('Xóa'),
          ),
        ],
      ),
    );
  }
}

class _CategoryTile extends StatelessWidget {
  const _CategoryTile({
    required this.category,
    required this.taxLabel,
    required this.onEdit,
    required this.onDelete,
  });

  final Category category;
  final String taxLabel;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: AppColors.borderGray),
      ),
      child: ListTile(
        leading: const Icon(Icons.category_outlined, color: AppColors.primary),
        title: Text(
          category.categoryName,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(
          '${category.categoryCode} • $taxLabel',
          style: const TextStyle(fontSize: 12),
        ),
        trailing: Wrap(
          spacing: 4,
          children: [
            IconButton(
              icon: const Icon(Icons.edit_outlined, size: 20),
              tooltip: 'Sửa',
              onPressed: onEdit,
            ),
            IconButton(
              icon: const Icon(
                Icons.delete_outline,
                size: 20,
                color: Colors.red,
              ),
              tooltip: 'Xóa',
              onPressed: onDelete,
            ),
          ],
        ),
      ),
    );
  }
}
