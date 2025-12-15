import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:rezervasyon_mobil/core/constants.dart';
import 'package:rezervasyon_mobil/models/user_model/user_model.dart';

class UserService {
  final String baseUrl = Constants.baseUrl;

  /// Kullanıcı kayıt
  Future<void> userRegister(Map<String, dynamic> userData) async {
    final response = await http.post(
      Uri.parse('$baseUrl/user/register'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(userData),
    );

    if (response.statusCode != 200) {
      throw Exception("User registration failed");
    }
  }

  /// Giriş yapan kullanıcının bilgisi
  Future<User> fetchUser(String token) async {
    final response = await http.get(
      Uri.parse('$baseUrl/user/myUser'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return User.fromJson(data);
    } else {
      throw Exception('Kullanıcı bilgisi alınamadı');
    }
  }

  /// Kullanıcı güncelle
  /// password varsa gönderilir, yoksa gönderilmez
  Future<void> updateUser({
    required String token,
    required Map<String, dynamic> data,
  }) async {
    final response = await http.put(
      Uri.parse('$baseUrl/user/update'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(data),
    );

    if (response.statusCode != 200) {
      throw Exception('Kullanıcı güncellenemedi');
    }
  }
}
