import 'package:flutter/foundation.dart';
import 'package:mini_mart_management_mobile_app/core/api_exception.dart';
import 'package:mini_mart_management_mobile_app/models/customer_order.dart';
import 'package:mini_mart_management_mobile_app/models/customer_point_transaction.dart';
import 'package:mini_mart_management_mobile_app/models/customer_summary.dart';
import 'package:mini_mart_management_mobile_app/repositories/customer_repository.dart';

class CustomerProvider with ChangeNotifier {
  CustomerProvider(this._customerRepository);

  final CustomerRepository _customerRepository;

  List<CustomerSummary> _customers = [];
  bool _isLoading = false;
  String? _error;

  // Per-customer cache
  final Map<int, List<CustomerOrder>> _ordersCache = {};
  final Map<int, List<CustomerPointTransaction>> _txnCache = {};

  List<CustomerSummary> get customers => _customers;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchCustomers() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      _customers = await _customerRepository.getAllCustomers();
    } on ApiException catch (e) {
      _error = e.message;
    } catch (_) {
      _error = 'Đã xảy ra lỗi khi tải danh sách khách hàng.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<CustomerSummary?> getCustomerById(int id) async {
    try {
      return await _customerRepository.getCustomerById(id);
    } on ApiException catch (e) {
      _error = e.message;
      notifyListeners();
      return null;
    }
  }

  Future<bool> createCustomer(Map<String, dynamic> data) async {
    try {
      final created = await _customerRepository.createCustomer(data);
      _customers = [..._customers, created];
      notifyListeners();
      return true;
    } on ApiException catch (e) {
      _error = e.message;
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateCustomer(int id, Map<String, dynamic> data) async {
    try {
      final updated = await _customerRepository.updateCustomer(id, data);
      _customers = _customers
          .map((c) => c.customerId == id ? updated : c)
          .toList();
      notifyListeners();
      return true;
    } on ApiException catch (e) {
      _error = e.message;
      notifyListeners();
      return false;
    }
  }

  /// Soft delete — set customerStatus = false
  Future<bool> disableCustomer(int id) async {
    return updateCustomer(id, {'customerStatus': false});
  }

  Future<int?> fetchCustomerPoints(int id) async {
    try {
      return await _customerRepository.getCustomerPoints(id);
    } on ApiException catch (e) {
      _error = e.message;
      notifyListeners();
      return null;
    }
  }

  Future<bool> updateCustomerPoints(int customerId, int delta) async {
    try {
      final newPoints = await _customerRepository.updateCustomerPoints(
        customerId,
        delta,
      );
      _customers = _customers.map((c) {
        if (c.customerId == customerId) {
          return CustomerSummary(
            customerId: c.customerId,
            customerCode: c.customerCode,
            name: c.name,
            phone: c.phone,
            email: c.email,
            address: c.address,
            points: newPoints,
            customerStatus: c.customerStatus,
          );
        }
        return c;
      }).toList();
      notifyListeners();
      return true;
    } on ApiException catch (e) {
      _error = e.message;
      notifyListeners();
      return false;
    }
  }

  Future<List<CustomerOrder>> fetchCustomerOrders(int id) async {
    if (_ordersCache.containsKey(id)) return _ordersCache[id]!;
    try {
      final orders = await _customerRepository.getCustomerOrders(id);
      _ordersCache[id] = orders;
      return orders;
    } on ApiException catch (e) {
      _error = e.message;
      notifyListeners();
      return [];
    }
  }

  Future<List<CustomerPointTransaction>> fetchCustomerPointTransactions(
    int id,
  ) async {
    if (_txnCache.containsKey(id)) return _txnCache[id]!;
    try {
      final txns = await _customerRepository.getCustomerPointTransactions(id);
      _txnCache[id] = txns;
      return txns;
    } on ApiException catch (e) {
      _error = e.message;
      notifyListeners();
      return [];
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
