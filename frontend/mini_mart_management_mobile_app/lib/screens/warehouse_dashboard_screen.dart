import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:mini_mart_management_mobile_app/models/employee_user.dart';
import 'package:mini_mart_management_mobile_app/models/warehouse_dashboard.dart';
import 'package:mini_mart_management_mobile_app/providers/warehouse_dashboard_provider.dart';
import 'package:mini_mart_management_mobile_app/screens/create_inventory_receipt_screen.dart';
import 'package:mini_mart_management_mobile_app/screens/stock_count_history_screen.dart';
import 'package:mini_mart_management_mobile_app/services/warehouse_dashboard_service.dart';
import 'package:mini_mart_management_mobile_app/theme/app_colors.dart';

class WarehouseDashboardScreen extends StatelessWidget {
  const WarehouseDashboardScreen({required this.user, super.key});

  final EmployeeUser user;

  static Widget withProvider({required EmployeeUser user}) {
    return ChangeNotifierProvider(
      create: (_) => WarehouseDashboardProvider(WarehouseDashboardService())
        ..fetchDashboard(),
      child: WarehouseDashboardScreen(user: user),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        title: const Text('Tổng quan kho'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'Tải lại',
            onPressed: () =>
                context.read<WarehouseDashboardProvider>().fetchDashboard(),
          ),
        ],
      ),
      body: _DashboardBody(user: user),
    );
  }
}

class _DashboardBody extends StatelessWidget {
  const _DashboardBody({required this.user});

  final EmployeeUser user;

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<WarehouseDashboardProvider>();

    if (provider.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (provider.error != null && provider.data == null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.red),
            const SizedBox(height: 12),
            Text(provider.error!, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: () =>
                  context.read<WarehouseDashboardProvider>().fetchDashboard(),
              child: const Text('Thử lại'),
            ),
          ],
        ),
      );
    }

    final data = provider.data;
    if (data == null) return const SizedBox.shrink();

    return RefreshIndicator(
      onRefresh: () =>
          context.read<WarehouseDashboardProvider>().fetchDashboard(),
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
        children: [
          _GreetingHeader(user: user),
          const SizedBox(height: 16),
          _StatsRow(data: data),
          const SizedBox(height: 16),
          _QuickActions(user: user),
          const SizedBox(height: 20),
          if (data.lowStockItems.isNotEmpty) ...[
            _SectionHeader(
              icon: Icons.warning_amber_rounded,
              iconColor: Colors.orange,
              title: 'Cần nhập thêm hàng',
              subtitle: '${data.lowStockItems.length} sản phẩm',
            ),
            const SizedBox(height: 10),
            ...data.lowStockItems.map((item) => _LowStockTile(item: item)),
            const SizedBox(height: 20),
          ],
          if (data.nearExpiryProducts.isNotEmpty) ...[
            _SectionHeader(
              icon: Icons.hourglass_bottom_rounded,
              iconColor: Colors.deepOrange,
              title: 'Sắp hết hạn (30 ngày)',
              subtitle: '${data.nearExpiryProducts.length} sản phẩm',
            ),
            const SizedBox(height: 10),
            ...data.nearExpiryProducts
                .map((p) => _NearExpiryTile(product: p)),
            const SizedBox(height: 20),
          ],
          if (data.recentBatches.isNotEmpty) ...[
            _SectionHeader(
              icon: Icons.local_shipping_outlined,
              iconColor: AppColors.primary,
              title: 'Lô hàng nhập gần đây',
              subtitle: '7 ngày qua',
            ),
            const SizedBox(height: 10),
            ...data.recentBatches.map((b) => _RecentBatchTile(batch: b)),
          ],
          if (data.lowStockItems.isEmpty &&
              data.nearExpiryProducts.isEmpty &&
              data.recentBatches.isEmpty)
            _EmptyCard(
              icon: Icons.check_circle_outline_rounded,
              message: 'Kho hàng ổn định, không có cảnh báo.',
              color: Colors.green,
            ),
        ],
      ),
    );
  }
}

class _GreetingHeader extends StatelessWidget {
  const _GreetingHeader({required this.user});
  final EmployeeUser user;

  @override
  Widget build(BuildContext context) {
    final hour = DateTime.now().hour;
    final greeting = hour < 12 ? 'Chào buổi sáng' : hour < 18 ? 'Chào buổi chiều' : 'Chào buổi tối';
    return Row(
      children: [
        CircleAvatar(
          radius: 22,
          backgroundColor: AppColors.primaryContainer,
          child: Text(
            user.fullName.isNotEmpty ? user.fullName.trim().split(' ').last[0].toUpperCase() : '?',
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 16),
          ),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '$greeting, ${user.fullName.trim().split(' ').last}!',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700, color: AppColors.primary),
            ),
            Text(user.roleName,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(color: AppColors.textMuted)),
          ],
        ),
      ],
    );
  }
}

class _StatsRow extends StatelessWidget {
  const _StatsRow({required this.data});
  final WarehouseDashboardData data;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: _StatCard(label: 'Tổng SP', value: '${data.totalProducts}', icon: Icons.inventory_2_outlined, color: AppColors.primary)),
        const SizedBox(width: 10),
        Expanded(child: _StatCard(label: 'Sắp hết', value: '${data.lowStockCount}', icon: Icons.warning_amber_rounded, color: Colors.orange)),
        const SizedBox(width: 10),
        Expanded(child: _StatCard(label: 'Hết hàng', value: '${data.outOfStockCount}', icon: Icons.remove_shopping_cart_outlined, color: Colors.red)),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({required this.label, required this.value, required this.icon, required this.color});
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: color.withValues(alpha: 0.3)),
      ),
      color: color.withValues(alpha: 0.06),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
        child: Column(
          children: [
            Icon(icon, color: color, size: 26),
            const SizedBox(height: 6),
            Text(value, style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: color)),
            const SizedBox(height: 2),
            Text(label, style: Theme.of(context).textTheme.labelSmall?.copyWith(color: AppColors.textMuted)),
          ],
        ),
      ),
    );
  }
}

