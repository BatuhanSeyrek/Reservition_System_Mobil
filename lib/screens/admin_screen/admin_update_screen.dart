import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/admin_provider.dart';
import '../models/admin_model.dart';
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
      });
    } else {
      setState(() {
        isLoading = false;
      });
    }
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
      return AdminLayout(body: Center(child: CircularProgressIndicator()));
    }

    return AdminLayout(
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
              color: Colors.grey[200], // soft gri
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
                                  color: Colors.redAccent, // kırmızı ton
                                ),
                              ),
                              SizedBox(height: 24),

                              // Admin Name
                              TextFormField(
                                initialValue: admin!.adminName,
                                decoration: InputDecoration(
                                  labelText: 'Admin Name',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  filled: true,
                                  fillColor: Colors.grey[50],
                                ),
                                onChanged:
                                    (value) => setState(() {
                                      admin = AdminModel(
                                        id: admin!.id,
                                        adminName: value,
                                        phoneNumber: admin!.phoneNumber,
                                        storeName: admin!.storeName,
                                        chairCount: admin!.chairCount,
                                        status: admin!.status,
                                        startTime: admin!.startTime,
                                        endTime: admin!.endTime,
                                      );
                                    }),
                                validator:
                                    (value) =>
                                        value!.isEmpty
                                            ? 'Boş bırakılamaz'
                                            : null,
                              ),
                              SizedBox(height: 16),

                              // Password
                              TextFormField(
                                initialValue: password,
                                decoration: InputDecoration(
                                  labelText: 'Password',
                                  hintText:
                                      'Şifre sizin güvenliğiniz için görünmüyor',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  filled: true,
                                  fillColor: Colors.grey[50],
                                ),
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
                              TextFormField(
                                initialValue: admin!.storeName,
                                decoration: InputDecoration(
                                  labelText: 'Store Name',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  filled: true,
                                  fillColor: Colors.grey[50],
                                ),
                                onChanged:
                                    (value) => setState(() {
                                      admin = AdminModel(
                                        id: admin!.id,
                                        adminName: admin!.adminName,
                                        phoneNumber: admin!.phoneNumber,
                                        storeName: value,
                                        chairCount: admin!.chairCount,
                                        status: admin!.status,
                                        startTime: admin!.startTime,
                                        endTime: admin!.endTime,
                                      );
                                    }),
                                validator:
                                    (value) =>
                                        value!.isEmpty
                                            ? 'Boş bırakılamaz'
                                            : null,
                              ),
                              SizedBox(height: 16),

                              // Phone Number
                              TextFormField(
                                initialValue: admin!.phoneNumber,
                                decoration: InputDecoration(
                                  labelText: 'Phone Number',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  filled: true,
                                  fillColor: Colors.grey[50],
                                ),
                                onChanged:
                                    (value) => setState(() {
                                      admin = AdminModel(
                                        id: admin!.id,
                                        adminName: admin!.adminName,
                                        phoneNumber: value,
                                        storeName: admin!.storeName,
                                        chairCount: admin!.chairCount,
                                        status: admin!.status,
                                        startTime: admin!.startTime,
                                        endTime: admin!.endTime,
                                      );
                                    }),
                                validator:
                                    (value) =>
                                        value!.isEmpty
                                            ? 'Boş bırakılamaz'
                                            : null,
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
                                    backgroundColor: Colors.redAccent,
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
    );
  }
}
