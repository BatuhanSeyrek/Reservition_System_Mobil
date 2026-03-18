import 'package:flutter/material.dart';
import 'package:rezervasyon_mobil/core/app_colors.dart'; // Renk paleti
import 'package:rezervasyon_mobil/screens/about_screen.dart';
import 'package:rezervasyon_mobil/screens/all_stores_screen.dart';
import 'package:rezervasyon_mobil/screens/reservation_update_delete_screen.dart';
import 'package:rezervasyon_mobil/screens/user_update_screen.dart';

class UserBottomBar extends StatelessWidget {
  final int? currentIndex;

  const UserBottomBar({Key? key, this.currentIndex}) : super(key: key);

  void _onTap(BuildContext context, int index) {
    if (index == currentIndex)
      return; // Zaten o sayfadaysak tekrar yükleme yapma

    Widget page;
    switch (index) {
      case 0:
        page = AllStoresScreen();
        break;
      case 1:
        page = const ReservationUpdateDeleteScreen();
        break;
      case 2:
        page = const UserUpdateScreen();
        break;
      case 3:
        page = const AboutScreen();
        break;
      default:
        return;
    }

    // Daha yumuşak bir geçiş için FadeTransition kullanılabilir veya direkt pushReplacement
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
    final int indexToShow = currentIndex ?? -1;

    return Container(
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(color: Colors.white.withOpacity(0.05), width: 1),
        ),
      ),
      child: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: AppColors.darkGrey, // Arka plan: Füme
        currentIndex: indexToShow >= 0 ? indexToShow : 0,
        onTap: (index) => _onTap(context, index),
        selectedItemColor: AppColors.primaryGreen, // Seçili: Su Yeşili
        unselectedItemColor: Colors.white54, // Seçili olmayan: Mat Beyaz
        selectedLabelStyle: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 12,
          letterSpacing: 0.5,
        ),
        unselectedLabelStyle: const TextStyle(fontSize: 11),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.storefront_rounded),
            label: 'Mağazalar',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_month_rounded),
            label: 'Randevular',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_pin_rounded),
            label: 'Profil',
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
