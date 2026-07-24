import 'package:mini_mart_management_mobile_app/core/api_exception.dart';
import 'package:mini_mart_management_mobile_app/models/e_invoice.dart';
import 'package:mini_mart_management_mobile_app/services/e_invoice_service.dart';

class EInvoiceRepository {
  const EInvoiceRepository(this._service);

  final EInvoiceService _service;

  Future<List<EInvoice>> fetchInvoices() async {
    try {
      return await _service.fetchInvoices();
    } on ApiException {
      rethrow;
    } on FormatException {
      throw const ApiException(
        'Phản hồi danh sách hóa đơn không thể đọc được.',
      );
    }
  }

  Future<EInvoiceDetailResponse> fetchInvoiceById(int id) async {
    try {
      return await _service.fetchInvoiceById(id);
    } on ApiException {
      rethrow;
    } on FormatException {
      throw const ApiException('Phản hồi chi tiết hóa đơn không thể đọc được.');
    }
  }

  Future<EInvoice> createInvoiceFromOrder(int orderId) async {
    try {
      return await _service.createInvoiceFromOrder(orderId);
    } on ApiException {
      rethrow;
    } on FormatException {
      throw const ApiException('Phản hồi tạo hóa đơn không thể đọc được.');
    }
  }
}
