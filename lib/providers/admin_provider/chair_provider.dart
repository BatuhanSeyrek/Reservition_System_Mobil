import 'package:flutter/material.dart';
import '../models/chair_model.dart';
import '../services/chair_service.dart';
import '../core/secure_storage.dart';

class ChairProvider with ChangeNotifier {
  final SecureStorage _storage = SecureStorage();

  List<Chair> chairs = [];
  bool isLoading = false;

  Future<String?> _getToken() async {
    return await _storage.readToken();
  }

  Future<void> fetchChairs() async {
    isLoading = true;
    notifyListeners();

    try {
      final token = await _getToken();
      final service = ChairService(token: token);
      chairs = await service.fetchChairs();
    } catch (e) {
      print("Fetch Chairs Error: $e");
    }

    isLoading = false;
    notifyListeners();
  }

  Future<void> addChair(Chair chair) async {
    try {
      final token = await _getToken();
      final service = ChairService(token: token);
      await service.addChair(chair);
      await fetchChairs();
    } catch (e) {
      print("Add Chair Error: $e");
    }
  }

  Future<void> updateChair(int id, Chair chair) async {
    try {
      final token = await _getToken();
      final service = ChairService(token: token);
      await service.updateChair(id, chair);
      await fetchChairs();
    } catch (e) {
      print("Update Chair Error: $e");
    }
  }

  Future<void> deleteChair(int id) async {
    try {
      final token = await _getToken();
      final service = ChairService(token: token);
      await service.deleteChair(id);
      chairs.removeWhere((c) => c.id == id);
      notifyListeners();
    } catch (e) {
      print("Delete Chair Error: $e");
    }
  }
}
