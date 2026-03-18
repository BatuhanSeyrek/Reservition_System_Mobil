import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rezervasyon_mobil/core/app_colors.dart';
import 'package:rezervasyon_mobil/screens/about_screen.dart';
import 'package:rezervasyon_mobil/screens/reference_id_login.dart';
import 'package:rezervasyon_mobil/screens/user_register.dart';
import '../providers/auth_provider.dart';
import 'admin_screen/admin_login.dart';

class UserLogin extends StatefulWidget {
  @override
  _UserLoginState createState() => _UserLoginState();
}

class _UserLoginState extends State<UserLogin> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: AppColors.background,
      resizeToAvoidBottomInset: true,
      body: Stack(
        children: [
          // 1. Arka Plan Resmi ve Dinamik Filtre (Piramit Füme)
          Container(
            width: size.width,
            height: size.height,
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/barbershop.jpg'),
                fit: BoxFit.cover,
                colorFilter: ColorFilter.mode(
                  AppColors.darkGrey.withOpacity(0.7),
                  BlendMode.darken,
                ),
              ),
            ),
          ),

          // 2. Ana İçerik
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Logo ve Üst Başlık (Form Dışında)
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
                        Icons.content_cut_rounded,
                        color: AppColors.primaryGreen,
                        size: 50,
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'KesTıraşı',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                        letterSpacing: 2,
                      ),
                    ),
                    const SizedBox(height: 40),

                    // Giriş Formu (Modern Kart)
                    Container(
                      width: size.width * 0.9,
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
                            "Tekrar Hoş Geldin",
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: AppColors.darkGrey,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            "Randevun için giriş yap",
                            style: TextStyle(
                              color: Colors.grey.shade500,
                              fontSize: 13,
                            ),
                          ),
                          const SizedBox(height: 32),

                          // Kullanıcı Adı (İkon Kişi Olarak Güncellendi 👤)
                          _buildModernField(
                            controller: _usernameController,
                            hint: "Kullanıcı Adı",
                            icon: Icons.person_outline_rounded, // ⬅️ DEĞİŞTİ
                          ),
                          const SizedBox(height: 16),

                          // Şifre
                          _buildModernField(
                            controller: _passwordController,
                            hint: "Şifre",
                            icon: Icons.lock_open_rounded,
                            isPassword: true,
                          ),
                          const SizedBox(height: 32),

                          // Giriş Butonu (Senin Fonksiyonunla)
                          SizedBox(
                            width: double.infinity,
                            height: 58,
                            child: ElevatedButton(
                              onPressed: () async {
                                try {
                                  await context.read<AuthProvider>().loginUser(
                                    _usernameController.text,
                                    _passwordController.text,
                                  );
                                  Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => const AboutScreen(),
                                    ),
                                  );
                                } catch (e) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        'Hatalı kullanıcı adı veya şifre',
                                      ),
                                    ),
                                  );
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primaryGreen,
                                foregroundColor: Colors.white,
                                elevation: 8,
                                shadowColor: AppColors.primaryGreen.withOpacity(
                                  0.4,
                                ),
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
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 40),

                    // Alternatif Giriş Seçenekleri
                    Row(
                      children: [
                        _buildSmallAuthButton(
                          title: "Referans",
                          icon: Icons.qr_code_2_rounded,
                          onTap:
                              () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => ReferenceIdLoginScreen(),
                                ),
                              ),
                        ),
                        const SizedBox(width: 16),
                        _buildSmallAuthButton(
                          title: "Yönetici",
                          icon: Icons.admin_panel_settings_rounded,
                          onTap:
                              () => Navigator.push(
                                context,
                                MaterialPageRoute(builder: (_) => AdminLogin()),
                              ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 30),

                    // Kayıt Ol Alt Yazı
                    TextButton(
                      onPressed:
                          () => Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => UserRegister()),
                          ),
                      child: RichText(
                        text: const TextSpan(
                          style: TextStyle(fontSize: 14, color: Colors.white70),
                          children: [
                            TextSpan(text: "Hesabın yok mu? "),
                            TextSpan(
                              text: "Kayıt Ol",
                              style: TextStyle(
                                color: AppColors.primaryGreen,
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
        ],
      ),
    );
  }

  // ✅ MODERN TEXTFIELD
  Widget _buildModernField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    bool isPassword = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.background.withOpacity(0.4), // Modern hafif arka plan
        borderRadius: BorderRadius.circular(16),
      ),
      child: TextField(
        controller: controller,
        obscureText: isPassword,
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

  // ✅ ALT KÜÇÜK BUTONLAR
  Widget _buildSmallAuthButton({
    required String title,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withOpacity(0.2)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: Colors.white, size: 18),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
