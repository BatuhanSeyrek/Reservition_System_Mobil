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
  bool _kvkkApproved = false;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: AppColors.background,
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: [
          // 1. Arka Plan
          Container(
            width: size.width,
            height: size.height,
            decoration: BoxDecoration(
              image: DecorationImage(
                image: const AssetImage('assets/images/barbershop.jpg'),
                fit: BoxFit.cover,
                colorFilter: ColorFilter.mode(
                  AppColors.darkGrey.withOpacity(0.75),
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

          // 3. İçerik
          SafeArea(
            child: Column(
              children: [
                const Spacer(flex: 1),
                SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    children: [
                      _buildHeaderIcon(),
                      const SizedBox(height: 15),
                      const Text(
                        'Yeni Hesap',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                          letterSpacing: 1,
                        ),
                      ),
                      const SizedBox(height: 30),

                      Container(
                        width: double.infinity,
                        constraints: const BoxConstraints(maxWidth: 400),
                        padding: const EdgeInsets.all(28),
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
                              label: "Kullanıcı Adı",
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
                            const SizedBox(height: 12),

                            // ✅ KVKK Alanı (Pop-up Tıklamalı)
                            _buildKvkkCheckboxWithPopup(),

                            const SizedBox(height: 24),
                            _buildRegisterButton(),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const Spacer(flex: 2),
                _buildLoginLink(),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ✅ KVKK Checkbox ve Pop-up Mantığı
  Widget _buildKvkkCheckboxWithPopup() {
    return Theme(
      data: ThemeData(unselectedWidgetColor: Colors.grey),
      child: CheckboxListTile(
        contentPadding: EdgeInsets.zero,
        value: _kvkkApproved,
        activeColor: AppColors.primaryGreen,
        onChanged: (val) => setState(() => _kvkkApproved = val ?? false),
        controlAffinity: ListTileControlAffinity.leading,
        dense: true,
        title: GestureDetector(
          onTap: _showKvkkDialog, // Tıklanınca Pop-up açar
          child: RichText(
            text: const TextSpan(
              style: TextStyle(
                fontSize: 11,
                color: AppColors.darkGrey,
                fontWeight: FontWeight.w600,
              ),
              children: [
                TextSpan(text: "KVKK Aydınlatma Metni"),
                TextSpan(
                  text: "'ni okudum, onaylıyorum.",
                  style: TextStyle(
                    fontWeight: FontWeight.normal,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ✅ KVKK Pop-up Penceresi
  void _showKvkkDialog() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            title: const Text(
              "KVKK Aydınlatma Metni",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: AppColors.darkGrey,
              ),
            ),
            content: const SingleChildScrollView(
              child: Text(
                "Kişisel verileriniz, 6698 sayılı Kişisel Verilerin Korunması Kanunu (KVKK) kapsamında, "
                "uygulama içi hizmetlerin sunulması, randevu oluşturulması ve iletişim süreçlerinin yönetilmesi "
                "amacıyla işlenmektedir. \n\n"
                "Verileriniz güvenli sunucularda saklanmakta olup, üçüncü taraflarla yasal zorunluluklar dışında paylaşılmamaktadır. "
                "Hesabınızı dilediğiniz zaman silme ve verilerinizin güncellenmesini talep etme hakkınız saklıdır.",
                style: TextStyle(fontSize: 13, color: Colors.black87),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text(
                  "Kapat",
                  style: TextStyle(
                    color: AppColors.primaryGreen,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
    );
  }

  Widget _buildHeaderIcon() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white.withOpacity(0.2)),
      ),
      child: const Icon(
        Icons.person_add_rounded,
        color: AppColors.primaryGreen,
        size: 45,
      ),
    );
  }

  Widget _buildDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: AppColors.background.withOpacity(0.4),
        borderRadius: BorderRadius.circular(16),
      ),
      child: DropdownButtonFormField<String>(
        value: _notificationType,
        dropdownColor: Colors.white,
        style: const TextStyle(
          color: AppColors.darkGrey,
          fontWeight: FontWeight.w600,
        ),
        decoration: const InputDecoration(
          border: InputBorder.none,
          labelText: "Bildirim Türü",
          labelStyle: TextStyle(color: Colors.grey, fontSize: 12),
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
          labelStyle: const TextStyle(color: Colors.grey, fontSize: 12),
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

  Widget _buildRegisterButton() {
    return SizedBox(
      width: double.infinity,
      height: 58,
      child: ElevatedButton(
        onPressed: () async {
          if (_userNameController.text.isEmpty ||
              _passwordController.text.isEmpty) {
            _showSnackBar("Lütfen tüm alanları doldurun.", Colors.orange);
            return;
          }
          if (!_kvkkApproved) {
            _showSnackBar("Lütfen KVKK metnini onaylayın.", Colors.redAccent);
            return;
          }

          final request = User(
            userName: _userNameController.text,
            email: _emailController.text,
            phoneNumber: _phoneController.text,
            notificationType: _notificationType,
            password: _passwordController.text,
            kvkk: _kvkkApproved,
          );

          try {
            await context.read<RegisterProvider>().registerUser(
              request.toJson(),
            );
            if (!mounted) return;
            _showSnackBar("Kayıt Başarılı!", AppColors.primaryGreen);
            Navigator.pop(context);
          } catch (e) {
            if (!mounted) return;
            _showSnackBar("Kayıt sırasında hata oluştu.", Colors.redAccent);
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
            fontSize: 15,
            fontWeight: FontWeight.w800,
            letterSpacing: 1,
          ),
        ),
      ),
    );
  }

  Widget _buildLoginLink() {
    return TextButton(
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
    );
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }
}
