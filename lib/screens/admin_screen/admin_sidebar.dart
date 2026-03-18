import 'package:flutter/material.dart';
import 'package:rezervasyon_mobil/core/app_colors.dart'; // Renk paletini dahil ettik
import 'package:rezervasyon_mobil/screens/admin_screen/admin_dashboard_screen.dart';
import 'package:rezervasyon_mobil/screens/admin_screen/admin_employee.dart';
import 'package:rezervasyon_mobil/screens/admin_screen/admin_update_screen.dart';
import 'package:rezervasyon_mobil/screens/admin_screen/admin_chair.dart';
import 'package:rezervasyon_mobil/screens/about_screen.dart';

class AdminBottomBar extends StatelessWidget {
  final int currentIndex;

  const AdminBottomBar({super.key, required this.currentIndex});

  void _onTap(BuildContext context, int index) {
    if (index == currentIndex)
      return; // Zaten o sayfadaysak tekrar yükleme yapma

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
        page = const AboutScreen();
        break;
      default:
        return;
    }

    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => page,
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: Colors.white.withOpacity(
              0.05,
            ), // Çok ince bir üst sınır çizgisi
            width: 1,
          ),
        ),
      ),
      child: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: AppColors.darkGrey, // Arka plan: Füme
        currentIndex: currentIndex,
        onTap: (index) => _onTap(context, index),
        selectedItemColor: AppColors.primaryGreen, // Seçili öğe: Su Yeşili
        unselectedItemColor: Colors.white54, // Seçili olmayan: Mat Beyaz
        selectedLabelStyle: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 12,
          letterSpacing: 0.5,
        ),
        unselectedLabelStyle: const TextStyle(fontSize: 11),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard_rounded),
            label: 'Panel',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.chair_alt_rounded),
            label: 'Koltuklar',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.badge_rounded),
            label: 'Personel',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.admin_panel_settings_rounded),
            label: 'Yönetici',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.info_outline_rounded),
            label: 'Hakkında',
          ),
        ],
      ),
    );
  }
}
