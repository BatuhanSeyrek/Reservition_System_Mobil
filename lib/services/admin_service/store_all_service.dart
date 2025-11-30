import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:rezervasyon_mobil/core/constants.dart';

class StoreAllService {
  final String baseUrl = Constants.baseUrl;
  final String? token;

  StoreAllService({this.token});
  Map<String, String> get headers {
    final h = {'Content-Type': 'application/json'};
    if (token != null) h['Authorization'] = 'Bearer $token';
    return h;
  }

  //burada tüm mağazaları çekiyorum.... tüm özellikleriyle birlikte
  Future<List<dynamic>> storeAllData() async {
    final response = await http.get(
      Uri.parse('$baseUrl/store/storeAll'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data; // <-- artık return geçerli
    } else {
      throw Exception("StoreAll getirme hatası: ${response.statusCode}");
    }
  }
}
