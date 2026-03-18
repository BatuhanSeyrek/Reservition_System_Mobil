import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rezervasyon_mobil/core/app_colors.dart';
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

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _fadeAnimation = CurvedAnimation(parent: _controller, curve: Curves.easeIn);
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
          color: AppColors.background,
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(
              horizontal: 22.0,
              vertical: 24.0,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 💎 MODERN & PREMIUM HEADER
                _buildHeader(),
                const SizedBox(height: 32),

                _sectionLabel("SİSTEM ÇÖZÜMLERİMİZ"),
                const SizedBox(height: 16),

                _buildFeatureTile(
                  title: 'Merkezi Rezervasyon Paneli',
                  desc:
                      'Tüm randevuları tek merkezden yöneten, kullanıcı dostu akıllı arayüz.',
                  icon: Icons.auto_awesome_motion_rounded,
                ),
                _buildFeatureTile(
                  title: 'Gelişmiş Dinamik Filtreleme',
                  desc:
                      'Personel, koltuk ve tarih bazlı anlık sorgulama ve planlama desteği.',
                  icon: Icons.manage_search_rounded,
                ),
                _buildFeatureTile(
                  title: 'Veri Analitiği & Raporlama',
                  desc:
                      'İşletme verilerini PostgreSQL üzerinden çekerek Excel formatında raporlayın.',
                  icon: Icons.analytics_rounded,
                ),
                _buildFeatureTile(
                  title: 'Docker & Spring Boot Gücü',
                  desc:
                      'Java Spring Boot ve Docker mimarisiyle yüksek performanslı altyapı.',
                  icon: Icons.terminal_rounded,
                ),

                const SizedBox(height: 32),

                _sectionLabel("PROJE MİMARLARI"),
                const SizedBox(height: 16),

                // GELİŞTİRİCİ KARTLARI
                Row(
                  children: [
                    _buildDeveloperCard("Baran BATUR", "Backend Developer"),
                    const SizedBox(width: 12),
                    _buildDeveloperCard("Batuhan SEYREK", "Flutter & Java Dev"),
                  ],
                ),

                const SizedBox(height: 40),

                // FOOTER
                Center(
                  child: Opacity(
                    opacity: 0.5,
                    child: Column(
                      children: [
                        const Divider(thickness: 1),
                        const SizedBox(height: 10),
                        Text(
                          "v1.0.0 - KesTıraşı Rezervasyon Sistemi",
                          style: TextStyle(
                            color: AppColors.darkGrey,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 20),
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
      width: double.infinity,
      padding: const EdgeInsets.all(26),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.darkGrey, Color(0xFF3D3D3D)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Arka plan dekoratif daire
          Positioned(
            top: -30,
            right: -30,
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: AppColors.primaryGreen.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white.withOpacity(0.15)),
                    ),
                    child: const Icon(
                      Icons.auto_awesome_mosaic_rounded,
                      color: AppColors.primaryGreen,
                      size: 30,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primaryGreen.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      "GÜNCEL",
                      style: TextStyle(
                        color: AppColors.primaryGreen,
                        fontSize: 10,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              const Text(
                'KesTıraşı Kurumsal\nRezervasyon Sistemi',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                  height: 1.1,
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'Yüksek performanslı dijital dönüşüm çözümü',
                style: TextStyle(
                  color: Colors.white60,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 18),
              Container(
                height: 4,
                width: 45,
                decoration: BoxDecoration(
                  color: AppColors.primaryGreen,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _sectionLabel(String label) {
    return Text(
      label,
      style: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w900,
        color: AppColors.darkGrey.withOpacity(0.7),
        letterSpacing: 1.8,
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
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.lightGrey.withOpacity(0.4)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 12,
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
              color: AppColors.primaryGreen.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, color: AppColors.primaryGreen, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: AppColors.darkGrey,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  desc,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey.shade600,
                    height: 1.3,
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
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: AppColors.lightGrey.withOpacity(0.6)),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.primaryGreen.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.code_rounded,
                color: AppColors.primaryGreen,
                size: 22,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              name,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: 13,
                color: AppColors.darkGrey,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              role,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 10,
                color: Colors.grey,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
