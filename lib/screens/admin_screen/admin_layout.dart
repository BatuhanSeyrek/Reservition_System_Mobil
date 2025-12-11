import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
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

    setState(() {
      // Admin kontrolü
      if (auth.admin != null) {
        isAdmin = true;
        isReference = false;
        displayName = auth.admin!.adminName;
        showSidebar = true;
        storeName = storedName;
      }
      // Reference ID kontrolü
      else if (auth.user == null &&
          storedName != null &&
          storedName.isNotEmpty) {
        isAdmin = false;
        isReference = true;
        displayName = null; // sağda isim gözükmesin
        showSidebar = false;
        storeName = storedName;
      }
      // Normal kullanıcı (guest)
      else if (auth.user != null) {
        isAdmin = false;
        isReference = false;
        displayName = auth.user!.name;
        showSidebar = false;
        storeName = null; // sol taraf MyApp
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
    if (isAdmin) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => AdminProfileScreen()),
      );
    }
  }

  Widget buildLeftWidget() {
    if (isAdmin || isReference) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            storeName ?? '',
            style: TextStyle(color: Colors.white, fontSize: 18),
          ),
          SizedBox(width: 6),
          Icon(Icons.content_cut, color: Colors.redAccent, size: 20),
        ],
      );
    } else {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text('MyApp', style: TextStyle(color: Colors.white, fontSize: 18)),
          SizedBox(width: 6),
          Icon(Icons.content_cut, color: Colors.redAccent, size: 20),
        ],
      );
    }
  }

  Widget? buildRightWidget(BuildContext context) {
    if (isAdmin) {
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
            items: [
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
              style: TextStyle(color: Colors.white, fontSize: 18),
            ),
            SizedBox(width: 6),
            Icon(Icons.person, color: Colors.redAccent, size: 20),
          ],
        ),
      );
    } else if (!isReference && displayName != null) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            displayName!,
            style: TextStyle(color: Colors.white, fontSize: 18),
          ),
          SizedBox(width: 6),
          Icon(Icons.person, color: Colors.redAccent, size: 20),
        ],
      );
    }
    return null; // Reference ID kullanıcı: sağda hiçbir şey
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
                  icon: Icon(Icons.menu, color: Colors.white, size: 28),
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
