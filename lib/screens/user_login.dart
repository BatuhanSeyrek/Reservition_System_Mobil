import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
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
      resizeToAvoidBottomInset: true,
      body: Stack(
        children: [
          // 1. Arka Plan Resmi ve Overlay
          Container(
            width: size.width,
            height: size.height,
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/barbershop.jpg'),
                fit: BoxFit.cover,
                colorFilter: ColorFilter.mode(
                  Colors.black.withOpacity(0.4),
                  BlendMode.darken,
                ),
              ),
            ),
          ),

          // 2. Form İçeriği (Tam Ortalanmış)
          Container(
            width: double.infinity,
            height: double.infinity,
            alignment: Alignment.center,
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 40),
              child: Container(
                width: size.width * 0.9,
                constraints: BoxConstraints(maxWidth: 400),
                padding: EdgeInsets.all(28),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.95),
                  borderRadius: BorderRadius.circular(35),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 20,
                      offset: Offset(0, 10),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Üst Butonlar (Referans ve Yönetici Girişi)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _topLoginOption(
                          context,
                          title: "Referans",
                          icon: Icons.qr_code_scanner,
                          color: Colors.red.shade700,
                          onTap:
                              () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => ReferenceIdLoginScreen(),
                                ),
                              ),
                        ),
                        SizedBox(width: 12),
                        _topLoginOption(
                          context,
                          title: "Yönetici",
                          icon: Icons.admin_panel_settings,
                          color: Colors.red.shade700,
                          onTap:
                              () => Navigator.push(
                                context,
                                MaterialPageRoute(builder: (_) => AdminLogin()),
                              ),
                        ),
                      ],
                    ),
                    SizedBox(height: 30),

                    // Başlık Alanı
                    Column(
                      children: [
                        Icon(
                          Icons.content_cut,
                          color: Colors.red.shade700,
                          size: 40,
                        ),
                        SizedBox(height: 10),
                        Text(
                          'Kullanıcı Girişi',
                          style: TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.w900,
                            color: Colors.blueGrey.shade900,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 35),

                    // Kullanıcı Adı Kutusu
                    _buildTextField(
                      controller: _usernameController,
                      label: "Kullanıcı Adı",
                      icon: Icons.person_outline_rounded,
                    ),
                    SizedBox(height: 18),

                    // Şifre Kutusu
                    _buildTextField(
                      controller: _passwordController,
                      label: "Şifre",
                      icon: Icons.lock_outline_rounded,
                      isPassword: true,
                    ),
                    SizedBox(height: 35),

                    // Giriş Yap Butonu (Senin Fonksiyonunla Birlikte)
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
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Giriş başarılı!')),
                            );
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(builder: (_) => AboutScreen()),
                            );
                          } catch (e) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Giriş başarısız!')),
                            );
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red.shade600,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18),
                          ),
                          elevation: 5,
                        ),
                        child: Text(
                          'Giriş Yap',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 25),

                    // Kayıt Ol Linki
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Hesabınız yok mu? ',
                          style: TextStyle(
                            color: Colors.blueGrey.shade600,
                            fontSize: 15,
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => UserRegister()),
                            );
                          },
                          child: Text(
                            'Kayıt Ol',
                            style: TextStyle(
                              color: Colors.red.shade700,
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
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

  // ✅ KUTULARI BELLİ EDEN TEXTFIELD TASARIMI
  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool isPassword = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 5,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        obscureText: isPassword,
        style: TextStyle(color: Colors.blueGrey.shade900),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: Colors.blueGrey.shade500),
          prefixIcon: Icon(icon, color: Colors.red.shade400),
          contentPadding: EdgeInsets.symmetric(vertical: 18, horizontal: 20),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(18),
            borderSide: BorderSide(color: Colors.grey.shade300, width: 1.5),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(18),
            borderSide: BorderSide(color: Colors.red.shade400, width: 2),
          ),
          border: InputBorder.none,
        ),
      ),
    );
  }

  // ✅ ÜST BUTONLARIN TAŞMASINI ÖNLEYEN WIDGET
  Widget _topLoginOption(
    BuildContext context, {
    required String title,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(15),
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: color.withOpacity(0.08),
            borderRadius: BorderRadius.circular(15),
            border: Border.all(color: color.withOpacity(0.2)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: color, size: 18),
              SizedBox(width: 6),
              Flexible(
                child: Text(
                  title,
                  style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
