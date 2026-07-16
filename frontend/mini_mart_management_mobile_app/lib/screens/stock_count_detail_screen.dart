import 'package:flutter/material.dart';
import 'package:mini_mart_management_mobile_app/models/scanned_product.dart';
import 'package:mini_mart_management_mobile_app/screens/barcode_scanner_screen.dart';
import 'package:mini_mart_management_mobile_app/theme/app_colors.dart';
import 'package:mini_mart_management_mobile_app/widgets/layout/mini_mart_app_bar.dart';

class StockCountDetailScreen extends StatefulWidget {
  const StockCountDetailScreen({
    this.documentCode = 'Phiếu kiểm kê mới',
    this.location = 'Kho Tổng · Khu vực A – Bánh kẹo',
    this.staffName = 'Nguyễn Văn An',
    super.key,
  });

  final String documentCode;
  final String location;
  final String staffName;

  @override
  State<StockCountDetailScreen> createState() => _StockCountDetailScreenState();
}

class _StockCountDetailScreenState extends State<StockCountDetailScreen> {
  final List<_StockCountLine> _lines = [];

  int get _discrepancyCount =>
      _lines.where((line) => line.variance != 0).length;

  Future<void> _openBarcodeScanner() async {
    final scannedProducts = await Navigator.of(context)
        .push<List<ScannedProduct>>(
          MaterialPageRoute<List<ScannedProduct>>(
            builder: (_) => const BarcodeScannerScreen(),
          ),
        );
    if (!mounted || scannedProducts == null || scannedProducts.isEmpty) return;

    setState(() {
      for (final scanned in scannedProducts) {
        final existingLine = _lines.where(
          (line) => line.barcode == scanned.product.barcode,
        );
        if (existingLine.isEmpty) {
          _lines.add(
            _StockCountLine(
              barcode: scanned.product.barcode,
              productName: scanned.product.productName,
              expectedQuantity: scanned.product.stockQuantity,
              actualQuantity: scanned.quantity,
            ),
          );
        } else {
          existingLine.first.actualQuantity += scanned.quantity;
        }
      }
    });
  }

  void _changeQuantity(_StockCountLine line, int delta) {
    final nextQuantity = line.actualQuantity + delta;
    if (nextQuantity < 0) return;
    setState(() => line.actualQuantity = nextQuantity);
  }

