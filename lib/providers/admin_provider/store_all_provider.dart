import 'package:flutter/material.dart';
import 'package:rezervasyon_mobil/core/secure_storage.dart';
import 'package:rezervasyon_mobil/services/store_all_service.dart';

class StoreAllProvider with ChangeNotifier {
  final SecureStorage _storage = SecureStorage();
  List<dynamic> storeAllData = [];
  bool isLoading = false;
  Future<String?> _getToken() async {
    return await _storage.readToken();
  }

  Future<void> fetchStoreAllData() async {
    isLoading = true;
    notifyListeners();
    try {
      final token = await _getToken();
      final service = StoreAllService(token: token);
      storeAllData = await service.storeAllData();
    } catch (e) {
      print("Fetch Store All Data Error: $e");
    }
    isLoading = false;
    notifyListeners();
  }
}
