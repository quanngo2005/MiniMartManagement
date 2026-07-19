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
    int shiftType = 0, // 0 = Sáng, 1 = Chiều, 2 = Tối
    String? note,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final now = DateTime.now();
      final shifts = await _shiftRepository.getAllShifts();
      final assignedShift = shifts.cast<Shift?>().firstWhere(
        (shift) =>
            shift != null &&
            shift.status == 1 &&
            shift.employeeId == cashierId &&
            _isSameDay(shift.workDate, now) &&
            _shiftTypeFromStartTime(shift.startTime) == shiftType,
        orElse: () => null,
      );

      if (assignedShift != null) {
        _currentShift = await _shiftRepository.openShift(
          shiftId: assignedShift.shiftId,
          cashierId: cashierId,
          startCash: startCash,
          note: note,
        );
        return true;
      }

      final dateStr =
          '${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}';

      String shiftCodePrefix;
      String shiftName;
      int startHour;
      int startMinute = 0;
      int endHour;
      int endMinute = 0;

      if (shiftType == 0) {
        shiftCodePrefix = 'SA-';
        shiftName = 'Ca sáng';
        startHour = 6;
        endHour = 11;
      } else if (shiftType == 1) {
        shiftCodePrefix = 'CH-';
        shiftName = 'Ca chiều';
        startHour = 11;
        endHour = 16;
      } else {
        shiftCodePrefix = 'TO-';
        shiftName = 'Ca tối';
        startHour = 16;
        endHour = 22;
        endMinute = 30;
      }

      final shiftCode = shiftCodePrefix + dateStr;
      final startTime = DateTime(
        now.year,
        now.month,
        now.day,
        startHour,
        startMinute,
      );
      final endTime = DateTime(
        now.year,
        now.month,
        now.day,
        endHour,
        endMinute,
      );

      final startTimeStr = startTime.toIso8601String();
      final endTimeStr = endTime.toIso8601String();

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

  bool _isSameDay(DateTime left, DateTime right) {
    return left.year == right.year &&
        left.month == right.month &&
        left.day == right.day;
  }

  int _shiftTypeFromStartTime(DateTime startTime) {
    if (startTime.hour >= 6 && startTime.hour < 11) return 0;
    if (startTime.hour >= 11 && startTime.hour < 16) return 1;
    return 2;
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
