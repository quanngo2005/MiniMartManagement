import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:mini_mart_management_mobile_app/models/product_lookup.dart';
import 'package:mini_mart_management_mobile_app/models/scanned_product.dart';
import 'package:mini_mart_management_mobile_app/providers/inventory_lookup_provider.dart';
import 'package:mini_mart_management_mobile_app/theme/app_colors.dart';
import 'package:mini_mart_management_mobile_app/widgets/feedback/loading_overlay.dart';
import 'package:mini_mart_management_mobile_app/widgets/layout/mini_mart_app_bar.dart';
import 'package:provider/provider.dart';

class BarcodeScannerScreen extends StatefulWidget {
  const BarcodeScannerScreen({super.key});

  @override
  State<BarcodeScannerScreen> createState() => _BarcodeScannerScreenState();
}

class _BarcodeScannerScreenState extends State<BarcodeScannerScreen>
    with WidgetsBindingObserver {
  final MobileScannerController _scannerController = MobileScannerController(
    autoZoom: true,
  );
  final TextEditingController _manualController = TextEditingController();
  final FocusNode _manualFocusNode = FocusNode();
  final Map<String, _ScannedEntry> _scannedItems = {};

  bool _torchOn = false;
  bool _isProcessing = false;
  String? _errorMessage;

  int get _totalQuantity =>
      _scannedItems.values.fold(0, (sum, e) => sum + e.quantity);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _scannerController.dispose();
    _manualController.dispose();
    _manualFocusNode.dispose();
    super.dispose();
  }

  void _addOrIncrement(ProductLookup product) {
    final entry = _scannedItems[product.barcode];
    if (entry != null) {
      entry.quantity++;
    } else {
      _scannedItems[product.barcode] = _ScannedEntry(product);
    }
    HapticFeedback.lightImpact();
    _errorMessage = null;
  }

  Future<void> _onBarcodeDetected(String rawValue) async {
    if (_isProcessing) return;
    setState(() => _isProcessing = true);

    final provider = context.read<InventoryLookupProvider>();
    final product = await provider.fetchProductByBarcode(rawValue);

    if (!mounted) return;

    if (product != null) {
      _addOrIncrement(product);
      setState(() => _isProcessing = false);
    } else {
      HapticFeedback.heavyImpact();
      setState(() {
        _errorMessage =
            provider.errorMessage ??
            'Không tìm thấy sản phẩm với mã vạch "$rawValue"';
        _isProcessing = false;
      });
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.resumed:
        _scannerController.start();
        return;
      case AppLifecycleState.inactive:
      case AppLifecycleState.paused:
      case AppLifecycleState.hidden:
      case AppLifecycleState.detached:
        _scannerController.stop();
        return;
    }
  }

  Future<void> _onManualSubmit() async {
    final rawValue = _manualController.text.trim();
    if (rawValue.isEmpty) return;
    _manualController.clear();
    _manualFocusNode.unfocus();
    await _onBarcodeDetected(rawValue);
  }

  void _decrement(String barcode) {
    final entry = _scannedItems[barcode];
    if (entry == null) return;
    if (entry.quantity <= 1) {
      _scannedItems.remove(barcode);
    } else {
      entry.quantity--;
    }
    setState(() {});
  }

  void _removeItem(String barcode) {
    _scannedItems.remove(barcode);
    setState(() {});
  }

  void _onConfirm() {
    final result = _scannedItems.values
        .map((e) => ScannedProduct(product: e.product, quantity: e.quantity))
        .toList(growable: false);
    Navigator.pop(context, result);
  }

  void _toggleTorch() {
    _scannerController.toggleTorch();
    setState(() => _torchOn = !_torchOn);
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<InventoryLookupProvider>();
    final hasItems = _scannedItems.isNotEmpty;

    return Scaffold(
      appBar: _buildAppBar(),
      body: Stack(
        children: [
          Column(
            children: [
              _buildScannerSection(),
              _buildManualInputSection(),
              if (_errorMessage != null && !provider.isScanning)
                _buildErrorBanner(),
              if (hasItems) _buildScannedList(),
            ],
          ),
          if (provider.isScanning) const LoadingOverlay(),
        ],
      ),
      bottomNavigationBar: hasItems
          ? SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                child: SizedBox(
                  height: 48,
                  child: ElevatedButton.icon(
                    onPressed: _onConfirm,
                    icon: const Icon(Icons.check_circle_outline_rounded),
                    label: Text('Xác nhận ($_totalQuantity)'),
                  ),
                ),
              ),
            )
          : null,
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return MiniMartAppBar.scanner(
      title: 'Quét mã vạch',
      isTorchOn: _torchOn,
      onToggleTorch: _toggleTorch,
    );
  }

  Widget _buildScannerSection() {
    return SizedBox(
      height: 280,
      width: double.infinity,
      child: Stack(
        children: [
          MobileScanner(
            controller: _scannerController,
            errorBuilder: (context, error) => _buildCameraError(error),
            onDetect: (capture) {
              final barcode = capture.barcodes.firstOrNull;
              if (barcode?.rawValue != null && !_isProcessing) {
                _onBarcodeDetected(barcode!.rawValue!);
              }
            },
          ),
          _buildViewfinderOverlay(),
          if (_isProcessing)
            Container(
              color: Colors.black54,
              child: const Center(
                child: CircularProgressIndicator(color: Colors.white),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildCameraError(MobileScannerException error) {
    final isPermissionError =
        error.errorCode == MobileScannerErrorCode.permissionDenied;

    return ColoredBox(
      color: Colors.black,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.camera_alt_outlined,
                color: Colors.white,
                size: 36,
              ),
              const SizedBox(height: 12),
              Text(
                isPermissionError
                    ? 'Chưa được cấp quyền dùng camera.'
                    : 'Không thể khởi động camera để quét mã vạch.',
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white),
              ),
              const SizedBox(height: 12),
              OutlinedButton(
                onPressed: _scannerController.start,
                style: OutlinedButton.styleFrom(foregroundColor: Colors.white),
                child: const Text('Thử lại'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildViewfinderOverlay() {
    return CustomPaint(size: Size.infinite, painter: _ViewfinderPainter());
  }

  Widget _buildManualInputSection() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: Column(
        children: [
          Row(
            children: [
              const Expanded(
                child: Divider(thickness: 1, color: AppColors.outlineVariant),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Text(
                  'hoặc nhập mã vạch',
                  style: TextStyle(
                    color: AppColors.textMuted,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              const Expanded(
                child: Divider(thickness: 1, color: AppColors.outlineVariant),
              ),
            ],
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _manualController,
            focusNode: _manualFocusNode,
            decoration: InputDecoration(
              hintText: 'Nhập mã vạch...',
              prefixIcon: const Icon(Icons.qr_code_scanner),
              suffixIcon: IconButton(
                icon: const Icon(Icons.search),
                onPressed: _onManualSubmit,
              ),
              filled: true,
              fillColor: AppColors.backgroundSlate,
              isDense: true,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: AppColors.outlineVariant),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: AppColors.outlineVariant),
              ),
            ),
            onSubmitted: (_) => _onManualSubmit(),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorBanner() {
    return Container(
      color: AppColors.errorContainer,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          const Icon(
            Icons.error_outline,
            color: AppColors.statusError,
            size: 18,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              _errorMessage!,
              style: const TextStyle(fontSize: 13, color: AppColors.primary),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close, size: 18),
            onPressed: () => setState(() => _errorMessage = null),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        ],
      ),
    );
  }

  Widget _buildScannedList() {
    return Expanded(
      child: Container(
        color: Colors.white,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
              child: Row(
                children: [
                  Text(
                    'Đã quét (${_scannedItems.length} mã)',
                    style: TextStyle(
                      color: AppColors.textMuted,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const Spacer(),
                  GestureDetector(
                    onTap: () {
                      _scannedItems.clear();
                      setState(() {});
                    },
                    child: Text(
                      'Xoá tất cả',
                      style: TextStyle(
                        color: AppColors.statusError,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                itemCount: _scannedItems.length,
                separatorBuilder: (_, _) =>
                    const Divider(height: 1, indent: 16, endIndent: 16),
                itemBuilder: (_, i) {
                  final entry = _scannedItems.values.elementAt(i);
                  return _ScannedItemTile(
                    entry: entry,
                    onIncrement: () {
                      entry.quantity++;
                      setState(() {});
                    },
                    onDecrement: () => _decrement(entry.product.barcode),
                    onRemove: () => _removeItem(entry.product.barcode),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ScannedEntry {
  final ProductLookup product;
  int quantity;

  _ScannedEntry(this.product) : quantity = 1;
}

class _ScannedItemTile extends StatelessWidget {
  const _ScannedItemTile({
    required this.entry,
    required this.onIncrement,
    required this.onDecrement,
    required this.onRemove,
  });

  final _ScannedEntry entry;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final product = entry.product;
    final currencyFormatter = NumberFormat.currency(
      locale: 'vi_VN',
      symbol: 'đ',
    );

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.productName,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  '${product.barcode} | ${currencyFormatter.format(product.sellingPrice)}',
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textMuted,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Container(
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.outlineVariant),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                InkWell(
                  onTap: onDecrement,
                  child: const Padding(
                    padding: EdgeInsets.all(6),
                    child: Icon(Icons.remove, size: 18),
                  ),
                ),
                SizedBox(
                  width: 28,
                  child: Text(
                    '${entry.quantity}',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ),
                InkWell(
                  onTap: onIncrement,
                  child: const Padding(
                    padding: EdgeInsets.all(6),
                    child: Icon(Icons.add, size: 18),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 4),
          IconButton(
            onPressed: onRemove,
            icon: const Icon(
              Icons.close,
              size: 18,
              color: AppColors.statusError,
            ),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        ],
      ),
    );
  }
}

class _ViewfinderPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black54
      ..style = PaintingStyle.fill;

    final scanRect = Rect.fromCenter(
      center: Offset(size.width / 2, size.height / 2),
      width: size.width * 0.7,
      height: size.height * 0.5,
    );

    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, scanRect.top), paint);
    canvas.drawRect(
      Rect.fromLTWH(
        0,
        scanRect.bottom,
        size.width,
        size.height - scanRect.bottom,
      ),
      paint,
    );
    canvas.drawRect(
      Rect.fromLTWH(0, scanRect.top, scanRect.left, scanRect.height),
      paint,
    );
    canvas.drawRect(
      Rect.fromLTWH(
        scanRect.right,
        scanRect.top,
        size.width - scanRect.right,
        scanRect.height,
      ),
      paint,
    );

    final cornerPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;

    const cornerLength = 24.0;
    final corners = [
      (scanRect.topLeft, 1, 1),
      (scanRect.topRight, -1, 1),
      (scanRect.bottomLeft, 1, -1),
      (scanRect.bottomRight, -1, -1),
    ];

    for (final (point, dx, dy) in corners) {
      canvas.drawLine(
        point,
        Offset(point.dx + dx * cornerLength, point.dy),
        cornerPaint,
      );
      canvas.drawLine(
        point,
        Offset(point.dx, point.dy + dy * cornerLength),
        cornerPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
