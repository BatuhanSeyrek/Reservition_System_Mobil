import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rezervasyon_mobil/screens/admin_screen/admin_sidebar.dart';
import 'package:rezervasyon_mobil/screens/user_sidebar.dart';

import '../providers/auth_provider.dart';
import 'admin_screen/admin_layout.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    return AppLayout(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text(
              'Uygulamamızın Özellikleri',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            Text(
              'Bu uygulama, rezervasyon işlemlerini yönetmenizi ve kullanıcılarla çalışanlar arasındaki etkileşimi kolaylaştırmanızı sağlar. '
              'Gelişmiş filtreleme sistemi sayesinde bugünün ve geleceğin rezervasyonlarını hızlıca görebilir, Excel raporları indirebilir '
              've tüm rezervasyonları tek bir panelden yönetebilirsiniz.',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 16),
            Text(
              'Özellikler:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text('- Rezervasyon listeleme ve detay görüntüleme'),
            Text('- Bugünün ve gelecek rezervasyonlarını filtreleme'),
            Text('- ID, kullanıcı, çalışan ve koltuk bazlı filtreleme'),
            Text('- Son 6 ayın rezervasyonlarını Excel olarak indirme'),
            Text('- Admin ve kullanıcı rolleri ile yönetim paneli'),
            SizedBox(height: 16),
            Text(
              'Geliştiriciler:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text('- Baran Batur'),
            Text('- Batuhan Seyrek'),
            SizedBox(height: 24),
            Center(
              child: Text(
                'Uygulamayı keyifle kullanın!',
                style: TextStyle(fontSize: 16, fontStyle: FontStyle.italic),
              ),
            ),
          ],
        ),
      ),

      // 🔥 ASIL OLAY BURASI
      bottomBar:
          auth.admin != null
              ? const AdminBottomBar(currentIndex: 4)
              : const UserBottomBar(currentIndex: 3),
    );
  }
}
