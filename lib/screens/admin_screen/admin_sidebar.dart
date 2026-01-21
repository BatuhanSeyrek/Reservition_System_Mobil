import 'package:flutter/material.dart';
import 'package:rezervasyon_mobil/screens/admin_screen/admin_dashboard_screen.dart';
import 'package:rezervasyon_mobil/screens/admin_screen/admin_employee.dart';
import 'package:rezervasyon_mobil/screens/admin_screen/admin_update_screen.dart';
import 'package:rezervasyon_mobil/screens/admin_screen/admin_chair.dart';
import 'package:rezervasyon_mobil/screens/about_screen.dart';

class AdminBottomBar extends StatelessWidget {
  final int currentIndex;

  const AdminBottomBar({super.key, required this.currentIndex});

  void _onTap(BuildContext context, int index) {
    Widget page;

    switch (index) {
      case 0:
        page = AdminDashboardScreen();
        break;
      case 1:
        page = ChairDeleteUpdate();
        break;
      case 2:
        page = EmployeeDeleteUpdateScreen();
        break;
      case 3:
        page = OwnerUpdateScreen();
        break;
      case 4:
        page = AboutScreen();
        break;
      default:
        return;
    }

    Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => page));
  }

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      backgroundColor: const Color(0xFF1C1C1E), // koyu arka plan
      currentIndex: currentIndex,
      onTap: (index) => _onTap(context, index),
      selectedItemColor: const Color(0xFFB1123C), // kırmızı ton
      unselectedItemColor: Colors.white,
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.dashboard), label: 'Panel'),
        BottomNavigationBarItem(icon: Icon(Icons.chair), label: 'Koltuklar'),
        BottomNavigationBarItem(icon: Icon(Icons.people), label: 'Personel'),
        BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Yönetici'),
        BottomNavigationBarItem(icon: Icon(Icons.info), label: 'Hakkında'),
      ],
    );
  }
}
