import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:rezervasyon_mobil/models/admin_model/chair_model.dart';
import 'package:rezervasyon_mobil/models/admin_model/store_model.dart';
import '../core/constants.dart';
import '../models/reservation_model.dart';

class ReservationService {
  final String baseUrl = Constants.baseUrl;

  Map<String, String> _headers(String token) => {
    'Authorization': 'Bearer $token',
    'Content-Type': 'application/json',
  };

  Future<List<Reservation>> getUserReservations(String token) async {
    final res = await http.get(
      Uri.parse('$baseUrl/store/userReservationGet'),
      headers: _headers(token),
    );

    if (res.statusCode != 200) {
      throw Exception('Rezervasyonlar alınamadı');
    }

    final List data = jsonDecode(res.body);
    return data.map((e) => Reservation.fromJson(e)).toList();
  }

  Future<List<Store>> getStores(String token) async {
    final res = await http.get(
      Uri.parse('$baseUrl/store/storeAll'),
      headers: _headers(token),
    );

    final List data = jsonDecode(res.body);
    return data.map((e) => Store.fromJson(e['store'])).toList();
  }

  Future<List<Chair>> getChairsByStore(String token, int storeId) async {
    final res = await http.get(
      Uri.parse('$baseUrl/store/chairgetbystore/$storeId'),
      headers: _headers(token),
    );

    final List data = jsonDecode(res.body);
    return data.map((e) => Chair.fromJson(e)).toList();
  }

  Future<void> updateReservation(
    String token,
    int id,
    Map<String, dynamic> data,
  ) async {
    await http.put(
      Uri.parse('$baseUrl/store/reservationUpdate/$id'),
      headers: _headers(token),
      body: jsonEncode(data),
    );
  }

  Future<void> deleteReservation(String token, int id) async {
    await http.delete(
      Uri.parse('$baseUrl/store/userReservationDelete/$id'),
      headers: _headers(token),
    );
  }
}
