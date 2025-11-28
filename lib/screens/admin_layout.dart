import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import 'admin_sidebar.dart';
import 'footer.dart';
import 'about_screen.dart';

class AdminLayout extends StatelessWidget {
  final Widget body; // Sayfanın içeriği buraya gelecek
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  AdminLayout({required this.body});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final admin = auth.admin!;
    final storeName = admin.storeName;
    final adminName = admin.adminName;

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
              storeName,
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
                  PopupMenuItem(child: Text('About'), value: 'about'),
                  PopupMenuItem(
                    child: Text(
                      'Exit',
                      style: TextStyle(color: Colors.redAccent),
                    ),
                    value: 'exit',
                  ),
                ],
              ).then((value) async {
                if (value == 'about') {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => AboutScreen(isAdmin: true),
                    ),
                  );
                } else if (value == 'exit') {
                  await auth.logout();
                  Navigator.pushNamedAndRemoveUntil(context, '/', (_) => false);
                }
              });
            },
            child: Row(
              children: [
                Text(adminName, style: TextStyle(color: Colors.white)),
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
