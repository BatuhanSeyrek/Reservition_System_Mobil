import 'package:flutter/material.dart';
import '../../models/admin_model/reservation_model.dart';
import '../../services/admin_service/reservation_service.dart';
import '../../core/secure_storage.dart';

class ReservationProvider with ChangeNotifier {
  List<Reservation> reservations = [];
  bool isLoading = false;
  final SecureStorage _storage = SecureStorage();

  Future<String?> _getToken() async {
    return await _storage.readToken();
  }

  Future<void> fetchReservations() async {
    isLoading = true;
    notifyListeners();

    try {
      final token = await _getToken();
      final service = ReservationService(token: token);
      reservations = await service.fetchReservations();
    } catch (e) {
      print("Fetch Reservations Error: $e");
    }

    isLoading = false;
    notifyListeners();
  }
}
