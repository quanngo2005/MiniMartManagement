import 'package:flutter/foundation.dart';
import 'package:mini_mart_management_mobile_app/core/api_exception.dart';
import 'package:mini_mart_management_mobile_app/models/employee.dart';
import 'package:mini_mart_management_mobile_app/repositories/employee_repository.dart';

class EmployeeProvider extends ChangeNotifier {
  EmployeeProvider(this._employeeRepository);

  final EmployeeRepository _employeeRepository;

  List<Employee> _employees = [];
  bool _isLoading = false;
  String? _error;

  List<Employee> get employees => _employees;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchEmployees() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _employees = await _employeeRepository.getAllEmployees();
    } on ApiException catch (e) {
      _error = e.message;
    } catch (_) {
      _error = 'Đã xảy ra lỗi khi tải danh sách nhân viên.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> createEmployee(Map<String, dynamic> data) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final created = await _employeeRepository.createEmployee(data);
      _employees.add(created);
      return true;
    } on ApiException catch (e) {
      _error = e.message;
      return false;
    } catch (_) {
      _error = 'Đã xảy ra lỗi khi tạo nhân viên mới.';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> updateEmployee(int id, Map<String, dynamic> data) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final updated = await _employeeRepository.updateEmployee(id, data);
      final index = _employees.indexWhere((e) => e.employeeId == id);
      if (index != -1) {
        _employees[index] = updated;
      }
      return true;
    } on ApiException catch (e) {
      _error = e.message;
      return false;
    } catch (_) {
      _error = 'Đã xảy ra lỗi khi cập nhật thông tin nhân viên.';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> toggleEmployeeStatus(int id, int currentStatus) async {
    // 0 is Inactive, 1 is Active
    final nextStatus = currentStatus == 1 ? 0 : 1;
    final employee = _employees.firstWhere((e) => e.employeeId == id);
    
    // Optimistic UI update
    final index = _employees.indexWhere((e) => e.employeeId == id);
    if (index != -1) {
      _employees[index] = Employee(
        employeeId: employee.employeeId,
        fullName: employee.fullName,
        gender: employee.gender,
        dateOfBirth: employee.dateOfBirth,
        phoneNumber: employee.phoneNumber,
        email: employee.email,
        address: employee.address,
        username: employee.username,
        salary: employee.salary,
        hireDate: employee.hireDate,
        avatar: employee.avatar,
        status: nextStatus,
        roleId: employee.roleId,
        roleName: employee.roleName,
      );
      notifyListeners();
    }

    try {
      if (nextStatus == 0) {
        // Disable
        await _employeeRepository.disableEmployee(id);
      } else {
        // Enable is done by updateEmployee with status = 1
        await _employeeRepository.updateEmployee(id, {
          'fullName': employee.fullName,
          'gender': employee.gender,
          'dateOfBirth': employee.dateOfBirth.toIso8601String(),
          'phoneNumber': employee.phoneNumber,
          'email': employee.email,
          'address': employee.address,
          'username': employee.username,
          'salary': employee.salary,
          'hireDate': employee.hireDate.toIso8601String(),
          'status': 1,
          'roleId': employee.roleId,
        });
      }
      return true;
    } catch (e) {
      // Revert on error
      if (index != -1) {
        _employees[index] = employee;
        notifyListeners();
      }
      _error = e is ApiException ? e.message : 'Không thể thay đổi trạng thái nhân viên.';
      return false;
    }
  }
}
