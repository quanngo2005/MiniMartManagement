import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mini_mart_management_mobile_app/models/supplier_debt_tracking.dart';
import 'package:mini_mart_management_mobile_app/providers/supplier_debt_provider.dart';
import 'package:mini_mart_management_mobile_app/theme/app_colors.dart';
import 'package:mini_mart_management_mobile_app/widgets/feedback/empty_state.dart';
import 'package:mini_mart_management_mobile_app/widgets/feedback/error_banner.dart';
import 'package:mini_mart_management_mobile_app/widgets/feedback/loading_overlay.dart';
import 'package:mini_mart_management_mobile_app/widgets/suppliers/supplier_debt_cards.dart';
import 'package:provider/provider.dart';

class SupplierDebtDetailScreen extends StatefulWidget {
  const SupplierDebtDetailScreen({super.key, required this.supplierId});

  final int supplierId;

  @override
  State<SupplierDebtDetailScreen> createState() =>
      _SupplierDebtDetailScreenState();
}

class _SupplierDebtDetailScreenState extends State<SupplierDebtDetailScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<SupplierDebtProvider>().fetchDebtDetail(widget.supplierId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<SupplierDebtProvider>();
    final detail = provider.detail;

    return Scaffold(
      appBar: AppBar(title: const Text('Chi tiết công nợ')),
      body: provider.isDetailLoading
          ? const LoadingOverlay()
          : provider.detailError != null
          ? ErrorBanner(
              message: provider.detailError!,
              onRetry: () => context
                  .read<SupplierDebtProvider>()
                  .fetchDebtDetail(widget.supplierId),
            )
          : detail == null
          ? const EmptyState(message: 'Không tìm thấy công nợ nhà cung cấp.')
          : RefreshIndicator(
              onRefresh: () => context
                  .read<SupplierDebtProvider>()
                  .fetchDebtDetail(widget.supplierId),
              child: ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: detail.receipts.length + 1,
                separatorBuilder: (_, _) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  if (index == 0) return _buildHeader(detail);
                  return SupplierDebtReceiptCard(
                    receipt: detail.receipts[index - 1],
                  );
                },
              ),
            ),
    );
  }

  Widget _buildHeader(SupplierDebtDetail detail) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.primaryContainer,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            detail.supplierName,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Mã NCC: ${detail.supplierCode}',
            style: const TextStyle(
              color: AppColors.primaryFixed,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'TỔNG CÔNG NỢ',
            style: TextStyle(
              color: AppColors.primaryFixed,
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '${NumberFormat('#,##0', 'vi_VN').format(detail.totalDebt)} đ',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '${detail.receipts.length} phiếu nhập còn nợ',
            style: const TextStyle(
              color: AppColors.secondaryFixed,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
