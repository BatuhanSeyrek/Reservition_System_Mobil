import 'package:flutter/material.dart';
import 'package:rezervasyon_mobil/models/user_model/store_models.dart';
import 'package:rezervasyon_mobil/services/user_service/store_service.dart';

class StoreProvider extends ChangeNotifier {
  List<StoreResponse> _stores = [];
  bool _isLoading = false;
  String? _error;

  List<StoreResponse> get stores => _stores;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchStores({required String token}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _stores = await StoreService.fetchStores(token: token);
    } catch (e) {
      _error = e.toString();
    }

    _isLoading = false;
    notifyListeners();
  }
}
