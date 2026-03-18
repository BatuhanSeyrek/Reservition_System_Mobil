import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:geolocator/geolocator.dart';
import 'package:rezervasyon_mobil/core/app_colors.dart'; // Renk paleti
import 'package:rezervasyon_mobil/screens/admin_screen/admin_sidebar.dart';
import '../../providers/admin_provider/admin_provider.dart';
import '../../models/admin_model/admin_model.dart';
import 'admin_layout.dart';

class OwnerUpdateScreen extends StatefulWidget {
  const OwnerUpdateScreen({super.key});

  @override
  _OwnerUpdateScreenState createState() => _OwnerUpdateScreenState();
}

class _OwnerUpdateScreenState extends State<OwnerUpdateScreen> {
  final _formKey = GlobalKey<FormState>();
  AdminModel? admin;
  bool isLoading = true;
  String password = '';
  bool _showReferenceHint = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      fetchAdminData();
    });
  }

  Future<void> fetchAdminData() async {
    final provider = Provider.of<AdminProvider>(context, listen: false);
    await provider.fetchMyAdmin();

    if (provider.admins.isNotEmpty) {
      final a = provider.admins.first;
      if (!mounted) return;
      setState(() {
        admin = a;
        password = '';
        isLoading = false;
        _showReferenceHint = !a.referenceStatus;
      });

      if (!a.referenceStatus) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          showReferenceModal();
        });
      }
    } else {
      if (!mounted) return;
      setState(() => isLoading = false);
    }
  }

  void showReferenceModal() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
            ),
            title: const Text(
              'Hoş Geldiniz!',
              style: TextStyle(
                fontWeight: FontWeight.w900,
                color: AppColors.darkGrey,
              ),
            ),
            content: const Text(
              'Sistemimize ilk girişinizde Reference ID\'niz bulunmamaktadır. '
              'Bu ID sayesinde müşterileriniz sizi bulacak.\n\n'
              'Önemli: Reference ID girip güncellediğinizde, mağazanızın konumu otomatik olarak kaydedilecektir.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text(
                  'Anladım',
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

  Future<Position?> _getCurrentLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return null;

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return null;
    }
    if (permission == LocationPermission.deniedForever) return null;

    return await Geolocator.getCurrentPosition();
  }

  void handleSubmit() async {
    if (_formKey.currentState!.validate() && admin != null) {
      final provider = Provider.of<AdminProvider>(context, listen: false);
      setState(() => isLoading = true);

      try {
        double lat = admin!.latitude;
        double lng = admin!.longitude;

        if (!admin!.referenceStatus) {
          Position? pos = await _getCurrentLocation();
          if (pos != null) {
            lat = pos.latitude;
            lng = pos.longitude;
          }
        }

        final updatedAdmin = admin!.copyWith(
          password: password.isNotEmpty ? password : '',
          latitude: lat,
          longitude: lng,
        );

        await provider.updateAdmin(updatedAdmin);
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Bilgiler ve konum başarıyla güncellendi.'),
            backgroundColor: AppColors.primaryGreen,
          ),
        );
        fetchAdminData();
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Güncelleme sırasında hata oluştu.'),
            backgroundColor: Colors.redAccent,
          ),
        );
      } finally {
        setState(() => isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const AppLayout(
        body: Center(
          child: CircularProgressIndicator(color: AppColors.primaryGreen),
        ),
      );
    }

    return AppLayout(
      body: Container(
        color: AppColors.background,
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 32),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 500),
              child: Column(
                children: [
                  // 🛡️ Header Alanı
                  _buildHeader(),
                  const SizedBox(height: 32),

                  // 📝 Form Kartı
                  Container(
                    padding: const EdgeInsets.all(28),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(32),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child:
                        admin == null
                            ? const Center(child: Text('Veri bulunamadı.'))
                            : Form(
                              key: _formKey,
                              child: Column(
                                children: [
                                  _buildTextField(
                                    label: 'Yönetici Adı',
                                    initialValue: admin!.adminName,
                                    icon: Icons.badge_outlined,
                                    onChanged:
                                        (value) =>
                                            _updateAdmin(adminName: value),
                                  ),
                                  const SizedBox(height: 16),
                                  _buildTextField(
                                    label: 'İşletme Adı',
                                    initialValue: admin!.storeName,
                                    icon: Icons.store_outlined,
                                    onChanged:
                                        (value) =>
                                            _updateAdmin(storeName: value),
                                  ),
                                  const SizedBox(height: 16),
                                  _buildTextField(
                                    label: 'Telefon Numarası',
                                    initialValue: admin!.phoneNumber,
                                    icon: Icons.phone_android_outlined,
                                    onChanged:
                                        (value) =>
                                            _updateAdmin(phoneNumber: value),
                                  ),
                                  const SizedBox(height: 16),
                                  _buildTextField(
                                    label: 'Reference ID',
                                    initialValue: admin!.referenceId,
                                    icon: Icons.vpn_key_outlined,
                                    readOnly: admin!.referenceStatus,
                                    fillColor:
                                        admin!.referenceStatus
                                            ? AppColors.background
                                            : Colors.white,
                                    onChanged: (value) {
                                      _updateAdmin(referenceId: value);
                                      if (value.isNotEmpty)
                                        setState(
                                          () => _showReferenceHint = false,
                                        );
                                    },
                                  ),
                                  if (_showReferenceHint)
                                    const Padding(
                                      padding: EdgeInsets.only(top: 8, left: 4),
                                      child: Text(
                                        'Reference ID ve Konum bir kere girilebilir.',
                                        style: TextStyle(
                                          color: Colors.orange,
                                          fontSize: 11,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  const SizedBox(height: 16),
                                  _buildTextField(
                                    label: 'Yeni Şifre',
                                    hintText:
                                        'Değişmesin istiyorsanız boş bırakın',
                                    icon: Icons.lock_open_rounded,
                                    obscureText: true,
                                    onChanged: (value) => password = value,
                                    validator: (value) {
                                      if (value != null &&
                                          value.isNotEmpty &&
                                          value.length < 6) {
                                        return 'En az 6 karakter olmalı';
                                      }
                                      return null;
                                    },
                                  ),
                                  const SizedBox(height: 32),
                                  _buildSubmitButton(),
                                ],
                              ),
                            ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      bottomBar: const AdminBottomBar(currentIndex: 3),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.primaryGreen.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.admin_panel_settings_rounded,
            size: 40,
            color: AppColors.primaryGreen,
          ),
        ),
        const SizedBox(height: 16),
        const Text(
          'Profil Ayarları',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w900,
            color: AppColors.darkGrey,
          ),
        ),
        const Text(
          'İşletme ve yönetici bilgilerinizi güncelleyin',
          style: TextStyle(
            color: Colors.grey,
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildTextField({
    required String label,
    required IconData icon,
    String? initialValue,
    String? hintText,
    bool obscureText = false,
    bool readOnly = false,
    Color? fillColor,
    Function(String)? onChanged,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      initialValue: initialValue,
      readOnly: readOnly,
      onChanged: onChanged,
      obscureText: obscureText,
      style: const TextStyle(
        fontWeight: FontWeight.w600,
        color: AppColors.darkGrey,
      ),
      decoration: InputDecoration(
        labelText: label,
        hintText: hintText,
        prefixIcon: Icon(icon, color: AppColors.primaryGreen, size: 20),
        filled: true,
        fillColor: fillColor ?? AppColors.background.withOpacity(0.4),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(
          vertical: 18,
          horizontal: 20,
        ),
      ),
      validator:
          validator ??
          (value) =>
              (value == null || value.isEmpty) ? 'Boş bırakılamaz' : null,
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      height: 58,
      child: ElevatedButton(
        onPressed: handleSubmit,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryGreen,
          foregroundColor: Colors.white,
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
        ),
        child: const Text(
          'GÜNCELLEMELERİ KAYDET',
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w800,
            letterSpacing: 1,
          ),
        ),
      ),
    );
  }

  void _updateAdmin({
    String? adminName,
    String? phoneNumber,
    String? storeName,
    String? referenceId,
  }) {
    if (admin == null) return;
    setState(() {
      admin = admin!.copyWith(
        adminName: adminName ?? admin!.adminName,
        phoneNumber: phoneNumber ?? admin!.phoneNumber,
        storeName: storeName ?? admin!.storeName,
        referenceId: referenceId ?? admin!.referenceId,
      );
    });
  }
}
