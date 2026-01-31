import 'package:flutter/material.dart';
import 'package:rezervasyon_mobil/core/secure_storage.dart';
import 'package:rezervasyon_mobil/models/user_model/store_models.dart';
import 'package:rezervasyon_mobil/services/user_service/store_service.dart';

class StoreProvider extends ChangeNotifier {
  List<StoreResponse> _stores = [];
  List<int> _favorites = [];
  bool _isLoading = false;

  String _selectedCity = '';
  String _selectedDistrict = '';
  String? _token;

  // ================= GETTERS =================
  List<StoreResponse> get stores => _stores;
  bool get isLoading => _isLoading;
  bool get hasToken => _token != null && _token!.isNotEmpty;
  String? get token => _token;
  String get selectedCity => _selectedCity;
  String get selectedDistrict => _selectedDistrict;

  bool isFavorite(int storeId) => _favorites.contains(storeId);

  // ================= TOKEN KURTARMA (YENİ) =================
  // Hafızada token yoksa storage'a bakıp token'ı geri getirir
  Future<void> _ensureToken() async {
    if (_token == null || _token!.isEmpty) {
      final storage = SecureStorage();
      _token = await storage.readToken();
    }
  }

  // ================= INIT =================
  Future<void> initializeProvider() async {
    final storage = SecureStorage();
    final savedToken = await storage.readToken();

    if (savedToken != null && savedToken.isNotEmpty) {
      await fetchStores(token: savedToken);
    } else {
      await fetchStoresPublic();
    }
  }

  // ================= AUTH STORES =================
  Future<void> fetchStores({required String token}) async {
    _isLoading = true;
    _token = token;
    notifyListeners();

    try {
      final results = await Future.wait([
        StoreService.fetchStores(token: token),
        StoreService.fetchFavorites(token: token),
      ]);

      _stores = results[0] as List<StoreResponse>;
      final dynamic favData = results[1];
      _favorites =
          (favData as List).map((e) => int.parse(e.toString())).toList();
    } catch (e) {
      debugPrint("Store fetch error: $e");
    }

    _isLoading = false;
    notifyListeners();
  }

  // ================= PUBLIC STORES =================
  Future<void> fetchStoresPublic() async {
    _isLoading = true;
    _token = null;
    notifyListeners();

    try {
      _stores = await StoreService.fetchStoresPublic();
      _favorites.clear();
    } catch (e) {
      debugPrint("Public store error: $e");
    }

    _isLoading = false;
    notifyListeners();
  }

  // ================= FAVORITE (DÜZELTİLDİ) =================
  Future<void> toggleFavorite(int storeId) async {
    // 1. Token'ı garantile (Eğer login olduysan ama hafıza boşsa)
    await _ensureToken();

    if (!hasToken) {
      debugPrint(
        "HATA: Giriş yapılmadığı için favorileme engellendi. Token hâlâ null.",
      );
      return;
    }

    final isFav = _favorites.contains(storeId);

    // Optimistic UI
    if (isFav) {
      _favorites.remove(storeId);
    } else {
      _favorites.add(storeId);
    }
    notifyListeners();

    try {
      await StoreService.toggleFavorite(token: _token!, storeId: storeId);
    } catch (e) {
      debugPrint("Favori API hatası: $e");
      // Hata olursa işlemi geri al
      if (isFav) {
        _favorites.add(storeId);
      } else {
        _favorites.remove(storeId);
      }
      notifyListeners();
    }
  }

  // ================= FILTER & SORT =================
  List<StoreResponse> get sortedStores {
    final city = _selectedCity.toLowerCase();
    final district = _selectedDistrict.toLowerCase();

    final filtered =
        _stores.where((s) {
          if (s.address == null) return false;
          final c = s.address!.city.toLowerCase();
          final d = s.address!.district.toLowerCase();

          if (city.isEmpty) return true;
          if (district.isEmpty) return c == city;
          return c == city && d == district;
        }).toList();

    filtered.sort((a, b) {
      final af = isFavorite(a.store.id);
      final bf = isFavorite(b.store.id);
      if (af && !bf) return -1;
      if (!af && bf) return 1;
      return 0;
    });

    return filtered;
  }

  List<String> get availableCities {
    return _stores
        .map((e) => e.address?.city ?? "")
        .where((e) => e.isNotEmpty)
        .toSet()
        .toList()
      ..sort();
  }

  List<String> get availableDistricts {
    if (_selectedCity.isEmpty) return [];
    return _stores
        .where(
          (s) => s.address?.city.toLowerCase() == _selectedCity.toLowerCase(),
        )
        .map((s) => s.address?.district ?? "")
        .where((e) => e.isNotEmpty)
        .toSet()
        .toList()
      ..sort();
  }

  void updateLocationFilter(String city, String district) {
    _selectedCity = city;
    _selectedDistrict = district;
    notifyListeners();
  }

  void clearFilters() {
    _selectedCity = '';
    _selectedDistrict = '';
    notifyListeners();
  }
}
