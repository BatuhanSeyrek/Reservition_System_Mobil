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
          // 🔥 ARKA PLAN (UserLogin ile aynı)
          Container(
            width: size.width,
            height: size.height,
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/barbershop.jpg'),
                fit: BoxFit.cover,
                colorFilter: ColorFilter.mode(
                  Colors.black.withOpacity(0.35),
                  BlendMode.darken,
                ),
              ),
            ),
          ),

          // 🔥 ORTADAKİ FORM (UserLogin ile birebir aynı tasarım)
          Center(
            child: SingleChildScrollView(
              child: Container(
                width: size.width * 0.85,
                padding: EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.9),
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 10,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),

                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(height: 10),

                    // 🔥 Başlık - UserLogin ile aynı stil
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(width: 8),
                        Text(
                          'Reference ID Girişi',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey[800],
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: 30),

                    // 🔥 Reference ID input
                    TextField(
                      controller: referenceCtrl,
                      decoration: InputDecoration(
                        labelText: 'Reference ID',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),

                    SizedBox(height: 30),

                    // 🔥 Giriş Yap butonu (UserLogin ile aynı style)
                    SizedBox(
                      width: double.infinity,
                      child:
                          provider.isLoading
                              ? Center(child: CircularProgressIndicator())
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
                                      SnackBar(
                                        content: Text(
                                          'Reference ID hatalı veya bulunamadı.',
                                        ),
                                      ),
                                    );
                                  }
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.red,
                                  padding: EdgeInsets.symmetric(vertical: 16),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
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

                    SizedBox(height: 20),

                    // 🔥 Kullanıcı Giriş yönlendirme (React sürümündeki gibi)
                    Column(
                      children: [
                        Text(
                          "Kullanıcı olarak giriş yapmak ister misiniz?",
                          style: TextStyle(color: Colors.grey[700]),
                        ),
                        SizedBox(height: 10),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (_) => UserLogin()),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.black87,
                              padding: EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: Text(
                              "Kullanıcı Girişi Yap",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
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
