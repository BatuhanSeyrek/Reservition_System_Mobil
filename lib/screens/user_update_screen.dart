import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:provider/provider.dart';
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
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Bilgiler başarıyla güncellendi')),
      );
    } catch (_) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Güncelleme sırasında bir hata oluştu')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<UserProvider>();

    if (!_initialized || provider.isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (provider.user == null) {
      return const Scaffold(
        body: Center(child: Text('Kullanıcı bilgisi bulunamadı')),
      );
    }

    return AppLayout(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Card(
              color: const Color.fromARGB(
                255,
                245,
                245,
                245,
              ), // Biraz daha açık bir gri
              elevation: 6,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    const Text(
                      'Bilgilerini Güncelle',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Color.fromARGB(
                          255,
                          255,
                          82,
                          82,
                        ), // Kurumsal mavi
                      ),
                    ),
                    const SizedBox(height: 24),

                    _input('Ad Soyad', _userNameController),
                    const SizedBox(height: 16),
                    _input('E-posta Adresi', _emailController),
                    const SizedBox(height: 16),
                    _input('Telefon Numarası', _phoneController),
                    const SizedBox(height: 16),

                    DropdownButtonFormField<String>(
                      value: _notificationType,
                      decoration: const InputDecoration(
                        labelText: 'Bildirim Tercihi',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.notifications_active_outlined),
                      ),
                      items: const [
                        DropdownMenuItem(value: 'MAIL', child: Text('E-posta')),
                        DropdownMenuItem(value: 'SMS', child: Text('SMS')),
                        DropdownMenuItem(value: 'PUSH', child: Text('Hepsi')),
                      ],
                      onChanged: (v) => setState(() => _notificationType = v!),
                    ),

                    const SizedBox(height: 16),

                    TextField(
                      controller: _passwordController,
                      obscureText: true,
                      decoration: const InputDecoration(
                        labelText: 'Yeni Şifre',
                        hintText: 'Değiştirmek istemiyorsanız boş bırakın',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.lock_outline),
                      ),
                    ),

                    const SizedBox(height: 28),

                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color.fromARGB(
                            255,
                            255,
                            82,
                            82,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: _submit,
                        child: const Text(
                          'Güncelle',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
      bottomBar: const UserBottomBar(currentIndex: 2),
    );
  }

  Widget _input(String label, TextEditingController c) {
    return TextField(
      controller: c,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
        // Label kısmındaki "Label" yazısını düzelttim
      ),
    );
  }
}
