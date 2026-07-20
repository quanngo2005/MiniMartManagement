import 'package:flutter/foundation.dart';
import 'package:mini_mart_management_mobile_app/core/api_exception.dart';
import 'package:mini_mart_management_mobile_app/models/warehouse_dashboard.dart';
import 'package:mini_mart_management_mobile_app/services/warehouse_dashboard_service.dart';

class WarehouseDashboardProvider extends ChangeNotifier {
  WarehouseDashboardProvider(this._service);

  final WarehouseDashboardService _service;

  WarehouseDashboardData? _data;
  bool _isLoading = false;
  String? _error;

  WarehouseDashboardData? get data => _data;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchDashboard() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final results = await Future.wait([
        _service.getInventoryReport(),
        _service.getLowStockAlerts(),
        _service.getNearExpiryProducts(days: 30),
        _service.getRecentBatches(),
      ]);

      final allItems = results[0] as List<InventoryStatus>;
      final lowStock = results[1] as List<InventoryStatus>;
      final nearExpiry = results[2] as List<NearExpiryProduct>;
      final recentBatches = results[3] as List<RecentBatch>;

      _data = WarehouseDashboardData(
        totalProducts: allItems.length,
        lowStockCount: lowStock.where((i) => i.currentStock > 0).length,
        outOfStockCount: lowStock.where((i) => i.currentStock == 0).length,
        lowStockItems: lowStock.take(8).toList(),
        nearExpiryProducts: nearExpiry.take(8).toList(),
        recentBatches: recentBatches,
      );
    } on ApiException catch (e) {
      _error = e.message;
    } catch (_) {
      _error = 'Đã xảy ra lỗi khi tải dữ liệu.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
