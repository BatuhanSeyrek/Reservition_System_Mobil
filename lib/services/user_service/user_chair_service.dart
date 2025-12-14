import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:rezervasyon_mobil/core/constants.dart';

class UserChairService {
  static String baseUrl = Constants.baseUrl;

  static Future<List<Map<String, dynamic>>> getData(
    String path, {
    required String token,
  }) async {
    if (token.isEmpty) throw Exception("Token bulunamadı!");

    final response = await http.get(
      Uri.parse("$baseUrl$path"),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      return List<Map<String, dynamic>>.from(jsonDecode(response.body));
    } else {
      throw Exception("API error: ${response.statusCode}");
    }
  }

  static Future<void> postData(
    String path,
    Map<String, dynamic> data, {
    required String token,
  }) async {
    if (token.isEmpty) throw Exception("Token bulunamadı!");

    final response = await http.post(
      Uri.parse("$baseUrl$path"),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(data),
    );

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception("API POST error: ${response.statusCode}");
    }
  }
}
