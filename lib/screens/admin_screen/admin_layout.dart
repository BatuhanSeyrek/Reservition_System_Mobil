import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../providers/auth_provider.dart';
import '../admin_screen/admin_profile_screen.dart';
import '../user_profile_screen.dart' as user_profile;

class AppLayout extends StatefulWidget {
  final Widget body;
  final Widget? bottomBar;
  final bool guestMode; // 🔒 GUEST KİLİDİ

  const AppLayout({
    Key? key,
    required this.body,
    this.bottomBar,
    this.guestMode = false,
  }) : super(key: key);

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
    _updateRole();
  }

  Future<void> _updateRole() async {
    final auth = context.read<AuthProvider>();
    final storedName = await secureStorage.read(key: "storeName");

    if (!mounted) return;

    setState(() {
      isAdmin = auth.admin != null;
      isUser = auth.user != null;

      if (isAdmin) {
        displayName = auth.admin!.adminName;
        storeName = auth.admin!.storeName ?? storedName;
        isUser = false;
        isReference = false;
      } else if (isUser) {
        displayName = auth.user!.name;
        isAdmin = false;
        isReference = false;
      } else if (storedName != null && storedName.isNotEmpty) {
        isReference = true;
        storeName = storedName;
        isAdmin = false;
        isUser = false;
      } else {
        displayName = null;
        storeName = null;
        isAdmin = false;
        isUser = false;
        isReference = false;
      }
    });
  }

  Future<void> _logout() async {
    final auth = context.read<AuthProvider>();
    await auth.logout();
    await secureStorage.deleteAll();

    if (mounted) {
      Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
    }
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
        Text('KesTıraşı', style: TextStyle(color: Colors.white, fontSize: 18)),
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
    context.watch<AuthProvider>();

    return WillPopScope(
      onWillPop: () async => false,
      child: Stack(
        children: [
          /// 🧱 NORMAL UYGULAMA
          Scaffold(
            appBar: AppBar(
              backgroundColor: Colors.grey[900],
              automaticallyImplyLeading: false,
              title: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [_buildLeftWidget(), _buildRightWidget()],
              ),
            ),
            body: widget.body,
            bottomNavigationBar: widget.bottomBar,
          ),

          /// 🔒 GUEST MODE → HER TIK LOGIN
          if (widget.guestMode)
            Positioned.fill(
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () {
                  Navigator.of(
                    context,
                  ).pushNamedAndRemoveUntil('/login', (route) => false);
                },
                child: Container(color: Colors.black.withOpacity(0.01)),
              ),
            ),
        ],
      ),
    );
  }
}
