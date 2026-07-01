import 'package:flutter/material.dart';
import 'package:mini_mart_management_mobile_app/models/inventory_document.dart';
import 'package:mini_mart_management_mobile_app/models/receipt.dart';
import 'package:mini_mart_management_mobile_app/screens/create_inventory_receipt_screen.dart';
import 'package:mini_mart_management_mobile_app/screens/inventory_document_receipt_screen.dart';
import 'package:mini_mart_management_mobile_app/theme/app_colors.dart';
import 'package:mini_mart_management_mobile_app/widgets/categories/category_stat_card.dart';
import 'package:mini_mart_management_mobile_app/widgets/inventory_documents/inventory_document_card.dart';

class InventoryDocumentsScreen extends StatelessWidget {
  const InventoryDocumentsScreen({super.key});

  static const List<InventoryDocument> _documents = [
    InventoryDocument(
      id: '#IMP-20231024-001',
      createdAt: 'Hôm nay, 14:30',
      type: 'Nhập kho tổng',
      store: 'Cửa hàng #402',
      warehouse: 'Kho tổng',
      supplier: 'NCC Minh Long',
      createdBy: 'Nguyễn Văn An',
      status: InventoryDocumentStatus.completed,
      itemCount: 48,
      icon: Icons.archive_rounded,
      iconColor: AppColors.secondary,
      lines: [
        InventoryDocumentLine(
          sku: 'MLK-001',
          name: 'Sữa tươi 1L',
          quantity: 24,
          unitPrice: 25000,
          lineTotal: 600000,
        ),
        InventoryDocumentLine(
          sku: 'RIC-005',
          name: 'Gạo thơm 5kg',
          quantity: 10,
          unitPrice: 145000,
          lineTotal: 1450000,
        ),
        InventoryDocumentLine(
          sku: 'OIL-002',
          name: 'Dầu ăn 2L',
          quantity: 15,
          unitPrice: 85000,
          lineTotal: 1275000,
        ),
        InventoryDocumentLine(
          sku: 'CKB-011',
          name: 'Bánh quy bơ',
          quantity: 20,
          unitPrice: 35000,
          lineTotal: 700000,
        ),
      ],
      notes: 'Hàng nhập đủ số lượng, bao bì nguyên vẹn.',
    ),
    InventoryDocument(
      id: '#EXP-20231024-042',
      createdAt: 'Hôm nay, 09:15',
      type: 'Xuất kho sỉ',
      store: 'Cửa hàng #402',
      warehouse: 'Kho tổng',
      supplier: 'Khách sỉ An Phú',
      createdBy: 'Trần Minh Khoa',
      status: InventoryDocumentStatus.pending,
      itemCount: 12,
      icon: Icons.unarchive_rounded,
      iconColor: AppColors.statusWarning,
    ),
    InventoryDocument(
      id: '#TRF-20231023-089',
      createdAt: 'Hôm qua, 17:50',
      type: 'Nhận hoàn trả',
      store: 'Cửa hàng #402',
      warehouse: 'Kho kiểm hàng',
      supplier: 'Quầy thu ngân',
      createdBy: 'Lê Thu Hà',
      status: InventoryDocumentStatus.cancelled,
      itemCount: 0,
      icon: Icons.block_rounded,
      iconColor: AppColors.statusError,
    ),
    InventoryDocument(
      id: '#IMP-20231023-055',
      createdAt: 'Hôm qua, 11:20',
      type: 'Nhập thực phẩm tươi',
      store: 'Cửa hàng #402',
      warehouse: 'Kho lạnh',
      supplier: 'NCC Rau Sạch',
      createdBy: 'Nguyễn Văn An',
      status: InventoryDocumentStatus.completed,
      itemCount: 156,
      icon: Icons.archive_rounded,
      iconColor: AppColors.secondary,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(context),
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(child: _buildFilters(context)),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              sliver: SliverGrid.count(
                crossAxisCount: 2,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 1.45,
                children: const [
                  CategoryStatCard(
                    label: 'Tổng Nhập',
                    value: '1,284',
                    caption: '+12%',
                    valueColor: AppColors.primary,
                  ),
                  CategoryStatCard(
                    label: 'Tổng Xuất',
                    value: '842',
                    caption: '-5%',
                    valueColor: AppColors.primary,
                  ),
                ],
              ),
            ),
            SliverToBoxAdapter(child: _buildSectionTitle(context)),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 88),
              sliver: SliverList.separated(
                itemCount: _documents.length,
                separatorBuilder: (_, _) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final document = _documents[index];
                  return InventoryDocumentCard(
                    document: document,
                    onTap: () => _openDocument(context, document),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _openCreateReceipt(context),
        tooltip: 'Tạo chứng từ',
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.surfaceContainerLowest,
        child: const Icon(Icons.add_rounded),
      ),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: AppColors.surfaceBright,
      foregroundColor: AppColors.primary,
      titleSpacing: 0,
      leading: const Icon(Icons.storefront_rounded),
      title: Text(
        'Cửa hàng #402 | Nhập/Xuất',
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
          color: AppColors.primary,
          fontWeight: FontWeight.w800,
        ),
      ),
      actions: [
        IconButton(
          onPressed: () => _showActionSnackBar(context, 'Tài khoản'),
          tooltip: 'Tài khoản',
          icon: const Icon(Icons.account_circle_outlined),
        ),
      ],
    );
  }

  Widget _buildFilters(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(color: AppColors.backgroundSlate),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
        child: Row(
          children: [
            const Expanded(
              child: TextField(
                decoration: InputDecoration(
                  prefixIcon: Icon(Icons.search_rounded),
                  hintText: 'Tìm kiếm chứng từ...',
                ),
                textInputAction: TextInputAction.search,
              ),
            ),
            const SizedBox(width: 8),
            SizedBox.square(
              dimension: 48,
              child: OutlinedButton(
                onPressed: () => _showActionSnackBar(context, 'Bộ lọc'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.primary,
                  side: const BorderSide(color: AppColors.borderGray),
                  backgroundColor: AppColors.surfaceContainerLowest,
                  padding: EdgeInsets.zero,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Icon(Icons.filter_list_rounded),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 10),
      child: Text(
        'Danh sách chứng từ',
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
          color: AppColors.primary,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }

  Widget _buildBottomNavigationBar() {
    return NavigationBar(
      selectedIndex: 1,
      backgroundColor: AppColors.surface,
      indicatorColor: AppColors.secondaryFixed,
      destinations: const [
        NavigationDestination(
          icon: Icon(Icons.inventory_2_outlined),
          label: 'Checkout',
        ),
        NavigationDestination(
          selectedIcon: Icon(Icons.inventory_rounded),
          icon: Icon(Icons.inventory_2_outlined),
          label: 'Inventory',
        ),
        NavigationDestination(
          icon: Icon(Icons.receipt_long_outlined),
          label: 'Returns',
        ),
        NavigationDestination(
          icon: Icon(Icons.settings_outlined),
          label: 'Settings',
        ),
      ],
    );
  }

  Future<void> _openCreateReceipt(BuildContext context) async {
    final receipt = await Navigator.of(context).push<CreateReceipt>(
      MaterialPageRoute<CreateReceipt>(
        builder: (_) => const CreateInventoryReceiptScreen(),
      ),
    );
    if (!context.mounted || receipt == null) return;

    _showActionSnackBar(context, 'Đã tạo ${receipt.receiptCode}');
  }

  void _openDocument(BuildContext context, InventoryDocument document) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => InventoryDocumentReceiptScreen(document: document),
      ),
    );
  }

  void _showActionSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }
}
