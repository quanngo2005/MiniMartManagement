import 'package:mini_mart_management_mobile_app/core/api_exception.dart';
import 'package:mini_mart_management_mobile_app/models/employee.dart';
import 'package:mini_mart_management_mobile_app/models/role.dart';
import 'package:mini_mart_management_mobile_app/services/employee_service.dart';

class EmployeeRepository {
  const EmployeeRepository(this._employeeService);

  final EmployeeService _employeeService;

  Future<List<Employee>> getAllEmployees() async {
    try {
      return await _employeeService.getAllEmployees();
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException('Không thể tải danh sách nhân viên: ${e.toString()}');
    }
  }

  Future<Employee> createEmployee(Map<String, dynamic> data) async {
    try {
      return await _employeeService.createEmployee(data);
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException('Không thể tạo nhân viên: ${e.toString()}');
    }
  }

  Future<Employee> updateEmployee(int id, Map<String, dynamic> data) async {
    try {
      return await _employeeService.updateEmployee(id, data);
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException('Không thể cập nhật nhân viên: ${e.toString()}');
    }
  }

  Future<void> disableEmployee(int id) async {
    try {
      await _employeeService.disableEmployee(id);
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException('Không thể vô hiệu hóa nhân viên: ${e.toString()}');
    }
  }

  Future<List<Role>> getRoles() async {
    try {
      return await _employeeService.getRoles();
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException('Không thể tải danh sách vai trò: ${e.toString()}');
    }
  }
}
