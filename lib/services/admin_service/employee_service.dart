import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:rezervasyon_mobil/core/constants.dart';
import 'package:rezervasyon_mobil/models/admin_model/employee_model.dart';

class EmployeeService {
  final String baseUrl = Constants.baseUrl;
  final String? token;

  EmployeeService({this.token});

  Map<String, String> get headers {
    final h = {'Content-Type': 'application/json'};
    if (token != null) h['Authorization'] = 'Bearer $token';
    return h;
  }

  Future<List<Employee>> fetchEmployees() async {
    final response = await http.get(
      Uri.parse('$baseUrl/admin/employee/list'),
      headers: headers,
    );
    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      return data.map((e) => Employee.fromJson(e)).toList();
    } else {
      throw Exception("Failed to fetch employees");
    }
  }

  Future<void> addEmployee(Employee employee) async {
    final response = await http.post(
      Uri.parse('$baseUrl/admin/employee/employeeAdd'),
      headers: headers,
      body: jsonEncode(employee.toJson()),
    );
    if (response.statusCode != 200) throw Exception("Add failed");
  }

  Future<void> updateEmployee(int id, Employee employee) async {
    final response = await http.put(
      Uri.parse('$baseUrl/admin/empolyee/update/$id'),
      headers: headers,
      body: jsonEncode(employee.toJson()),
    );
    if (response.statusCode != 200) throw Exception("Update failed");
  }

  Future<void> deleteEmployee(int id) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/admin/employee/delete/$id'),
      headers: headers,
    );
    if (response.statusCode != 200) throw Exception("Delete failed");
  }
}