  void _completeStockCount() {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(
            _lines.isEmpty
                ? 'Hãy quét ít nhất một sản phẩm trước khi hoàn tất.'
                : 'Đã ghi nhận kiểm kê. Chờ quản lý duyệt.',
          ),
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MiniMartAppBar.secondary(title: 'Kiểm kê kho hàng'),
      backgroundColor: AppColors.backgroundSlate,
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 104),
        children: [
          _buildDocumentHeader(context),
          const SizedBox(height: 12),
          _buildScannerCallToAction(context),
          const SizedBox(height: 12),
          _buildSummary(context),
          const SizedBox(height: 20),
          _buildSectionHeader(context),
          const SizedBox(height: 8),
          if (_lines.isEmpty)
            _buildEmptyState(context)
          else
            ..._lines.map(
              (line) => _StockCountLineTile(
                line: line,
                onIncrement: () => _changeQuantity(line, 1),
                onDecrement: () => _changeQuantity(line, -1),
              ),
            ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          child: SizedBox(
            height: 48,
            child: ElevatedButton.icon(
              onPressed: _completeStockCount,
              icon: const Icon(Icons.fact_check_outlined),
              label: const Text('Hoàn tất kiểm kê'),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDocumentHeader(BuildContext context) {
    return DecoratedBox(
      decoration: _panelDecoration(),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    widget.documentCode,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                const _CountingStatusBadge(),
              ],
            ),
            const SizedBox(height: 12),
            _MetadataRow(
              icon: Icons.warehouse_outlined,
              value: widget.location,
            ),
            const SizedBox(height: 8),
            _MetadataRow(
              icon: Icons.person_outline_rounded,
              value: '${widget.staffName} · 15/07/2026, 09:30',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScannerCallToAction(BuildContext context) {
    return Material(
      color: AppColors.primaryContainer,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: _openBarcodeScanner,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              const DecoratedBox(
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.all(Radius.circular(10)),
                ),
                child: SizedBox(
                  width: 48,
                  height: 48,
                  child: Icon(
                    Icons.qr_code_scanner_rounded,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Quét mã vạch để thêm sản phẩm',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Mở máy quét và cập nhật số lượng thực tế.',
                      style: TextStyle(color: Colors.white70, fontSize: 13),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right_rounded, color: Colors.white),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSummary(BuildContext context) {
    return DecoratedBox(
      decoration: _panelDecoration(),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 14),
        child: Row(
          children: [
            _SummaryMetric(
              label: 'Đã kiểm',
              value: '${_lines.length} sản phẩm',
            ),
            const _VerticalDivider(),
            _SummaryMetric(
              label: 'Chênh lệch',
              value: '$_discrepancyCount sản phẩm',
              valueColor: _discrepancyCount == 0
                  ? AppColors.secondary
                  : AppColors.statusWarning,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context) {
    return Text(
      'Danh sách đã kiểm',
      style: Theme.of(context).textTheme.titleMedium?.copyWith(
        color: AppColors.primary,
        fontWeight: FontWeight.w800,
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return DecoratedBox(
      decoration: _panelDecoration(),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const Icon(
              Icons.inventory_2_outlined,
              color: AppColors.textMuted,
              size: 36,
            ),
            const SizedBox(height: 12),
            Text(
              'Chưa có sản phẩm được kiểm',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'Quét mã vạch để bắt đầu kiểm kê.',
              style: TextStyle(color: AppColors.textMuted),
            ),
          ],
        ),
      ),
    );
  }

  BoxDecoration _panelDecoration() => BoxDecoration(
    color: AppColors.surfaceContainerLowest,
    border: Border.all(color: AppColors.borderGray),
    borderRadius: BorderRadius.circular(12),
  );
}

class _StockCountLine {
  _StockCountLine({
    required this.barcode,
    required this.productName,
    required this.expectedQuantity,
    required this.actualQuantity,
  });

  final String barcode;
  final String productName;
  final int expectedQuantity;
  int actualQuantity;

  int get variance => actualQuantity - expectedQuantity;
}

class _CountingStatusBadge extends StatelessWidget {
  const _CountingStatusBadge();

  @override
  Widget build(BuildContext context) {
    return const DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.warningContainer,
        borderRadius: BorderRadius.all(Radius.circular(999)),
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        child: Text(
          'Đang kiểm kê',
          style: TextStyle(
            color: AppColors.statusWarning,
            fontSize: 12,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}

class _MetadataRow extends StatelessWidget {
  const _MetadataRow({required this.icon, required this.value});

  final IconData icon;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AppColors.textMuted),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(color: AppColors.textDark, fontSize: 13),
          ),
        ),
      ],
    );
  }
}

class _SummaryMetric extends StatelessWidget {
  const _SummaryMetric({
    required this.label,
    required this.value,
    this.valueColor = AppColors.primary,
  });

  final String label;
  final String value;
  final Color valueColor;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Text(
            label,
            style: const TextStyle(color: AppColors.textMuted, fontSize: 12),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: valueColor,
              fontSize: 14,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _VerticalDivider extends StatelessWidget {
  const _VerticalDivider();

  @override
  Widget build(BuildContext context) => const SizedBox(
    height: 36,
    child: VerticalDivider(color: AppColors.borderGray),
  );
}

class _StockCountLineTile extends StatelessWidget {
  const _StockCountLineTile({
    required this.line,
    required this.onIncrement,
    required this.onDecrement,
  });

  final _StockCountLine line;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;

  @override
  Widget build(BuildContext context) {
    final varianceColor = line.variance < 0
        ? AppColors.statusError
        : line.variance > 0
        ? AppColors.statusWarning
        : AppColors.secondary;
    final varianceLabel = line.variance > 0
        ? '+${line.variance}'
        : '${line.variance}';

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerLowest,
          border: Border.all(color: AppColors.borderGray),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                line.productName,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                line.barcode,
                style: const TextStyle(
                  color: AppColors.textMuted,
                  fontSize: 12,
                  fontFamily: 'monospace',
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _QuantityLabel(
                      label: 'Tồn kho',
                      value: '${line.expectedQuantity}',
                    ),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const Text(
                          'Thực tế',
                          style: TextStyle(
                            color: AppColors.textMuted,
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(height: 4),
                        _QuantityStepper(
                          quantity: line.actualQuantity,
                          onIncrement: onIncrement,
                          onDecrement: onDecrement,
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: _QuantityLabel(
                      label: 'Chênh lệch',
                      value: varianceLabel,
                      valueColor: varianceColor,
                    ),
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

class _QuantityLabel extends StatelessWidget {
  const _QuantityLabel({
    required this.label,
    required this.value,
    this.valueColor = AppColors.primary,
  });

  final String label;
  final String value;
  final Color valueColor;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        label,
        style: const TextStyle(color: AppColors.textMuted, fontSize: 12),
      ),
      const SizedBox(height: 4),
      Text(
        value,
        style: TextStyle(
          color: valueColor,
          fontSize: 15,
          fontWeight: FontWeight.w800,
        ),
      ),
    ],
  );
}

class _QuantityStepper extends StatelessWidget {
  const _QuantityStepper({
    required this.quantity,
    required this.onIncrement,
    required this.onDecrement,
  });

  final int quantity;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;

  @override
  Widget build(BuildContext context) => DecoratedBox(
    decoration: BoxDecoration(
      border: Border.all(color: AppColors.borderGray),
      borderRadius: BorderRadius.circular(8),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: 40,
          height: 40,
          child: IconButton(
            onPressed: onDecrement,
            icon: const Icon(Icons.remove_rounded, size: 18),
          ),
        ),
        SizedBox(
          width: 28,
          child: Text(
            '$quantity',
            textAlign: TextAlign.center,
            style: const TextStyle(fontWeight: FontWeight.w800),
          ),
        ),
        SizedBox(
          width: 40,
          height: 40,
          child: IconButton(
            onPressed: onIncrement,
            icon: const Icon(Icons.add_rounded, size: 18),
          ),
        ),
      ],
    ),
  );
}
