import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rezervasyon_mobil/screens/admin_screen/admin_sidebar.dart';
import '../../providers/admin_provider/admin_provider.dart';
import '../../models/admin_model/admin_model.dart';
import 'admin_layout.dart';

class OwnerUpdateScreen extends StatefulWidget {
  @override
  _OwnerUpdateScreenState createState() => _OwnerUpdateScreenState();
}

class _OwnerUpdateScreenState extends State<OwnerUpdateScreen> {
  final _formKey = GlobalKey<FormState>();
  AdminModel? admin;
  bool isLoading = true;
  String password = '';
  bool _showReferenceHint = false; // Reference ID uyarısı kontrolü

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
      setState(() {
        admin = a;
        password = '';
        isLoading = false;
        _showReferenceHint = !a.referenceStatus; // reference yoksa hint göster
      });

      if (!a.referenceStatus) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          showReferenceModal();
        });
      }
    } else {
      setState(() {
        isLoading = false;
      });
    }
  }

  void showReferenceModal() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (context) => AlertDialog(
            title: Text('Hoşgeldiniz!'),
            content: Text(
              'Sistemimize ilk girişinizde Reference ID\'niz bulunmamaktadır. '
              'Bu ID sayesinde müşterileriniz sizi bulacak. Lütfen bir kere mahsus Reference ID giriniz.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text('Tamam'),
              ),
            ],
          ),
    );
  }

  void handleSubmit() async {
    if (_formKey.currentState!.validate() && admin != null) {
      final provider = Provider.of<AdminProvider>(context, listen: false);

      try {
        final updatedAdmin = AdminModel(
          id: admin!.id,
          adminName: admin!.adminName,
          phoneNumber: admin!.phoneNumber,
          storeName: admin!.storeName,
          chairCount: admin!.chairCount,
          status: admin!.status,
          startTime: admin!.startTime,
          endTime: admin!.endTime,
          password: password.isNotEmpty ? password : '',
          referenceId: admin!.referenceId,
        );

        await provider.updateAdmin(updatedAdmin);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Bilgiler başarıyla güncellendi.')),
        );

        fetchAdminData();
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Güncelleme sırasında hata oluştu.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return AppLayout(
        body: Center(
          child: CircularProgressIndicator(color: Color(0xFF9C1132)),
        ),
      );
    }

    return AppLayout(
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 32),
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: 500),
            child: Card(
              elevation: 4,
              shadowColor: Colors.grey.withOpacity(0.3),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              color: Color(0xFFF5F5F5),
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child:
                    admin == null
                        ? Center(
                          child: Text(
                            'Admin verisi bulunamadı.',
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.grey[700],
                            ),
                          ),
                        )
                        : Form(
                          key: _formKey,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'Profil Güncelleme',
                                style: TextStyle(
                                  fontSize: 26,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF9C1132),
                                ),
                              ),
                              SizedBox(height: 24),

                              // Admin Name
                              _buildTextField(
                                label: 'Admin Name',
                                initialValue: admin!.adminName,
                                onChanged:
                                    (value) => _updateAdmin(adminName: value),
                              ),

                              SizedBox(height: 16),

                              // Password
                              _buildTextField(
                                label: 'Password',
                                initialValue: password,
                                hintText: 'Boş bırakırsanız değişmez',
                                obscureText: true,
                                onChanged: (value) => password = value,
                                validator: (value) {
                                  if (value != null &&
                                      value.isNotEmpty &&
                                      value.length < 6) {
                                    return 'Şifre en az 6 karakter olmalı';
                                  }
                                  return null;
                                },
                              ),

                              SizedBox(height: 16),

                              // Store Name
                              _buildTextField(
                                label: 'Store Name',
                                initialValue: admin!.storeName,
                                onChanged:
                                    (value) => _updateAdmin(storeName: value),
                              ),

                              SizedBox(height: 16),

                              // Phone Number
                              _buildTextField(
                                label: 'Phone Number',
                                initialValue: admin!.phoneNumber,
                                onChanged:
                                    (value) => _updateAdmin(phoneNumber: value),
                              ),

                              SizedBox(height: 16),

                              // Reference ID + hint
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _buildTextField(
                                    label: 'Reference ID',
                                    initialValue: admin!.referenceId,
                                    readOnly: admin!.referenceStatus,
                                    fillColor:
                                        admin!.referenceStatus
                                            ? Color(0xFFE0E0E0)
                                            : Colors.grey[50],
                                    onChanged: (value) {
                                      _updateAdmin(
                                        referenceId: value,
                                        referenceStatus: value.isNotEmpty,
                                      );
                                      if (value.isNotEmpty) {
                                        setState(() {
                                          _showReferenceHint = false;
                                        });
                                      }
                                    },
                                    validator: (value) {
                                      if (!admin!.referenceStatus &&
                                          (value == null || value.isEmpty)) {
                                        return 'Reference ID boş olamaz';
                                      }
                                      return null;
                                    },
                                  ),
                                  if (_showReferenceHint)
                                    Padding(
                                      padding: const EdgeInsets.only(top: 4.0),
                                      child: Text(
                                        'Reference ID sadece bir kere girilebilir.',
                                        style: TextStyle(
                                          color: Colors.redAccent,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ),
                                ],
                              ),

                              SizedBox(height: 24),

                              // Update Button
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton(
                                  onPressed: handleSubmit,
                                  style: ElevatedButton.styleFrom(
                                    padding: EdgeInsets.symmetric(vertical: 16),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    backgroundColor: Color(0xFF821034),
                                  ),
                                  child: Text(
                                    'Güncelle',
                                    style: TextStyle(
                                      fontSize: 18,
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
      ),
      bottomBar: const AdminBottomBar(currentIndex: 3),
    );
  }

  Widget _buildTextField({
    required String label,
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
      decoration: InputDecoration(
        labelText: label,
        hintText: hintText,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        filled: true,
        fillColor: fillColor ?? Colors.grey[50],
      ),
      obscureText: obscureText,
      readOnly: readOnly,
      onChanged: onChanged,
      validator:
          validator ?? (value) => value!.isEmpty ? 'Boş bırakılamaz' : null,
    );
  }

  void _updateAdmin({
    String? adminName,
    String? phoneNumber,
    String? storeName,
    String? referenceId,
    bool? referenceStatus,
  }) {
    if (admin == null) return;
    setState(() {
      admin = AdminModel(
        id: admin!.id,
        adminName: adminName ?? admin!.adminName,
        phoneNumber: phoneNumber ?? admin!.phoneNumber,
        storeName: storeName ?? admin!.storeName,
        chairCount: admin!.chairCount,
        status: admin!.status,
        startTime: admin!.startTime,
        endTime: admin!.endTime,
        referenceId: referenceId ?? admin!.referenceId,
        referenceStatus: referenceStatus ?? admin!.referenceStatus,
      );
    });
  }
}
