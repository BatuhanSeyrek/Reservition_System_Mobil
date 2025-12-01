import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:rezervasyon_mobil/core/constants.dart';
import 'package:rezervasyon_mobil/models/admin_model/reservation_model.dart';

class ReservationService {
  final String baseUrl = Constants.baseUrl;
  // Rezervasyon oluşturma
  final String? token;
  ReservationService({this.token});
  Map<String, String> get headers {
    final h = {'Content-Type': 'application/json'};
    if (token != null) h['Authorization'] = 'Bearer $token';
    return h;
  }

  Future<List<Reservation>> fetchReservations() async {
    final response = await http.get(
      Uri.parse('$baseUrl/store/getMyReservations'),
      headers: headers,
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return (data as List).map((e) => Reservation.fromJson(e)).toList();
    } else {
      throw Exception("Failed to fetch reservations");
    }
  }
}
