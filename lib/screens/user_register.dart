import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rezervasyon_mobil/models/user_model/user_model.dart';
import 'package:rezervasyon_mobil/providers/user_provider.dart';

class UserRegister extends StatefulWidget {
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
      resizeToAvoidBottomInset: true,
      body: Stack(
        children: [
          // Background Image
          Positioned.fill(
            child: Image.asset(
              'assets/images/barbershop.jpg',
              fit: BoxFit.cover,
            ),
          ),
          // Daha görünür overlay
          Positioned.fill(
            child: Container(color: Colors.black.withOpacity(0.25)),
          ),

          // Form Container
          Center(
            child: SingleChildScrollView(
              child: Container(
                width: size.width * 0.87,
                padding: EdgeInsets.all(26),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.89),
                  borderRadius: BorderRadius.circular(22),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 18,
                      offset: Offset(0, 6),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Icon(Icons.person_add_alt_1, size: 40, color: Colors.red),
                    SizedBox(height: 12),
                    Text(
                      "Kayıt Ol",
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[800],
                      ),
                    ),
                    SizedBox(height: 30),

                    // 1. UserName
                    _buildInput(
                      label: "İsim",
                      controller: _userNameController,
                      icon: Icons.person_outline,
                    ),
                    SizedBox(height: 18),

                    // 2. Email
                    _buildInput(
                      label: "Email",
                      controller: _emailController,
                      icon: Icons.email_outlined,
                    ),
                    SizedBox(height: 18),

                    // 3. Phone
                    _buildInput(
                      label: "Telefon",
                      controller: _phoneController,
                      icon: Icons.phone_android_outlined,
                    ),
                    SizedBox(height: 18),

                    // 4. NotificationType Dropdown
                    DropdownButtonFormField<String>(
                      value: _notificationType,
                      decoration: _inputDecoration("Bildirim Türü"),
                      items: [
                        DropdownMenuItem(value: "MAIL", child: Text("Email")),
                        DropdownMenuItem(value: "SMS", child: Text("SMS")),
                        DropdownMenuItem(
                          value: "BOTH",
                          child: Text("Her İkisi"),
                        ),
                      ],
                      onChanged: (v) => setState(() => _notificationType = v!),
                    ),
                    SizedBox(height: 18),

                    // 5. Password
                    _buildInput(
                      label: "Şifre",
                      controller: _passwordController,
                      icon: Icons.lock_outline,
                      isPassword: true,
                    ),
                    SizedBox(height: 32),

                    // 6. Register Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () async {
                          final request = User(
                            userName: _userNameController.text,
                            email: _emailController.text,
                            phoneNumber: _phoneController.text,
                            notificationType: _notificationType,
                            password: _passwordController.text,
                          );

                          bool success = false;
                          try {
                            await context.read<RegisterProvider>().registerUser(
                              request.toJson(),
                            );
                            success = true;
                          } catch (_) {
                            success = false;
                          }

                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                success
                                    ? "Kayıt başarılı!"
                                    : "Kayıt başarısız!",
                              ),
                              backgroundColor:
                                  success ? Colors.green : Colors.red,
                            ),
                          );

                          if (success) Navigator.pop(context);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          padding: EdgeInsets.symmetric(vertical: 15),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          "Kayıt Ol",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 20),

                    // 7. Login Link
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Text.rich(
                        TextSpan(
                          text: 'Zaten hesabınız var mı? ',
                          style: TextStyle(color: Colors.grey[700]),
                          children: [
                            TextSpan(
                              text: 'Giriş Yap',
                              style: TextStyle(
                                color: Colors.red,
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

  // ---------- CUSTOM COMPONENTS ----------
  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
    );
  }

  Widget _buildInput({
    required String label,
    required TextEditingController controller,
    required IconData icon,
    bool isPassword = false,
  }) {
    return TextField(
      controller: controller,
      obscureText: isPassword,
      decoration: InputDecoration(
        prefixIcon: Icon(icon),
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}
