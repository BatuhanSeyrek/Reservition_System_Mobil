import 'package:flutter/material.dart';
import 'package:rezervasyon_mobil/models/admin_model/admin_model.dart';
import '../models/auth_response.dart';
import '../services/auth_service.dart';
import '../core/secure_storage.dart';

class AuthProvider with ChangeNotifier {
  final AuthService _authService = AuthService();
  final SecureStorage _storage = SecureStorage();

  AuthResponse? _user;
  AuthResponse? get user => _user;

  AdminModel? _admin;
  AdminModel? get admin => _admin;

  Future<void> loginAdmin(String username, String password) async {
    _user = await _authService.loginAdmin(username, password);
    if (_user != null) {
      await _storage.writeToken(_user!.token);
      await fetchAdminData();
    }
    notifyListeners();
  }

  Future<void> loginUser(String username, String password) async {
    _user = await _authService.loginUser(username, password);
    if (_user != null) {
      await _storage.writeToken(_user!.token);
    }
    notifyListeners();
  }

  Future<void> fetchAdminData() async {
    final token = await _storage.readToken();
    if (token == null) return;
    try {
      final data = await _authService.getMyAdmin(token);
      _admin = AdminModel.fromJson(data);
      notifyListeners();
    } catch (e) {
      debugPrint("Admin verisi çekilemedi: $e");
    }
  }

  Future<bool> tryAutoLogin() async {
    final token = await _storage.readToken();
    if (token == null || token.isEmpty) return false;

    try {
      // HATA BURADAYDI: Modeldeki zorunlu alanları id: 0 ve name: "" diyerek geçiyoruz
      _user = AuthResponse(token: token, id: 0, name: "");

      // Admin verilerini çekmeyi dene
      await fetchAdminData();

      notifyListeners();
      return true;
    } catch (e) {
      await logout();
      return false;
    }
  }

  Future<void> logout() async {
    _user = null;
    _admin = null;
    await _storage.deleteToken();
    notifyListeners();
  }
}
