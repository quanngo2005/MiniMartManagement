import 'package:mini_mart_management_mobile_app/core/api_exception.dart';
import 'package:mini_mart_management_mobile_app/models/cashier_performance.dart';
import 'package:mini_mart_management_mobile_app/models/daily_revenue.dart';
import 'package:mini_mart_management_mobile_app/models/hourly_revenue.dart';
import 'package:mini_mart_management_mobile_app/models/inventory_status.dart';
import 'package:mini_mart_management_mobile_app/models/monthly_financial_report.dart';
import 'package:mini_mart_management_mobile_app/models/revenue_summary.dart';
import 'package:mini_mart_management_mobile_app/models/supplier_debt.dart';
import 'package:mini_mart_management_mobile_app/models/top_product.dart';
import 'package:mini_mart_management_mobile_app/services/report_service.dart';

class ReportRepository {
  const ReportRepository(this._reportService);

  final ReportService _reportService;

  Future<List<CashierPerformance>> getCashierPerformance({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      return await _reportService.getCashierPerformance(
        startDate: startDate,
        endDate: endDate,
      );
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException('Khong the tai hieu suat nhan vien: $e');
    }
  }

  Future<RevenueSummary> getRevenueSummary({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      return await _reportService.getRevenueSummary(
        startDate: startDate,
        endDate: endDate,
      );
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException('Khong the tai tong quan doanh thu: $e');
    }
  }

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
      throw ApiException('Khong the tai du lieu hieu suat san pham: $e');
    }
  }

  Future<List<DailyRevenue>> getDailyRevenue(int month, int year) async {
    try {
      final rawList = await _reportService.getDailyRevenue(month, year);
      return rawList
          .whereType<Map<String, dynamic>>()
          .map(DailyRevenue.fromJson)
          .toList();
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException('Khong the tai bao cao doanh thu ngay: $e');
    }
  }

  Future<List<HourlyRevenue>> getHourlyRevenue(DateTime date) async {
    try {
      final rawList = await _reportService.getHourlyRevenue(date);
      return rawList
          .whereType<Map<String, dynamic>>()
          .map(HourlyRevenue.fromJson)
          .toList();
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException('Khong the tai bao cao doanh thu gio: $e');
    }
  }

  Future<List<InventoryStatus>> getLowStockAlerts() async {
    try {
      final rawList = await _reportService.getLowStockAlerts();
      return rawList
          .whereType<Map<String, dynamic>>()
          .map(InventoryStatus.fromJson)
          .toList();
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException('Khong the tai canh bao ton kho: $e');
    }
  }

  Future<List<SupplierDebt>> getSupplierDebt() async {
    try {
      final rawList = await _reportService.getSupplierDebt();
      return rawList
          .whereType<Map<String, dynamic>>()
          .map(SupplierDebt.fromJson)
          .toList();
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException('Khong the tai cong no nha cung cap: $e');
    }
  }

  Future<MonthlyFinancialReport> getMonthlyFinancialReport(
    int month,
    int year,
  ) async {
    try {
      final raw = await _reportService.getMonthlyFinancialReport(month, year);
      return MonthlyFinancialReport.fromJson(raw);
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException('Khong the tai bao cao tai chinh thang: $e');
    }
  }
}
