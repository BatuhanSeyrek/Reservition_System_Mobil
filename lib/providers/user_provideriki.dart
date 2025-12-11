import 'package:flutter/material.dart';
import 'package:rezervasyon_mobil/services/user_service/user_service.dart';
import 'package:rezervasyon_mobil/models/user_model/user_model.dart';

class UserProvider with ChangeNotifier {
  final UserService _userService = UserService();

  User? _user;
  bool _isLoading = false;

  User? get user => _user;
  bool get isLoading => _isLoading;

  Future<void> loadUser(String token) async {
    _isLoading = true;
    notifyListeners();

    try {
      _user = await _userService.fetchUser(token);
    } catch (e) {
      _user = null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
