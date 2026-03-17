import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart'; // Mesafe hesaplama için eklendi
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

  // --- Kullanıcı Konum Bilgileri ---
  double? _userLatitude;
  double? _userLongitude;

  // ================= GETTERS =================
  List<StoreResponse> get stores => _stores;
  bool get isLoading => _isLoading;
  bool get hasToken => _token != null && _token!.isNotEmpty;
  String? get token => _token;
  String get selectedCity => _selectedCity;
  String get selectedDistrict => _selectedDistrict;

  // Koordinat Getterları (UI'da mesafe göstermek için)
  double? get userLatitude => _userLatitude;
  double? get userLongitude => _userLongitude;

  bool isFavorite(int storeId) => _favorites.contains(storeId);

  // ================= TOKEN KURTARMA =================
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

  // ================= FETCH METODLARI =================
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

  // ================= FAVORİ İŞLEMLERİ =================
  Future<void> toggleFavorite(int storeId) async {
    await _ensureToken();
    if (!hasToken) return;

    final isFav = _favorites.contains(storeId);

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
      if (isFav)
        _favorites.add(storeId);
      else
        _favorites.remove(storeId);
      notifyListeners();
    }
  }

  // ================= FİLTRELEME VE SIRALAMA (REVİZE EDİLDİ) =================
  List<StoreResponse> get sortedStores {
    final city = _selectedCity.toLowerCase();
    final district = _selectedDistrict.toLowerCase();

    // 1. Önce İl/İlçe Filtrelemesi Yap
    List<StoreResponse> filtered =
        _stores.where((s) {
          if (s.address == null) return false;
          final c = s.address!.city.toLowerCase();
          final d = s.address!.district.toLowerCase();

          if (city.isEmpty) return true;
          if (district.isEmpty) return c == city;
          return c == city && d == district;
        }).toList();

    // 2. Akıllı Sıralama (Önce Favoriler, Sonra En Yakın Mesafe)
    filtered.sort((a, b) {
      // Favori kontrolü
      final af = isFavorite(a.store.id);
      final bf = isFavorite(b.store.id);

      if (af && !bf) return -1;
      if (!af && bf) return 1;

      // Eğer ikisi de favori veya ikisi de değilse mesafeye bak
      if (_userLatitude != null && _userLongitude != null) {
        double distA = Geolocator.distanceBetween(
          _userLatitude!,
          _userLongitude!,
          a.address!.latitude,
          a.address!.longitude,
        );
        double distB = Geolocator.distanceBetween(
          _userLatitude!,
          _userLongitude!,
          b.address!.latitude,
          b.address!.longitude,
        );
        return distA.compareTo(distB);
      }

      return 0;
    });

    return filtered;
  }

  // ================= LOKASYON FİLTRELERİ =================
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

  // ================= KOORDİNAT GÜNCELLEME (REVİZE EDİLDİ) =================
  Future<void> updateLocationFromCoordinates(double lat, double lng) async {
    // Koordinatları sakla (Mesafe hesaplama için kritik)
    _userLatitude = lat;
    _userLongitude = lng;

    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(lat, lng);

      if (placemarks.isNotEmpty) {
        Placemark place = placemarks.first;

        String rawCity =
            (place.administrativeArea ?? "")
                .replaceAll(" Province", "")
                .replaceAll(" İli", "")
                .replaceAll("il", "")
                .trim();
        String rawDistrict = (place.subAdministrativeArea ?? "").trim();

        // Şehir Eşleştirme
        final cityMatch = availableCities.where(
          (c) =>
              c.toLowerCase().contains(rawCity.toLowerCase()) ||
              rawCity.toLowerCase().contains(c.toLowerCase()),
        );

        if (cityMatch.isNotEmpty) {
          _selectedCity = cityMatch.first;

          // İlçe Eşleştirme
          final districtList = availableDistricts;
          final districtMatch = districtList.where(
            (d) =>
                d.toLowerCase().contains(rawDistrict.toLowerCase()) ||
                rawDistrict.toLowerCase().contains(d.toLowerCase()),
          );

          if (districtMatch.isNotEmpty) {
            _selectedDistrict = districtMatch.first;
          } else {
            _selectedDistrict = '';
          }
        }
      }
    } catch (e) {
      debugPrint("Geocoding hatası: $e");
    }

    // Hem konum saklandı hem filtre güncellendi, arayüzü yenile
    notifyListeners();
  }
}
