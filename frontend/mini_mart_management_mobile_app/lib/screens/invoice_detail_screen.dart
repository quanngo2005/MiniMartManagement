import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mini_mart_management_mobile_app/config/store_config.dart';
import 'package:mini_mart_management_mobile_app/models/e_invoice.dart';
import 'package:mini_mart_management_mobile_app/providers/e_invoice_provider.dart';
import 'package:mini_mart_management_mobile_app/theme/app_colors.dart';
import 'package:mini_mart_management_mobile_app/widgets/feedback/error_banner.dart';
import 'package:mini_mart_management_mobile_app/widgets/feedback/loading_overlay.dart';
import 'package:provider/provider.dart';

class InvoiceDetailScreen extends StatefulWidget {
  const InvoiceDetailScreen({required this.invoiceId, super.key});

  final int invoiceId;

  @override
  State<InvoiceDetailScreen> createState() => _InvoiceDetailScreenState();
}

class _InvoiceDetailScreenState extends State<InvoiceDetailScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<EInvoiceProvider>().loadInvoiceDetail(widget.invoiceId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<EInvoiceProvider>();
    final detail = provider.selectedInvoice;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Chi tiết hóa đơn'),
        backgroundColor: AppColors.primaryContainer,
        foregroundColor: Colors.white,
      ),
      backgroundColor: AppColors.backgroundSlate,
      body: provider.isLoading && detail == null
          ? const LoadingOverlay()
          : provider.errorMessage != null && detail == null
          ? Padding(
              padding: const EdgeInsets.all(16),
              child: ErrorBanner(message: provider.errorMessage!),
            )
          : detail == null
          ? const SizedBox.shrink()
          : _buildBody(detail),
    );
  }

  Widget _buildBody(EInvoiceDetailResponse detail) {
    return RefreshIndicator(
      onRefresh: () =>
          context.read<EInvoiceProvider>().loadInvoiceDetail(widget.invoiceId),
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(12),
        children: [
          _StoreHeader(),
          const SizedBox(height: 10),
          _InvoiceHeaderCard(invoice: detail.invoice),
          const SizedBox(height: 10),
          _SectionTitle(title: 'Chi tiết hàng hóa'),
          const SizedBox(height: 6),
          _ItemsTable(items: detail.items),
          const SizedBox(height: 10),
          _PaymentSummary(items: detail.items, invoice: detail.invoice),
          const SizedBox(height: 10),
          _PaymentMethodCard(invoice: detail.invoice),
          const SizedBox(height: 10),
          _ActionButtons(invoice: detail.invoice),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: const TextStyle(
        color: AppColors.primary,
        fontSize: 15,
        fontWeight: FontWeight.w800,
      ),
    );
  }
}

class _StoreHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Column(
          children: [
            Text(
              StoreConfig.name,
              style: const TextStyle(
                color: AppColors.primary,
                fontSize: 17,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 6),
            _infoRow(Icons.location_on_outlined, StoreConfig.address),
            const SizedBox(height: 4),
            _infoRow(Icons.phone_outlined, StoreConfig.phone),
            const SizedBox(height: 4),
            _infoRow(Icons.description_outlined, 'MST: ${StoreConfig.taxCode}'),
          ],
        ),
      ),
    );
  }

  Widget _infoRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 14, color: AppColors.textMuted),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(color: AppColors.textMuted, fontSize: 12),
          ),
        ),
      ],
    );
  }
}

class _InvoiceHeaderCard extends StatelessWidget {
  const _InvoiceHeaderCard({required this.invoice});

  final EInvoice invoice;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color:
                        (invoice.status
                                ? AppColors.secondary
                                : AppColors.statusWarning)
                            .withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    invoice.statusLabel,
                    style: TextStyle(
                      color: invoice.status
                          ? AppColors.secondary
                          : AppColors.statusWarning,
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            _row('Số hóa đơn', invoice.invoiceNumber),
            _row('Ký hiệu', invoice.invoiceSerial),
            _row('Khách hàng', invoice.buyerName ?? 'Khách lẻ'),
            if (invoice.buyerTaxCode != null &&
                invoice.buyerTaxCode!.isNotEmpty)
              _row('Mã số thuế', invoice.buyerTaxCode!),
            _row(
              'Ngày phát hành',
              invoice.issuedAt == null
                  ? 'Chưa phát hành'
                  : DateFormat('dd/MM/yyyy HH:mm').format(invoice.issuedAt!),
            ),
          ],
        ),
      ),
    );
  }

  Widget _row(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: AppColors.textMuted)),
          Text(
            value,
            style: const TextStyle(
              color: AppColors.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _ItemsTable extends StatelessWidget {
  const _ItemsTable({required this.items});

  final List<EInvoiceDetail> items;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          const Divider(height: 1, color: AppColors.borderGray),
          ...items.map((item) => _ItemRow(item: item)),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      color: AppColors.primaryContainer.withValues(alpha: 0.04),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: const Row(
        children: [
          Expanded(flex: 3, child: _HeaderText('Tên hàng')),
          Expanded(flex: 1, child: _HeaderText('SL', align: right)),
          Expanded(flex: 2, child: _HeaderText('Đơn giá', align: right)),
          Expanded(flex: 2, child: _HeaderText('Thành tiền', align: right)),
        ],
      ),
    );
  }
}

const right = TextAlign.right;

class _HeaderText extends StatelessWidget {
  const _HeaderText(this.text, {this.align});

