import 'package:flutter/material.dart';
import '../../models/user_model/user_chair_model.dart';
import '../../services/user_service/user_chair_service.dart';

class ChairProvider with ChangeNotifier {
  List<Chair> chairs = [];
  List<String> availableDates = [];
  String? selectedDate;
  bool isLoading = false;
  String? error;

  // Seçilen sandalye adı
  String? selectedChairName;

  final int adminId;
  final String token;

  ChairProvider({required this.adminId, required this.token});

  Future<void> fetchChairs() async {
    if (token.isEmpty) {
      error = "Kullanıcı token bulunamadı!";
      notifyListeners();
      return;
    }

    isLoading = true;
    notifyListeners();

    try {
      final data = await UserChairService.getData(
        "/store/getAvailableSlots/$adminId",
        token: token,
      );

      chairs = data.map((e) => Chair.fromJson(e)).toList();

      if (chairs.isNotEmpty) {
        // 1. Tarihleri ayarla
        availableDates = chairs[0].slots.keys.toList();
        selectedDate = availableDates.isNotEmpty ? availableDates.first : null;

        // 2. İLK SANDALYEYİ SEÇİLİ HALE GETİR (Bu eksikti)
        selectedChairName = chairs.first.chairName;
      }

      error = null;
    } catch (e) {
      error = e.toString();
      chairs = [];
      availableDates = [];
      selectedDate = null;
      selectedChairName = null;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  void setSelectedChair(String chairName) {
    selectedChairName = chairName;
    notifyListeners();
  }

  void setSelectedDate(String date) {
    selectedDate = date;
    notifyListeners();
  }

  Future<void> reserveSlot(int chairId, String time) async {
    if (token.isEmpty) throw Exception("Token bulunamadı!");
    if (selectedDate == null) return;

    final payload = {
      "storeId": adminId,
      "chairId": chairId,
      "reservationDate": selectedDate,
      "startTime": time,
    };

    await UserChairService.postData("/store/create", payload, token: token);

    // Local update (Anlık değişim için)
    chairs =
        chairs.map((chair) {
          if (chair.chairId == chairId) {
            // İlgili slotu meşgul yap
            if (chair.slots.containsKey(selectedDate)) {
              chair.slots[selectedDate]![time] = false;
            }
          }
          return chair;
        }).toList();

    notifyListeners();
  }
}
