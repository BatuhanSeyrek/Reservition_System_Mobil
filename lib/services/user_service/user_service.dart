import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:rezervasyon_mobil/core/constants.dart';
import 'package:rezervasyon_mobil/models/user_model/user_model.dart';

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

  Future<User> fetchUser(String token) async {
    final response = await http.get(
      Uri.parse(
        'https://antone-unupbraiding-stephine.ngrok-free.dev/user/myUser',
      ),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    print("Status code: ${response.statusCode}");
    print("Body: ${response.body}");

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return User.fromJson(data);
    } else {
      throw Exception('Kullanıcı bilgisi alınamadı: ${response.body}');
    }
  }
}