class _QuickActions extends StatelessWidget {
  const _QuickActions({required this.user});
  final EmployeeUser user;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _ActionButton(
            icon: Icons.add_box_outlined,
            label: 'Tạo phiếu nhập',
            color: AppColors.primary,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute<void>(
                builder: (_) => const CreateInventoryReceiptScreen(),
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _ActionButton(
            icon: Icons.fact_check_outlined,
            label: 'Kiểm kê kho',
            color: Colors.teal,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute<void>(builder: (_) => const StockCountHistoryScreen()),
            ),
          ),
        ),
      ],
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({required this.icon, required this.label, required this.color, required this.onTap});
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 6),
            Text(label, style: TextStyle(color: color, fontWeight: FontWeight.w600, fontSize: 12)),
          ],
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.icon, required this.iconColor, required this.title, required this.subtitle});
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: iconColor, size: 20),
        const SizedBox(width: 8),
        Expanded(
          child: Text(title, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700, color: AppColors.primary)),
        ),
        Text(subtitle, style: Theme.of(context).textTheme.labelSmall?.copyWith(color: AppColors.textMuted)),
      ],
    );
  }
}

class _LowStockTile extends StatelessWidget {
  const _LowStockTile({required this.item});
  final InventoryStatus item;

  @override
  Widget build(BuildContext context) {
    final isOut = item.currentStock == 0;
    final color = isOut ? Colors.red : Colors.orange;
    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(color: color.withValues(alpha: 0.3)),
      ),
      child: ListTile(
        dense: true,
        leading: CircleAvatar(
          radius: 18,
          backgroundColor: color.withValues(alpha: 0.12),
          child: Icon(isOut ? Icons.remove_shopping_cart_outlined : Icons.warning_amber_rounded, color: color, size: 18),
        ),
        title: Text(item.productName, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13), maxLines: 1, overflow: TextOverflow.ellipsis),
        subtitle: Text(item.categoryName, style: const TextStyle(fontSize: 11)),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(isOut ? 'Hết hàng' : 'Còn ${item.currentStock}', style: TextStyle(color: color, fontWeight: FontWeight.w700, fontSize: 12)),
            Text('Tối thiểu: ${item.minimumStock}', style: const TextStyle(fontSize: 10, color: AppColors.textMuted)),
          ],
        ),
      ),
    );
  }
}

class _NearExpiryTile extends StatelessWidget {
  const _NearExpiryTile({required this.product});
  final NearExpiryProduct product;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(color: Colors.deepOrange.withValues(alpha: 0.3)),
      ),
      child: ListTile(
        dense: true,
        leading: CircleAvatar(
          radius: 18,
          backgroundColor: Colors.deepOrange.withValues(alpha: 0.12),
          child: const Icon(Icons.hourglass_bottom_rounded, color: Colors.deepOrange, size: 18),
        ),
        title: Text(product.productName, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13), maxLines: 1, overflow: TextOverflow.ellipsis),
        subtitle: Text(product.categoryName ?? '', style: const TextStyle(fontSize: 11)),
        trailing: Text('Tồn: ${product.stockQuantity}', style: const TextStyle(color: Colors.deepOrange, fontWeight: FontWeight.w700, fontSize: 12)),
      ),
    );
  }
}

class _RecentBatchTile extends StatelessWidget {
  const _RecentBatchTile({required this.batch});
  final RecentBatch batch;

  @override
  Widget build(BuildContext context) {
    final fmt = DateFormat('dd/MM/yyyy');
    final daysLeft = batch.expiryDate.difference(DateTime.now()).inDays;
    final expiryColor = daysLeft < 30 ? Colors.orange : daysLeft < 0 ? Colors.red : Colors.green;

    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: const BorderSide(color: AppColors.borderGray),
      ),
      child: ListTile(
        dense: true,
        leading: const CircleAvatar(
          radius: 18,
          backgroundColor: AppColors.primaryContainer,
          child: Icon(Icons.local_shipping_outlined, color: Colors.white, size: 16),
        ),
        title: Text(batch.productName, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13), maxLines: 1, overflow: TextOverflow.ellipsis),
        subtitle: Text('Nhập: ${fmt.format(batch.importDate)} | SL: ${batch.quantityImported}', style: const TextStyle(fontSize: 11)),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text('HSD: ${fmt.format(batch.expiryDate)}', style: TextStyle(color: expiryColor, fontWeight: FontWeight.w700, fontSize: 11)),
            Text(daysLeft >= 0 ? 'Còn $daysLeft ngày' : 'Đã hết hạn', style: TextStyle(fontSize: 10, color: expiryColor)),
          ],
        ),
      ),
    );
  }
}

class _EmptyCard extends StatelessWidget {
  const _EmptyCard({required this.icon, required this.message, required this.color});
  final IconData icon;
  final String message;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: color.withValues(alpha: 0.3)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Icon(icon, color: color, size: 36),
            const SizedBox(height: 10),
            Text(message, style: TextStyle(color: color, fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }
}
