import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rezervasyon_mobil/screens/public_all_stores_screen.dart';
import 'package:rezervasyon_mobil/screens/reference_id_login.dart';
import '../providers/auth_provider.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkLogin();
  }

  void _checkLogin() async {
    final authProvider = context.read<AuthProvider>();
    bool isLoggedIn = await authProvider.tryAutoLogin();

    await Future.delayed(Duration(seconds: 2));

    // Her durumda Reference Login sayfasını aç
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => PublicAllStoresScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: Center(child: CircularProgressIndicator()));
  }
}
