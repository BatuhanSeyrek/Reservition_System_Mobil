import 'package:flutter/material.dart';
import 'package:rezervasyon_mobil/core/secure_storage.dart';
import 'package:rezervasyon_mobil/models/admin_model/employee_model.dart';
import 'package:rezervasyon_mobil/services/admin_service/employee_service.dart';

class EmployeeProvider with ChangeNotifier {
  final SecureStorage _storage = SecureStorage();

  List<Employee> employees = [];
  bool isLoading = false;
  Future<String?> _getToken() async {
    return await _storage.readToken();
  }

  Future<void> fetchEmployees() async {
    isLoading = true;
    notifyListeners();
    try {
      final token = await _getToken();
      final service = EmployeeService(token: token);
      employees = await service.fetchEmployees();
    } catch (e) {
      print("Fetch Employees Error: $e");
    }
    isLoading = false;
    notifyListeners();
  }

  Future<void> addEmployee(Employee employee) async {
    try {
      final token = await _getToken();
      final service = EmployeeService(token: token);
      await service.addEmployee(employee);
      await fetchEmployees();
    } catch (e) {
      print("Add Employee Error: $e");
    }
  }

  Future<void> updateEmployee(int id, Employee employee) async {
    try {
      final token = await _getToken();
      final service = EmployeeService(token: token);
      await service.updateEmployee(id, employee);
      await fetchEmployees();
    } catch (e) {
      print("Update Employee Error: $e");
    }
  }

  Future<void> deleteEmployee(int id) async {
    try {
      final token = await _getToken();
      final service = EmployeeService(token: token);
      await service.deleteEmployee(id);
      employees.removeWhere((e) => e.id == id);
      notifyListeners();
    } catch (e) {
      print("Delete Employee Error: $e");
    }
  }
}
