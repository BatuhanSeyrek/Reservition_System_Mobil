import 'package:flutter/material.dart';
import 'package:rezervasyon_mobil/models/admin_model.dart';
import '../models/auth_response.dart';
import '../services/auth_service.dart';
import '../core/secure_storage.dart';

class AuthProvider with ChangeNotifier {
  final AuthService _authService = AuthService();
  final SecureStorage _storage = SecureStorage();

  AuthResponse? _user;
  AuthResponse? get user => _user;

  AdminModel? _admin;
  AdminModel? get admin => _admin; // Navbar ve diğer sayfalarda kullanılacak

  // Admin login artık username ve password ile
  Future<void> loginAdmin(String username, String password) async {
    _user = await _authService.loginAdmin(username, password);
    await _storage.writeToken(_user!.token);

    // Admin bilgilerini çek
    await fetchAdminData();

    notifyListeners();
  }

  // User login
  Future<void> loginUser(String username, String password) async {
    _user = await _authService.loginUser(username, password);
    await _storage.writeToken(_user!.token);
    notifyListeners();
  }

  // Admin bilgilerini çekme
  Future<void> fetchAdminData() async {
    if (_user == null) return;

    final data = await _authService.getMyAdmin(_user!.token);
    _admin = AdminModel.fromJson(data);
    notifyListeners();
  }

  // Uygulama açıldığında token kontrolü
  Future<bool> tryAutoLogin() async {
    final token = await _storage.readToken();
    if (token == null) return false;
    return true;
  }

  // Logout işlemi
  Future<void> logout() async {
    _user = null;
    await _storage.deleteToken();
    notifyListeners();
  }
}
