import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mini_mart_management_mobile_app/models/category.dart' as product_category;
import 'package:mini_mart_management_mobile_app/providers/category_provider.dart';
import 'package:mini_mart_management_mobile_app/screens/category_detail_screen.dart';
import 'package:mini_mart_management_mobile_app/theme/app_colors.dart';
import 'package:mini_mart_management_mobile_app/widgets/layout/app_bottom_nav_bar.dart';
import 'package:mini_mart_management_mobile_app/widgets/feedback/empty_state.dart';
import 'package:mini_mart_management_mobile_app/widgets/feedback/error_banner.dart';
import 'package:mini_mart_management_mobile_app/widgets/feedback/loading_overlay.dart';

class CategoryManagementScreen extends StatefulWidget {
  const CategoryManagementScreen({super.key});

  @override
  State<CategoryManagementScreen> createState() => _CategoryManagementScreenState();
}

class _CategoryManagementScreenState extends State<CategoryManagementScreen> {
  final _searchCtrl = TextEditingController();
  String _query = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CategoryProvider>().fetchAll();
    });
    _searchCtrl.addListener(() {
      setState(() => _query = _searchCtrl.text.trim().toLowerCase());
    });
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<CategoryProvider>();
    final categories = provider.categories.where((category) {
      if (_query.isEmpty) return true;
      return category.categoryName.toLowerCase().contains(_query) ||
          category.categoryCode.toLowerCase().contains(_query);
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Quản lý Danh Mục'),
        backgroundColor: AppColors.surfaceContainerLowest,
        foregroundColor: AppColors.primary,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: TextField(
                controller: _searchCtrl,
                decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.search),
                  hintText: 'Tìm danh mục...',
                ),
              ),
            ),
            Expanded(
              child: provider.isLoading && provider.categories.isEmpty
                  ? const LoadingOverlay()
                  : provider.error != null && provider.categories.isEmpty
                      ? ErrorBanner(
                          message: provider.error!,
                          onRetry: () => context.read<CategoryProvider>().fetchAll(),
                        )
                      : categories.isEmpty
                          ? const EmptyState(
                              message: 'Chưa có danh mục nào',
                              icon: Icons.category_outlined,
                            )
                          : ListView.separated(
                              padding: const EdgeInsets.fromLTRB(16, 0, 16, 96),
                              itemCount: categories.length,
                              separatorBuilder: (_, _) => const SizedBox(height: 12),
                              itemBuilder: (_, index) => _CategoryTile(
                                category: categories[index],
                                onTap: () => Navigator.push<void>(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => CategoryDetailScreen(
                                      categoryId: categories[index].categoryId,
                                    ),
                                  ),
                                ),
                              ),
                            ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.push<void>(
          context,
          MaterialPageRoute(builder: (_) => const CategoryDetailScreen()),
        ),
        child: const Icon(Icons.add),
      ),
      bottomNavigationBar: const AppBottomNavBar(selectedTab: AppNavTab.categories),
    );
  }
}

class _CategoryTile extends StatelessWidget {
  const _CategoryTile({required this.category, required this.onTap});

  final product_category.Category category;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        onTap: onTap,
        title: Text(category.categoryName),
        subtitle: Text(
          '${category.categoryCode} • ${category.parentCategoryName ?? 'Danh mục gốc'}',
        ),
        trailing: const Icon(Icons.chevron_right_rounded),
      ),
    );
  }
}
