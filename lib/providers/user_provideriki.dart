import 'package:flutter/material.dart';
import 'package:rezervasyon_mobil/models/user_model/user_model.dart';
import 'package:rezervasyon_mobil/services/user_service/user_service.dart';

class UserProvider with ChangeNotifier {
  final UserService _userService = UserService();

  User? _user;
  bool _isLoading = false;

  User? get user => _user;
  bool get isLoading => _isLoading;

  /// Kullanıcıyı yükle
  Future<void> loadUser(String token) async {
    _isLoading = true;
    notifyListeners();

    try {
      _user = await _userService.fetchUser(token);
    } catch (e) {
      _user = null;
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Kullanıcıyı güncelle
  Future<void> updateUser({
    required String token,
    required Map<String, dynamic> data,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _userService.updateUser(token: token, data: data);
      _user = await _userService.fetchUser(token); // 🔄 refresh
    } catch (e) {
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Logout veya token silinince
  void clearUser() {
    _user = null;
    notifyListeners();
  }
}
