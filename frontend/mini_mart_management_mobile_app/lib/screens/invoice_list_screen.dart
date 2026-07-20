import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mini_mart_management_mobile_app/models/e_invoice.dart';
import 'package:mini_mart_management_mobile_app/models/order_summary.dart';
import 'package:mini_mart_management_mobile_app/providers/e_invoice_provider.dart';
import 'package:mini_mart_management_mobile_app/providers/order_provider.dart';
import 'package:mini_mart_management_mobile_app/screens/invoice_detail_screen.dart';
import 'package:mini_mart_management_mobile_app/theme/app_colors.dart';
import 'package:mini_mart_management_mobile_app/widgets/feedback/error_banner.dart';
import 'package:mini_mart_management_mobile_app/widgets/feedback/empty_state.dart';
import 'package:mini_mart_management_mobile_app/widgets/feedback/loading_overlay.dart';
import 'package:mini_mart_management_mobile_app/widgets/layout/mini_mart_app_bar.dart';
import 'package:provider/provider.dart';

class InvoiceListScreen extends StatefulWidget {
  const InvoiceListScreen({this.onMenuTap, super.key});

  final VoidCallback? onMenuTap;

  @override
  State<InvoiceListScreen> createState() => _InvoiceListScreenState();
}

class _InvoiceListScreenState extends State<InvoiceListScreen> {
  final _orderIdController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<EInvoiceProvider>().loadInvoices();
      context.read<OrderProvider>().fetchAllOrders();
    });
  }

  @override
  void dispose() {
    _orderIdController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<EInvoiceProvider>();
    final orderProvider = context.watch<OrderProvider>();
    final invoices = provider.invoices;
    final availableOrders = orderProvider.orders
        .where((order) => order.isCompleted && !order.isCancelled)
        .toList();

    return Scaffold(
      appBar: MiniMartAppBar.primary(
        title: 'Hóa đơn',
        onBrandTap: widget.onMenuTap,
      ),
      backgroundColor: AppColors.backgroundSlate,
      body: Stack(
        children: [
          RefreshIndicator(
            onRefresh: () => context.read<EInvoiceProvider>().loadInvoices(),
            child: CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [
                SliverPadding(
                  padding: const EdgeInsets.all(16),
                  sliver: SliverToBoxAdapter(
                    child: _buildCreateCard(context, availableOrders),
                  ),
                ),
                if (provider.errorMessage != null && invoices.isEmpty)
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: ErrorBanner(message: provider.errorMessage!),
                    ),
                  )
                else if (provider.isLoading && invoices.isEmpty)
                  const SliverFillRemaining(
                    hasScrollBody: false,
                    child: LoadingOverlay(),
                  )
                else if (invoices.isEmpty)
                  const SliverFillRemaining(
                    hasScrollBody: false,
                    child: EmptyState(message: 'Chưa có hóa đơn nào'),
                  )
                else
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                    sliver: SliverList.separated(
                      itemCount: invoices.length,
                      separatorBuilder: (context, index) =>
                          const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        return _InvoiceCard(
                          invoice: invoices[index],
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => InvoiceDetailScreen(
                                invoiceId: invoices[index].eInvoiceId,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
              ],
            ),
          ),
          if (provider.isLoading && invoices.isNotEmpty)
            const Positioned.fill(child: LoadingOverlay()),
        ],
      ),
    );
  }

  Widget _buildCreateCard(
    BuildContext context,
    List<OrderSummary> availableOrders,
  ) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Tạo hóa đơn từ đơn hàng',
              style: TextStyle(
                color: AppColors.primary,
                fontSize: 16,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _orderIdController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Order ID',
                hintText: 'Nhập ID đơn hàng',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton.icon(
                onPressed: availableOrders.isEmpty
                    ? null
                    : () => _openOrderPicker(context, availableOrders),
                icon: const Icon(Icons.list_alt_rounded),
                label: const Text('Chọn từ danh sách đơn hàng'),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 48,
              child: ElevatedButton.icon(
                onPressed: () => _createInvoice(context),
                icon: const Icon(Icons.receipt_long_outlined),
                label: const Text('Tạo hóa đơn'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _openOrderPicker(
    BuildContext context,
    List<OrderSummary> availableOrders,
  ) async {
    final selectedOrder = await showModalBottomSheet<OrderSummary>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) {
        return SafeArea(
          child: SizedBox(
            height: MediaQuery.sizeOf(sheetContext).height * 0.7,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Padding(
                  padding: EdgeInsets.all(16),
                  child: Text(
                    'Chọn đơn hàng đã hoàn tất',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: AppColors.primary,
                    ),
                  ),
                ),
                const Divider(height: 1),
                Expanded(
                  child: ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: availableOrders.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (_, index) {
                      final order = availableOrders[index];
                      return ListTile(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: const BorderSide(color: AppColors.borderGray),
                        ),
                        title: Text(
                          order.orderCode,
                          style: const TextStyle(
                            fontWeight: FontWeight.w800,
                            color: AppColors.primary,
                          ),
                        ),
                        subtitle: Text(
                          'ID: ${order.orderId} • ${DateFormat('dd/MM/yyyy HH:mm').format(order.orderDate)}',
                        ),
                        trailing: Text(
                          NumberFormat.currency(
                            locale: 'vi_VN',
                            symbol: 'đ',
                            decimalDigits: 0,
                          ).format(order.finalAmount),
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            color: AppColors.secondary,
                          ),
                        ),
                        onTap: () => Navigator.pop(sheetContext, order),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );

    if (selectedOrder == null || !context.mounted) return;
    setState(() {
      _orderIdController.text = selectedOrder.orderId.toString();
    });
  }

  Future<void> _createInvoice(BuildContext context) async {
    final orderId = int.tryParse(_orderIdController.text.trim());
    if (orderId == null || orderId <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng nhập Order ID hợp lệ.')),
      );
      return;
    }

    final success = await context
        .read<EInvoiceProvider>()
        .createInvoiceFromOrder(orderId);
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          success
              ? 'Đã tạo hóa đơn thành công.'
              : context.read<EInvoiceProvider>().errorMessage ??
                    'Tạo hóa đơn thất bại.',
        ),
      ),
    );
  }
}

class _InvoiceCard extends StatelessWidget {
  const _InvoiceCard({required this.invoice, required this.onTap});

  final EInvoice invoice;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Card(
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      invoice.orderCode,
                      style: const TextStyle(
                        color: AppColors.primary,
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  _StatusBadge(label: invoice.statusLabel),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'Số HĐ: ${invoice.invoiceNumber}',
                style: const TextStyle(color: AppColors.textMuted),
              ),
              const SizedBox(height: 4),
              Text(
                'Ký hiệu: ${invoice.invoiceSerial}',
                style: const TextStyle(color: AppColors.textMuted),
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    NumberFormat(
                      '#,###',
                      'vi_VN',
                    ).format(invoice.totalAfterVAT),
                    style: const TextStyle(
                      color: AppColors.secondary,
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  Text(
                    invoice.issuedAt == null
                        ? 'Chưa phát hành'
                        : DateFormat(
                            'dd/MM/yyyy HH:mm',
                          ).format(invoice.issuedAt!),
                    style: const TextStyle(color: AppColors.textMuted),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.secondaryFixed,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: AppColors.secondary,
          fontSize: 11,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}
