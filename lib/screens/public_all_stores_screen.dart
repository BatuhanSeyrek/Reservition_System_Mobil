import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:geolocator/geolocator.dart';

// Kendi dosya yollarınıza göre düzenleyin
import 'package:rezervasyon_mobil/core/secure_storage.dart';
import 'package:rezervasyon_mobil/screens/admin_screen/admin_layout.dart';
import 'package:rezervasyon_mobil/screens/user_login.dart';
import '../providers/store_provider.dart';
import '../models/user_model/store_models.dart';
import 'user_sidebar.dart';

class PublicAllStoresScreen extends StatefulWidget {
  const PublicAllStoresScreen({super.key});

  @override
  State<PublicAllStoresScreen> createState() => _PublicAllStoresScreenState();
}

class _PublicAllStoresScreenState extends State<PublicAllStoresScreen> {
  final SecureStorage _myStorage = SecureStorage();
  final FlutterSecureStorage secureStorage = const FlutterSecureStorage();

  String? _cachedToken;
  bool _isLoadingAuth = true;

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  // Sayfa açıldığında hem yetkiyi kontrol eder hem konumu sorar
  Future<void> _initializeData() async {
    await _checkAuth();
    await _askForLocation();
  }

  Future<void> _checkAuth() async {
    final token = await secureStorage.read(key: "token");
    if (mounted) {
      setState(() {
        _cachedToken = token;
        _isLoadingAuth = false;
      });
      context.read<StoreProvider>().fetchStoresPublic();
    }
  }

  // KONUM İZNİ VE KAYIT SÜRECİ
  Future<void> _askForLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) return;

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) return;
      }

      if (permission == LocationPermission.deniedForever) return;

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      // Koordinatları SecureStorage'a kaydet
      await _myStorage.saveLocation(position.latitude, position.longitude);
      print("Konum başarıyla kaydedildi: ${position.latitude}");
    } catch (e) {
      print("Konum hatası: $e");
    }
  }

  void _showLoginPopup() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            title: const Icon(
              Icons.lock_person_rounded,
              size: 50,
              color: Color(0xFF0F172A),
            ),
            content: const Text(
              "Bu özelliği kullanmak için giriş yapmalısınız.",
              textAlign: TextAlign.center,
              style: TextStyle(fontWeight: FontWeight.w500),
            ),
            actionsAlignment: MainAxisAlignment.center,
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text(
                  "Vazgeç",
                  style: TextStyle(color: Colors.grey),
                ),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 42, 42, 43),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => UserLogin()),
                  );
                },
                child: const Text(
                  "Giriş Yap",
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<StoreProvider>();
    final bool isGuest = _cachedToken == null || _cachedToken!.isEmpty;

    return Stack(
      children: [
        AppLayout(
          bottomBar: const UserBottomBar(currentIndex: 0),
          body:
              _isLoadingAuth || provider.isLoading
                  ? const Center(
                    child: CircularProgressIndicator(color: Color(0xFF0F172A)),
                  )
                  : RefreshIndicator(
                    onRefresh: _initializeData,
                    child: GridView.builder(
                      padding: const EdgeInsets.all(12),
                      itemCount: provider.sortedStores.length,
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            mainAxisExtent: 210,
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 12,
                          ),
                      itemBuilder: (context, index) {
                        return _StoreCard(
                          storeData: provider.sortedStores[index],
                        );
                      },
                    ),
                  ),
        ),

        // GUEST KALKANI: Misafirse her yer kilitli ve popup açar
        if (isGuest && !_isLoadingAuth)
          Positioned.fill(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: _showLoginPopup,
              child: Container(color: Colors.transparent),
            ),
          ),
      ],
    );
  }
}

class _StoreCard extends StatelessWidget {
  final StoreResponse storeData;
  const _StoreCard({required this.storeData});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 65,
            width: double.infinity,
            decoration: const BoxDecoration(
              color: Color(0xFF1E293B),
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: const Center(
              child: Icon(
                FontAwesomeIcons.store,
                color: Colors.white10,
                size: 30,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  storeData.store.storeName,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  "Yönetici: ${storeData.admin.adminName}",
                  style: const TextStyle(fontSize: 11, color: Colors.grey),
                ),
                const SizedBox(height: 14),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _badge(
                      FontAwesomeIcons.chair,
                      "${storeData.chairs.length}",
                      Colors.blue,
                    ),
                    _badge(
                      FontAwesomeIcons.userCheck,
                      "${storeData.employees.length}",
                      Colors.green,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _badge(IconData icon, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        children: [
          Icon(icon, size: 10, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
