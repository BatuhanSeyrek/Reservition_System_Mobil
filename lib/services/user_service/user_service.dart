import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:rezervasyon_mobil/core/constants.dart';

class UserService {
  final String baseUrl = Constants.baseUrl;
  final String? token;

  UserService({this.token});

  Map<String, String> get headers {
    final h = {'Content-Type': 'application/json'};
    if (token != null) h['Authorization'] = 'Bearer $token';
    return h;
  }

  Future<void> userRegister(Map<String, dynamic> userData) async {
    final response = await http.post(
      Uri.parse('$baseUrl/user/register'),
      headers: headers,
      body: jsonEncode(userData),
    );
    if (response.statusCode != 200) throw Exception("User registration failed");
  }
}
