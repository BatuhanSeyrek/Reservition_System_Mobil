import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rezervasyon_mobil/core/app_colors.dart';
import 'package:rezervasyon_mobil/models/user_model/user_model.dart';
import 'package:rezervasyon_mobil/providers/user_provider.dart';

class UserRegister extends StatefulWidget {
  const UserRegister({super.key});

  @override
  _UserRegisterState createState() => _UserRegisterState();
}

class _UserRegisterState extends State<UserRegister> {
  final TextEditingController _userNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  String _notificationType = "MAIL";

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: AppColors.background,
      resizeToAvoidBottomInset:
          false, // Klavye açıldığında tasarımın yukarı fırlamasını önler
      body: Stack(
        children: [
          // 1. Arka Plan Resmi ve Filtre (Login ile Aynı)
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

          // 3. Form İçeriği (Login gibi yukarı taşınmış yapı)
          SafeArea(
            child: Column(
              children: [
                const Spacer(flex: 1), // Üstten boşluk (Formu yukarı iter)
                SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    children: [
                      // Başlık İkonu (Login stilinde halkalı ikon)
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
                          Icons.person_add_rounded,
                          color: AppColors.primaryGreen,
                          size: 50,
                        ),
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        'Yeni Hesap Oluştur',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                          letterSpacing: 1,
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
                            _buildModernInput(
                              label: "Tam İsim",
                              controller: _userNameController,
                              icon: Icons.person_outline_rounded,
                            ),
                            const SizedBox(height: 16),
                            _buildModernInput(
                              label: "E-posta Adresi",
                              controller: _emailController,
                              icon: Icons.email_outlined,
                            ),
                            const SizedBox(height: 16),
                            _buildModernInput(
                              label: "Telefon Numarası",
                              controller: _phoneController,
                              icon: Icons.phone_android_outlined,
                            ),
                            const SizedBox(height: 16),
                            _buildDropdown(),
                            const SizedBox(height: 16),
                            _buildModernInput(
                              label: "Şifre",
                              controller: _passwordController,
                              icon: Icons.lock_outline_rounded,
                              isPassword: true,
                            ),
                            const SizedBox(height: 32),
                            _buildRegisterButton(),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const Spacer(
                  flex: 2,
                ), // Alttan boşluk (Formun yukarıda kalmasını sağlar)
                // Giriş Yap Linki (Daha aşağıda, formun dışında)
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: RichText(
                    text: const TextSpan(
                      style: TextStyle(fontSize: 14, color: Colors.white70),
                      children: [
                        TextSpan(text: "Zaten hesabınız var mı? "),
                        TextSpan(
                          text: "Giriş Yap",
                          style: TextStyle(
                            color: AppColors.primaryGreen,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ✅ MODERN DROPDOWN
  Widget _buildDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: AppColors.background.withOpacity(0.4),
        borderRadius: BorderRadius.circular(16),
      ),
      child: DropdownButtonFormField<String>(
        value: _notificationType,
        style: const TextStyle(
          color: AppColors.darkGrey,
          fontWeight: FontWeight.w600,
        ),
        decoration: const InputDecoration(
          border: InputBorder.none,
          labelText: "Bildirim Türü",
          labelStyle: TextStyle(color: Colors.grey, fontSize: 13),
          icon: Icon(
            Icons.notifications_active_outlined,
            color: AppColors.primaryGreen,
            size: 20,
          ),
        ),
        items: const [
          DropdownMenuItem(value: "MAIL", child: Text("Email")),
          DropdownMenuItem(value: "SMS", child: Text("SMS")),
          DropdownMenuItem(value: "BOTH", child: Text("Her İkisi")),
        ],
        onChanged: (v) => setState(() => _notificationType = v!),
      ),
    );
  }

  // ✅ MODERN TEXTFIELD (Login stiliyle birebir aynı)
  Widget _buildModernInput({
    required String label,
    required TextEditingController controller,
    required IconData icon,
    bool isPassword = false,
  }) {
    return Container(
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
          labelText: label,
          labelStyle: const TextStyle(color: Colors.grey, fontSize: 13),
          prefixIcon: Icon(icon, color: AppColors.primaryGreen, size: 20),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            vertical: 14,
            horizontal: 16,
          ),
        ),
      ),
    );
  }

  // ✅ KAYIT BUTONU
  Widget _buildRegisterButton() {
    return SizedBox(
      width: double.infinity,
      height: 58,
      child: ElevatedButton(
        onPressed: () async {
          // Kayıt işlemi mantığı...
          final request = User(
            userName: _userNameController.text,
            email: _emailController.text,
            phoneNumber: _phoneController.text,
            notificationType: _notificationType,
            password: _passwordController.text,
          );

          try {
            await context.read<RegisterProvider>().registerUser(
              request.toJson(),
            );
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Kayıt Başarılı!'),
                backgroundColor: AppColors.primaryGreen,
              ),
            );
            Navigator.pop(context);
          } catch (e) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Kayıt Başarısız.'),
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
          "KAYIT OL",
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
