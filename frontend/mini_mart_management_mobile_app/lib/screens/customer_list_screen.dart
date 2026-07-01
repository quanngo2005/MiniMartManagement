import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/customer_provider.dart';
import '../theme/app_colors.dart';
import '../widgets/customers/customer_card.dart';
import 'customer_profile_screen.dart';

class CustomerListScreen extends StatefulWidget {
  const CustomerListScreen({super.key});

  @override
  State<CustomerListScreen> createState() => _CustomerListScreenState();
}

class _CustomerListScreenState extends State<CustomerListScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CustomerProvider>().fetchCustomers();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(context),
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(child: _buildSearchSection(context)),
            SliverToBoxAdapter(child: _buildFilterSection()),
            _buildCustomerList(context),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.surfaceContainerLowest,
        child: const Icon(Icons.person_add_outlined),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: AppColors.surface,
      foregroundColor: AppColors.primary,
      titleSpacing: 0,
      leading: const Icon(Icons.storefront, color: AppColors.primary),
      title: Text(
        'Quản lý Khách hàng',
        style: Theme.of(context).textTheme.titleLarge?.copyWith(
          color: AppColors.primary,
          fontWeight: FontWeight.bold,
        ),
      ),
      actions: const [
        Padding(
          padding: EdgeInsets.only(right: 16),
          child: CircleAvatar(
            backgroundImage: NetworkImage('https://i.pravatar.cc/150'),
          ),
        ),
      ],
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Container(color: AppColors.borderGray, height: 1),
      ),
    );
  }

  Widget _buildSearchSection(BuildContext context) {
    return Container(
      color: AppColors.backgroundSlate,
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: TextField(
        decoration: InputDecoration(
          prefixIcon: const Icon(Icons.search, color: AppColors.outlineVariant),
          hintText: 'Tìm theo tên hoặc số điện thoại...',
          filled: true,
          fillColor: AppColors.surfaceContainerLowest,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.borderGray),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.borderGray),
          ),
        ),
      ),
    );
  }

  Widget _buildFilterSection() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          _buildFilterChip('Tất cả', isSelected: true),
          const SizedBox(width: 8),
          _buildFilterChip('Vàng (Gold)'),
          const SizedBox(width: 8),
          _buildFilterChip('Bạc (Silver)'),
          const SizedBox(width: 8),
          _buildFilterChip('Đồng (Bronze)'),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, {bool isSelected = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: isSelected ? AppColors.primary : AppColors.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isSelected ? AppColors.primary : AppColors.outlineVariant,
        ),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: isSelected ? AppColors.surfaceContainerLowest : AppColors.textDark,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildCustomerList(BuildContext context) {
    final provider = context.watch<CustomerProvider>();
    if (provider.isLoading) {
      return const SliverFillRemaining(
        child: Center(child: CircularProgressIndicator()),
      );
    }
    
    return SliverPadding(
      padding: const EdgeInsets.all(16),
      sliver: SliverList.separated(
        itemCount: provider.customers.length,
        separatorBuilder: (_, _) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final customer = provider.customers[index];
          return CustomerCard(
            customer: customer,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => CustomerProfileScreen(customerId: customer.id),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
