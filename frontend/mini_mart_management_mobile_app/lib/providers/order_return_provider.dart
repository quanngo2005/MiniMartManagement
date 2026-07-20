import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:mini_mart_management_mobile_app/core/api_exception.dart';
import 'package:mini_mart_management_mobile_app/models/order_return.dart';
import 'package:mini_mart_management_mobile_app/repositories/order_return_repository.dart';

class OrderReturnProvider extends ChangeNotifier {
  OrderReturnProvider(this._orderReturnRepository);

  final OrderReturnRepository _orderReturnRepository;

  Map<String, dynamic>? _currentOrder;
  List<OrderReturn> _allReturns = [];
  List<OrderReturn> _pendingReturns = [];
  bool _isLoading = false;
  String? _errorMessage;

  Map<String, dynamic>? get currentOrder => _currentOrder;
  List<OrderReturn> get allReturns => _allReturns;
  List<OrderReturn> get pendingReturns => _pendingReturns;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  void clearCurrentOrder() {
    _currentOrder = null;
    _errorMessage = null;
    notifyListeners();
  }

  Future<void> searchOrder(String orderCode) async {
    _isLoading = true;
    _errorMessage = null;
    _currentOrder = null;
    notifyListeners();

    try {
      _currentOrder = await _orderReturnRepository.fetchOrderDetailsForReturn(
        orderCode,
      );
    } on ApiException catch (e) {
      _errorMessage = e.message;
    } catch (e) {
      _errorMessage = 'Không thể tìm thấy hóa đơn. Lỗi kết nối.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> createReturnRequest({
    required int originalOrderId,
    required String reason,
    required int classify,
    required String localImagePath,
    String? localImageName,
    Uint8List? localImageBytes,
    required List<Map<String, dynamic>> items,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final imageUrl = await _orderReturnRepository.uploadImage(
        localImagePath,
        fileName: localImageName,
        bytes: localImageBytes,
      );

      final payload = {
        'originalOrderId': originalOrderId,
        'reason': reason,
        'refundMethod': 1,
        'classify': classify,
        'imageEvidence': imageUrl,
        'items': items,
      };

      await _orderReturnRepository.createOrderReturn(payload);
      _currentOrder = null;
      return true;
    } on ApiException catch (e) {
      _errorMessage = e.message;
      return false;
    } catch (e) {
      _errorMessage = 'Không thể tạo yêu cầu hoàn trả: $e';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadAllReturns() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _allReturns = await _orderReturnRepository.fetchOrderReturns();
      _pendingReturns = _allReturns.where((r) => r.status == 1).toList();
    } on ApiException catch (e) {
      _errorMessage = e.message;
    } catch (e) {
      _errorMessage = 'Không thể tải danh sách hoàn trả: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> approveReturn(int id) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _orderReturnRepository.approveOrderReturn(id);
      await loadAllReturns();
      return true;
    } on ApiException catch (e) {
      _errorMessage = e.message;
      return false;
    } catch (e) {
      _errorMessage = 'Không thể phê duyệt yêu cầu hoàn trả: $e';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> rejectReturn(int id, String note) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _orderReturnRepository.rejectOrderReturn(id, note);
      await loadAllReturns();
      return true;
    } on ApiException catch (e) {
      _errorMessage = e.message;
      return false;
    } catch (e) {
      _errorMessage = 'Không thể từ chối yêu cầu hoàn trả: $e';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> confirmCashRefund(int id) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _orderReturnRepository.confirmCashRefund(id);
      await loadAllReturns();
      return true;
    } on ApiException catch (e) {
      _errorMessage = e.message;
      return false;
    } catch (e) {
      _errorMessage = 'Không thể xác nhận hoàn tiền mặt: $e';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
