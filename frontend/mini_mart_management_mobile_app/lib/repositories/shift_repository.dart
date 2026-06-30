import 'package:mini_mart_management_mobile_app/core/api_exception.dart';
import 'package:mini_mart_management_mobile_app/models/shift.dart';
import 'package:mini_mart_management_mobile_app/services/shift_service.dart';

class ShiftRepository {
  const ShiftRepository(this._shiftService);

  final ShiftService _shiftService;

  Future<List<Shift>> getAllShifts() async {
    try {
      return await _shiftService.getAllShifts();
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException('Không thể tải danh sách ca làm việc: ${e.toString()}');
    }
  }

  Future<Shift> createShift(Map<String, dynamic> data) async {
    try {
      return await _shiftService.createShift(data);
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException('Không thể tạo ca làm việc: ${e.toString()}');
    }
  }

  Future<Shift?> getCurrentShift() async {
    try {
      return await _shiftService.getCurrentShift();
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException('Không thể tải thông tin ca làm việc hiện tại: ${e.toString()}');
    }
  }

  Future<Shift> openShift({
    required int shiftId,
    required int cashierId,
    required double startCash,
    String? note,
  }) async {
    try {
      return await _shiftService.openShift(
        shiftId: shiftId,
        cashierId: cashierId,
        startCash: startCash,
        note: note,
      );
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException('Không thể mở ca làm việc: ${e.toString()}');
    }
  }

  Future<Shift> closeShift({
    required int shiftId,
    required double endCash,
    String? note,
  }) async {
    try {
      return await _shiftService.closeShift(
        shiftId: shiftId,
        endCash: endCash,
        note: note,
      );
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException('Không thể đóng ca làm việc: ${e.toString()}');
    }
  }
}
