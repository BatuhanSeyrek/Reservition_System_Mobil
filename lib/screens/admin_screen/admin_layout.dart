import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../providers/auth_provider.dart';

class AppLayout extends StatefulWidget {
  final Widget body;
  final Widget? bottomBar;
  final bool guestMode;

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
      } else if (isUser) {
        displayName = auth.user!.name;
      } else if (storedName != null && storedName.isNotEmpty) {
        isReference = true;
        storeName = storedName;
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

  Widget _buildLeftWidget() {
    return Row(
      children: [
        Text(
          (isAdmin || isReference) ? (storeName ?? '') : 'KesTıraşı',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(width: 8),
        const Icon(Icons.content_cut, color: Colors.redAccent, size: 20),
      ],
    );
  }

  Widget _buildRightWidget() {
    // 1. Referans Girişi İçin Şık Çıkış Butonu
    if (isReference) {
      return OutlinedButton.icon(
        onPressed: _logout,
        icon: const Icon(Icons.logout, size: 16),
        label: const Text('Çıkış'),
        style: OutlinedButton.styleFrom(
          foregroundColor: Colors.redAccent,
          side: const BorderSide(color: Colors.redAccent, width: 1.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 12),
        ),
      );
    }

    // 2. Admin veya Kullanıcı İçin Modern Popup Menü
    if (isAdmin || isUser) {
      return InkWell(
        onTap: () {
          showMenu(
            context: context,
            elevation: 8,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            color: Colors.grey[850],
            position: RelativeRect.fromLTRB(
              MediaQuery.of(context).size.width - 20,
              kToolbarHeight + 10,
              20,
              0,
            ),
            items: [
              PopupMenuItem(
                value: 'logout',
                child: Row(
                  children: const [
                    Icon(Icons.logout, color: Colors.redAccent, size: 20),
                    SizedBox(width: 12),
                    Text(
                      'Çıkış Yap',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ).then((value) {
            if (value == 'logout') _logout();
          });
        },
        borderRadius: BorderRadius.circular(10),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
          child: Row(
            children: [
              Text(
                displayName ?? '',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(width: 8),
              const CircleAvatar(
                radius: 14,
                backgroundColor: Colors.redAccent,
                child: Icon(Icons.person, size: 18, color: Colors.white),
              ),
            ],
          ),
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
          Scaffold(
            appBar: AppBar(
              backgroundColor: Colors.grey[900],
              elevation: 0,
              automaticallyImplyLeading: false,
              title: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [_buildLeftWidget(), _buildRightWidget()],
              ),
            ),
            body: widget.body,
            bottomNavigationBar: widget.bottomBar,
          ),
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
