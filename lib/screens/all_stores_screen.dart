import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:rezervasyon_mobil/screens/user_chair_screen.dart';
import '../providers/store_provider.dart';
import 'admin_screen/admin_layout.dart';
import '../screens/user_sidebar.dart'; // UserBottomBar

class AllStoresScreen extends StatefulWidget {
  const AllStoresScreen({super.key});

  @override
  State<AllStoresScreen> createState() => _AllStoresScreenState();
}

class _AllStoresScreenState extends State<AllStoresScreen> {
  final FlutterSecureStorage secureStorage = const FlutterSecureStorage();

  @override
  void initState() {
    super.initState();
    // Kullanıcı token'ı ile mağazaları çek
    Future.microtask(() async {
      final userToken = await secureStorage.read(key: "token");
      if (userToken != null && userToken.isNotEmpty) {
        context.read<StoreProvider>().fetchStores(token: userToken);
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Kullanıcı token bulunamadı!')),
          );
        }
      }
    });
  }

  // Responsive grid sütun sayısını belirleyen fonksiyon
  int _calculateCrossAxisCount(double width) {
    if (width >= 1200) return 4; // Büyük ekran
    if (width >= 800) return 3; // Tablet
    return 2; // Mobil
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<StoreProvider>();
    final screenWidth = MediaQuery.of(context).size.width;

    return AppLayout(
      body:
          provider.isLoading
              ? const Center(child: CircularProgressIndicator())
              : provider.error != null
              ? Center(child: Text(provider.error!))
              : provider.stores.isEmpty
              ? const Center(child: Text('Hiç mağaza bulunamadı.'))
              : Padding(
                padding: const EdgeInsets.all(12.0),
                child: GridView.builder(
                  physics: const BouncingScrollPhysics(),
                  itemCount: provider.stores.length,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: _calculateCrossAxisCount(screenWidth),
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    mainAxisExtent: 180, // Kart yüksekliği
                  ),
                  itemBuilder: (context, index) {
                    final item = provider.stores[index];
                    return _StoreCard(item: item);
                  },
                ),
              ),
      bottomBar: const UserBottomBar(currentIndex: 0),
    );
  }
}

class _StoreCard extends StatelessWidget {
  final dynamic item;

  const _StoreCard({required this.item});

  @override
  Widget build(BuildContext context) {
    const Color accentColor = Color(0xFF9C1132); // Koyu kırmızı
    const Color softAccentColor = Color(0xFF821034); // Soft kırmızı
    const Color primaryTextColor = Color(0xFF14183E);

    return Material(
      elevation: 6,
      borderRadius: BorderRadius.circular(20),
      shadowColor: Colors.black26,
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ChairAvailabilityScreen(adminId: item.admin.id),
            ),
          );
        },
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
          ),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                item.store.storeName,
                style: const TextStyle(
                  color: primaryTextColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 6),
              Text(
                'Sahibi: ${item.admin.adminName}',
                style: TextStyle(color: Colors.grey[700], fontSize: 14),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const Spacer(),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _InfoBadge(
                    icon: Icons.event_seat,
                    text: '${item.chairs.length}',
                    bgColor: accentColor.withOpacity(0.1),
                    iconColor: accentColor,
                    textColor: accentColor,
                  ),
                  _InfoBadge(
                    icon: Icons.people,
                    text: '${item.employees.length}',
                    bgColor: softAccentColor.withOpacity(0.1),
                    iconColor: softAccentColor,
                    textColor: softAccentColor,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _InfoBadge extends StatelessWidget {
  final IconData icon;
  final String text;
  final Color bgColor;
  final Color iconColor;
  final Color textColor;

  const _InfoBadge({
    required this.icon,
    required this.text,
    required this.bgColor,
    required this.iconColor,
    required this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, color: iconColor, size: 16),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(color: textColor, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
