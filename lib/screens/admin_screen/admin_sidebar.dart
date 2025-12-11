import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rezervasyon_mobil/screens/admin_screen/admin_dashboard_screen.dart';
import 'package:rezervasyon_mobil/screens/admin_screen/admin_employee.dart';
import 'package:rezervasyon_mobil/screens/admin_screen/admin_update_screen.dart';
import '../../providers/auth_provider.dart';
import '../about_screen.dart';
import 'admin_chair.dart';

class AdminSidebar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final admin = auth.admin!;

    final menuItems = [
      {'icon': Icons.info, 'title': 'About', 'page': AboutScreen()},
      {
        'icon': Icons.chair,
        'title': 'Chair Management',
        'page': ChairDeleteUpdate(),
      },
      {
        'icon': Icons.person,
        'title': 'Employee Management',
        'page': EmployeeDeleteUpdateScreen(),
      },
      {
        'icon': Icons.person,
        'title': 'Admin Update',
        'page': OwnerUpdateScreen(),
      },
      {
        'icon': Icons.dashboard,
        'title': 'Admin Reservation Dasboard',
        'page': AdminDashboardScreen(),
      },
    ];

    return ListView(
      padding: EdgeInsets.zero,
      children: [
        DrawerHeader(
          decoration: BoxDecoration(color: Colors.grey[900]),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                admin.storeName,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 4),
              Text(
                admin.adminName,
                style: TextStyle(color: Colors.white70, fontSize: 16),
              ),
            ],
          ),
        ),
        ...menuItems.map(
          (item) => SidebarTile(
            icon: item['icon'] as IconData,
            title: item['title'] as String,
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => item['page'] as Widget),
              );
            },
          ),
        ),
      ],
    );
  }
}

class SidebarTile extends StatefulWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  SidebarTile({required this.icon, required this.title, required this.onTap});

  @override
  _SidebarTileState createState() => _SidebarTileState();
}

class _SidebarTileState extends State<SidebarTile> {
  bool isHover = false;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: widget.onTap,
      onHover: (hovering) => setState(() => isHover = hovering),
      borderRadius: BorderRadius.circular(8),
      splashColor: Colors.redAccent.withOpacity(0.2),
      highlightColor: Colors.redAccent.withOpacity(0.1),
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color:
              isHover ? Colors.redAccent.withOpacity(0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          boxShadow:
              isHover
                  ? [
                    BoxShadow(
                      color: Colors.redAccent.withOpacity(0.3),
                      blurRadius: 8,
                      offset: Offset(0, 2),
                    ),
                  ]
                  : [],
        ),
        child: ListTile(
          leading: Icon(
            widget.icon,
            color: isHover ? Colors.redAccent : Colors.black87,
          ),
          title: Text(
            widget.title,
            style: TextStyle(
              color: isHover ? Colors.redAccent : Colors.black87,
            ),
          ),
        ),
      ),
    );
  }
}
