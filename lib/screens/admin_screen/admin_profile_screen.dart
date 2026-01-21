import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../admin_screen/admin_sidebar.dart'; // AdminBottomBar'ın olduğu dosya yolu
import 'admin_layout.dart';

class AdminProfileScreen extends StatelessWidget {
  const AdminProfileScreen({super.key});

  // Saat ve Tarihi "SS:DD - GG.AA.YYYY" formatına çevirir
  String formatDateTimeTR(String dateStr) {
    try {
      DateTime dt = DateTime.parse(dateStr);

      String hour = dt.hour.toString().padLeft(2, '0');
      String minute = dt.minute.toString().padLeft(2, '0');

      String day = dt.day.toString().padLeft(2, '0');
      String month = dt.month.toString().padLeft(2, '0');
      String year = dt.year.toString();

      return "$hour:$minute - $day.$month.$year";
    } catch (e) {
      return dateStr;
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final admin = auth.admin;

    return AppLayout(
      body:
          admin == null
              ? const Center(child: Text("Admin bilgisi bulunamadı"))
              : SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    // Profil Bölümü
                    CircleAvatar(
                      radius: 45,
                      backgroundColor: Colors.black87,
                      child: Text(
                        admin.adminName.substring(0, 1).toUpperCase(),
                        style: const TextStyle(
                          fontSize: 40,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(height: 15),
                    Text(
                      admin.adminName,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 30),

                    // Bilgi Kartları
                    buildInfoCard("Mağaza", admin.storeName),
                    buildInfoCard("Telefon", admin.phoneNumber ?? "-"),
                    buildInfoCard(
                      "Başlangıç Zamanı",
                      formatDateTimeTR(admin.startTime),
                    ),
                    buildInfoCard(
                      "Bitiş Zamanı",
                      formatDateTimeTR(admin.endTime),
                    ),
                    buildInfoCard("Koltuk Sayısı", admin.chairCount.toString()),
                  ],
                ),
              ),

      // 🔥 Bottom Bar buraya eklendi
      bottomBar: const AdminBottomBar(currentIndex: 3),
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
