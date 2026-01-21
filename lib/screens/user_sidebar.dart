import 'package:flutter/material.dart';
import 'package:rezervasyon_mobil/screens/about_screen.dart';
import 'package:rezervasyon_mobil/screens/all_stores_screen.dart';
import 'package:rezervasyon_mobil/screens/reservation_update_delete_screen.dart';
import 'package:rezervasyon_mobil/screens/user_update_screen.dart';

class UserBottomBar extends StatelessWidget {
  final int? currentIndex; // nullable parametre ekledik

  const UserBottomBar({Key? key, this.currentIndex}) : super(key: key);

  void _onTap(BuildContext context, int index) {
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

    Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => page));
  }

  @override
  Widget build(BuildContext context) {
    // currentIndex null ise -1 yapıyoruz, seçili renk gözükmez
    final int indexToShow = currentIndex ?? -1;

    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      backgroundColor: const Color(0xFF1C1C1E),
      currentIndex: indexToShow >= 0 ? indexToShow : 0,
      onTap: (index) => _onTap(context, index),
      selectedItemColor: const Color(0xFFB1123C),
      unselectedItemColor: Colors.white,
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.store), label: 'Mağazalar'),
        BottomNavigationBarItem(
          icon: Icon(Icons.calendar_today),
          label: 'Randevular',
        ),
        BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Kullanıcı'),
        BottomNavigationBarItem(icon: Icon(Icons.info), label: 'Hakkında'),
      ],
    );
  }
}
