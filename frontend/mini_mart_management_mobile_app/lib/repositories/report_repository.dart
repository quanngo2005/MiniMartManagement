import 'package:mini_mart_management_mobile_app/core/api_exception.dart';
import 'package:mini_mart_management_mobile_app/models/top_product.dart';
import 'package:mini_mart_management_mobile_app/services/report_service.dart';

class ReportRepository {
  const ReportRepository(this._reportService);

  final ReportService _reportService;

  Future<List<TopProduct>> getTopProducts({
    DateTime? startDate,
    DateTime? endDate,
    int top = 10,
  }) async {
    try {
      return await _reportService.getTopProducts(
        startDate: startDate,
        endDate: endDate,
        top: top,
      );
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException('Không thể tải dữ liệu hiệu suất sản phẩm: ${e.toString()}');
    }
  }
}
