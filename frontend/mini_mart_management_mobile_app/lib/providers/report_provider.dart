import 'package:flutter/foundation.dart';
import 'package:mini_mart_management_mobile_app/core/api_exception.dart';
import 'package:mini_mart_management_mobile_app/models/cashier_performance.dart';
import 'package:mini_mart_management_mobile_app/models/daily_revenue.dart';
import 'package:mini_mart_management_mobile_app/models/hourly_revenue.dart';
import 'package:mini_mart_management_mobile_app/models/inventory_status.dart';
import 'package:mini_mart_management_mobile_app/models/monthly_financial_report.dart';
import 'package:mini_mart_management_mobile_app/models/revenue_summary.dart';
import 'package:mini_mart_management_mobile_app/models/supplier_debt.dart';
import 'package:mini_mart_management_mobile_app/models/top_product.dart';
import 'package:mini_mart_management_mobile_app/repositories/report_repository.dart';

class ReportProvider with ChangeNotifier {
  ReportProvider(this._reportRepository);

  final ReportRepository _reportRepository;

  List<CashierPerformance> _cashierPerformance = [];
  List<TopProduct> _topProducts = [];
  List<TopProduct> _dashboardTopProducts = [];
  List<DailyRevenue> _dailyRevenue = [];
  List<HourlyRevenue> _hourlyRevenue = [];
  List<InventoryStatus> _lowStockAlerts = [];
  List<SupplierDebt> _supplierDebt = [];
  MonthlyFinancialReport? _monthlyFinancialReport;
  RevenueSummary? _revenueSummary;

  bool _isLoading = false;
  String? _error;

  List<CashierPerformance> get cashierPerformance => _cashierPerformance;
  List<TopProduct> get topProducts => _topProducts;
  List<TopProduct> get dashboardTopProducts => _dashboardTopProducts;
  List<DailyRevenue> get dailyRevenue => _dailyRevenue;
  List<HourlyRevenue> get hourlyRevenue => _hourlyRevenue;
  List<InventoryStatus> get lowStockAlerts => _lowStockAlerts;
  List<SupplierDebt> get supplierDebt => _supplierDebt;
  MonthlyFinancialReport? get monthlyFinancialReport => _monthlyFinancialReport;
  RevenueSummary? get revenueSummary => _revenueSummary;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchCashierPerformance({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      _cashierPerformance = await _reportRepository.getCashierPerformance(
        startDate: startDate,
        endDate: endDate,
      );
    } on ApiException catch (e) {
      _error = e.message;
    } catch (_) {
      _error = 'Đã xảy ra lỗi khi tải hiệu suất nhân viên.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

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

  Future<void> fetchAllReportsForDate(DateTime date, {int top = 10}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await Future.wait([
        _fetchDailyRevenue(date.month, date.year),
        _fetchHourlyRevenue(date),
        _fetchLowStockAlerts(),
        _fetchSupplierDebt(),
        _fetchDashboardTopProducts(startDate: date, endDate: date, top: top),
      ]);
    } catch (e) {
      _error = e is ApiException
          ? e.message
          : 'Đã xảy ra lỗi khi tải báo cáo tổng hợp.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchMonthlyFinancialReport(DateTime date) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _monthlyFinancialReport = await _reportRepository
          .getMonthlyFinancialReport(date.month, date.year);
    } on ApiException catch (e) {
      _error = e.message;
    } catch (_) {
      _error = 'Đã xảy ra lỗi khi tải báo cáo tài chính tháng.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchRevenueSummary({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _revenueSummary = await _reportRepository.getRevenueSummary(
        startDate: startDate,
        endDate: endDate,
      );
    } on ApiException catch (e) {
      _error = e.message;
    } catch (_) {
      _error = 'Đã xảy ra lỗi khi tải tổng quan doanh thu.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _fetchDailyRevenue(int month, int year) async {
    _dailyRevenue = await _reportRepository.getDailyRevenue(month, year);
  }

  Future<void> _fetchHourlyRevenue(DateTime date) async {
    _hourlyRevenue = await _reportRepository.getHourlyRevenue(date);
  }

  Future<void> _fetchLowStockAlerts() async {
    _lowStockAlerts = await _reportRepository.getLowStockAlerts();
  }

  Future<void> _fetchSupplierDebt() async {
    _supplierDebt = await _reportRepository.getSupplierDebt();
  }

  Future<void> _fetchDashboardTopProducts({
    DateTime? startDate,
    DateTime? endDate,
    int top = 10,
  }) async {
    _dashboardTopProducts = await _reportRepository.getTopProducts(
      startDate: startDate,
      endDate: endDate,
      top: top,
    );
  }
}
