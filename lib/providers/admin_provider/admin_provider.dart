import 'package:flutter/material.dart';
import 'package:rezervasyon_mobil/core/secure_storage.dart';
import 'package:rezervasyon_mobil/models/admin_model/admin_model.dart';
import 'package:rezervasyon_mobil/services/admin_service/admin_service.dart';

class AdminProvider with ChangeNotifier {
  final SecureStorage _storage = SecureStorage();

  List<AdminModel> admins = [];
  bool isLoading = false;

  /// Token alma
  Future<String?> _getToken() async {
    try {
      return await _storage.readToken();
    } catch (e) {
      print("Error getting token: $e");
      return null;
    }
  }

  /// Mevcut admin bilgilerini getir
  Future<void> fetchMyAdmin() async {
    isLoading = true;
    notifyListeners();

    try {
      final token = await _getToken();
      if (token == null) throw Exception("Token bulunamadı.");
      final service = AdminService(token: token);
      admins = await service.fetchMyAdmin();
    } catch (e) {
      print("Fetch My Admin Error: $e");
      admins = [];
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  /// Yeni admin ekle
  Future<void> addAdmin(AdminModel admin) async {
    isLoading = true;
    notifyListeners();

    try {
      final token = await _getToken();
      if (token == null) throw Exception("Token bulunamadı.");
      final service = AdminService(token: token);
      await service.addAdmin(admin);
      await fetchMyAdmin(); // Listeyi güncelle
    } catch (e) {
      print("Add Admin Error: $e");
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  /// Admin bilgilerini güncelle
  Future<void> updateAdmin(AdminModel admin) async {
    isLoading = true;
    notifyListeners();

    try {
      final token = await _getToken();
      if (token == null) throw Exception("Token bulunamadı.");
      final service = AdminService(token: token);
      await service.updateAdmin(admin);
      await fetchMyAdmin();
    } catch (e) {
      print("Update Admin Error: $e");
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  /// Admin sil
  Future<void> deleteAdmin(int id) async {
    isLoading = true;
    notifyListeners();

    try {
      final token = await _getToken();
      if (token == null) throw Exception("Token bulunamadı.");
      final service = AdminService(token: token);
      await service.deleteAdmin(id);
      admins.removeWhere((a) => a.id == id);
    } catch (e) {
      print("Delete Admin Error: $e");
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
