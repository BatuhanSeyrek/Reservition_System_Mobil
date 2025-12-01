import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:rezervasyon_mobil/core/constants.dart';
import 'package:rezervasyon_mobil/models/admin_model/admin_model.dart';
import 'package:rezervasyon_mobil/models/admin_model/employee_model.dart';

class AdminService {
  final String baseUrl = Constants.baseUrl;
  final String? token;
  AdminService({this.token});
  Map<String, String> get headers {
    final h = {'Content-Type': 'application/json'};
    if (token != null) h['Authorization'] = 'Bearer $token';
    return h;
  }

  Future<List<AdminModel>> fetchMyAdmin() async {
    final response = await http.get(
      Uri.parse('$baseUrl/admin/myAdmin'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      // JSON tek obje döndüğü için direkt AdminModel oluşturuyoruz ve listeye sarıyoruz
      return [AdminModel.fromJson(data)];

      // Eğer API bir liste döndürüyorsa:
      // return (data as List).map((e) => AdminModel.fromJson(e)).toList();
    } else {
      throw Exception("Failed to fetch admin data");
    }
  }

  Future<void> addAdmin(AdminModel admin) async {
    final response = await http.post(
      Uri.parse('$baseUrl/admin/register'),
      headers: headers,
      body: jsonEncode(admin.toJson()),
    );
    if (response.statusCode != 200) throw Exception("Add failed");
  }

  Future<void> updateAdmin(AdminModel admin) async {
    final response = await http.put(
      Uri.parse('$baseUrl/admin/update'),
      headers: headers,
      body: jsonEncode(admin.toJson()),
    );
    if (response.statusCode != 200) throw Exception("Update failed");
  }

  Future<void> deleteAdmin(int id) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/admin/delete/$id'),
      headers: headers,
    );
    if (response.statusCode != 200) throw Exception("Delete failed");
  }
}
