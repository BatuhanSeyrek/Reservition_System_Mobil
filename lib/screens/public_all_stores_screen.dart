import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:rezervasyon_mobil/core/secure_storage.dart';
import 'package:rezervasyon_mobil/screens/PublicChairAvailabilityScreen.dart';
import 'package:rezervasyon_mobil/screens/user_login.dart';
import 'package:rezervasyon_mobil/screens/admin_screen/admin_layout.dart';
import '../providers/store_provider.dart';
import '../models/user_model/store_models.dart';

class PublicAllStoresScreen extends StatefulWidget {
  const PublicAllStoresScreen({super.key});

  @override
  State<PublicAllStoresScreen> createState() => _PublicAllStoresScreenState();
}

class _PublicAllStoresScreenState extends State<PublicAllStoresScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _initializeData();
      }
    });
  }

  Future<void> _initializeData() async {
    final provider = context.read<StoreProvider>();
    await provider.fetchStoresPublic();
    await _handleLocationDiscovery();
  }

  Future<void> _handleLocationDiscovery() async {
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.always ||
          permission == LocationPermission.whileInUse) {
        Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.low,
        );

        if (mounted) {
          await context.read<StoreProvider>().updateLocationFromCoordinates(
            position.latitude,
            position.longitude,
          );
        }
      }
    } catch (e) {
      debugPrint("Konum hatası: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<StoreProvider>();
    final stores = provider.sortedStores;

    return AppLayout(
      bottomBar: _buildFakeBottomBar(),
      body: Column(
        children: [
          _buildLocationPicker(provider),
          Expanded(
            child:
                provider.isLoading
                    ? const Center(
                      child: CircularProgressIndicator(
                        color: Color(0xFFB1123C),
                      ),
                    )
                    : stores.isEmpty
                    ? const Center(child: Text("Bu bölgede dükkan bulunamadı."))
                    : RefreshIndicator(
                      onRefresh: _initializeData,
                      child: GridView.builder(
                        padding: const EdgeInsets.all(12),
                        itemCount: stores.length,
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              mainAxisExtent: 185,
                              crossAxisSpacing: 12,
                              mainAxisSpacing: 12,
                            ),
                        itemBuilder: (context, index) {
                          final storeData = stores[index];
                          return GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder:
                                      (context) =>
                                          PublicChairavailabilityscreen(
                                            adminId: storeData.admin.id,
                                          ),
                                ),
                              );
                            },
                            child: _StoreCard(storeData: storeData),
                          );
                        },
                      ),
                    ),
          ),
        ],
      ),
    );
  }

  Widget _buildLocationPicker(StoreProvider provider) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 8)],
      ),
      child: Row(
        children: [
          Expanded(
            child: _styledDropdown(
              hint: "İl Seç",
              value:
                  provider.selectedCity.isEmpty ? null : provider.selectedCity,
              items: provider.availableCities,
              onChanged: (val) => provider.updateLocationFilter(val!, ""),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _styledDropdown(
              hint: "İlçe Seç",
              value:
                  provider.selectedDistrict.isEmpty
                      ? null
                      : provider.selectedDistrict,
              items: provider.availableDistricts,
              onChanged:
                  (val) => provider.updateLocationFilter(
                    provider.selectedCity,
                    val!,
                  ),
            ),
          ),
          if (provider.selectedCity.isNotEmpty)
            IconButton(
              onPressed: () => provider.clearFilters(),
              icon: const Icon(Icons.refresh, color: Colors.redAccent),
            ),
        ],
      ),
    );
  }

  Widget _styledDropdown({
    required String hint,
    required String? value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return DropdownButtonHideUnderline(
      child: DropdownButton<String>(
        value: value,
        hint: Text(hint, style: const TextStyle(fontSize: 12)),
        isExpanded: true,
        items:
            items
                .map(
                  (e) => DropdownMenuItem(
                    value: e,
                    child: Text(e, style: const TextStyle(fontSize: 12)),
                  ),
                )
                .toList(),
        onChanged: onChanged,
      ),
    );
  }

  Widget _buildFakeBottomBar() {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      backgroundColor: const Color(0xFF1C1C1E),
      selectedItemColor: const Color(0xFFB1123C),
      unselectedItemColor: Colors.white,
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.store), label: 'Mağazalar'),
        BottomNavigationBarItem(
          icon: Icon(Icons.calendar_today),
          label: 'Randevular',
        ),
        BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Kullanıcı'),
      ],
      onTap: (_) => _showRestrictedAccessAlert(),
    );
  }

  void _showRestrictedAccessAlert() {
    showDialog(
      context: context,
      builder:
          (ctx) => AlertDialog(
            title: const Text("Giriş Yapmalısın"),
            content: const Text("Bu özelliği kullanmak için giriş yapın."),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text("Kapat"),
              ),
              ElevatedButton(
                onPressed:
                    () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => UserLogin()),
                    ),
                child: const Text("Giriş Yap"),
              ),
            ],
          ),
    );
  }
}