  final String text;
  final TextAlign? align;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      textAlign: align,
      style: const TextStyle(
        color: AppColors.textMuted,
        fontSize: 11,
        fontWeight: FontWeight.w700,
      ),
    );
  }
}

class _ItemRow extends StatelessWidget {
  const _ItemRow({required this.item});

  final EInvoiceDetail item;

  @override
  Widget build(BuildContext context) {
    final fmt = NumberFormat('#,###', 'vi_VN');
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: AppColors.borderGray.withValues(alpha: 0.5),
          ),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            flex: 3,
            child: Row(
              children: [
                Flexible(
                  child: Text(
                    item.productName,
                    style: const TextStyle(
                      color: AppColors.primary,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (item.isGift) ...[
                  const SizedBox(width: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 4,
                      vertical: 1,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.secondary.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Text(
                      'Q',
                      style: TextStyle(
                        color: AppColors.secondary,
                        fontSize: 9,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
          Expanded(
            flex: 1,
            child: Text(
              '${item.quantity}${item.unit}',
              textAlign: TextAlign.right,
              style: const TextStyle(color: AppColors.primary, fontSize: 13),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              fmt.format(item.unitPrice),
              textAlign: TextAlign.right,
              style: const TextStyle(color: AppColors.primary, fontSize: 13),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              fmt.format(item.amountAfterVAT),
              textAlign: TextAlign.right,
              style: const TextStyle(
                color: AppColors.secondary,
                fontSize: 13,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PaymentSummary extends StatelessWidget {
  const _PaymentSummary({required this.items, required this.invoice});

  final List<EInvoiceDetail> items;
  final EInvoice invoice;

  @override
  Widget build(BuildContext context) {
    final fmt = NumberFormat('#,###', 'vi_VN');
    final subtotal = items.fold<double>(
      0,
      (sum, item) => sum + item.unitPrice * item.quantity,
    );
    final totalDiscount = items.fold<double>(
      0,
      (sum, item) => sum + item.discountAmount,
    );

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _summaryRow('Tạm tính', fmt.format(subtotal)),
            if (totalDiscount > 0)
              _summaryRow(
                'Giảm giá / KM',
                '-${fmt.format(totalDiscount)}',
                valueColor: AppColors.statusError,
              ),
            _summaryRow('Thuế VAT', fmt.format(invoice.vatAmount)),
            const Divider(height: 20),
            _summaryRow(
              'Tổng cộng',
              fmt.format(invoice.totalAfterVAT),
              valueColor: AppColors.secondary,
              bold: true,
              large: true,
            ),
          ],
        ),
      ),
    );
  }

  Widget _summaryRow(
    String label,
    String value, {
    Color? valueColor,
    bool bold = false,
    bool large = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: AppColors.textMuted,
              fontSize: large ? 15 : 13,
              fontWeight: bold ? FontWeight.w700 : FontWeight.w500,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              color: valueColor ?? AppColors.primary,
              fontSize: large ? 17 : 14,
              fontWeight: bold ? FontWeight.w800 : FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _PaymentMethodCard extends StatelessWidget {
  const _PaymentMethodCard({required this.invoice});

  final EInvoice invoice;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            const Icon(
              Icons.payments_outlined,
              size: 20,
              color: AppColors.primary,
            ),
            const SizedBox(width: 10),
            const Text(
              'Hình thức thanh toán:',
              style: TextStyle(color: AppColors.textMuted, fontSize: 13),
            ),
            const SizedBox(width: 8),
            Text(
              paymentMethodLabel(invoice.paymentMethod),
              style: const TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.w700,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ActionButtons extends StatelessWidget {
  const _ActionButtons({required this.invoice});

  final EInvoice invoice;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _ActionButton(
            icon: Icons.print_outlined,
            label: 'In hóa đơn',
            onTap: () => _mockExportPdf(context),
          ),
        ),
        if (invoice.status) ...[
          const SizedBox(width: 10),
          Expanded(
            child: _ActionButton(
              icon: Icons.send_outlined,
              label: 'Gửi lại',
              onTap: () => _showSnackBar(context, 'Đã gửi lại hóa đơn'),
            ),
          ),
        ],
        const SizedBox(width: 10),
        Expanded(
          child: _ActionButton(
            icon: Icons.cancel_outlined,
            label: 'Hủy hóa đơn',
            color: AppColors.statusError,
            onTap: () => _confirmCancel(context),
          ),
        ),
      ],
    );
  }

  void _mockExportPdf(BuildContext context) {
    _showSnackBar(context, 'Đang xuất PDF...');
  }

  void _confirmCancel(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Xác nhận hủy'),
        content: const Text('Bạn có chắc muốn hủy hóa đơn này?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Không'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              _showSnackBar(context, 'Đã hủy hóa đơn');
            },
            child: const Text(
              'Hủy',
              style: TextStyle(color: AppColors.statusError),
            ),
          ),
        ],
      ),
    );
  }

  void _showSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), behavior: SnackBarBehavior.floating),
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
    this.color,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final btnColor = color ?? AppColors.primary;
    return SizedBox(
      height: 44,
      child: OutlinedButton.icon(
        onPressed: onTap,
        icon: Icon(icon, size: 18),
        label: Text(label, style: const TextStyle(fontSize: 12)),
        style: OutlinedButton.styleFrom(
          foregroundColor: btnColor,
          side: BorderSide(color: btnColor.withValues(alpha: 0.4)),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ),
    );
  }
}
