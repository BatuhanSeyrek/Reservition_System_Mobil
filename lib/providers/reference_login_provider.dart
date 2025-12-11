import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ReferenceLoginProvider with ChangeNotifier {
  bool isLoading = false;

  final FlutterSecureStorage secureStorage = const FlutterSecureStorage();

  Future<bool> loginWithReferenceId(String referenceId) async {
    isLoading = true;
    notifyListeners();

    try {
      final response = await AuthService().loginWithReferenceId(referenceId);

      isLoading = false;

      if (response == null) {
        notifyListeners();
        return false;
      }

      // Gelen JSON: { referenceId, adminName, id, storeName }
      await secureStorage.write(
        key: "referenceId",
        value: response["referenceId"],
      );
      await secureStorage.write(key: "adminName", value: response["adminName"]);
      await secureStorage.write(
        key: "adminId",
        value: response["id"].toString(),
      );
      await secureStorage.write(key: "storeName", value: response["storeName"]);

      notifyListeners();
      return true;
    } catch (e) {
      print("Reference Login Provider Error: $e");
      isLoading = false;
      notifyListeners();
      return false;
    }
  }
}