// ==========================================
// STORE CARD WIDGET (REVİZE EDİLDİ)
// ==========================================
class _StoreCard extends StatelessWidget {
  final StoreResponse storeData;
  const _StoreCard({required this.storeData});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<StoreProvider>();

    // 🔍 KONSOL KONTROLÜ (Hatanın kaynağını görmek için)
    debugPrint("--- KONUM LOGU ---");
    debugPrint(
      "Mağaza: ${storeData.store.storeName} -> Lat: ${storeData.address?.latitude}, Lng: ${storeData.address?.longitude}",
    );
    debugPrint(
      "Kullanıcı Konumu -> Lat: ${provider.userLatitude}, Lng: ${provider.userLongitude}",
    );
    debugPrint("------------------");

    String distanceText = "";

    // Mesafe Hesaplama (0.0 Değilse Hesapla)
    if (provider.userLatitude != null &&
        provider.userLongitude != null &&
        storeData.address?.latitude != null &&
        storeData.address?.longitude != null &&
        // ⚠️ Burası 0 ise hesaplama yapma (5425 km hatasını önler)
        storeData.address!.latitude != 0.0) {
      double distanceInMeters = Geolocator.distanceBetween(
        provider.userLatitude!,
        provider.userLongitude!,
        storeData.address!.latitude,
        storeData.address!.longitude,
      );

      if (distanceInMeters < 5) {
        distanceText = "Buradasınız";
      } else if (distanceInMeters < 1000) {
        distanceText = "${distanceInMeters.toStringAsFixed(0)} m";
      } else {
        distanceText = "${(distanceInMeters / 1000).toStringAsFixed(1)} km";
      }
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 5),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              Container(
                height: 60,
                decoration: const BoxDecoration(
                  color: Color(0xFF1E293B),
                  borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
                ),
                child: const Center(
                  child: Icon(
                    Icons.storefront,
                    color: Colors.white24,
                    size: 30,
                  ),
                ),
              ),
              // Eğer mesafe hesaplanabildiyse badge'i göster
              if (distanceText.isNotEmpty)
                Positioned(
                  top: 6,
                  left: 6,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black87,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          distanceText == "Buradasınız"
                              ? Icons.location_on
                              : Icons.near_me,
                          size: 10,
                          color: Colors.white,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          distanceText,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  storeData.store.storeName,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  storeData.admin.adminName,
                  style: const TextStyle(fontSize: 11, color: Colors.grey),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    const Icon(
                      Icons.location_on,
                      size: 10,
                      color: Colors.redAccent,
                    ),
                    const SizedBox(width: 3),
                    Expanded(
                      child: Text(
                        "${storeData.address?.city} / ${storeData.address?.district}",
                        style: const TextStyle(
                          fontSize: 9,
                          color: Colors.redAccent,
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _infoBadge(Icons.chair_alt, "${storeData.chairs.length}"),
                    _infoBadge(Icons.person, "${storeData.employees.length}"),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoBadge(IconData icon, String label) {
    return Row(
      children: [
        Icon(icon, size: 12, color: Colors.blueGrey),
        const SizedBox(width: 2),
        Text(
          label,
          style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}
