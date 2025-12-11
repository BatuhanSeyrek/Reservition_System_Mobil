import 'package:flutter/material.dart';
import 'package:rezervasyon_mobil/models/user_model/reference_chair_model.dart';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:rezervasyon_mobil/services/user_service/refrence_chair_service.dart';

class RefenceChairProvider extends ChangeNotifier {
  final ChairService _service = ChairService();
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  String selectedChairName = '';
  List<ChairModel> chairs = [];
  List<String> availableDates = [];
  String selectedDate = '';
  bool isLoading = false;

  void changeChairName(String name) {
    selectedChairName = name;
    notifyListeners();
  }

  Future<void> loadChairs() async {
    try {
      isLoading = true;
      notifyListeners();

      final data = await _service.getAvailableSlots();
      chairs =
          data
              .map((e) => ChairModel.fromJson(Map<String, dynamic>.from(e)))
              .toList();

      if (chairs.isNotEmpty) {
        availableDates = chairs.first.slots.keys.toList();
        if (availableDates.length > 7) {
          availableDates = availableDates.sublist(0, 7);
        }
        selectedDate = availableDates.isNotEmpty ? availableDates.first : '';
      } else {
        availableDates = [];
        selectedDate = '';
      }
    } catch (e) {
      // Hata için log bırak
      debugPrint('loadChairs error: $e');
      rethrow;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  void changeDate(String date) {
    selectedDate = date;
    notifyListeners();
  }

  Future<bool> makeReservation({
    required int chairId,
    required String time,
    required String name,
    required String surname,
    required String phone,
  }) async {
    try {
      final adminIdStr = await _storage.read(key: 'adminId') ?? '0';
      final adminId = int.tryParse(adminIdStr) ?? 0;

      final payload = {
        'storeId': adminId,
        'chairId': chairId,
        'reservationDate': selectedDate,
        'startTime': time,
        'customerName': name,
        'customerSurname': surname,
        'customerPhone': phone,
      };

      final ok = await _service.createReservation(payload);
      if (ok) {
        // Lokal UI güncellemesi: ilgili slotu false yap
        final idx = chairs.indexWhere((c) => c.chairId == chairId);
        if (idx != -1 && chairs[idx].slots.containsKey(selectedDate)) {
          chairs[idx].slots[selectedDate]![time] = false;
        }
        notifyListeners();
      }
      return ok;
    } catch (e) {
      debugPrint('makeReservation error: $e');
      return false;
    }
  }
}
