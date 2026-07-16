import 'package:flutter/foundation.dart';
import 'package:mini_mart_management_mobile_app/core/api_exception.dart';
import 'package:mini_mart_management_mobile_app/models/e_invoice.dart';
import 'package:mini_mart_management_mobile_app/repositories/e_invoice_repository.dart';

class EInvoiceProvider extends ChangeNotifier {
  EInvoiceProvider(this._repository);

  final EInvoiceRepository _repository;

  List<EInvoice> _invoices = [];
  EInvoiceDetailResponse? _selectedInvoice;
  bool _isLoading = false;
  String? _errorMessage;

  List<EInvoice> get invoices => _invoices;
  EInvoiceDetailResponse? get selectedInvoice => _selectedInvoice;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> loadInvoices() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _invoices = await _repository.fetchInvoices();
    } on ApiException catch (e) {
      _errorMessage = e.message;
    } catch (e) {
      _errorMessage = 'Không thể tải danh sách hóa đơn: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadInvoiceDetail(int id) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _selectedInvoice = await _repository.fetchInvoiceById(id);
    } on ApiException catch (e) {
      _errorMessage = e.message;
    } catch (e) {
      _errorMessage = 'Không thể tải chi tiết hóa đơn: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> createInvoiceFromOrder(int orderId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _repository.createInvoiceFromOrder(orderId);
      await loadInvoices();
      return true;
    } on ApiException catch (e) {
      _errorMessage = e.message;
      return false;
    } catch (e) {
      _errorMessage = 'Không thể tạo hóa đơn: $e';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
