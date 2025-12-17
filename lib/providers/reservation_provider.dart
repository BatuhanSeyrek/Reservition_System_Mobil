import 'package:flutter/material.dart';
import 'package:rezervasyon_mobil/models/admin_model/chair_model.dart';
import 'package:rezervasyon_mobil/models/admin_model/store_model.dart';
import 'package:rezervasyon_mobil/services/reservation_user_service.dart';
import '../models/reservation_model.dart';
import '../services/reservation_service.dart';

class ReservationUserProvider extends ChangeNotifier {
  final _service = ReservationService();

  bool isLoading = false;

  List<Reservation> reservations = [];
  List<Store> stores = [];
  List<Chair> chairs = [];

  Future<void> loadReservations(String token) async {
    isLoading = true;
    notifyListeners();

    reservations = await _service.getUserReservations(token);

    isLoading = false;
    notifyListeners();
  }

  Future<void> loadStores(String token) async {
    stores = await _service.getStores(token);
    notifyListeners();
  }

  Future<void> loadChairs(String token, int storeId) async {
    chairs = await _service.getChairsByStore(token, storeId);
    notifyListeners();
  }

  void clearChairs() {
    chairs = [];
    notifyListeners();
  }

  Future<void> updateReservation(
    String token,
    int id,
    Map<String, dynamic> data,
  ) async {
    await _service.updateReservation(token, id, data);
    await loadReservations(token);
  }

  Future<void> deleteReservation(String token, int id) async {
    await _service.deleteReservation(token, id);
    await loadReservations(token);
  }
}
