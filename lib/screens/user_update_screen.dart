import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:provider/provider.dart';
import 'package:rezervasyon_mobil/providers/user_provideriki.dart';
import 'package:rezervasyon_mobil/screens/admin_screen/admin_layout.dart';

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
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Bilgiler güncellendi')));
    } catch (_) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Güncelleme hatası')));
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
              color: const Color.fromARGB(255, 232, 232, 232),
              elevation: 6,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    const Text(
                      'Update Your Info',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 24),

                    _input('Name', _userNameController),
                    const SizedBox(height: 16),
                    _input('Email', _emailController),
                    const SizedBox(height: 16),
                    _input('Phone', _phoneController),
                    const SizedBox(height: 16),

                    DropdownButtonFormField<String>(
                      value: _notificationType,
                      decoration: const InputDecoration(
                        labelText: 'Notification Type',
                        border: OutlineInputBorder(),
                      ),
                      items: const [
                        DropdownMenuItem(value: 'MAIL', child: Text('Email')),
                        DropdownMenuItem(value: 'SMS', child: Text('SMS')),
                        DropdownMenuItem(value: 'PUSH', child: Text('Push')),
                      ],
                      onChanged: (v) => setState(() => _notificationType = v!),
                    ),

                    const SizedBox(height: 16),

                    TextField(
                      controller: _passwordController,
                      obscureText: true,
                      decoration: const InputDecoration(
                        labelText: 'Password',
                        hintText: 'Yeni şifre (isteğe bağlı)',
                        border: OutlineInputBorder(),
                      ),
                    ),

                    const SizedBox(height: 28),

                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        onPressed: _submit,
                        child: const Text('Update'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _input(String label, TextEditingController c) {
    return TextField(
      controller: c,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
    );
  }
}
