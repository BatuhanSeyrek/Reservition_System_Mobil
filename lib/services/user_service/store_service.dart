import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:rezervasyon_mobil/core/constants.dart';
import 'package:rezervasyon_mobil/models/user_model/store_models.dart';

class StoreService {
  static Future<List<StoreResponse>> fetchStores({
    required String token,
  }) async {
    final response = await http.get(
      Uri.parse('${Constants.baseUrl}/store/storeAll'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token', // token burada
      },
    );

    if (response.statusCode == 200) {
      final List data = json.decode(response.body);
      return data.map((e) => StoreResponse.fromJson(e)).toList();
    } else if (response.statusCode == 403) {
      throw Exception('403 Forbidden: Yetkiniz yok veya token hatalı.');
    } else {
      throw Exception('Store verileri alınamadı: ${response.statusCode}');
    }
  }

  static Future<List<int>> fetchFavorites({required String token}) async {
    final response = await http.get(
      Uri.parse('${Constants.baseUrl}/api/favorites/my-favorites'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      final List data = json.decode(response.body);
      // React tarafında f.id mapping'i yapılmış, burada da aynısını yapıyoruz
      return data.map<int>((e) => e['id'] as int).toList();
    }
    return [];
  }

  static Future<void> toggleFavorite({
    required String token,
    required int storeId,
  }) async {
    await http.post(
      Uri.parse('${Constants.baseUrl}/api/favorites/toggle/$storeId'),
      headers: {'Authorization': 'Bearer $token'},
    );
  }
}
