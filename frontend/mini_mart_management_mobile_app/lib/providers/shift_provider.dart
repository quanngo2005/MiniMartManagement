import 'package:flutter/foundation.dart';
import 'package:mini_mart_management_mobile_app/core/api_exception.dart';
import 'package:mini_mart_management_mobile_app/models/shift.dart';
import 'package:mini_mart_management_mobile_app/repositories/shift_repository.dart';

class ShiftProvider extends ChangeNotifier {
  ShiftProvider(this._shiftRepository);

  final ShiftRepository _shiftRepository;

  Shift? _currentShift;
  List<Shift> _shifts = [];
  bool _isLoading = false;
  String? _error;

  Shift? get currentShift => _currentShift;
  List<Shift> get shifts => _shifts;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchCurrentShift() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _currentShift = await _shiftRepository.getCurrentShift();
    } on ApiException catch (e) {
      _error = e.message;
    } catch (_) {
      _error = 'Đã xảy ra lỗi khi tải ca làm việc hiện tại.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchShifts() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _shifts = await _shiftRepository.getAllShifts();
    } on ApiException catch (e) {
      _error = e.message;
    } catch (_) {
      _error = 'Đã xảy ra lỗi khi tải danh sách ca làm việc.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> openNewShift({
    required int cashierId,
    required double startCash,
    bool isMorning = true,
    String? note,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final now = DateTime.now();
      final dateStr =
          '${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}';
      final shiftCode = (isMorning ? 'SA-' : 'CH-') + dateStr;
      final shiftName = isMorning ? 'Ca sáng' : 'Ca chiều';
      final startTimeStr = DateTime(
        now.year,
        now.month,
        now.day,
        isMorning ? 6 : 14,
      ).toIso8601String();
      final endTimeStr = DateTime(
        now.year,
        now.month,
        now.day,
        isMorning ? 14 : 22,
      ).toIso8601String();

      final newShiftPayload = {
        'shiftCode': shiftCode,
        'shiftName': shiftName,
        'startTime': startTimeStr,
        'endTime': endTimeStr,
        'workDate': DateTime(now.year, now.month, now.day).toIso8601String(),
        'startCash': startCash,
        'endCash': 0.0,
        'revenue': 0.0,
        'status': 1, // Pending
        'employeeId': cashierId,
        'note': note ?? '',
      };

      final createdShift = await _shiftRepository.createShift(newShiftPayload);
      final opened = await _shiftRepository.openShift(
        shiftId: createdShift.shiftId,
        cashierId: cashierId,
        startCash: startCash,
        note: note,
      );
      _currentShift = opened;
      return true;
    } on ApiException catch (e) {
      _error = e.message;
      return false;
    } catch (_) {
      _error = 'Không thể mở ca làm việc mới.';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> openShift({
    required int shiftId,
    required int cashierId,
    required double startCash,
    String? note,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final opened = await _shiftRepository.openShift(
        shiftId: shiftId,
        cashierId: cashierId,
        startCash: startCash,
        note: note,
      );
      _currentShift = opened;
      return true;
    } on ApiException catch (e) {
      _error = e.message;
      return false;
    } catch (_) {
      _error = 'Không thể mở ca làm việc mới.';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> closeShift({
    required int shiftId,
    required double endCash,
    String? note,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _shiftRepository.closeShift(
        shiftId: shiftId,
        endCash: endCash,
        note: note,
      );
      _currentShift = null;
      return true;
    } on ApiException catch (e) {
      _error = e.message;
      return false;
    } catch (_) {
      _error = 'Không thể kết thúc ca làm việc.';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
