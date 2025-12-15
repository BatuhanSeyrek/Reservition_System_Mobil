import 'package:flutter/material.dart';
import 'package:rezervasyon_mobil/screens/user_update_screen.dart';

import 'all_stores_screen.dart';

class UserSidebar extends StatelessWidget {
  const UserSidebar({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: EdgeInsets.zero,
      children: [
        const DrawerHeader(
          decoration: BoxDecoration(color: Colors.black87),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.person, color: Colors.white, size: 48),
              SizedBox(height: 8),
              Text(
                'User Menu',
                style: TextStyle(color: Colors.white, fontSize: 18),
              ),
            ],
          ),
        ),

        // 🔥 ALL STORES
        ListTile(
          leading: const Icon(Icons.store),
          title: const Text('All Stores'),
          onTap: () {
            Navigator.pop(context);
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => AllStoresScreen()),
            );
          },
        ),

        ListTile(
          leading: const Icon(Icons.person),
          title: const Text('User Update'),
          onTap: () {
            Navigator.pop(context);
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => UserUpdateScreen()),
            );
          },
        ),
      ],
    );
  }
}

class UserProfileScreen extends StatelessWidget {
  const UserProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('User Profile')),
      body: const Center(child: Text('User Profile Details Here')),
    );
  }
}
