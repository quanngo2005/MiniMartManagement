import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mini_mart_management_mobile_app/models/supplier.dart';
import 'package:mini_mart_management_mobile_app/providers/supplier_provider.dart';
import 'package:mini_mart_management_mobile_app/screens/supplier_debt_screen.dart';
import 'package:mini_mart_management_mobile_app/screens/supplier_detail_screen.dart';
import 'package:mini_mart_management_mobile_app/widgets/feedback/empty_state.dart';
import 'package:mini_mart_management_mobile_app/widgets/feedback/error_banner.dart';
import 'package:mini_mart_management_mobile_app/widgets/feedback/loading_overlay.dart';
import 'package:mini_mart_management_mobile_app/widgets/layout/app_bottom_nav_bar.dart';
import 'package:mini_mart_management_mobile_app/widgets/layout/mini_mart_app_bar.dart';

class SupplierManagementScreen extends StatefulWidget {
  const SupplierManagementScreen({this.showBottomNavBar = true, super.key});

  final bool showBottomNavBar;

  @override
  State<SupplierManagementScreen> createState() =>
      _SupplierManagementScreenState();
}

class _SupplierManagementScreenState extends State<SupplierManagementScreen> {
  final _searchController = TextEditingController();
  String _query = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<SupplierProvider>().fetchSuppliers();
    });
    _searchController.addListener(
      () =>
          setState(() => _query = _searchController.text.trim().toLowerCase()),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<SupplierProvider>();
    final filtered = provider.suppliers.where((supplier) {
      if (_query.isEmpty) return true;
      return supplier.supplierName.toLowerCase().contains(_query) ||
          supplier.supplierCode.toLowerCase().contains(_query) ||
          (supplier.contactPerson?.toLowerCase().contains(_query) ?? false);
    }).toList();

    return Scaffold(
      appBar: MiniMartAppBar.primary(
        title: 'NhÃ  cung cáº¥p',
        onBrandTap: null,
        onProfileTap: () => Navigator.of(context).push(
          MaterialPageRoute<void>(builder: (_) => const SupplierDebtScreen()),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: TextField(
                controller: _searchController,
                decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.search_rounded),
                  hintText: 'TÃ¬m theo tÃªn, mÃ£, liÃªn há»‡...',
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => const SupplierDebtScreen(),
                    ),
                  ),
                  icon: const Icon(Icons.payments_outlined),
                  label: const Text('Quản lý nợ nhà cung cấp'),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: provider.isLoading && provider.suppliers.isEmpty
                  ? const LoadingOverlay()
                  : provider.error != null && provider.suppliers.isEmpty
                  ? ErrorBanner(
                      message: provider.error!,
                      onRetry: () =>
                          context.read<SupplierProvider>().fetchSuppliers(),
                    )
                  : filtered.isEmpty
                  ? const EmptyState(
                      message: 'ChÆ°a cÃ³ nhÃ  cung cáº¥p nÃ o.',
                      icon: Icons.local_shipping_outlined,
                    )
                  : RefreshIndicator(
                      onRefresh: () =>
                          context.read<SupplierProvider>().fetchSuppliers(),
                      child: ListView.separated(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 96),
                        itemCount: filtered.length,
                        separatorBuilder: (_, _) => const SizedBox(height: 12),
                        itemBuilder: (_, index) => _SupplierTile(
                          supplier: filtered[index],
                          onTap: () => Navigator.push<void>(
                            context,
                            MaterialPageRoute(
                              builder: (_) => SupplierDetailScreen(
                                supplierId: filtered[index].supplierId,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: widget.showBottomNavBar
          ? const AppBottomNavBar(selectedTab: AppNavTab.suppliers)
          : null,
    );
  }
}

class _SupplierTile extends StatelessWidget {
  const _SupplierTile({required this.supplier, required this.onTap});

  final Supplier supplier;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        onTap: onTap,
        title: Text(supplier.supplierName),
        subtitle: Text(
          '${supplier.supplierCode} â€¢ ${supplier.contactPerson ?? 'ChÆ°a cÃ³ liÃªn há»‡'}',
        ),
        trailing: const Icon(Icons.chevron_right_rounded),
      ),
    );
  }
}

