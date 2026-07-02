import 'package:flutter/material.dart';
import 'package:mini_mart_management_mobile_app/models/category_summary.dart';
<<<<<<< HEAD
import 'package:mini_mart_management_mobile_app/widgets/layout/app_bottom_nav_bar.dart';
=======
import 'package:mini_mart_management_mobile_app/screens/employee_management_screen.dart';
import 'package:mini_mart_management_mobile_app/screens/supplier_management_screen.dart';
>>>>>>> kiet_dev
import 'package:mini_mart_management_mobile_app/theme/app_colors.dart';
import 'package:mini_mart_management_mobile_app/widgets/categories/category_stat_card.dart';
import 'package:mini_mart_management_mobile_app/widgets/categories/category_tree_card.dart';

class CategoryManagementScreen extends StatelessWidget {
  const CategoryManagementScreen({super.key});

  static const List<CategorySummary> _categories = [
    CategorySummary(
      name: 'Fresh Produce',
      productCount: 452,
      icon: Icons.folder_rounded,
      children: [
        CategorySummary(
          name: 'Vegetables',
          productCount: 210,
          icon: Icons.folder_rounded,
          children: [
            CategorySummary(
              name: 'Organic Greens',
              productCount: 45,
              icon: Icons.folder_rounded,
            ),
          ],
        ),
        CategorySummary(
          name: 'Fruits',
          productCount: 184,
          icon: Icons.folder_rounded,
        ),
      ],
    ),
    CategorySummary(
      name: 'Electronics',
      productCount: 1204,
      icon: Icons.devices_rounded,
      children: [
        CategorySummary(
          name: 'Accessories',
          productCount: 840,
          icon: Icons.folder_rounded,
        ),
      ],
    ),
    CategorySummary(
      name: 'Home & Kitchen',
      productCount: 890,
      icon: Icons.soup_kitchen_rounded,
    ),
    CategorySummary(
      name: 'Frozen Foods',
      productCount: 320,
      icon: Icons.ac_unit_rounded,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(context),
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(child: _buildSearchSection(context)),
            SliverPadding(
              padding: const EdgeInsets.all(16),
              sliver: SliverList.separated(
                itemCount: _categories.length,
                separatorBuilder: (_, _) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  return CategoryTreeCard(
                    category: _categories[index],
                    onEdit: (category) =>
                        _showActionSnackBar(context, 'Edit ${category.name}'),
                    onDelete: (category) =>
                        _showActionSnackBar(context, 'Delete ${category.name}'),
                  );
                },
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 88),
              sliver: SliverGrid.count(
                crossAxisCount: 2,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 1.45,
                children: const [
                  CategoryStatCard(
                    label: 'Top Category',
                    value: 'Electronics',
                    progress: 0.8,
                  ),
                  CategoryStatCard(
                    label: 'Empty Slotted',
                    value: '12 Empty',
                    caption: 'Categories w/o Products',
                    valueColor: AppColors.statusWarning,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(heroTag: null,
        onPressed: () => _showActionSnackBar(context, 'Add category'),
        tooltip: 'Add category',
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.surfaceContainerLowest,
        child: const Icon(Icons.add_box_outlined),
      ),
      bottomNavigationBar: _buildBottomNavigationBar(context),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: AppColors.primary,
      foregroundColor: AppColors.surfaceContainerLowest,
      titleSpacing: 0,
      leading: IconButton(
        onPressed: () {},
        tooltip: 'Menu',
        icon: const Icon(Icons.menu_rounded),
      ),
      title: Text(
        'Retail Manager',
        style: Theme.of(context).textTheme.titleLarge?.copyWith(
          color: AppColors.surfaceContainerLowest,
          fontWeight: FontWeight.w700,
        ),
      ),
      actions: [
        IconButton(
          onPressed: () {},
          tooltip: 'Search',
          icon: const Icon(Icons.search_rounded),
        ),
        IconButton(
          onPressed: () {},
          tooltip: 'Notifications',
          icon: const Icon(Icons.notifications_none_rounded),
        ),
      ],
    );
  }

  Widget _buildSearchSection(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return DecoratedBox(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(bottom: BorderSide(color: AppColors.borderGray)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Categories',
                    style: textTheme.titleLarge?.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                FilledButton.icon(
                  onPressed: () => _showActionSnackBar(context, 'Add category'),
                  icon: const Icon(Icons.add_rounded),
                  label: const Text('Add Category'),
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: AppColors.surfaceContainerLowest,
                    minimumSize: const Size(0, 48),
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextField(
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.search_rounded),
                hintText: 'Search categories (e.g. Dairy, Electronics)...',
              ),
              textInputAction: TextInputAction.search,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomNavigationBar(BuildContext context) {
<<<<<<< HEAD
    return const AppBottomNavBar(selectedTab: AppNavTab.categories);
=======
    return NavigationBar(
      selectedIndex: 1,
      backgroundColor: AppColors.surface,
      indicatorColor: AppColors.primaryContainer,
      onDestinationSelected: (index) {
        if (index == 2) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => const EmployeeManagementScreen()),
          );
        } else if (index == 3) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => const SupplierManagementScreen()),
          );
        }
      },
      destinations: const [
        NavigationDestination(icon: Icon(Icons.inventory_2_outlined), label: 'Catalog'),
        NavigationDestination(
          selectedIcon: Icon(Icons.category_rounded),
          icon: Icon(Icons.category_outlined),
          label: 'Categories',
        ),
        NavigationDestination(icon: Icon(Icons.group_outlined), label: 'Staff'),
        NavigationDestination(
          icon: Icon(Icons.local_shipping_outlined),
          label: 'Suppliers',
        ),
      ],
    );
>>>>>>> kiet_dev
  }

  void _showActionSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }
}
