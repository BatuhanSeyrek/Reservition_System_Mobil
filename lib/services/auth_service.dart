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

  // Reference ID Login
  Future<Map<String, dynamic>> loginWithReferenceId(String referenceId) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/user/refenceIdLogin'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'referenceId': referenceId}),
      );

      print('Status code (reference): ${response.statusCode}');
      print('Body (reference): ${response.body}');

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Reference ID login failed: ${response.body}');
      }
    } catch (e) {
      print('Reference Login error: $e');
      rethrow;
    }
  }

  // User login
  Future<AuthResponse> loginUser(String username, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/user/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'username': username, 'password': password}),
      );

      print('Status code: ${response.statusCode}');
      print('Body: ${response.body}');

      if (response.statusCode == 200) {
        return AuthResponse.fromJson(jsonDecode(response.body));
      } else {
        throw Exception('User login failed: ${response.body}');
      }
    } catch (e) {
      print('Login error: $e');
      rethrow;
    }
  }

  Future<Map<String, dynamic>> getMyAdmin(String token) async {
    final response = await http.get(
      Uri.parse('$baseUrl/admin/myAdmin'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to fetch admin data');
    }
  }
}
