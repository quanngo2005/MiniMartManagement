import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mini_mart_management_mobile_app/models/product_lookup.dart';
import 'package:mini_mart_management_mobile_app/models/cart_item.dart';
import 'package:mini_mart_management_mobile_app/providers/cart_provider.dart';
import 'package:mini_mart_management_mobile_app/providers/promotion_provider.dart';
import 'package:mini_mart_management_mobile_app/providers/shift_provider.dart';
import 'package:mini_mart_management_mobile_app/providers/auth_provider.dart';
import 'package:mini_mart_management_mobile_app/repositories/order_repository.dart';
import 'package:mini_mart_management_mobile_app/theme/app_colors.dart';
import 'package:mini_mart_management_mobile_app/widgets/layout/cashier_bottom_navigation_bar.dart';
import 'package:mini_mart_management_mobile_app/widgets/layout/cashier_drawer.dart';
import 'package:mini_mart_management_mobile_app/widgets/layout/mini_mart_app_bar.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'dart:convert';
import 'package:mini_mart_management_mobile_app/config/api_config.dart';
import 'package:mini_mart_management_mobile_app/services/http_client_factory.dart';
import 'package:mini_mart_management_mobile_app/screens/shift_management_screen.dart';
import 'dart:async';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:mini_mart_management_mobile_app/screens/barcode_scanner_screen.dart';
import 'package:mini_mart_management_mobile_app/models/scanned_product.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final TextEditingController _customerPhoneController =
      TextEditingController();
  final TextEditingController _newCustomerNameController =
      TextEditingController();
  final TextEditingController _productSearchController =
      TextEditingController();
  final currencyFormatter = NumberFormat.currency(locale: 'vi_VN', symbol: 'đ');

  bool _isSearchingCustomer = false;
  bool _isCreatingCustomer = false;
  bool _showCreateCustomerButton = false;
  String? _customerLookupMessage;
  List<ProductLookup> _productSuggestions = [];

  final TextEditingController _customerGivenAmountController =
      TextEditingController();
  final TextEditingController _pointsToUseController = TextEditingController();

  void _rebuildOnChange() {
    setState(() {});
  }

  void _resetForm() {
    setState(() {
      _customerPhoneController.clear();
      _newCustomerNameController.clear();
      _customerGivenAmountController.clear();
      _pointsToUseController.clear();
      _isSearchingCustomer = false;
      _isCreatingCustomer = false;
      _showCreateCustomerButton = false;
      _customerLookupMessage = null;
      _productSuggestions.clear();
    });
  }

  @override
  void initState() {
    super.initState();
    _customerGivenAmountController.addListener(_rebuildOnChange);
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final shiftProvider = context.read<ShiftProvider>();
      final promotionProvider = context.read<PromotionProvider>();
      await shiftProvider.fetchCurrentShift();
      await promotionProvider.fetchPromotions();
      if (mounted) {
        context.read<CartProvider>().setPromotions(promotionProvider.promotions);
      }
      if (mounted && shiftProvider.currentShift == null) {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => const ShiftManagementScreen(),
            fullscreenDialog: true,
          ),
        );
      }
    });
  }

  @override
  void dispose() {
    _productSearchController.dispose();
    _customerPhoneController.dispose();
    _newCustomerNameController.dispose();
    _customerGivenAmountController.removeListener(_rebuildOnChange);
    _customerGivenAmountController.dispose();
    _pointsToUseController.dispose();
    super.dispose();
  }

  Future<void> _searchCustomer() async {
    final phone = _customerPhoneController.text.trim();
    if (phone.isEmpty) return;

    setState(() {
      _isSearchingCustomer = true;
      _customerLookupMessage = null;
    });

    try {
      final client = createConfiguredClient();
      final path = Uri.encodeFull(
        '/api/customers?\$filter=PhoneNumber eq \'$phone\'',
      );
      final uri = ApiConfig.uri(path);
      final response = await client.get(
        uri,
        headers: {'Accept': 'application/json'},
      );

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        List items = [];
        if (decoded is List) {
          items = decoded;
        } else if (decoded is Map) {
          items = (decoded['value'] ?? decoded['Value'] ?? []) as List;
        }

        if (items.isNotEmpty) {
          final customer = items.first;
          if (mounted) {
            final customerId =
                (customer['customerId'] ?? customer['CustomerId']);
            final fullName =
                (customer['fullName'] ?? customer['FullName'])?.toString() ??
                'Khách hàng';
            final pointRaw = (customer['point'] ?? customer['Point']);

            int parsedId = 0;
            if (customerId is int) {
              parsedId = customerId;
            } else if (customerId is String) {
              parsedId = int.tryParse(customerId) ?? 0;
            }

            int parsedPoint = 0;
            if (pointRaw is int) {
              parsedPoint = pointRaw;
            } else if (pointRaw is double) {
              parsedPoint = pointRaw.toInt();
            } else if (pointRaw is String) {
              parsedPoint = int.tryParse(pointRaw) ?? 0;
            }

            context.read<CartProvider>().setCustomer(
              parsedId,
              fullName,
              parsedPoint,
            );
            _newCustomerNameController.clear();
            _pointsToUseController.clear();
            setState(() {
              _showCreateCustomerButton = false;
              _customerLookupMessage = 'Tìm thấy khách hàng: $fullName';
            });
          }
        } else {
          if (mounted) {
            context.read<CartProvider>().clearCustomer();
          }
          setState(() {
            _showCreateCustomerButton = true;
            _customerLookupMessage =
                'Số điện thoại mới, vui lòng nhập họ và tên khách hàng.';
          });
        }
      } else {
        _showError('Lỗi kết nối. Mã lỗi: ${response.statusCode}');
      }
    } catch (e) {
      _showError('Lỗi hệ thống: $e');
    } finally {
      if (mounted) {
        setState(() => _isSearchingCustomer = false);
      }
    }
  }

  int _parseCustomerId(dynamic rawId) {
    if (rawId is int) return rawId;
    if (rawId is num) return rawId.toInt();
    if (rawId is String) return int.tryParse(rawId) ?? 0;
    return 0;
  }

  Future<bool> _createCustomerFromInlineForm() async {
    final phone = _customerPhoneController.text.trim();
    final name = _newCustomerNameController.text.trim();

    if (!_showCreateCustomerButton || phone.isEmpty) {
      return true;
    }

    if (name.isEmpty) {
      _showError('Vui lòng nhập họ và tên khách hàng mới.');
      return false;
    }

    setState(() => _isCreatingCustomer = true);
    try {
      final client = createConfiguredClient();

      final csrfRes = await client.get(
        ApiConfig.uri('/api/auth/csrf-token'),
        headers: {'Accept': 'application/json'},
      );
      String csrfToken = '';
      if (csrfRes.statusCode >= 200 && csrfRes.statusCode < 300) {
        final data = jsonDecode(csrfRes.body);
        final payload = data['data'] ?? data['Data'];
        csrfToken = payload['csrfToken'] ?? payload['CsrfToken'] ?? '';
      }

      final response = await client.post(
        ApiConfig.uri('/api/customers'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          if (csrfToken.isNotEmpty) 'X-XSRF-TOKEN': csrfToken,
        },
        body: jsonEncode({
          'customerCode': 'KH$phone',
          'fullName': name,
          'phoneNumber': phone,
          'address': '',
          'point': 0,
          'customerStatus': true,
        }),
      );

      if (response.statusCode < 200 || response.statusCode >= 300) {
        final error = jsonDecode(response.body);
        final errorMsg = error['message'] ?? error['title'] ?? response.body;
        _showError('Không thể tạo khách hàng mới: $errorMsg');
        return false;
      }

      final created = jsonDecode(response.body);
      final customerId = _parseCustomerId(
        created['customerId'] ?? created['CustomerId'],
      );
      if (customerId <= 0) {
        _showError('Không đọc được mã khách hàng mới từ server.');
        return false;
      }

      if (!mounted) return false;
      context.read<CartProvider>().setCustomer(customerId, name, 0);
      setState(() {
        _showCreateCustomerButton = false;
        _customerLookupMessage = 'Đã tạo khách hàng mới: $name';
      });
      return true;
    } catch (e) {
      _showError('Lỗi hệ thống khi tạo khách hàng: $e');
      return false;
    } finally {
      if (mounted) {
        setState(() => _isCreatingCustomer = false);
      }
    }
  }

  Future<void> _searchProduct(String keyword) async {
    if (keyword.isEmpty) {
      setState(() => _productSuggestions = []);
      return;
    }

    try {
      final client = createConfiguredClient();
      final path = Uri.encodeFull(
        '/api/products?\$filter=contains(tolower(ProductName), tolower(\'$keyword\')) or contains(tolower(ProductCode), tolower(\'$keyword\'))',
      );
      final uri = ApiConfig.uri(path);
      final response = await client.get(
        uri,
        headers: {'Accept': 'application/json'},
      );

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        List items = [];
        if (decoded is List) {
          items = decoded;
        } else if (decoded is Map) {
          items = (decoded['value'] ?? decoded['Value'] ?? []) as List;
        }

        setState(() {
          _productSuggestions = items
              .map((e) => ProductLookup.fromJson(e))
              .toList();
        });
      }
    } catch (e) {
      // Ignore errors for autocomplete
    } finally {
      // Done
    }
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: AppColors.statusError),
    );
  }

  void _showSuccess(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: AppColors.secondary),
    );
  }

  Future<void> _openBarcodeScanner() async {
    final cart = context.read<CartProvider>();
    final scannedList = await Navigator.of(context).push<List<ScannedProduct>>(
      MaterialPageRoute(builder: (_) => const BarcodeScannerScreen()),
    );
    if (scannedList == null || scannedList.isEmpty) return;
    int addedCount = 0;
    for (final entry in scannedList) {
      for (int i = 0; i < entry.quantity; i++) {
        cart.addItem(entry.product);
        addedCount++;
      }
    }

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Đã thêm $addedCount sản phẩm vào giỏ hàng'),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  Future<void> _handleCheckout() async {
    final cart = context.read<CartProvider>();
    if (cart.items.isEmpty) {
      _showError('Giỏ hàng đang trống.');
      return;
    }

    final shiftProvider = context.read<ShiftProvider>();
    if (shiftProvider.currentShift == null) {
      _showError('Vui lòng mở ca làm việc trước khi thanh toán.');
      return;
    }

    final authProvider = context.read<AuthProvider>();
    final currentUser = authProvider.currentUser;
    if (currentUser == null) return;

    try {
      final orderRepo = context.read<OrderRepository>();
      final customerReady = await _createCustomerFromInlineForm();
      if (!customerReady) return;

      final items = cart.items
          .map(
            (i) => {'productId': i.product.productId, 'quantity': i.quantity},
          )
          .toList();

      final givenStr = _customerGivenAmountController.text.replaceAll(
        RegExp(r'[^0-9]'),
        '',
      );
      final givenAmount = double.tryParse(givenStr) ?? cart.finalAmount;
      if (cart.paymentMethod == 1 && givenAmount < cart.finalAmount) {
        _showError('Tiền khách đưa không đủ.');
        return;
      }

      final response = await orderRepo.checkout(
        employeeId: currentUser.employeeId,
        shiftId: shiftProvider.currentShift!.shiftId,
        customerId: cart.selectedCustomerId,
        loyaltyPointsToUse: cart.pointsToUse,
        paymentMethod: cart.paymentMethod,
        paidAmount: cart.paymentMethod == 1 ? givenAmount : cart.finalAmount,
        items: items,
      );

      if (cart.paymentMethod == 5) {
        final orderId = response['orderId'] ?? response['OrderId'];
        if (orderId == null) {
          throw Exception('Không tìm thấy OrderId từ server.');
        }

        final client = createConfiguredClient();
        final csrfRes = await client.get(
          ApiConfig.uri('/api/auth/csrf-token'),
          headers: {'Accept': 'application/json'},
        );
        String csrfToken = '';
        if (csrfRes.statusCode >= 200 && csrfRes.statusCode < 300) {
          final data = jsonDecode(csrfRes.body);
          final payload = data['data'] ?? data['Data'];
          csrfToken = payload['csrfToken'] ?? payload['CsrfToken'] ?? '';
        }

        final payRes = await client.post(
          ApiConfig.uri('/api/payments/create-url'),
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
            if (csrfToken.isNotEmpty) 'X-XSRF-TOKEN': csrfToken,
          },
          body: jsonEncode({'orderId': orderId, 'paymentMethod': 5}),
        );

        if (payRes.statusCode >= 200 && payRes.statusCode < 300) {
          final payData = jsonDecode(payRes.body);
          final paymentUrl = payData['paymentUrl'] ?? payData['PaymentUrl'];
          final transactionRef =
              payData['transactionRef'] ?? payData['TransactionRef'];

          if (paymentUrl != null && transactionRef != null) {
            await _showVnPayQrDialog(paymentUrl, transactionRef);
            return;
          } else {
            throw Exception('Server không trả về Payment URL');
          }
        } else {
          throw Exception('Lỗi tạo URL thanh toán VNPAY');
        }
      }

      _showSuccess('Thanh toán thành công!');
      cart.clearCart();
      _resetForm();
    } catch (e) {
      _showError(e.toString());
    }
  }

  Future<void> _showVnPayQrDialog(
    String paymentUrl,
    String transactionRef,
  ) async {
    int timeLeft = 600;
    Timer? countdownTimer;
    Timer? pollingTimer;
    bool isPaid = false;

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            countdownTimer ??= Timer.periodic(const Duration(seconds: 1), (
              timer,
            ) {
              if (!mounted) {
                timer.cancel();
                return;
              }
              setDialogState(() {
                if (timeLeft > 0) {
                  timeLeft--;
                } else {
                  timer.cancel();
                  Navigator.pop(ctx);
                  _showError('Đã hết thời gian thanh toán VNPAY.');
                }
              });
            });

            pollingTimer ??= Timer.periodic(const Duration(seconds: 5), (
              timer,
            ) async {
              try {
                final client = createConfiguredClient();
                final res = await client.get(
                  ApiConfig.uri('/api/payments/$transactionRef/status'),
                );
                if (!ctx.mounted) return;
                if (res.statusCode == 200) {
                  final data = jsonDecode(res.body);
                  final status = data['status'] ?? data['Status'];
                  if (status == 2) {
                    timer.cancel();
                    isPaid = true;
                    Navigator.pop(ctx);
                  }
                }
              } catch (_) {}
            });

            final minutes = (timeLeft / 60).floor();
            final seconds = timeLeft % 60;
            final timeStr =
                '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';

            return Dialog(
              child: Container(
                width: 340,
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'Thanh toán VNPAY',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Vui lòng quét mã QR dưới đây bằng ứng dụng ngân hàng hoặc ví VNPAY.',
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: 250,
                      height: 250,
                      child: QrImageView(
                        data: paymentUrl,
                        version: QrVersions.auto,
                        size: 250.0,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Thời gian còn lại: $timeStr',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: AppColors.statusError,
                      ),
                    ),
                    const SizedBox(height: 16),
                    const CircularProgressIndicator(),
                    const SizedBox(height: 8),
                    const Text(
                      'Đang chờ thanh toán...',
                      style: TextStyle(color: AppColors.textMuted),
                    ),
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        TextButton(
                          onPressed: () {
                            countdownTimer?.cancel();
                            pollingTimer?.cancel();
                            Navigator.pop(ctx);
                          },
                          child: const Text('Hủy giao dịch'),
                        ),
                        TextButton(
                          onPressed: () async {
                            countdownTimer?.cancel();
                            pollingTimer?.cancel();
                            try {
                              final client = createConfiguredClient();
                              await client.post(
                                ApiConfig.uri(
                                  '/api/payments/$transactionRef/mock-success',
                                ),
                              );
                              if (!ctx.mounted) return;
                            } catch (_) {}
                            isPaid = true;
                            Navigator.pop(ctx);
                          },
                          child: const Text(
                            'Giao dịch thành công',
                            style: TextStyle(color: AppColors.secondary),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );

    countdownTimer?.cancel();
    pollingTimer?.cancel();

    if (isPaid && mounted) {
      _showSuccess('Thanh toán VNPAY thành công!');
      context.read<CartProvider>().clearCart();
      _resetForm();
    }
  }

  void _showCreateCustomerDialog() {
    final nameController = TextEditingController();
    final addressController = TextEditingController();
    final phone = _customerPhoneController.text.trim();

    showDialog(
      context: context,
      builder: (ctx) {
        bool isCreating = false;
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Tạo Khách Hàng Mới'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: TextEditingController(text: phone),
                      enabled: false,
                      decoration: const InputDecoration(
                        labelText: 'Số điện thoại',
                        filled: true,
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: nameController,
                      decoration: const InputDecoration(
                        labelText: 'Họ và tên *',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: addressController,
                      decoration: const InputDecoration(
                        labelText: 'Địa chỉ (Tùy chọn)',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Hủy'),
                ),
                ElevatedButton(
                  onPressed: isCreating
                      ? null
                      : () async {
                          final name = nameController.text.trim();
                          if (name.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Vui lòng nhập Họ và tên',
                                  style: TextStyle(color: Colors.white),
                                ),
                                backgroundColor: AppColors.statusError,
                              ),
                            );
                            return;
                          }
                          setDialogState(() => isCreating = true);
                          try {
                            final client = createConfiguredClient();

                            final csrfRes = await client.get(
                              ApiConfig.uri('/api/auth/csrf-token'),
                              headers: {'Accept': 'application/json'},
                            );
                            String csrfToken = '';
                            if (csrfRes.statusCode >= 200 &&
                                csrfRes.statusCode < 300) {
                              final data = jsonDecode(csrfRes.body);
                              final payload = data['data'] ?? data['Data'];
                              csrfToken =
                                  payload['csrfToken'] ??
                                  payload['CsrfToken'] ??
                                  '';
                            }

                            final response = await client.post(
                              ApiConfig.uri('/api/customers'),
                              headers: {
                                'Content-Type': 'application/json',
                                'Accept': 'application/json',
                                if (csrfToken.isNotEmpty)
                                  'X-XSRF-TOKEN': csrfToken,
                              },
                              body: jsonEncode({
                                'customerCode': 'KH$phone',
                                'fullName': name,
                                'phoneNumber': phone,
                                'address': addressController.text.trim(),
                                'point': 0,
                                'customerStatus': true,
                              }),
                            );

                            if (response.statusCode >= 200 &&
                                response.statusCode < 300) {
                              final created = jsonDecode(response.body);
                              final customerId =
                                  created['customerId'] ??
                                  created['CustomerId'] ??
                                  0;
                              if (!context.mounted) return;
                              context.read<CartProvider>().setCustomer(
                                customerId,
                                name,
                                0,
                              );
                              _pointsToUseController.clear();
                              setState(() {
                                _showCreateCustomerButton = false;
                              });
                              final messenger = ScaffoldMessenger.of(context);
                              Navigator.pop(context);
                              messenger.showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'Tạo khách hàng thành công!',
                                    style: TextStyle(color: Colors.white),
                                  ),
                                  backgroundColor: AppColors.secondary,
                                ),
                              );
                            } else {
                              final error = jsonDecode(response.body);
                              final errorMsg =
                                  error['message'] ??
                                  error['title'] ??
                                  response.body;
                              if (!context.mounted) return;
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    'Lỗi: $errorMsg',
                                    style: const TextStyle(color: Colors.white),
                                  ),
                                  backgroundColor: AppColors.statusError,
                                ),
                              );
                            }
                          } catch (e) {
                            if (!context.mounted) return;
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  'Lỗi hệ thống: $e',
                                  style: const TextStyle(color: Colors.white),
                                ),
                                backgroundColor: AppColors.statusError,
                              ),
                            );
                          } finally {
                            setDialogState(() => isCreating = false);
                          }
                        },
                  child: isCreating
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Lưu'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showEditQuantityDialog(CartItem item) {
    final TextEditingController qtyController = TextEditingController(
      text: item.quantity.toString(),
    );
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Nhập số lượng'),
        content: TextField(
          controller: qtyController,
          keyboardType: TextInputType.number,
          autofocus: true,
          decoration: const InputDecoration(
            hintText: 'Số lượng',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Hủy'),
          ),
          FilledButton(
            onPressed: () {
              final newQty = int.tryParse(qtyController.text) ?? -1;
              if (newQty < 0) {
                _showError('Số lượng không hợp lệ.');
                return;
              }
              if (newQty > item.product.stockQuantity) {
                _showError(
                  'Không đủ hàng tồn. Tồn kho: ${item.product.stockQuantity}',
                );
                return;
              }
              Navigator.pop(ctx);
              context.read<CartProvider>().setQuantity(
                item.product.productId,
                newQty,
              );
            },
            child: const Text('Xác nhận'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>();
    final givenStr = _customerGivenAmountController.text.replaceAll(
      RegExp(r'[^0-9]'),
      '',
    );
    final givenAmount = double.tryParse(givenStr) ?? 0.0;
    double changeAmount = givenAmount - cart.finalAmount;
    final isShort = givenStr.isNotEmpty && changeAmount < 0;
    if (changeAmount < 0) changeAmount = 0.0;

    return Scaffold(
      backgroundColor: AppColors.backgroundSlate,
      drawer: const CashierDrawer(selectedTab: CashierNavTab.checkout),
      appBar: const MiniMartAppBar.primary(title: 'Bán hàng', showMenu: true),
      body: ListView(
        padding: const EdgeInsets.only(bottom: 24),
        children: [
          // Customer Search Section
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                TextField(
                  controller: _customerPhoneController,
                  onChanged: (val) {
                    setState(() {
                      _showCreateCustomerButton = false;
                      _customerLookupMessage = null;
                    });
                    _newCustomerNameController.clear();
                    cart.clearCustomer();
                    _pointsToUseController.clear();
                  },
                  decoration: InputDecoration(
                    hintText: 'Nhập số điện thoại khách hàng...',
                    prefixIcon: const Icon(Icons.phone),
                    suffixIcon: _isSearchingCustomer
                        ? const Padding(
                            padding: EdgeInsets.all(12.0),
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (_showCreateCustomerButton)
                                IconButton(
                                  icon: const Icon(
                                    Icons.person_add,
                                    color: AppColors.primary,
                                  ),
                                  onPressed: _showCreateCustomerDialog,
                                  tooltip: 'Tạo khách hàng mới',
                                ),
                              IconButton(
                                icon: const Icon(Icons.search),
                                onPressed: _searchCustomer,
                              ),
                            ],
                          ),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(
                        color: AppColors.outlineVariant,
                      ),
                    ),
                  ),
                  keyboardType: TextInputType.phone,
                  onSubmitted: (_) => _searchCustomer(),
                ),
                if (_customerLookupMessage != null) ...[
                  const SizedBox(height: 8),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      _customerLookupMessage!,
                      style: TextStyle(
                        color: _showCreateCustomerButton
                            ? AppColors.statusWarning
                            : AppColors.secondary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
                if (_showCreateCustomerButton) ...[
                  const SizedBox(height: 12),
                  TextField(
                    controller: _newCustomerNameController,
                    textInputAction: TextInputAction.done,
                    decoration: InputDecoration(
                      hintText: 'Nhập họ và tên khách hàng mới...',
                      prefixIcon: const Icon(Icons.person_outline),
                      suffixIcon: _isCreatingCustomer
                          ? const Padding(
                              padding: EdgeInsets.all(12.0),
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : null,
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(
                          color: AppColors.outlineVariant,
                        ),
                      ),
                    ),
                  ),
                ],
                if (cart.selectedCustomerId != null) ...[
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primaryFixed,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.primaryContainer),
                    ),
                    child: Row(
                      children: [
                        IconButton(
                          icon: const Icon(
                            Icons.close,
                            color: AppColors.primaryContainer,
                          ),
                          onPressed: () {
                            cart.clearCustomer();
                            _pointsToUseController.clear();
                          },
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        ),
                        const SizedBox(width: 12),
                        const Icon(
                          Icons.person,
                          color: AppColors.primaryContainer,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                cart.selectedCustomerName ?? '',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.primaryContainer,
                                ),
                              ),
                              Text(
                                'Điểm tích lũy: ${cart.selectedCustomerPoints}',
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: AppColors.textMuted,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),

          // Product Search Section
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              children: [
                TextField(
                  controller: _productSearchController,
                  decoration: InputDecoration(
                    hintText: 'Tìm sản phẩm (tên hoặc mã)...',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: const Icon(Icons.barcode_reader),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(
                        color: AppColors.outlineVariant,
                      ),
                    ),
                  ),
                  onChanged: _searchProduct,
                ),
                if (_productSuggestions.isNotEmpty)
                  Container(
                    constraints: const BoxConstraints(maxHeight: 200),
                    margin: const EdgeInsets.only(top: 4),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(color: AppColors.outlineVariant),
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.1),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: _productSuggestions.length,
                      itemBuilder: (context, index) {
                        final product = _productSuggestions[index];
                        return ListTile(
                          title: Text(product.productName),
                          subtitle: Text(
                            'SKU: ${product.productCode} | Tồn: ${product.stockQuantity}',
                          ),
                          trailing: Text(
                            currencyFormatter.format(product.sellingPrice),
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          onTap: () {
                            cart.addItem(product);
                            _productSearchController.clear();
                            setState(() => _productSuggestions = []);
                          },
                        );
                      },
                    ),
                  ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Cart Section
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.outlineVariant),
            ),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  decoration: const BoxDecoration(
                    color: AppColors.surfaceContainerLow,
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(12),
                    ),
                    border: Border(
                      bottom: BorderSide(color: AppColors.outlineVariant),
                    ),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.shopping_cart_outlined),
                          SizedBox(width: 8),
                          Text(
                            'Giỏ hàng',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                cart.items.isEmpty
                    ? Container(
                        height: 120,
                        alignment: Alignment.center,
                        child: const Text('Chưa có sản phẩm nào'),
                      )
                    : ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: cart.items.length,
                        separatorBuilder: (_, _) => const Divider(height: 1),
                        itemBuilder: (context, index) {
                          final item = cart.items[index];
                          final giftQuantity = cart.giftQuantityForProduct(
                            item.product.productId,
                          );
                          return Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        item.product.productName,
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        'SKU: ${item.product.productCode} | ${currencyFormatter.format(item.product.sellingPrice)}',
                                        style: const TextStyle(
                                          fontSize: 12,
                                          color: AppColors.textMuted,
                                        ),
                                      ),
                                      if (giftQuantity > 0) ...[
                                        const SizedBox(height: 4),
                                        Text(
                                          'Tặng thêm: $giftQuantity',
                                          style: const TextStyle(
                                            fontSize: 12,
                                            color: AppColors.secondary,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                                Row(
                                  children: [
                                    Container(
                                      decoration: BoxDecoration(
                                        border: Border.all(
                                          color: AppColors.outlineVariant,
                                        ),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Row(
                                        children: [
                                          IconButton(
                                            icon: const Icon(
                                              Icons.remove,
                                              size: 20,
                                            ),
                                            onPressed: () =>
                                                cart.updateQuantity(
                                                  item.product.productId,
                                                  -1,
                                                ),
                                            constraints: const BoxConstraints(
                                              minWidth: 36,
                                              minHeight: 36,
                                            ),
                                            padding: EdgeInsets.zero,
                                          ),
                                          InkWell(
                                            onTap: () =>
                                                _showEditQuantityDialog(item),
                                            child: SizedBox(
                                              width: 32,
                                              height: 36,
                                              child: Center(
                                                child: Text(
                                                  '${item.quantity}',
                                                  textAlign: TextAlign.center,
                                                  style: const TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    decoration: TextDecoration
                                                        .underline,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                          IconButton(
                                            icon: const Icon(
                                              Icons.add,
                                              size: 20,
                                            ),
                                            onPressed: () {
                                              if (item.quantity >=
                                                  item.product.stockQuantity) {
                                                _showError(
                                                  'Không đủ hàng tồn. Tồn kho: ${item.product.stockQuantity}',
                                                );
                                              } else {
                                                cart.updateQuantity(
                                                  item.product.productId,
                                                  1,
                                                );
                                              }
                                            },
                                            constraints: const BoxConstraints(
                                              minWidth: 36,
                                              minHeight: 36,
                                            ),
                                            padding: EdgeInsets.zero,
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    SizedBox(
                                      width: 80,
                                      child: Text(
                                        currencyFormatter.format(
                                          item.totalPrice,
                                        ),
                                        textAlign: TextAlign.right,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          );
                        },
                      ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Payment Methods
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Phương thức thanh toán',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    _buildPaymentChip(
                      cart,
                      1,
                      'Tiền mặt',
                      Icons.payments_outlined,
                    ),
                    const SizedBox(width: 8),
                    _buildPaymentChip(
                      cart,
                      5,
                      'VNPAY',
                      Icons.account_balance_wallet_outlined,
                    ),
                  ],
                ),
                if (cart.paymentMethod == 1) ...[
                  const SizedBox(height: 16),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _customerGivenAmountController,
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                            TextInputFormatter.withFunction((
                              oldValue,
                              newValue,
                            ) {
                              if (newValue.text.isEmpty) return newValue;
                              final intValue =
                                  int.tryParse(
                                    newValue.text.replaceAll(
                                      RegExp(r'[^0-9]'),
                                      '',
                                    ),
                                  ) ??
                                  0;
                              final formatted = NumberFormat.decimalPattern(
                                'vi_VN',
                              ).format(intValue);
                              return TextEditingValue(
                                text: formatted,
                                selection: TextSelection.collapsed(
                                  offset: formatted.length,
                                ),
                              );
                            }),
                          ],
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: isShort
                                ? AppColors.statusError
                                : AppColors.textDark,
                          ),
                          decoration: const InputDecoration(
                            labelText: 'Tiền khách đưa',
                            prefixText: 'đ ',
                            border: OutlineInputBorder(),
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 16,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextField(
                          controller: TextEditingController(
                            text: currencyFormatter.format(changeAmount),
                          ),
                          readOnly: true,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: AppColors.secondary,
                          ),
                          decoration: const InputDecoration(
                            labelText: 'Tiền thối lại',
                            border: OutlineInputBorder(),
                            filled: true,
                            fillColor: AppColors.surfaceContainerLow,
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 16,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),

          // Summary & Checkout
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.outlineVariant),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: Column(
              children: [
                if (cart.selectedCustomerPoints != null &&
                    cart.selectedCustomerPoints! > 0) ...[
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    secondary: const Icon(
                      Icons.stars_rounded,
                      color: AppColors.secondary,
                    ),
                    title: const Text(
                      'Sử dụng điểm tích lũy',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary,
                      ),
                    ),
                    subtitle: Text(
                      '${cart.selectedCustomerPoints} điểm khả dụng • 1 điểm = 1.000 đ',
                      style: const TextStyle(color: AppColors.textMuted),
                    ),
                    value: cart.useLoyaltyPoints,
                    activeColor: AppColors.secondary,
                    onChanged: (value) {
                      cart.setUseLoyaltyPoints(value);
                      _pointsToUseController.text = value
                          ? cart.pointsToUse.toString()
                          : '';
                    },
                  ),
                  if (cart.useLoyaltyPoints) ...[
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        TextButton.icon(
                          onPressed: () {
                            cart.setPointsToUse(cart.maxPointsCanUse);
                            _pointsToUseController.text = cart.pointsToUse
                                .toString();
                          },
                          icon: const Icon(Icons.auto_awesome, size: 18),
                          label: Text(
                            'Dùng tối đa ${cart.maxPointsCanUse} điểm',
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                  ],
                ],
                if (cart.useLoyaltyPoints &&
                    cart.selectedCustomerPoints != null &&
                    cart.selectedCustomerPoints! > 0) ...[
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _pointsToUseController,
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                          ],
                          onChanged: (val) {
                            final points = int.tryParse(val) ?? 0;
                            cart.setPointsToUse(points);
                            if (points > cart.maxPointsCanUse) {
                              _pointsToUseController.text = cart.maxPointsCanUse
                                  .toString();
                              _pointsToUseController.selection =
                                  TextSelection.collapsed(
                                    offset: _pointsToUseController.text.length,
                                  );
                            }
                          },
                          decoration: const InputDecoration(
                            labelText: 'Số điểm sử dụng',
                            hintText: 'Nhập số điểm...',
                            border: OutlineInputBorder(),
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Text(
                        '- ${currencyFormatter.format(cart.loyaltyDiscountAmount)}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.statusError,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                ],
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Tạm tính',
                      style: TextStyle(
                        fontSize: 16,
                        color: AppColors.textMuted,
                      ),
                    ),
                    Text(
                      currencyFormatter.format(cart.totalAmount),
                      style: const TextStyle(
                        fontSize: 16,
                        color: AppColors.textDark,
                      ),
                    ),
                  ],
                ),
                if (cart.promotionDiscountAmount > 0) ...[
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Khuyến mãi',
                        style: TextStyle(
                          fontSize: 14,
                          color: AppColors.statusError,
                        ),
                      ),
                      Text(
                        '- ${currencyFormatter.format(cart.promotionDiscountAmount)}',
                        style: const TextStyle(
                          fontSize: 14,
                          color: AppColors.statusError,
                        ),
                      ),
                    ],
                  ),
                ],
                if (cart.pointsToUse > 0) ...[
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Điểm tích lũy',
                        style: TextStyle(
                          fontSize: 14,
                          color: AppColors.statusError,
                        ),
                      ),
                      Text(
                        '- ${currencyFormatter.format(cart.loyaltyDiscountAmount)}',
                        style: const TextStyle(
                          fontSize: 14,
                          color: AppColors.statusError,
                        ),
                      ),
                    ],
                  ),
                ],
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'TỔNG CỘNG',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                    Text(
                      currencyFormatter.format(cart.finalAmount),
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w900,
                        color: AppColors.secondary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.secondary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onPressed: _handleCheckout,
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Thanh toán',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(width: 8),
                        Icon(Icons.arrow_forward),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 16.0),
        child: FloatingActionButton(
          onPressed: _openBarcodeScanner,
          backgroundColor: AppColors.primary,
          child: const Icon(Icons.qr_code_scanner, color: Colors.white),
        ),
      ),
      bottomNavigationBar: const CashierBottomNavigationBar(
        selectedTab: CashierNavTab.checkout,
      ),
    );
  }

  Widget _buildPaymentChip(
    CartProvider cart,
    int value,
    String label,
    IconData icon,
  ) {
    final isSelected = cart.paymentMethod == value;
    return InkWell(
      onTap: () => cart.setPaymentMethod(value),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.secondaryContainer : Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: isSelected
                ? AppColors.primaryContainer
                : AppColors.outlineVariant,
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 20,
              color: isSelected
                  ? AppColors.primaryContainer
                  : AppColors.outlineVariant,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: isSelected
                    ? AppColors.primaryContainer
                    : AppColors.textDark,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
