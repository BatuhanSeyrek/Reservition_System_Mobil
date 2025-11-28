import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rezervasyon_mobil/screens/admin_employee.dart';
import '../providers/auth_provider.dart';
import 'about_screen.dart';
import 'admin_chair.dart';

class SidebarContent extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final admin = auth.admin!;

    return ListView(
      padding: EdgeInsets.zero,
      children: [
        DrawerHeader(
          decoration: BoxDecoration(
            color: Colors.grey[900], // AppBar ile aynı renk
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                admin.storeName,
                style: TextStyle(
                  color: Colors.white, // yazılar beyaz
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 4),
              Text(
                admin.adminName,
                style: TextStyle(
                  color: Colors.white70, // hafif gri
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
        ListTile(
          leading: Icon(Icons.info, color: Colors.black87),
          title: Text('About', style: TextStyle(color: Colors.black87)),
          onTap: () {
            Navigator.pop(context);
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => AboutScreen(isAdmin: true)),
            );
          },
        ),
        ListTile(
          leading: Icon(Icons.chair, color: Colors.black87),
          title: Text(
            'Chair Management',
            style: TextStyle(color: Colors.black87),
          ),
          onTap: () {
            Navigator.pop(context);
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => ChairDeleteUpdate()),
            );
          },
        ),
        ListTile(
          leading: Icon(Icons.person, color: Colors.black87),
          title: Text(
            'Employee Management',
            style: TextStyle(color: Colors.black87),
          ),
          onTap: () {
            Navigator.pop(context);
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => EmployeeDeleteUpdateScreen()),
            );
          },
        ),
        ListTile(
          leading: Icon(Icons.logout, color: Colors.redAccent),
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
