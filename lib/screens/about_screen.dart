import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';

class AboutScreen extends StatelessWidget {
  final bool isAdmin;
  const AboutScreen({Key? key, required this.isAdmin}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    return Scaffold(
      appBar: AppBar(
        title: Text(isAdmin ? 'Admin Hakkında' : 'User Hakkında'),
        backgroundColor: Colors.grey[900],
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (isAdmin && auth.admin != null) ...[
              Text(
                'Admin Name: ${auth.admin!.adminName}',
                style: TextStyle(fontSize: 18),
              ),
              SizedBox(height: 8),
              Text(
                'Store Name: ${auth.admin!.storeName}',
                style: TextStyle(fontSize: 18),
              ),
              SizedBox(height: 8),
              Text(
                'Phone Number: ${auth.admin!.phoneNumber}',
                style: TextStyle(fontSize: 18),
              ),
              SizedBox(height: 8),
              Text(
                'Chair Count: ${auth.admin!.chairCount}',
                style: TextStyle(fontSize: 18),
              ),
            ] else
              Center(child: Text('Veri yok')),
          ],
        ),
      ),
    );
  }
}
