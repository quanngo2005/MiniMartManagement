import 'package:flutter/material.dart';
import 'package:mini_mart_management_mobile_app/models/category.dart';
import 'package:mini_mart_management_mobile_app/providers/category_provider.dart';
import 'package:mini_mart_management_mobile_app/repositories/category_repository.dart';
import 'package:mini_mart_management_mobile_app/screens/category_detail_screen.dart';
import 'package:mini_mart_management_mobile_app/services/category_service.dart';
import 'package:mini_mart_management_mobile_app/theme/app_colors.dart';
import 'package:mini_mart_management_mobile_app/widgets/categories/category_action_button.dart';
import 'package:mini_mart_management_mobile_app/widgets/categories/category_stat_card.dart';
import 'package:mini_mart_management_mobile_app/widgets/feedback/empty_state.dart';
import 'package:mini_mart_management_mobile_app/widgets/feedback/error_banner.dart';
import 'package:mini_mart_management_mobile_app/widgets/feedback/loading_overlay.dart';
import 'package:mini_mart_management_mobile_app/widgets/layout/mini_mart_app_bar.dart';
import 'package:provider/provider.dart';

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
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openEditor(context),
        icon: const Icon(Icons.add_rounded),
        label: const Text('Thêm danh mục'),
      ),
    );
  }

  static Future<void> _openEditor(
    BuildContext context, [
    Category? category,
  ]) async {
    final provider = context.read<CategoryProvider>();
    final changed = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => ChangeNotifierProvider.value(
          value: provider,
          child: CategoryDetailScreen(categoryId: category?.categoryId),
        ),
      ),
    );
    if (changed == true && context.mounted) await provider.fetchAll();
  }
}

class _CategoryBody extends StatefulWidget {
  const _CategoryBody();

  @override
  State<_CategoryBody> createState() => _CategoryBodyState();
}

class _CategoryBodyState extends State<_CategoryBody> {
  final _searchController = TextEditingController();
  String _query = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<CategoryProvider>();
      if (provider.categories.isEmpty && !provider.isLoading) {
        provider.fetchAll();
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<CategoryProvider>();
    if (provider.isLoading && provider.categories.isEmpty) {
      return const LoadingOverlay();
    }
    if (provider.error != null && provider.categories.isEmpty) {
      return ErrorBanner(
        message: provider.error!,
        onRetry: context.read<CategoryProvider>().fetchAll,
      );
    }

    final categories =
        provider.categories.where((category) {
          final query = _query.toLowerCase();
          return query.isEmpty ||
              category.categoryName.toLowerCase().contains(query) ||
              category.categoryCode.toLowerCase().contains(query) ||
              (category.description?.toLowerCase().contains(query) ?? false);
        }).toList()..sort((a, b) {
          final order = a.displayOrder.compareTo(b.displayOrder);
          return order == 0 ? a.categoryName.compareTo(b.categoryName) : order;
        });

    return RefreshIndicator(
      onRefresh: context.read<CategoryProvider>().fetchAll,
      child: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          SliverToBoxAdapter(child: _buildHeader(context, provider)),
          if (provider.error != null)
            SliverToBoxAdapter(child: ErrorBanner(message: provider.error!)),
          if (categories.isEmpty)
            const SliverFillRemaining(
              hasScrollBody: false,
              child: EmptyState(
                message: 'Không tìm thấy danh mục phù hợp.',
                icon: Icons.category_outlined,
              ),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 104),
              sliver: SliverList.separated(
                itemCount: categories.length,
                separatorBuilder: (_, _) => const SizedBox(height: 8),
                itemBuilder: (_, index) => _CategoryCard(
                  category: categories[index],
                  onEdit: () => CategoryManagementScreen._openEditor(
                    context,
                    categories[index],
                  ),
                  onDelete: () => _confirmDelete(context, categories[index]),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, CategoryProvider provider) {
    final active = provider.categories.where((item) => item.status).length;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            controller: _searchController,
            onChanged: (value) => setState(() => _query = value.trim()),
            decoration: const InputDecoration(
              prefixIcon: Icon(Icons.search_rounded),
              hintText: 'Tìm theo tên hoặc mã danh mục',
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: CategoryStatCard(
                  label: 'Tổng danh mục',
                  value: '${provider.categories.length}',
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: CategoryStatCard(
                  label: 'Đang hoạt động',
                  value: '$active',
                  valueColor: AppColors.secondary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _confirmDelete(BuildContext context, Category category) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Xóa danh mục?'),
        content: Text('Bạn có chắc muốn xóa “${category.categoryName}”?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Hủy'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Xóa'),
          ),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;
    final error = await context.read<CategoryProvider>().delete(
      category.categoryId,
    );
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(error ?? 'Đã xóa ${category.categoryName}.')),
    );
  }
}

class _CategoryCard extends StatelessWidget {
  const _CategoryCard({
    required this.category,
    required this.onEdit,
    required this.onDelete,
  });

  final Category category;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        border: Border.all(color: AppColors.borderGray),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 12, 6, 12),
        child: Row(
          children: [
            const Icon(Icons.folder_outlined, color: AppColors.primary),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    category.categoryName,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    category.categoryCode,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: AppColors.textMuted,
                    ),
                  ),
                ],
              ),
            ),
            CategoryActionButton(
              icon: Icons.edit_outlined,
              tooltip: 'Sửa danh mục',
              onPressed: onEdit,
            ),
            CategoryActionButton(
              icon: Icons.delete_outline,
              tooltip: 'Xóa danh mục',
              foregroundColor: AppColors.statusError,
              onPressed: onDelete,
            ),
          ],
        ),
      ),
    );
  }
}
