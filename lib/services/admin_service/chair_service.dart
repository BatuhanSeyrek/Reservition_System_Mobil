import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../core/constants.dart';
import '../../models/admin_model/chair_model.dart';

class ChairService {
  final String baseUrl = Constants.baseUrl;
  final String? token;

  ChairService({this.token});

  Map<String, String> get headers {
    final h = {'Content-Type': 'application/json'};
    if (token != null) h['Authorization'] = 'Bearer $token';
    return h;
  }

  Future<List<Chair>> fetchChairs() async {
    final response = await http.get(
      Uri.parse('$baseUrl/admin/chair/list'),
      headers: headers,
    );
    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      return data.map((e) => Chair.fromJson(e)).toList();
    } else {
      throw Exception("Failed to fetch chairs");
    }
  }

  Future<void> addChair(Chair chair) async {
    final response = await http.post(
      Uri.parse('$baseUrl/admin/chair/chairAdd'),
      headers: headers,
      body: jsonEncode(chair.toJson()),
    );
    if (response.statusCode != 200) throw Exception("Add failed");
  }

  Future<void> updateChair(int id, Chair chair) async {
    final response = await http.put(
      Uri.parse('$baseUrl/admin/chair/update/$id'),
      headers: headers,
      body: jsonEncode(chair.toJson()),
    );
    if (response.statusCode != 200) throw Exception("Update failed");
  }

  Future<void> deleteChair(int id) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/admin/chair/delete/$id'),
      headers: headers,
    );
    if (response.statusCode != 200) throw Exception("Delete failed");
  }
}
