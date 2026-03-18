import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rezervasyon_mobil/core/app_colors.dart';
import 'package:rezervasyon_mobil/screens/chair_availability_screen.dart';
import 'package:rezervasyon_mobil/screens/user_login.dart';
import '../providers/reference_login_provider.dart';

class ReferenceIdLoginScreen extends StatefulWidget {
  const ReferenceIdLoginScreen({super.key});

  @override
  _ReferenceIdLoginScreenState createState() => _ReferenceIdLoginScreenState();
}

class _ReferenceIdLoginScreenState extends State<ReferenceIdLoginScreen> {
  final TextEditingController referenceCtrl = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ReferenceLoginProvider>(context);
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: AppColors.background,
      resizeToAvoidBottomInset:
          false, // Klavye açıldığında tasarımın bozulmaması için
      body: Stack(
        children: [
          // 1. Arka Plan Resmi ve Füme Overlay
          Container(
            width: size.width,
            height: size.height,
            decoration: BoxDecoration(
              image: DecorationImage(
                image: const AssetImage('assets/images/barbershop.jpg'),
                fit: BoxFit.cover,
                colorFilter: ColorFilter.mode(
                  AppColors.darkGrey.withOpacity(0.7),
                  BlendMode.darken,
                ),
              ),
            ),
          ),

          // 2. Geri Butonu
          Positioned(
            top: MediaQuery.of(context).padding.top + 10,
            left: 10,
            child: IconButton(
              icon: const Icon(
                Icons.arrow_back_ios_new_rounded,
                color: Colors.white,
                size: 24,
              ),
              onPressed: () => Navigator.pop(context),
            ),
          ),

          // 3. Form İçeriği (Dengeli Yükseklik)
          SafeArea(
            child: Column(
              children: [
                const Spacer(flex: 1), // Formu biraz yukarı iter
                SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    children: [
                      // Başlık İkonu
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.1),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.white.withOpacity(0.2),
                          ),
                        ),
                        child: const Icon(
                          Icons.qr_code_scanner_rounded,
                          color: AppColors.primaryGreen,
                          size: 50,
                        ),
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        'Referans Girişi',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                          letterSpacing: 1.5,
                        ),
                      ),
                      const SizedBox(height: 40),

                      // Giriş Formu Kartı
                      Container(
                        width: double.infinity,
                        constraints: const BoxConstraints(maxWidth: 400),
                        padding: const EdgeInsets.all(32),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(32),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.3),
                              blurRadius: 30,
                              offset: const Offset(0, 15),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            const Text(
                              "Reference ID",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: AppColors.darkGrey,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              "İşletme kodunu girerek devam edin",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.grey.shade500,
                                fontSize: 12,
                              ),
                            ),
                            const SizedBox(height: 32),

                            // Modern TextField
                            _buildModernField(
                              controller: referenceCtrl,
                              hint: "Örn: REF12345",
                              icon: Icons.vpn_key_rounded,
                            ),

                            const SizedBox(height: 32),

                            // Giriş Butonu
                            _buildLoginButton(provider),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const Spacer(
                  flex: 2,
                ), // Alttan daha fazla boşluk bırakarak formu yukarıda tutar
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ✅ MODERN GİRİŞ ALANI
  Widget _buildModernField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.background.withOpacity(0.4),
        borderRadius: BorderRadius.circular(16),
      ),
      child: TextField(
        controller: controller,
        style: const TextStyle(
          color: AppColors.darkGrey,
          fontWeight: FontWeight.w600,
        ),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(color: Colors.grey.shade500, fontSize: 14),
          prefixIcon: Icon(icon, color: AppColors.primaryGreen, size: 20),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            vertical: 18,
            horizontal: 20,
          ),
        ),
      ),
    );
  }

  // ✅ GİRİŞ BUTONU
  Widget _buildLoginButton(ReferenceLoginProvider provider) {
    return SizedBox(
      width: double.infinity,
      height: 58,
      child:
          provider.isLoading
              ? const Center(
                child: CircularProgressIndicator(color: AppColors.primaryGreen),
              )
              : ElevatedButton(
                onPressed: () async {
                  bool ok = await provider.loginWithReferenceId(
                    referenceCtrl.text.trim(),
                  );

                  if (ok && mounted) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ChairAvailabilityScreen(),
                      ),
                    );
                  } else if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Reference ID hatalı veya bulunamadı.'),
                        backgroundColor: Colors.redAccent,
                      ),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryGreen,
                  foregroundColor: Colors.white,
                  elevation: 8,
                  shadowColor: AppColors.primaryGreen.withOpacity(0.4),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                ),
                child: const Text(
                  'GİRİŞ YAP',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1,
                  ),
                ),
              ),
    );
  }
}
