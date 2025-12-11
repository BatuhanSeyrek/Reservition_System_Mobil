import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:rezervasyon_mobil/screens/user_profile_screen.dart';
import '../../providers/auth_provider.dart';
import '../footer.dart';
import 'admin_profile_screen.dart';
import 'admin_sidebar.dart';

class AppLayout extends StatefulWidget {
  final Widget body;

  AppLayout({required this.body});

  @override
  _AppLayoutState createState() => _AppLayoutState();
}

class _AppLayoutState extends State<AppLayout> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final FlutterSecureStorage secureStorage = const FlutterSecureStorage();

  String? displayName;
  String? storeName;
  bool isAdmin = false;
  bool showSidebar = false;
  bool isReference = false;

  @override
  void initState() {
    super.initState();
    _loadRole();
  }

  Future<void> _loadRole() async {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    String? storedName = await secureStorage.read(key: "storeName");

    if (!mounted) return;

    // Önceki login bilgilerini temizle Reference ID için
    if (auth.user == null && storedName != null && storedName.isNotEmpty) {
      auth.clearUserAndAdmin();
    }

    setState(() {
      if (auth.admin != null) {
        // Admin login
        isAdmin = true;
        isReference = false;
        displayName = auth.admin!.adminName;
        showSidebar = true;
        storeName = storedName;
      } else if (auth.user == null &&
          storedName != null &&
          storedName.isNotEmpty) {
        // Reference ID login
        isAdmin = false;
        isReference = true;
        displayName = null;
        showSidebar = false;
        storeName = storedName;
      } else if (auth.user != null) {
        // Normal user login
        isAdmin = false;
        isReference = false;
        displayName = auth.user!.name;
        showSidebar = false;
        storeName = null;
      } else {
        // Hiçbir login yok
        isAdmin = false;
        isReference = false;
        displayName = null;
        showSidebar = false;
        storeName = null;
      }
    });
  }

  void handleLogout(BuildContext context) async {
    final auth = context.read<AuthProvider>();
    await auth.logout();
    await secureStorage.deleteAll();
    Navigator.pushNamedAndRemoveUntil(context, '/', (_) => false);
  }

  void handleAbout(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context, listen: false);

    if (isAdmin) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => AdminProfileScreen()),
      );
    } else if (!isAdmin && !isReference && auth.user != null) {
      final token = auth.user!.token;
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => UserProfileScreen(token: token)),
      );
    }
  }

  Widget buildLeftWidget() {
    final auth = context.read<AuthProvider>();
    if (isAdmin || isReference) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            storeName ?? auth.admin!.storeName,
            style: const TextStyle(color: Colors.white, fontSize: 18),
          ),
          const SizedBox(width: 6),
          const Icon(Icons.content_cut, color: Colors.redAccent, size: 20),
        ],
      );
    } else {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: const [
          Text('MyApp', style: TextStyle(color: Colors.white, fontSize: 18)),
          SizedBox(width: 6),
          Icon(Icons.content_cut, color: Colors.redAccent, size: 20),
        ],
      );
    }
  }

  Widget? buildRightWidget(BuildContext context) {
    if (isAdmin || (!isReference && displayName != null)) {
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
              PopupMenuItem(child: Text('About'), value: 'about'),
              PopupMenuItem(
                child: Text(
                  'Logout',
                  style: TextStyle(color: Colors.redAccent),
                ),
                value: 'logout',
              ),
            ],
          ).then((value) {
            if (value == 'about')
              handleAbout(context);
            else if (value == 'logout')
              handleLogout(context);
          });
        },
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              displayName ?? '',
              style: const TextStyle(color: Colors.white, fontSize: 18),
            ),
            const SizedBox(width: 6),
            const Icon(Icons.person, color: Colors.redAccent, size: 20),
          ],
        ),
      );
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      drawer:
          (showSidebar && isAdmin)
              ? Drawer(child: Material(elevation: 16, child: AdminSidebar()))
              : null,
      appBar: AppBar(
        backgroundColor: Colors.grey[900],
        leadingWidth: 40,
        leading:
            (showSidebar && isAdmin)
                ? IconButton(
                  icon: const Icon(Icons.menu, color: Colors.white, size: 28),
                  onPressed: () => _scaffoldKey.currentState!.openDrawer(),
                )
                : null,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            buildLeftWidget(),
            if (buildRightWidget(context) != null) buildRightWidget(context)!,
          ],
        ),
      ),
      body: widget.body,
      bottomNavigationBar: Footer(),
    );
  }
}
