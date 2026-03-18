import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:provider/provider.dart';
import 'package:rezervasyon_mobil/core/app_colors.dart';
import 'package:rezervasyon_mobil/providers/user_provideriki.dart';
import 'package:rezervasyon_mobil/screens/admin_screen/admin_layout.dart';
import 'package:rezervasyon_mobil/screens/user_sidebar.dart';

class UserUpdateScreen extends StatefulWidget {
  const UserUpdateScreen({Key? key}) : super(key: key);

  @override
  State<UserUpdateScreen> createState() => _UserUpdateScreenState();
}

class _UserUpdateScreenState extends State<UserUpdateScreen> {
  final _storage = const FlutterSecureStorage();

  final _userNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();

  String _notificationType = 'MAIL';
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    final token = await _storage.read(key: 'token');
    if (token == null) return;

    final provider = context.read<UserProvider>();
    await provider.loadUser(token);

    final user = provider.user;
    if (user != null) {
      _userNameController.text = user.userName;
      _emailController.text = user.email;
      _phoneController.text = user.phoneNumber;
      _notificationType = user.notificationType;
    }

    setState(() => _initialized = true);
  }

  Future<void> _submit() async {
    final token = await _storage.read(key: 'token');
    if (token == null) return;

    final data = {
      'userName': _userNameController.text,
      'email': _emailController.text,
      'phoneNumber': _phoneController.text,
      'notificationType': _notificationType,
      if (_passwordController.text.isNotEmpty)
        'password': _passwordController.text,
    };

    try {
      await context.read<UserProvider>().updateUser(token: token, data: data);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Bilgileriniz başarıyla güncellendi'),
          backgroundColor: AppColors.primaryGreen,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Güncelleme sırasında bir hata oluşti'),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<UserProvider>();

    if (!_initialized || provider.isLoading) {
      return const Scaffold(
        backgroundColor: AppColors.background,
        body: Center(
          child: CircularProgressIndicator(color: AppColors.primaryGreen),
        ),
      );
    }

    return AppLayout(
      body: Container(
        color: AppColors.background,
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: Column(
            children: [
              // 👤 Profil Başlık Alanı
              _buildProfileHeader(provider.user?.userName ?? ""),
              const SizedBox(height: 32),

              // 📝 Form Kartı
              Container(
                width: double.infinity,
                constraints: const BoxConstraints(maxWidth: 450),
                padding: const EdgeInsets.all(28),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Hesap Bilgileri",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: AppColors.darkGrey,
                      ),
                    ),
                    const SizedBox(height: 24),

                    _buildModernInput(
                      label: 'Ad Soyad',
                      controller: _userNameController,
                      icon: Icons.person_outline_rounded,
                    ),
                    const SizedBox(height: 16),

                    _buildModernInput(
                      label: 'E-posta Adresi',
                      controller: _emailController,
                      icon: Icons.email_outlined,
                      keyboardType: TextInputType.emailAddress,
                    ),
                    const SizedBox(height: 16),

                    _buildModernInput(
                      label: 'Telefon Numarası',
                      controller: _phoneController,
                      icon: Icons.phone_android_outlined,
                      keyboardType: TextInputType.phone,
                    ),
                    const SizedBox(height: 16),

                    _buildDropdown(),

                    const SizedBox(height: 16),

                    _buildModernInput(
                      label: 'Yeni Şifre',
                      controller: _passwordController,
                      icon: Icons.lock_outline_rounded,
                      isPassword: true,
                      hint: 'Değiştirmek istemiyorsanız boş bırakın',
                    ),

                    const SizedBox(height: 32),

                    _buildSubmitButton(),
                  ],
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
      bottomBar: const UserBottomBar(currentIndex: 2),
    );
  }

  Widget _buildProfileHeader(String name) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.primaryGreen, width: 2),
          ),
          child: const CircleAvatar(
            radius: 40,
            backgroundColor: AppColors.darkGrey,
            child: Icon(
              Icons.person_rounded,
              size: 45,
              color: AppColors.primaryGreen,
            ),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          name,
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w900,
            color: AppColors.darkGrey,
          ),
        ),
        const Text(
          "Profilini buradan güncelleyebilirsin",
          style: TextStyle(
            color: Colors.grey,
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildModernInput({
    required String label,
    required TextEditingController controller,
    required IconData icon,
    bool isPassword = false,
    String? hint,
    TextInputType? keyboardType,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.background.withOpacity(0.5),
        borderRadius: BorderRadius.circular(16),
      ),
      child: TextField(
        controller: controller,
        obscureText: isPassword,
        keyboardType: keyboardType,
        style: const TextStyle(
          color: AppColors.darkGrey,
          fontWeight: FontWeight.w600,
          fontSize: 15,
        ),
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          hintStyle: const TextStyle(fontSize: 12, color: Colors.grey),
          labelStyle: const TextStyle(color: Colors.grey, fontSize: 14),
          prefixIcon: Icon(icon, color: AppColors.primaryGreen, size: 22),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            vertical: 16,
            horizontal: 20,
          ),
        ),
      ),
    );
  }

  Widget _buildDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: AppColors.background.withOpacity(0.5),
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
          labelText: 'Bildirim Tercihi',
          labelStyle: TextStyle(color: Colors.grey, fontSize: 14),
          prefixIcon: Icon(
            Icons.notifications_active_outlined,
            color: AppColors.primaryGreen,
            size: 22,
          ),
          border: InputBorder.none,
        ),
        items: const [
          DropdownMenuItem(value: 'MAIL', child: Text('E-posta')),
          DropdownMenuItem(value: 'SMS', child: Text('SMS')),
          DropdownMenuItem(value: 'PUSH', child: Text('Uygulama İçi')),
        ],
        onChanged: (v) => setState(() => _notificationType = v!),
      ),
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      height: 55,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryGreen,
          foregroundColor: Colors.white,
          elevation: 5,
          shadowColor: AppColors.primaryGreen.withOpacity(0.3),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
        ),
        onPressed: _submit,
        child: const Text(
          'DEĞİŞİKLİKLERİ KAYDET',
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w800,
            letterSpacing: 1,
          ),
        ),
      ),
    );
  }
}
