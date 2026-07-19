import 'package:mini_mart_management_mobile_app/core/api_exception.dart';
import 'package:mini_mart_management_mobile_app/models/supplier_debt_tracking.dart';
import 'package:mini_mart_management_mobile_app/services/supplier_debt_service.dart';

class SupplierDebtRepository {
  const SupplierDebtRepository(this._service);

  final SupplierDebtService _service;

  Future<List<SupplierDebtSummary>> getDebtSummaries() async {
    try {
      return await _service.getDebtSummaries();
    } on ApiException {
      rethrow;
    } catch (error) {
      throw ApiException('Không thể tải công nợ nhà cung cấp: $error');
    }
  }

  Future<SupplierDebtDetail> getDebtDetail(int supplierId) async {
    try {
      return await _service.getDebtDetail(supplierId);
    } on ApiException {
      rethrow;
    } catch (error) {
      throw ApiException('Không thể tải chi tiết công nợ: $error');
    }
  }
}
