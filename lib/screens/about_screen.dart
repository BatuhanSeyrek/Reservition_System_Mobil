import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rezervasyon_mobil/screens/admin_screen/admin_sidebar.dart';
import 'package:rezervasyon_mobil/screens/user_sidebar.dart';
import '../providers/auth_provider.dart';
import 'admin_screen/admin_layout.dart';

class AboutScreen extends StatefulWidget {
  const AboutScreen({Key? key}) : super(key: key);

  @override
  State<AboutScreen> createState() => _AboutScreenState();
}

class _AboutScreenState extends State<AboutScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;

  // Kurumsal Renk Paleti
  final Color primaryBlue = const Color.fromARGB(
    255,
    38,
    38,
    38,
  ); // Deep Ocean Blue
  final Color lightBlue = const Color.fromARGB(255, 83, 84, 86);
  final Color scaffoldBg = const Color(0xFFF8FAFC);
  final Color cardColor = Colors.white;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    return AppLayout(
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: Container(
          color: scaffoldBg,
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(
              horizontal: 22.0,
              vertical: 24.0,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Modern Header Section
                _buildHeader(),
                const SizedBox(height: 32),

                _sectionLabel("SİSTEM ÇÖZÜMLERİMİZ"),
                const SizedBox(height: 16),

                // Dolu Dolu Özellik Listesi
                _buildFeatureTile(
                  title: 'Merkezi Rezervasyon Paneli',
                  desc:
                      'Tüm rezervasyonları tek bir ekranda toplayan, kullanıcı ve çalışan etkileşimini maksimize eden akıllı yönetim arayüzü.',
                  icon: Icons.dashboard_customize_rounded,
                ),
                _buildFeatureTile(
                  title: 'Gelişmiş Dinamik Filtreleme',
                  desc:
                      'ID, kullanıcı adı, personel ve koltuk numarasına göre saniyelik arama. Bugünün ve geleceğin planlarını anlık olarak ayırın.',
                  icon: Icons.manage_search_rounded,
                ),
                _buildFeatureTile(
                  title: 'Veri Analitiği ve Excel Raporlama',
                  desc:
                      'Son 6 aya ait tüm geçmiş verileri PostgreSQL tabanlı sistemimizden çekerek profesyonel Excel formatında raporlayın.',
                  icon: Icons.assessment_rounded,
                ),
                _buildFeatureTile(
                  title: 'Rol Bazlı Güvenlik Mimarisi',
                  desc:
                      'Admin ve standart kullanıcılar için özelleştirilmiş erişim seviyeleri ile veri güvenliğini en üst düzeyde tutun.',
                  icon: Icons.security_update_good_rounded,
                ),
                _buildFeatureTile(
                  title: 'Docker ve Spring Boot Entegrasyonu',
                  desc:
                      'Arka planda Java Spring Boot gücü ve Docker konteyner yapısıyla kesintisiz, ölçeklenebilir bir performans sunar.',
                  icon: Icons.layers_rounded,
                ),

                const SizedBox(height: 32),

                _sectionLabel("PROJE MİMARLARI"),
                const SizedBox(height: 16),

                // Geliştirici Kartları
                Row(
                  children: [
                    _buildDeveloperCard("Baran BATUR", "Backend Developer"),
                    const SizedBox(width: 12),
                    _buildDeveloperCard("Batuhan SEYREK", "Java Developer"),
                  ],
                ),

                const SizedBox(height: 40),

                // Alt Bilgi
                Center(
                  child: Opacity(
                    opacity: 0.6,
                    child: Column(
                      children: [
                        const Divider(),
                        const SizedBox(height: 10),
                        Text(
                          "v1.0.0 - Rezervasyon Yönetim Sistemi",
                          style: TextStyle(
                            color: primaryBlue,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      bottomBar:
          auth.admin != null
              ? const AdminBottomBar(currentIndex: 4)
              : const UserBottomBar(currentIndex: 3),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [primaryBlue, lightBlue],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: primaryBlue.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.business_center_rounded,
            color: Colors.white,
            size: 40,
          ),
          const SizedBox(height: 16),
          const Text(
            'Kurumsal Rezervasyon\nOtomasyonu',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.w800,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            height: 3,
            width: 60,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.5),
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionLabel(String label) {
    return Text(
      label,
      style: TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.bold,
        color: primaryBlue.withOpacity(0.8),
        letterSpacing: 1.5,
      ),
    );
  }

  Widget _buildFeatureTile({
    required String title,
    required String desc,
    required IconData icon,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.blue.shade50),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: primaryBlue.withOpacity(0.05),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: primaryBlue, size: 26),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E293B),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  desc,
                  style: TextStyle(
                    fontSize: 13,
                    color: const Color.fromARGB(255, 80, 80, 80),
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDeveloperCard(String name, String role) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color.fromARGB(255, 31, 31, 31)),
        ),
        child: Column(
          children: [
            CircleAvatar(
              backgroundColor: primaryBlue.withOpacity(0.1),
              radius: 20,
              child: Icon(Icons.person, color: primaryBlue, size: 20),
            ),
            const SizedBox(height: 10),
            Text(
              name,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
            ),
            Text(
              role,
              style: TextStyle(
                fontSize: 11,
                color: const Color.fromARGB(255, 86, 88, 89),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
