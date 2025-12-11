import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rezervasyon_mobil/providers/admin_provider/admin_provider.dart';
import 'package:rezervasyon_mobil/providers/admin_provider/employee_provider.dart';
import 'package:rezervasyon_mobil/providers/admin_provider/reservation_provider.dart';
import 'package:rezervasyon_mobil/providers/admin_provider/store_all_provider.dart';
import 'package:rezervasyon_mobil/providers/reference_chair_provider.dart';
import 'package:rezervasyon_mobil/providers/reference_login_provider.dart';
import 'package:rezervasyon_mobil/providers/user_provider.dart';
import 'package:rezervasyon_mobil/screens/reference_id_login.dart';
import 'providers/auth_provider.dart';
import 'screens/splash_screen.dart';
import 'providers/admin_provider/chair_provider.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => ChairProvider()),
        ChangeNotifierProvider(create: (_) => EmployeeProvider()),
        ChangeNotifierProvider(create: (_) => AdminProvider()),
        ChangeNotifierProvider(create: (_) => StoreAllProvider()),
        ChangeNotifierProvider(create: (_) => ReservationProvider()),
        ChangeNotifierProvider(create: (_) => RegisterProvider()),
        ChangeNotifierProvider(create: (_) => ReferenceLoginProvider()),
        ChangeNotifierProvider(create: (_) => RefenceChairProvider()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Flutter Login Flow',
        theme: ThemeData(primarySwatch: Colors.blue),
        home: SplashScreen(),
      ),
    );
  }
}
