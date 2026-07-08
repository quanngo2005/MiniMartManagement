import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mini_mart_management_mobile_app/config/api_config.dart';
import 'package:mini_mart_management_mobile_app/theme/app_colors.dart';
import 'package:mini_mart_management_mobile_app/models/order_return.dart';
import 'package:mini_mart_management_mobile_app/providers/order_return_provider.dart';
import 'package:provider/provider.dart';

class ManagerReturnDetailScreen extends StatefulWidget {
  const ManagerReturnDetailScreen({required this.orderReturn, super.key});

  final OrderReturn orderReturn;

  @override
  State<ManagerReturnDetailScreen> createState() =>
      _ManagerReturnDetailScreenState();
}

class _ManagerReturnDetailScreenState extends State<ManagerReturnDetailScreen> {
  final _noteController = TextEditingController();

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _handleApprove() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Phê duyệt hoàn trả'),
        content: Text(
          'Xác nhận duyệt yêu cầu hoàn tiền ${NumberFormat('#,###').format(widget.orderReturn.refundAmount)}đ từ két tiền và cập nhật kho hàng?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.secondary,
            ),
            child: const Text('Đồng ý'),
          ),
        ],
      ),
    );

    if (!mounted) return;
    if (confirmed != true) return;

    final provider = context.read<OrderReturnProvider>();
    final success = await provider.approveReturn(
      widget.orderReturn.orderReturnId,
    );

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Đã phê duyệt và hoàn tất hoàn trả thành công.'),
        ),
      );
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(provider.errorMessage ?? 'Phê duyệt thất bại.')),
      );
    }
  }

  Future<void> _handleReject() async {
    final note = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Từ chối hoàn trả'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Vui lòng nhập lý do từ chối:'),
            const SizedBox(height: 8),
            TextField(
              controller: _noteController,
              decoration: const InputDecoration(
                hintText: 'Nhập lý do...',
                border: OutlineInputBorder(),
              ),
              maxLines: 2,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, null),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () {
              final text = _noteController.text.trim();
              Navigator.pop(context, text.isEmpty ? 'Không rõ lý do' : text);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.statusError,
            ),
            child: const Text('Từ chối'),
          ),
        ],
      ),
    );

    if (!mounted) return;
    if (note == null) return;

    final provider = context.read<OrderReturnProvider>();
    final success = await provider.rejectReturn(
      widget.orderReturn.orderReturnId,
      note,
    );

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Đã từ chối yêu cầu hoàn trả.')),
      );
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(provider.errorMessage ?? 'Từ chối thất bại.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<OrderReturnProvider>();
    final isLoading = provider.isLoading;
    final r = widget.orderReturn;

    final String? imageUrl = r.imageEvidence != null
        ? '${ApiConfig.baseUrl}${r.imageEvidence}'
        : null;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Chi tiết yêu cầu hoàn tiền'),
        backgroundColor: AppColors.primaryContainer,
        foregroundColor: Colors.white,
      ),
      backgroundColor: AppColors.backgroundSlate,
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeaderCard(r),
                const SizedBox(height: 16),
                _buildReturnItemsList(r),
                const SizedBox(height: 16),
                if (imageUrl != null) _buildEvidenceCard(imageUrl),
                const SizedBox(height: 16),
                _buildReasonCard(r),
                const SizedBox(height: 100),
              ],
            ),
          ),
          if (r.status == 1) // Pending
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: _buildBottomActions(isLoading),
            ),
          if (isLoading)
            Container(
              color: Colors.black26,
              child: const Center(child: CircularProgressIndicator()),
            ),
        ],
      ),
    );
  }

  Widget _buildHeaderCard(OrderReturn r) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'MÃ YÊU CẦU',
                      style: TextStyle(
                        color: AppColors.textMuted,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      r.returnCode,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: AppColors.primaryContainer,
                      ),
                    ),
                  ],
                ),
                _buildStatusBadge(r.status, r.statusLabel),
              ],
            ),
            const Divider(height: 24),
            _buildDetailRow('Đơn hàng gốc:', r.originalOrderCode),
            _buildDetailRow(
              'Thời gian mua:',
              DateFormat('dd/MM/yyyy HH:mm').format(r.orderDate),
            ),
            _buildDetailRow('Khách hàng:', r.customerName),
            _buildDetailRow('Thu ngân yêu cầu:', r.employeeName),
            if (r.shiftCode != null && r.shiftCode!.isNotEmpty)
              _buildDetailRow('Ca làm việc:', r.shiftCode!),
            const Divider(height: 24),
            _buildDetailRow(
              'Số tiền hoàn lại:',
              '${NumberFormat('#,###').format(r.refundAmount)}đ',
              isBoldValue: true,
              valueColor: AppColors.statusError,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(
    String label,
    String value, {
    bool isBoldValue = false,
    Color? valueColor,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(color: AppColors.textMuted, fontSize: 13),
          ),
          Text(
            value,
            style: TextStyle(
              color: valueColor ?? AppColors.textDark,
              fontSize: 13,
              fontWeight: isBoldValue ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReturnItemsList(OrderReturn r) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            'Sản phẩm hoàn trả',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
              color: AppColors.textDark,
            ),
          ),
        ),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: r.orderReturnDetails.length,
          itemBuilder: (context, index) {
            final d = r.orderReturnDetails[index];
            return Card(
              margin: const EdgeInsets.symmetric(vertical: 4),
              elevation: 0.5,
              child: ListTile(
                title: Text(
                  d.productName,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                subtitle: Text(
                  'Mã: ${d.productCode} | SL hoàn trả: ${d.quantity}',
                  style: const TextStyle(fontSize: 12),
                ),
                trailing: Text(
                  '${NumberFormat('#,###').format(d.totalPrice)}đ',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildEvidenceCard(String imageUrl) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            'Hình ảnh minh chứng',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
              color: AppColors.textDark,
            ),
          ),
        ),
        Card(
          elevation: 1,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                imageUrl,
                fit: BoxFit.cover,
                width: double.infinity,
                height: 200,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    height: 150,
                    color: AppColors.surfaceContainerHigh,
                    alignment: Alignment.center,
                    child: const Text('Không thể tải hình ảnh minh chứng'),
                  );
                },
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildReasonCard(OrderReturn r) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'PHÂN LOẠI:',
                  style: TextStyle(
                    color: AppColors.textMuted,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  r.classifyLabel,
                  style: TextStyle(
                    color: r.classify == 1
                        ? AppColors.statusError
                        : AppColors.secondary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const Divider(height: 20),
            const Text(
              'LÝ DO CHI TIẾT:',
              style: TextStyle(
                color: AppColors.textMuted,
                fontSize: 11,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              r.reason,
              style: const TextStyle(
                color: AppColors.textDark,
                fontSize: 13,
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomActions(bool isLoading) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Expanded(
            child: SizedBox(
              height: 46,
              child: OutlinedButton.icon(
                onPressed: isLoading ? null : _handleReject,
                icon: const Icon(Icons.cancel_outlined),
                label: const Text('Từ chối'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.statusError,
                  side: const BorderSide(color: AppColors.statusError),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: SizedBox(
              height: 46,
              child: ElevatedButton.icon(
                onPressed: isLoading ? null : _handleApprove,
                icon: const Icon(Icons.check_circle_outline),
                label: const Text('Phê duyệt'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.secondary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(int status, String label) {
    Color bg = AppColors.surfaceContainerLow;
    Color fg = AppColors.textMuted;

    if (status == 1) {
      bg = AppColors.warningContainer;
      fg = AppColors.statusWarning;
    } else if (status == 2) {
      bg = AppColors.secondaryContainer;
      fg = AppColors.secondary;
    } else if (status == 3) {
      bg = AppColors.errorContainer;
      fg = AppColors.statusError;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        label,
        style: TextStyle(color: fg, fontSize: 12, fontWeight: FontWeight.bold),
      ),
    );
  }
}
