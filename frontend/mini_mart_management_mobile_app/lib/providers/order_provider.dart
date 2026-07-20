import 'package:flutter/foundation.dart';
import 'package:mini_mart_management_mobile_app/core/api_exception.dart';
import 'package:mini_mart_management_mobile_app/models/order_summary.dart';
import 'package:mini_mart_management_mobile_app/repositories/order_repository.dart';

class OrderProvider extends ChangeNotifier {
  OrderProvider(this._repository);

  final OrderRepository _repository;

  List<OrderSummary> _orders = [];
  bool _isLoading = false;
  String? _error;

  List<OrderSummary> get orders => _orders;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchCashierOrders(int employeeId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _orders = await _repository.getOrdersByEmployee(employeeId);
    } on ApiException catch (error) {
      _error = error.message;
    } catch (_) {
      _error = 'Không thể tải lịch sử đơn hàng.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchAllOrders() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _orders = await _repository.getAllOrders();
    } on ApiException catch (error) {
      _error = error.message;
    } catch (_) {
      _error = 'Không thể tải danh sách đơn hàng.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
