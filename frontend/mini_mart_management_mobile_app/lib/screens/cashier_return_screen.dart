import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mini_mart_management_mobile_app/theme/app_colors.dart';
import 'package:mini_mart_management_mobile_app/widgets/layout/cashier_bottom_navigation_bar.dart';
import 'package:mini_mart_management_mobile_app/providers/order_return_provider.dart';
import 'package:mini_mart_management_mobile_app/providers/shift_provider.dart';
import 'package:provider/provider.dart';

class CashierReturnScreen extends StatefulWidget {
  const CashierReturnScreen({super.key});

  @override
  State<CashierReturnScreen> createState() => _CashierReturnScreenState();
}

class _CashierReturnScreenState extends State<CashierReturnScreen> {
  final _searchController = TextEditingController();
  final _reasonController = TextEditingController();

  int _classify = 1; // 1 = Product Error, 2 = No Longer Needed
  final Map<int, int> _selectedQuantities = {}; // ProductId -> Quantity
  final Map<int, bool> _selectedItems = {}; // ProductId -> IsSelected
  String? _localImagePath;
  bool _isUploadingImage = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ShiftProvider>().fetchCurrentShift();
      context.read<OrderReturnProvider>().clearCurrentOrder();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _reasonController.dispose();
    super.dispose();
  }

  Future<void> _handleSearch() async {
    final code = _searchController.text.trim();
    if (code.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng nhập mã hóa đơn.')),
      );
      return;
    }
    final provider = context.read<OrderReturnProvider>();
    await provider.searchOrder(code);

    if (!mounted) return;

    // Reset selections when new order is loaded
    setState(() {
      _selectedItems.clear();
      _selectedQuantities.clear();
      _localImagePath = null;
    });
  }

  Future<void> _mockCaptureImage() async {
    setState(() => _isUploadingImage = true);
    try {
      final tempDir = Directory.systemTemp;
      final tempFile = File(
        '${tempDir.path}/evidence_image_${DateTime.now().millisecondsSinceEpoch}.png',
      );

      // Write 1x1 transparent PNG bytes
      await tempFile.writeAsBytes([
        137,
        80,
        78,
        71,
        13,
        10,
        26,
        10,
        0,
        0,
        0,
        13,
        73,
        72,
        68,
        82,
        0,
        0,
        0,
        1,
        0,
        0,
        0,
        1,
        8,
        6,
        0,
        0,
        0,
        31,
        21,
        196,
        137,
        0,
        0,
        0,
        10,
        73,
        68,
        65,
        84,
        120,
        156,
        99,
        0,
        1,
        0,
        0,
        5,
        0,
        1,
        13,
        10,
        45,
        180,
        0,
        0,
        0,
        0,
        73,
        69,
        78,
        68,
        174,
        66,
        96,
        130,
      ]);

      if (!mounted) return;

      setState(() {
        _localImagePath = tempFile.path;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Đã chụp ảnh minh chứng thành công.')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Lỗi chụp ảnh: $e')));
    } finally {
      if (mounted) {
        setState(() => _isUploadingImage = false);
      }
    }
  }

  Future<void> _handleSubmit() async {
    final provider = context.read<OrderReturnProvider>();
    final currentOrder = provider.currentOrder;
    if (currentOrder == null) return;

    final originalOrderId = currentOrder['orderId'] as int;
    final reason = _reasonController.text.trim();

    if (reason.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng nhập lý do hoàn trả.')),
      );
      return;
    }

    if (_localImagePath == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vui lòng chụp ảnh minh chứng trước khi gửi yêu cầu.'),
        ),
      );
      return;
    }

    final itemsToReturn = <Map<String, dynamic>>[];
    _selectedItems.forEach((productId, isSelected) {
      if (isSelected) {
        final qty = _selectedQuantities[productId] ?? 1;
        itemsToReturn.add({'productId': productId, 'quantity': qty});
      }
    });

    if (itemsToReturn.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vui lòng chọn ít nhất một sản phẩm để hoàn trả.'),
        ),
      );
      return;
    }

    final success = await provider.createReturnRequest(
      originalOrderId: originalOrderId,
      reason: reason,
      classify: _classify,
      localImagePath: _localImagePath!,
      items: itemsToReturn,
    );

    if (!mounted) return;

    if (success) {
      _reasonController.clear();
      setState(() {
        _selectedItems.clear();
        _selectedQuantities.clear();
        _localImagePath = null;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Gửi yêu cầu hoàn trả thành công! Chờ quản lý duyệt.'),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(provider.errorMessage ?? 'Gửi yêu cầu thất bại.'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final shiftProvider = context.watch<ShiftProvider>();
    final activeShift = shiftProvider.currentShift;
    final isShiftActive = activeShift != null;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Hoàn trả hàng'),
        backgroundColor: AppColors.primaryContainer,
        foregroundColor: Colors.white,
      ),
      body: !isShiftActive ? _buildNoShiftWidget() : _buildBody(),
      bottomNavigationBar: const CashierBottomNavigationBar(
        selectedTab: CashierNavTab.returns,
      ),
    );
  }

  Widget _buildNoShiftWidget() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.warning_amber_rounded,
              size: 80,
              color: AppColors.statusWarning,
            ),
            const SizedBox(height: 16),
            const Text(
              'Yêu cầu mở ca làm việc',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.textDark,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Thu ngân phải đang trong ca làm việc để thực hiện yêu cầu hoàn trả hàng cho khách.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.textMuted, fontSize: 14),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pushReplacementNamed('/shift-management');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryContainer,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
              ),
              child: const Text('Quản lý Ca làm việc'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBody() {
    final provider = context.watch<OrderReturnProvider>();
    final currentOrder = provider.currentOrder;
    final isLoading = provider.isLoading;
    final errorMessage = provider.errorMessage;

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Nhập mã hóa đơn (VD: ORD-...)',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      contentPadding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: isLoading ? null : _handleSearch,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Text('Tìm kiếm'),
                ),
              ],
            ),
            const SizedBox(height: 16),

            if (errorMessage != null && currentOrder == null)
              Container(
                padding: const EdgeInsets.all(12),
                width: double.infinity,
                decoration: BoxDecoration(
                  color: AppColors.errorContainer,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  errorMessage,
                  style: const TextStyle(
                    color: AppColors.statusError,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),

            if (currentOrder != null) ...[
              _buildOrderSummaryCard(currentOrder),
              const SizedBox(height: 16),
              _buildItemSelectionSection(currentOrder),
              const SizedBox(height: 16),
              _buildEvidenceSection(),
              const SizedBox(height: 16),
              _buildReasonAndClassifySection(),
              const SizedBox(height: 24),
              _buildSubmitButton(isLoading),
              const SizedBox(height: 40),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildOrderSummaryCard(Map<String, dynamic> order) {
    final orderCode = order['orderCode'] as String;
    final orderDateStr = order['orderDate'] as String;
    final orderDate = DateTime.parse(orderDateStr);
    final customerName = order['customerName'] as String;
    final finalAmount = (order['finalAmount'] as num).toDouble();

    final diffHours = DateTime.now().difference(orderDate).inHours;
    final isWithin48h = diffHours <= 48;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  orderCode,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: AppColors.primaryContainer,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: isWithin48h
                        ? AppColors.secondaryContainer
                        : AppColors.errorContainer,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    isWithin48h ? 'Trong hạn 48h' : 'Quá hạn 48h',
                    style: TextStyle(
                      color: isWithin48h
                          ? AppColors.secondary
                          : AppColors.statusError,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const Divider(height: 24),
            _buildInfoRow('Khách hàng:', customerName),
            _buildInfoRow(
              'Ngày mua:',
              DateFormat('dd/MM/yyyy HH:mm').format(orderDate),
            ),
            _buildInfoRow('Thời gian đã trôi qua:', '$diffHours giờ'),
            _buildInfoRow(
              'Tổng tiền:',
              '${NumberFormat('#,###').format(finalAmount)}đ',
              isBoldValue: true,
            ),

            if (!isWithin48h) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.errorContainer,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Row(
                  children: [
                    Icon(
                      Icons.error_outline,
                      color: AppColors.statusError,
                      size: 20,
                    ),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Đơn hàng này đã quá hạn 48 giờ. Không được phép tạo yêu cầu hoàn trả.',
                        style: TextStyle(
                          color: AppColors.statusError,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, {bool isBoldValue = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(color: AppColors.textMuted, fontSize: 14),
          ),
          Text(
            value,
            style: TextStyle(
              color: AppColors.textDark,
              fontSize: 14,
              fontWeight: isBoldValue ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildItemSelectionSection(Map<String, dynamic> order) {
    final items = order['items'] as List;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Chọn sản phẩm hoàn trả',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 15,
            color: AppColors.textDark,
          ),
        ),
        const SizedBox(height: 8),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: items.length,
          itemBuilder: (context, index) {
            final item = items[index] as Map<String, dynamic>;
            final productId = item['productId'] as int;
            final productName = item['productName'] as String;
            final productCode = item['productCode'] as String;
            final originalQty = item['quantity'] as int;
            final unitPrice = (item['unitPrice'] as num).toDouble();

            final isSelected = _selectedItems[productId] ?? false;
            final selectedQty = _selectedQuantities[productId] ?? 1;

            return Card(
              margin: const EdgeInsets.symmetric(vertical: 6),
              elevation: 1,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
                side: BorderSide(
                  color: isSelected ? AppColors.secondary : Colors.transparent,
                  width: 1.5,
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8.0,
                  vertical: 12.0,
                ),
                child: Row(
                  children: [
                    Checkbox(
                      value: isSelected,
                      activeColor: AppColors.secondary,
                      onChanged: (val) {
                        setState(() {
                          _selectedItems[productId] = val ?? false;
                          if (val == true &&
                              !_selectedQuantities.containsKey(productId)) {
                            _selectedQuantities[productId] = 1;
                          }
                        });
                      },
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            productName,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              color: AppColors.textDark,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Mã SP: $productCode | Giá: ${NumberFormat('#,###').format(unitPrice)}đ',
                            style: const TextStyle(
                              color: AppColors.textMuted,
                              fontSize: 12,
                            ),
                          ),
                          Text(
                            'Số lượng đã mua: $originalQty',
                            style: const TextStyle(
                              color: AppColors.textMuted,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (isSelected)
                      Row(
                        children: [
                          IconButton(
                            icon: const Icon(
                              Icons.remove_circle_outline,
                              color: AppColors.textMuted,
                            ),
                            onPressed: selectedQty > 1
                                ? () {
                                    setState(() {
                                      _selectedQuantities[productId] =
                                          selectedQty - 1;
                                    });
                                  }
                                : null,
                          ),
                          Text(
                            '$selectedQty',
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          IconButton(
                            icon: const Icon(
                              Icons.add_circle_outline,
                              color: AppColors.secondary,
                            ),
                            onPressed: selectedQty < originalQty
                                ? () {
                                    setState(() {
                                      _selectedQuantities[productId] =
                                          selectedQty + 1;
                                    });
                                  }
                                : null,
                          ),
                        ],
                      ),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildEvidenceSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Hình ảnh minh chứng',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 15,
            color: AppColors.textDark,
          ),
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: _isUploadingImage ? null : _mockCaptureImage,
          child: Container(
            height: 120,
            width: double.infinity,
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerLow,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: AppColors.borderGray,
                style: BorderStyle.solid,
              ),
            ),
            child: _localImagePath != null
                ? Stack(
                    children: [
                      Center(
                        child: Text(
                          'Đã đính kèm ảnh minh chứng:\n${Path.basename(_localImagePath!)}',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: AppColors.secondary,
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                      ),
                      Positioned(
                        right: 8,
                        top: 8,
                        child: IconButton(
                          icon: const Icon(
                            Icons.delete,
                            color: AppColors.statusError,
                          ),
                          onPressed: () {
                            setState(() {
                              _localImagePath = null;
                            });
                          },
                        ),
                      ),
                    ],
                  )
                : const Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.add_a_photo_outlined,
                        size: 40,
                        color: AppColors.textMuted,
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Chụp & Tải ảnh hàng lỗi/trả',
                        style: TextStyle(
                          color: AppColors.textMuted,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ],
    );
  }

  Widget _buildReasonAndClassifySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Phân loại hoàn trả',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 15,
            color: AppColors.textDark,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: ChoiceChip(
                label: const Center(child: Text('Sản phẩm lỗi')),
                selected: _classify == 1,
                selectedColor: AppColors.errorContainer,
                labelStyle: TextStyle(
                  color: _classify == 1
                      ? AppColors.statusError
                      : AppColors.textDark,
                  fontWeight: FontWeight.bold,
                ),
                onSelected: (val) {
                  if (val) setState(() => _classify = 1);
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ChoiceChip(
                label: const Center(child: Text('Không dùng nữa')),
                selected: _classify == 2,
                selectedColor: AppColors.secondaryContainer,
                labelStyle: TextStyle(
                  color: _classify == 2
                      ? AppColors.secondary
                      : AppColors.textDark,
                  fontWeight: FontWeight.bold,
                ),
                onSelected: (val) {
                  if (val) setState(() => _classify = 2);
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        const Text(
          'Lý do hoàn trả',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 15,
            color: AppColors.textDark,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _reasonController,
          maxLines: 3,
          decoration: InputDecoration(
            hintText:
                'Nhập chi tiết lý do (rách bao bì, đổi ý, lỗi sản phẩm...)',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            contentPadding: const EdgeInsets.all(12),
          ),
        ),
      ],
    );
  }

  Widget _buildSubmitButton(bool isLoading) {
    final orderDateStr =
        context.read<OrderReturnProvider>().currentOrder!['orderDate']
            as String;
    final diffHours = DateTime.parse(
      orderDateStr,
    ).difference(DateTime.now()).inHours.abs();
    final isWithin48h = diffHours <= 48;

    return SizedBox(
      width: double.infinity,
      height: 48,
      child: ElevatedButton(
        onPressed: (isLoading || !isWithin48h) ? null : _handleSubmit,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.statusError,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        child: isLoading
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2.5,
                ),
              )
            : const Text(
                'Gửi Yêu Cầu Hoàn Tiền',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
      ),
    );
  }
}

class Path {
  static String basename(String path) {
    return path.split('/').last;
  }
}
