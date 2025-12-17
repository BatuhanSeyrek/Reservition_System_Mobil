import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rezervasyon_mobil/providers/user_provideriki.dart';
import 'package:rezervasyon_mobil/screens/admin_screen/admin_layout.dart';
import 'package:rezervasyon_mobil/screens/user_sidebar.dart'; // ✅ UserBottomBar burada

class UserProfileScreen extends StatelessWidget {
  final String token;

  const UserProfileScreen({super.key, required this.token});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => UserProvider()..loadUser(token),
      child: Consumer<UserProvider>(
        builder: (context, userProvider, _) {
          final user = userProvider.user;

          return AppLayout(
            body:
                userProvider.isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : user == null
                    ? const Center(child: Text("Kullanıcı bilgisi bulunamadı"))
                    : SingleChildScrollView(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        children: [
                          CircleAvatar(
                            radius: 45,
                            backgroundColor: Colors.black87,
                            child: Text(
                              user.userName.substring(0, 1).toUpperCase(),
                              style: const TextStyle(
                                fontSize: 40,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          const SizedBox(height: 15),
                          Text(
                            user.userName,
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 30),
                          buildInfoCard("Email", user.email),
                          buildInfoCard("Telefon", user.phoneNumber ?? "-"),
                          buildInfoCard(
                            "Bildirim Tipi",
                            user.notificationType ?? "-",
                          ),
                        ],
                      ),
                    ),

            // 🔥 USER BOTTOM BAR EKLENDİ
            bottomBar: const UserBottomBar(currentIndex: 2),
          );
        },
      ),
    );
  }

  Widget buildInfoCard(String title, String value) {
    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 2,
            blurRadius: 5,
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          Text(value, style: const TextStyle(fontSize: 16)),
        ],
      ),
    );
  }
}
