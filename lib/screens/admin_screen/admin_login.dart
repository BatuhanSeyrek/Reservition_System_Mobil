import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
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
        SnackBar(content: Text('Giriş başarısız! ${e.toString()}')),
      );
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: Stack(
        children: [
          _buildBackground(size),
          Container(
            width: double.infinity,
            height: double.infinity,
            alignment: Alignment.center,
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
              child: Container(
                width: size.width * 0.9,
                constraints: const BoxConstraints(maxWidth: 400),
                padding: const EdgeInsets.all(28),
                decoration: _cardDecoration(),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // ✅ Üstteki küçük buton kaldırıldı, sadece başlık kaldı.
                    const SizedBox(height: 10),
                    _buildTitle("Yönetici Girişi", Icons.admin_panel_settings),
                    const SizedBox(height: 35),
                    _buildTextField(
                      _usernameController,
                      "Yönetici Adı",
                      Icons.admin_panel_settings_outlined,
                    ),
                    const SizedBox(height: 20),
                    _buildTextField(
                      _passwordController,
                      "Şifre",
                      Icons.lock_outline_rounded,
                      isPassword: true,
                    ),
                    const SizedBox(height: 35),
                    _buildAdminLoginButton(),

                    // ✅ ALT YÖNLENDİRME KISMI
                    const SizedBox(height: 30),
                    Column(
                      children: [
                        Text(
                          "Kullanıcı olarak giriş yapmak ister misiniz?",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.blueGrey.shade600,
                            fontSize: 13,
                          ),
                        ),
                        const SizedBox(height: 12),
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => UserLogin()),
                            );
                          },
                          child: Text(
                            "Kullanıcı Girişi Yap",
                            style: TextStyle(
                              color: Colors.red.shade700,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
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

  // --- UI BİLEŞENLERİ ---

  Widget _buildAdminLoginButton() => SizedBox(
    width: double.infinity,
    height: 58,
    child: ElevatedButton(
      onPressed: isLoading ? null : handleLogin,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.red.shade600,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        elevation: 5,
      ),
      child:
          isLoading
              ? const CircularProgressIndicator(color: Colors.white)
              : const Text(
                'Giriş Yap',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
    ),
  );

  Widget _buildBackground(Size size) => Container(
    width: size.width,
    height: size.height,
    decoration: BoxDecoration(
      image: DecorationImage(
        image: const AssetImage('assets/images/barbershop.jpg'),
        fit: BoxFit.cover,
        colorFilter: ColorFilter.mode(
          Colors.black.withOpacity(0.4),
          BlendMode.darken,
        ),
      ),
    ),
  );

  BoxDecoration _cardDecoration() => BoxDecoration(
    color: Colors.white.withOpacity(0.95),
    borderRadius: BorderRadius.circular(35),
    boxShadow: [
      const BoxShadow(
        color: Colors.black26,
        blurRadius: 20,
        offset: Offset(0, 10),
      ),
    ],
  );

  Widget _buildTitle(String text, IconData icon) => Column(
    children: [
      Icon(icon, color: Colors.red.shade700, size: 40),
      const SizedBox(height: 10),
      Text(
        text,
        style: TextStyle(
          fontSize: 26,
          fontWeight: FontWeight.w900,
          color: Colors.blueGrey.shade900,
        ),
      ),
    ],
  );

  Widget _buildTextField(
    TextEditingController controller,
    String label,
    IconData icon, {
    bool isPassword = false,
  }) => Container(
    decoration: BoxDecoration(
      color: Colors.grey.shade100,
      borderRadius: BorderRadius.circular(18),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.05),
          blurRadius: 5,
          offset: const Offset(0, 2),
        ),
      ],
    ),
    child: TextField(
      controller: controller,
      obscureText: isPassword,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: Colors.red.shade400),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide(color: Colors.red.shade400, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(
          vertical: 18,
          horizontal: 20,
        ),
      ),
    ),
  );
}
