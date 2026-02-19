import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:rezervasyon_mobil/core/constants.dart';
import 'package:rezervasyon_mobil/models/public_chair_models.dart';

class PublicChairService {
  final String baseUrl = Constants.baseUrl; // örn: http://10.0.2.2:8080

  Future<List<PublicChairModel>> fetchChairs(int adminId) async {
    final url = Uri.parse("$baseUrl/store/gettAvailableSlotss/$adminId");

    final response = await http.get(
      url,
      headers: {"Content-Type": "application/json"},
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);

      return data.map((e) => PublicChairModel.fromJson(e)).toList();
    } else {
      throw Exception("Koltuklar alınamadı");
    }
  }
}
