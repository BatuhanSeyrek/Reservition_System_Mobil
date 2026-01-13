import 'package:flutter/material.dart';
import 'package:rezervasyon_mobil/models/user_model/store_models.dart';
import 'package:rezervasyon_mobil/services/user_service/store_service.dart';

class StoreProvider extends ChangeNotifier {
  List<StoreResponse> _stores = [];
  List<int> _favorites = []; // Favori mağaza ID'leri
  bool _isLoading = false;
  String? _error;

  List<StoreResponse> get stores => _stores;
  List<int> get favorites => _favorites;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Favori mi kontrolü
  bool isFavorite(int storeId) => _favorites.contains(storeId);
  List<StoreResponse> get sortedStores {
    List<StoreResponse> sortedList = List.from(_stores);
    sortedList.sort((a, b) {
      bool aFav = isFavorite(a.store.id);
      bool bFav = isFavorite(b.store.id);
      if (aFav && !bFav) return -1; // Favori olan başa geçer
      if (!aFav && bFav) return 1;
      return 0;
    });
    return sortedList;
  }

  Future<void> fetchStores({required String token}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // React'taki Promise.all gibi paralel çalıştırıyoruz
      final results = await Future.wait([
        StoreService.fetchStores(token: token),
        StoreService.fetchFavorites(token: token),
      ]);

      _stores = results[0] as List<StoreResponse>;
      _favorites = results[1] as List<int>;
    } catch (e) {
      _error = e.toString();
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> toggleFavorite({
    required String token,
    required int storeId,
  }) async {
    try {
      // Optimistic Update: Önce arayüzde değiştiriyoruz (React'taki prev.includes mantığı)
      if (_favorites.contains(storeId)) {
        _favorites.remove(storeId);
      } else {
        _favorites.add(storeId);
      }
      notifyListeners();

      // Sonra sunucuya gönderiyoruz
      await StoreService.toggleFavorite(token: token, storeId: storeId);
    } catch (e) {
      // Hata olursa geri al (isteğe bağlı)
      print("Favori güncellenirken hata: $e");
    }
  }
}
