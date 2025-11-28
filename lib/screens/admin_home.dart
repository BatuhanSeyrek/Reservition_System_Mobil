import 'package:flutter/material.dart';
import 'admin_layout.dart';

class AdminHome extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return AdminLayout(
      body: Center(
        child: Text("Admin Home Screen", style: TextStyle(fontSize: 24)),
      ),
    );
  }
}
