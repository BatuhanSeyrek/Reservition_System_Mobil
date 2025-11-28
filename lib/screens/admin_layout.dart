import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import 'admin_sidebar.dart';
import 'footer.dart';
import 'admin_profile_screen.dart'; // Admin profil sayfası

class AdminLayout extends StatelessWidget {
  final Widget body; // Sayfanın içeriği buraya gelecek
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  AdminLayout({required this.body});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final admin = auth.admin!;

    return Scaffold(
      key: _scaffoldKey,
      drawer: Drawer(
        child: SidebarContent(), // Drawer içeriği ayrı widget
      ),
      appBar: AppBar(
        backgroundColor: Colors.grey[900],
        leadingWidth: 40,
        leading: IconButton(
          icon: Icon(Icons.menu, color: Colors.white, size: 28),
          onPressed: () => _scaffoldKey.currentState!.openDrawer(),
        ),
        title: Row(
          children: [
            SizedBox(width: 4),
            Text(
              admin.storeName,
              style: TextStyle(fontSize: 20, color: Colors.white),
            ),
            SizedBox(width: 6),
            Icon(Icons.content_cut, color: Colors.redAccent),
          ],
        ),
        actions: [
          GestureDetector(
            onTap: () {
              showMenu(
                context: context,
                position: RelativeRect.fromLTRB(1000, kToolbarHeight, 16, 0),
                items: [
                  PopupMenuItem(child: Text('Profile'), value: 'profile'),
                  PopupMenuItem(
                    child: Text(
                      'Logout',
                      style: TextStyle(color: Colors.redAccent),
                    ),
                    value: 'logout',
                  ),
                ],
              ).then((value) async {
                if (value == 'profile') {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => AdminProfileScreen()),
                  );
                } else if (value == 'logout') {
                  await auth.logout();
                  Navigator.pushNamedAndRemoveUntil(context, '/', (_) => false);
                }
              });
            },
            child: Row(
              children: [
                Text(admin.adminName, style: TextStyle(color: Colors.white)),
                SizedBox(width: 6),
                Icon(Icons.person, color: Colors.redAccent),
                SizedBox(width: 16),
              ],
            ),
          ),
        ],
      ),
      body: body,
      bottomNavigationBar: Footer(),
    );
  }
}
