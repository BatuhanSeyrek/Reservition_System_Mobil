import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../providers/auth_provider.dart';
import '../admin_screen/admin_profile_screen.dart';
import '../user_profile_screen.dart' as user_profile;

class AppLayout extends StatefulWidget {
  final Widget body;
  final Widget? bottomBar;

  const AppLayout({Key? key, required this.body, this.bottomBar})
    : super(key: key);

  @override
  State<AppLayout> createState() => _AppLayoutState();
}

class _AppLayoutState extends State<AppLayout> {
  final FlutterSecureStorage secureStorage = const FlutterSecureStorage();

  String? displayName;
  String? storeName;
  bool isAdmin = false;
  bool isUser = false;
  bool isReference = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _updateRole(); // provider değiştiğinde her zaman çalışacak
  }

  Future<void> _updateRole() async {
    final auth = context.watch<AuthProvider>();
    final storedName = await secureStorage.read(key: "storeName");

    // 🔹 Önce tüm state’i sıfırla
    displayName = null;
    storeName = null;
    isAdmin = false;
    isUser = false;
    isReference = false;

    if (auth.admin != null) {
      isAdmin = true;
      displayName = auth.admin!.adminName;
      storeName = auth.admin!.storeName ?? storedName;
    } else if (auth.user != null) {
      isUser = true;
      displayName = auth.user!.name;
    } else if (storedName != null && storedName.isNotEmpty) {
      isReference = true;
      storeName = storedName;
    }

    if (mounted) setState(() {});
  }

  Future<void> _logout() async {
    final auth = context.read<AuthProvider>();
    await auth.logout();
    await secureStorage.deleteAll();
    Navigator.pushNamedAndRemoveUntil(context, '/', (_) => false);
  }

  Future<void> _goProfile() async {
    if (isAdmin) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const AdminProfileScreen()),
      );
    } else if (isUser) {
      final token = await secureStorage.read(key: "token") ?? "";
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => user_profile.UserProfileScreen(token: token),
        ),
      );
    }
  }

  Widget _buildLeftWidget() {
    if (isAdmin || isReference) {
      return Row(
        children: [
          Text(
            storeName ?? '',
            style: const TextStyle(color: Colors.white, fontSize: 18),
          ),
          const SizedBox(width: 6),
          const Icon(Icons.content_cut, color: Colors.redAccent),
        ],
      );
    }

    return Row(
      children: const [
        Text('MyApp', style: TextStyle(color: Colors.white, fontSize: 18)),
        SizedBox(width: 6),
        Icon(Icons.content_cut, color: Colors.redAccent),
      ],
    );
  }

  Widget _buildRightWidget() {
    if (isReference) {
      return TextButton(
        onPressed: _logout,
        style: TextButton.styleFrom(
          foregroundColor: Colors.white,
          backgroundColor: Colors.redAccent,
        ),
        child: const Text(
          'Çıkış',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      );
    }

    if (isAdmin || isUser) {
      return GestureDetector(
        onTap: () {
          showMenu(
            context: context,
            position: RelativeRect.fromLTRB(
              MediaQuery.of(context).size.width - 150,
              kToolbarHeight,
              16,
              0,
            ),
            items: const [
              PopupMenuItem(value: 'profile', child: Text('Profilim')),
              PopupMenuItem(
                value: 'logout',
                child: Text(
                  'Çıkış Yap',
                  style: TextStyle(color: Colors.redAccent),
                ),
              ),
            ],
          ).then((value) {
            if (value == 'profile') _goProfile();
            if (value == 'logout') _logout();
          });
        },
        child: Row(
          children: [
            Text(
              displayName ?? '',
              style: const TextStyle(color: Colors.white, fontSize: 16),
            ),
            const SizedBox(width: 6),
            const Icon(Icons.person, color: Colors.redAccent),
          ],
        ),
      );
    }

    return const SizedBox();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.grey[900],
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [_buildLeftWidget(), _buildRightWidget()],
          ),
        ),
        body: widget.body,
        bottomNavigationBar: widget.bottomBar,
      ),
    );
  }
}
