import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';

import 'user_login.dart';

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

    await Future.delayed(Duration(seconds: 2)); // Splash bekletme

    if (isLoggedIn) {
      // İstersen burada admin/user ayrımı yapılabilir
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => UserLogin()),
      );
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => UserLogin()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: Center(child: CircularProgressIndicator()));
  }
}
