import 'package:flutter/material.dart';
import 'package:rezervasyon_mobil/models/user_model/store_models.dart';
import 'package:rezervasyon_mobil/services/user_service/store_service.dart';

class StoreProvider extends ChangeNotifier {
  List<StoreResponse> _stores = [];
  List<int> _favorites = [];
  bool _isLoading = false;
  String _selectedCity = "";
  String _selectedDistrict = "";

  List<StoreResponse> get stores => _stores;
  bool get isLoading => _isLoading;
  String get selectedCity => _selectedCity;
  String get selectedDistrict => _selectedDistrict;

  bool isFavorite(int storeId) => _favorites.contains(storeId);

  // ✅ Filtreleme ve Sıralama (SQL Verisiyle Tam Uyumlu)
  List<StoreResponse> get sortedStores {
    List<StoreResponse> filteredList =
        _stores.where((item) {
          if (_selectedCity.isEmpty) return true;

          // SQL'den gelen verileri al ve temizle
          final String storeCity =
              (item.admin.address?.city ?? "").trim().toLowerCase();
          final String storeDist =
              (item.admin.address?.district ?? "").trim().toLowerCase();

          // Senin seçtiğin filtreleri küçük harfe çevir
          final String filterCity = _selectedCity.trim().toLowerCase();
          final String filterDist = _selectedDistrict.trim().toLowerCase();

          // İlçe seçilmemişse sadece şehre bak, seçilmişse ikisine de bak
          if (filterDist.isEmpty) {
            return storeCity == filterCity;
          } else {
            return storeCity == filterCity && storeDist == filterDist;
          }
        }).toList();

    // Favorileri başa taşı
    filteredList.sort((a, b) {
      bool aFav = isFavorite(a.store.id);
      bool bFav = isFavorite(b.store.id);
      if (aFav && !bFav) return -1;
      if (!aFav && bFav) return 1;
      return 0;
    });

    return filteredList;
  }

  void updateLocationFilter(String city, String district) {
    _selectedCity = city;
    _selectedDistrict = district;
    notifyListeners();
  }

  Future<void> fetchStores({required String token}) async {
    _isLoading = true;
    notifyListeners();
    try {
      final results = await Future.wait([
        StoreService.fetchStores(token: token),
        StoreService.fetchFavorites(token: token),
      ]);
      _stores = results[0] as List<StoreResponse>;
      _favorites = results[1] as List<int>;
    } catch (e) {
      debugPrint("Hata: $e");
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<void> fetchStoresPublic() async {
    _isLoading = true;
    notifyListeners();
    try {
      _stores = await StoreService.fetchStoresPublic();
      _favorites = [];
    } catch (e) {
      debugPrint("Hata: $e");
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<void> toggleFavorite({
    required String token,
    required int storeId,
  }) async {
    try {
      if (_favorites.contains(storeId))
        _favorites.remove(storeId);
      else
        _favorites.add(storeId);
      notifyListeners();
      await StoreService.toggleFavorite(token: token, storeId: storeId);
    } catch (e) {
      debugPrint("Favori hatası: $e");
    }
  }
}
