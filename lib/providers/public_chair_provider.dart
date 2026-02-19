import 'package:flutter/material.dart';
import 'package:rezervasyon_mobil/models/public_chair_models.dart';
import '../services/public_chair_service.dart';

class PublicChairProvider extends ChangeNotifier {
  final int adminId;
  final PublicChairService _service = PublicChairService();

  PublicChairProvider({required this.adminId});

  List<PublicChairModel> chairs = [];
  bool isLoading = false;
  String? error;

  String? selectedChairName;
  String? selectedDate;

  List<String> availableDates = [];

  Future<void> fetchChairs() async {
    try {
      isLoading = true;
      error = null;
      notifyListeners();

      chairs = await _service.fetchChairs(adminId);

      if (chairs.isNotEmpty) {
        selectedChairName = chairs.first.chairName;

        availableDates = chairs.first.slots.keys.toList();

        if (availableDates.isNotEmpty) {
          selectedDate = availableDates.first;
        }
      }
    } catch (e) {
      error = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  void setSelectedChair(String? chairName) {
    selectedChairName = chairName;

    final selectedChair = chairs.firstWhere((c) => c.chairName == chairName);

    availableDates = selectedChair.slots.keys.toList();

    if (availableDates.isNotEmpty) {
      selectedDate = availableDates.first;
    } else {
      selectedDate = null;
    }

    notifyListeners();
  }

  void setSelectedDate(String? date) {
    selectedDate = date;
    notifyListeners();
  }
}
