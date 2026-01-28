import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rezervasyon_mobil/screens/chair_availability_screen.dart';
import 'package:rezervasyon_mobil/screens/user_login.dart';
import '../providers/reference_login_provider.dart';

class ReferenceIdLoginScreen extends StatefulWidget {
  @override
  _ReferenceIdLoginScreenState createState() => _ReferenceIdLoginScreenState();
}

class _ReferenceIdLoginScreenState extends State<ReferenceIdLoginScreen> {
  final TextEditingController referenceCtrl = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ReferenceLoginProvider>(context);
    final size = MediaQuery.of(context).size;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: Stack(
        children: [
          // 🔥 ARKA PLAN (Sabit Karartma)
          Container(
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
          ),

          // 🔥 ORTADAKİ FORM (Tam Hizalı ve Kırmızı Tema)
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
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.95),
                  borderRadius: BorderRadius.circular(35),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Başlık ve İkon (Kırmızı Renk Ayarlandı)
                    Column(
                      children: [
                        Icon(
                          Icons.qr_code_scanner,
                          color: Colors.red.shade700,
                          size: 40,
                        ),
                        const SizedBox(height: 10),
                        Text(
                          'Reference ID Girişi',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.w900,
                            color: Colors.blueGrey.shade900,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 35),

                    // 🔥 BELİRGİN TEXTBOX (Kırmızı Fokus ve Gri Dolgu)
                    Container(
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
                        controller: referenceCtrl,
                        style: TextStyle(color: Colors.blueGrey.shade900),
                        decoration: InputDecoration(
                          labelText: 'Reference ID',
                          labelStyle: TextStyle(
                            color: Colors.blueGrey.shade500,
                          ),
                          prefixIcon: const Icon(
                            Icons.vpn_key_outlined,
                            color: Colors.red,
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            vertical: 18,
                            horizontal: 20,
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(18),
                            borderSide: BorderSide(
                              color: Colors.grey.shade300,
                              width: 1.5,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(18),
                            borderSide: BorderSide(
                              color: Colors.red.shade400,
                              width: 2,
                            ),
                          ),
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                    const SizedBox(height: 35),

                    // 🔥 GİRİŞ BUTONU (Kırmızı)
                    SizedBox(
                      width: double.infinity,
                      height: 58,
                      child:
                          provider.isLoading
                              ? const Center(
                                child: CircularProgressIndicator(
                                  color: Colors.red,
                                ),
                              )
                              : ElevatedButton(
                                onPressed: () async {
                                  bool ok = await provider.loginWithReferenceId(
                                    referenceCtrl.text.trim(),
                                  );

                                  if (ok && context.mounted) {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder:
                                            (_) => ChairAvailabilityScreen(),
                                      ),
                                    );
                                  } else {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                          'Reference ID hatalı veya bulunamadı.',
                                        ),
                                      ),
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
                                child: const Text(
                                  'Giriş Yap',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                    ),
                    const SizedBox(height: 25),

                    // 🔥 KULLANICI GİRİŞİ YÖNLENDİRME (Kırmızı Vurgulu Link)
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
}
