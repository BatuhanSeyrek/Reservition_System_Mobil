import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rezervasyon_mobil/core/app_colors.dart';
import 'package:rezervasyon_mobil/screens/admin_screen/admin_update_screen.dart';
import '../../providers/auth_provider.dart';
import '../user_login.dart';
import '../about_screen.dart';

class AdminLogin extends StatefulWidget {
  @override
  _OwnerLoginScreenState createState() => _OwnerLoginScreenState();
}

class _OwnerLoginScreenState extends State<AdminLogin> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool isLoading = false;

  void handleLogin() async {
    setState(() => isLoading = true);
    try {
      final authProvider = context.read<AuthProvider>();
      await authProvider.loginAdmin(
        _usernameController.text,
        _passwordController.text,
      );
      final admin = authProvider.admin;
      if (admin == null) throw Exception("Admin bilgisi alınamadı");

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder:
              (_) =>
                  admin.referenceStatus == false
                      ? OwnerUpdateScreen()
                      : AboutScreen(),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Giriş başarısız!'),
          backgroundColor: Colors.redAccent,
        ),
      );
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: AppColors.background,
      resizeToAvoidBottomInset:
          false, // Klavye açıldığında taşmayı önlemek için
      body: Stack(
        children: [
          // 1. Arka Plan Resmi ve Overlay
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

          // 3. Form İçeriği (Yukarı Kaydırılmış)
          SafeArea(
            child: Column(
              children: [
                const Spacer(
                  flex: 1,
                ), // Üstten esnek boşluk (Formu yukarı iter)
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
                          Icons.admin_panel_settings_rounded,
                          color: AppColors.primaryGreen,
                          size: 50,
                        ),
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        'Yönetici Paneli',
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
                              "Yönetici Girişi",
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: AppColors.darkGrey,
                              ),
                            ),
                            const SizedBox(height: 32),
                            _buildTextField(
                              _usernameController,
                              "Yönetici Adı",
                              Icons.badge_outlined,
                            ),
                            const SizedBox(height: 16),
                            _buildTextField(
                              _passwordController,
                              "Şifre",
                              Icons.lock_open_rounded,
                              isPassword: true,
                            ),
                            const SizedBox(height: 32),
                            _buildAdminLoginButton(),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const Spacer(
                  flex: 2,
                ), // Alttan daha büyük esnek boşluk (Formu yukarıda tutar)
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAdminLoginButton() => SizedBox(
    width: double.infinity,
    height: 58,
    child: ElevatedButton(
      onPressed: isLoading ? null : handleLogin,
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primaryGreen,
        foregroundColor: Colors.white,
        elevation: 8,
        shadowColor: AppColors.primaryGreen.withOpacity(0.4),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      ),
      child:
          isLoading
              ? const CircularProgressIndicator(color: Colors.white)
              : const Text(
                'GİRİŞ YAP',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1,
                ),
              ),
    ),
  );

  Widget _buildTextField(
    TextEditingController controller,
    String hint,
    IconData icon, {
    bool isPassword = false,
  }) => Container(
    decoration: BoxDecoration(
      color: AppColors.background.withOpacity(0.4),
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
        prefixIcon: Icon(icon, color: AppColors.primaryGreen, size: 22),
        border: InputBorder.none,
        contentPadding: const EdgeInsets.symmetric(
          vertical: 18,
          horizontal: 20,
        ),
      ),
    ),
  );
}
