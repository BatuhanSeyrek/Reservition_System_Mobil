import 'dart:convert';
import 'package:http/http.dart' as http;
import '../core/constants.dart';
import '../models/auth_response.dart';

class AuthService {
  final String baseUrl = Constants.baseUrl;

  // Admin login artık username ve password ile
  Future<AuthResponse> loginAdmin(String username, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/admin/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'username': username, 'password': password}),
    );

    if (response.statusCode == 200) {
      return AuthResponse.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Admin login failed');
    }
  }

  // User login
  Future<AuthResponse> loginUser(String username, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/user/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'username': username, 'password': password}),
    );

    if (response.statusCode == 200) {
      return AuthResponse.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('User login failed');
    }
  }
}
