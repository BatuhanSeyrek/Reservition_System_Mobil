import 'package:flutter/material.dart';
import 'package:rezervasyon_mobil/services/user_service/user_service.dart';

class RegisterProvider with ChangeNotifier {
  final UserService _userService = UserService();
  bool _isLoading = false;
  Future<void> registerUser(Map<String, dynamic> userData) async {
    _isLoading = true;
    notifyListeners();
    try {
      await _userService.userRegister(userData);
    } catch (e) {
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
