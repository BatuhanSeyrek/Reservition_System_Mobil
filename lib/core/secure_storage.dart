import 'package:flutter_secure_storage/flutter_secure_storage.dart';
// ignore: depend_on_referenced_packages
import 'package:geocoding/geocoding.dart' as geo;

class SecureStorage {
  final _storage = const FlutterSecureStorage();

  // --- Token İşlemleri ---
  Future<void> writeToken(String token) async {
    await _storage.write(key: 'token', value: token);
  }

  Future<String?> readToken() async {
    return await _storage.read(key: 'token');
  }

  Future<void> deleteToken() async {
    await _storage.delete(key: 'token');
  }

  // --- Koordinat Kaydetme/Okuma ---
  Future<void> saveLocation(double lat, double lng) async {
    await _storage.write(key: 'lat', value: lat.toString());
    await _storage.write(key: 'lng', value: lng.toString());
  }

  Future<String?> readLat() async => await _storage.read(key: 'lat');
  Future<String?> readLng() async => await _storage.read(key: 'lng');

  // --- Koordinattan Adres Bulma (Geocoding) ---
  Future<Map<String, String>> getAddressFromCoords() async {
    String? latStr = await readLat();
    String? lngStr = await readLng();

    if (latStr != null && lngStr != null) {
      try {
        double lat = double.parse(latStr);
        double lng = double.parse(lngStr);

        // ✅ KURAL: 'as geo' dediğimiz için fonksiyonun başına 'geo.' ekliyoruz
        List<geo.Placemark> placemarks = await geo.placemarkFromCoordinates(
          lat,
          lng,
        );

        if (placemarks.isNotEmpty) {
          // ✅ KURAL: Değişken tipinin (Placemark) başına da 'geo.' ekliyoruz
          geo.Placemark place = placemarks[0];

          return {
            "city": place.administrativeArea ?? "", // Örn: İstanbul
            "district": place.subAdministrativeArea ?? "", // Örn: Kadıköy
          };
        }
      } catch (e) {
        // İnternet hatası veya servis kesintisi durumunda uygulamanın çökmesini engeller
        print("Geocoding hatası oluştu: $e");
      }
    }
    return {"city": "", "district": ""};
  }
}
