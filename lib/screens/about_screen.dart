import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import 'admin_layout.dart'; // AdminLayout

class AboutScreen extends StatelessWidget {
  const AboutScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    return AdminLayout(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Uygulamamızın Özellikleri',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            Text(
              'Bu uygulama, rezervasyon işlemlerini yönetmenizi ve kullanıcılarla çalışanlar arasındaki etkileşimi kolaylaştırmanızı sağlar. '
              'Gelişmiş filtreleme sistemi, bugünün ve geleceğin rezervasyonlarını hızlıca görmenizi, Excel raporları indirmenizi ve tüm rezervasyonları tek bir panelden takip etmenizi mümkün kılar.',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 16),
            Text(
              'Özellikler:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text('- Rezervasyon listeleme ve detaylarını görüntüleme'),
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
    );
  }
}
