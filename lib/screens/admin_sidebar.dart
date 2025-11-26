import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import 'about_screen.dart';

class AdminHome extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final admin = auth.admin!;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.grey[900],
        title: Row(
          children: [
            Text(admin.storeName, style: TextStyle(color: Colors.white)),
            SizedBox(width: 8),
            Icon(Icons.content_cut, color: Colors.redAccent),
          ],
        ),
        actions: [
          GestureDetector(
            onTap: () {
              // Burada dropdown açma mantığı ekleyebilirsin
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
      drawer: Drawer(child: SidebarContent()),
      body: Center(
        child: Text('Admin Ana Sayfa', style: TextStyle(fontSize: 24)),
      ),
    );
  }
}

class SidebarContent extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final admin = auth.admin!;

    return ListView(
      padding: EdgeInsets.zero,
      children: [
        DrawerHeader(
          decoration: BoxDecoration(color: Colors.red),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Admin Panel',
                style: TextStyle(color: Colors.white, fontSize: 24),
              ),
              SizedBox(height: 8),
              Text(admin.storeName, style: TextStyle(color: Colors.white70)),
              Text(admin.adminName, style: TextStyle(color: Colors.white70)),
            ],
          ),
        ),
        ListTile(
          title: Text('About'),
          onTap: () {
            Navigator.pop(context);
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => AboutScreen(isAdmin: true)),
            );
          },
        ),
        ListTile(
          title: Text('Logout', style: TextStyle(color: Colors.redAccent)),
          onTap: () async {
            Navigator.pop(context);
            await auth.logout();
            Navigator.pushNamedAndRemoveUntil(context, '/', (_) => false);
          },
        ),
      ],
    );
  }
}
