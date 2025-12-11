import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:rezervasyon_mobil/core/constants.dart';

class ChairService {
  final _storage = const FlutterSecureStorage();
  final String baseUrl = Constants.baseUrl; // ← burayı değiştir

  Future<List<dynamic>> getAvailableSlots() async {
    final referenceId = await _storage.read(key: 'referenceId');
    if (referenceId == null || referenceId.isEmpty) {
      throw Exception('Reference ID bulunamadı (secure storage).');
    }

    final res = await http.post(
      Uri.parse('$baseUrl/store/getAvailableSlotsReference'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'referenceId': referenceId}),
    );

    if (res.statusCode != 200) {
      throw Exception('API hata: ${res.statusCode} ${res.body}');
    }

    return jsonDecode(res.body) as List<dynamic>;
  }

  Future<bool> createReservation(Map<String, dynamic> payload) async {
    final res = await http.post(
      Uri.parse('$baseUrl/store/referenceReservationAdd'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(payload),
    );

    return res.statusCode == 200;
  }
}
