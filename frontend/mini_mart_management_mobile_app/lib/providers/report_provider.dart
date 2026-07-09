import 'package:flutter/foundation.dart';
import 'package:mini_mart_management_mobile_app/core/api_exception.dart';
import 'package:mini_mart_management_mobile_app/models/top_product.dart';
import 'package:mini_mart_management_mobile_app/repositories/report_repository.dart';

class ReportProvider with ChangeNotifier {
  ReportProvider(this._reportRepository);

  final ReportRepository _reportRepository;

  List<TopProduct> _topProducts = [];
  bool _isLoading = false;
  String? _error;

  List<TopProduct> get topProducts => _topProducts;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchTopProducts({
    DateTime? startDate,
    DateTime? endDate,
    int top = 10,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      _topProducts = await _reportRepository.getTopProducts(
        startDate: startDate,
        endDate: endDate,
        top: top,
      );
    } on ApiException catch (e) {
      _error = e.message;
    } catch (_) {
      _error = 'Đã xảy ra lỗi khi tải hiệu suất sản phẩm.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
