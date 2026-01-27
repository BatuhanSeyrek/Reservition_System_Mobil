import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorage {
  final _storage = const FlutterSecureStorage();

  Future<void> writeToken(String token) async {
    await _storage.write(key: 'token', value: token);
  }

  Future<String?> readToken() async {
    return await _storage.read(key: 'token');
  }

  Future<void> deleteToken() async {
    await _storage.delete(key: 'token');
  }

  // Konumu kasaya yaz
  Future<void> saveLocation(double lat, double lng) async {
    await _storage.write(key: 'lat', value: lat.toString());
    await _storage.write(key: 'lng', value: lng.toString());
  }

  // Konumu kasadan oku
  Future<String?> readLat() async => await _storage.read(key: 'lat');
  Future<String?> readLng() async => await _storage.read(key: 'lng');
}
