import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:rezervasyon_mobil/providers/store_provider.dart';
import 'package:rezervasyon_mobil/models/user_model/store_models.dart';
import 'package:rezervasyon_mobil/screens/user_chair_screen.dart';
import 'package:rezervasyon_mobil/screens/admin_screen/admin_layout.dart';
import 'package:rezervasyon_mobil/screens/user_sidebar.dart';

class AllStoresScreen extends StatefulWidget {
  const AllStoresScreen({super.key});

  @override
  State<AllStoresScreen> createState() => _AllStoresScreenState();
}

class _AllStoresScreenState extends State<AllStoresScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _setupInitialData());
  }

  Future<void> _setupInitialData() async {
    final provider = context.read<StoreProvider>();
    await provider.initializeProvider();
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
      bottomBar: const UserBottomBar(currentIndex: 0),
      body: Column(
        children: [
          _FilterBar(provider: provider),
          Expanded(
            child:
                provider.isLoading
                    ? const Center(
                      child: CircularProgressIndicator(
                        color: Color(0xFFB1123C),
                      ),
                    )
                    : stores.isEmpty
                    ? const _EmptyState()
                    : RefreshIndicator(
                      onRefresh: _setupInitialData,
                      child: GridView.builder(
                        padding: const EdgeInsets.all(12),
                        itemCount: stores.length,
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              crossAxisSpacing: 12,
                              mainAxisSpacing: 12,
                              mainAxisExtent:
                                  205, // Beyaz boşluğu azaltmak için ideal yükseklik
                            ),
                        itemBuilder: (_, i) => _StoreCard(store: stores[i]),
                      ),
                    ),
          ),
        ],
      ),
    );
  }
}

/* ================= FİLTRELEME ÇUBUĞU ================= */
class _FilterBar extends StatelessWidget {
  final StoreProvider provider;
  const _FilterBar({required this.provider});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: const [BoxShadow(blurRadius: 6, color: Colors.black12)],
      ),
      child: Row(
        children: [
          Expanded(
            child: _Dropdown(
              hint: "İl",
              value:
                  provider.selectedCity.isEmpty ? null : provider.selectedCity,
              items: provider.availableCities,
              onChanged: (v) => provider.updateLocationFilter(v ?? "", ""),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _Dropdown(
              hint: "İlçe",
              value:
                  provider.selectedDistrict.isEmpty
                      ? null
                      : provider.selectedDistrict,
              items: provider.availableDistricts,
              onChanged:
                  (v) => provider.updateLocationFilter(
                    provider.selectedCity,
                    v ?? "",
                  ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.redAccent, size: 22),
            onPressed: () => provider.clearFilters(),
          ),
        ],
      ),
    );
  }
}

class _Dropdown extends StatelessWidget {
  final String hint;
  final String? value;
  final List<String> items;
  final ValueChanged<String?> onChanged;
  const _Dropdown({
    required this.hint,
    required this.value,
    required this.items,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonHideUnderline(
      child: DropdownButton<String>(
        value: value,
        isExpanded: true,
        hint: Text(hint, style: const TextStyle(fontSize: 12)),
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
}

/* ================= MAĞAZA KARTI ================= */
class _StoreCard extends StatelessWidget {
  final StoreResponse store;
  const _StoreCard({required this.store});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<StoreProvider>();
    final isFav = provider.isFavorite(store.store.id);

    // Mesafe Hesaplama
    String distanceText = "";
    if (provider.userLatitude != null &&
        store.address?.latitude != null &&
        store.address!.latitude != 0.0) {
      double distanceInMeters = Geolocator.distanceBetween(
        provider.userLatitude!,
        provider.userLongitude!,
        store.address!.latitude,
        store.address!.longitude,
      );
      distanceText =
          distanceInMeters < 1000
              ? "${distanceInMeters.toStringAsFixed(0)} m"
              : "${(distanceInMeters / 1000).toStringAsFixed(1)} km";
      if (distanceInMeters < 15) distanceText = "Buradasınız";
    }

    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap:
          () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ChairAvailabilityScreen(adminId: store.admin.id),
            ),
          ),
      child: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              boxShadow: const [
                BoxShadow(blurRadius: 8, color: Colors.black12),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Üst Mavi/Lacivert Alan (Kısalmadı, 55 birim sabit)
                Container(
                  height: 55,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFF1E293B), Color(0xFF334155)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(18),
                    ),
                  ),
                  child: const Center(
                    child: Icon(
                      FontAwesomeIcons.store,
                      color: Colors.white24,
                      size: 24,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 8,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        store.store.storeName,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        store.admin.adminName,
                        style: const TextStyle(
                          fontSize: 10,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 6),

                      if (store.address != null)
                        _LocationChip(
                          "${store.address!.city} / ${store.address!.district}",
                        ),

                      const SizedBox(height: 4),

                      // Mesafe Yazısı
                      if (distanceText.isNotEmpty)
                        Row(
                          children: [
                            const Icon(
                              Icons.near_me,
                              size: 10,
                              color: Colors.blueAccent,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              distanceText,
                              style: const TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.bold,
                                color: Colors.blueGrey,
                              ),
                            ),
                          ],
                        ),

                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _IconCount(
                            icon: FontAwesomeIcons.chair,
                            count: store.chairs.length,
                          ),
                          _IconCount(
                            icon: FontAwesomeIcons.userTie,
                            count: store.employees.length,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Favori Butonu
          Positioned(
            top: 8,
            right: 8,
            child: GestureDetector(
              onTap: () => provider.toggleFavorite(store.store.id),
              child: CircleAvatar(
                radius: 14,
                backgroundColor: isFav ? Colors.white : Colors.black26,
                child: Icon(
                  isFav ? FontAwesomeIcons.solidHeart : FontAwesomeIcons.heart,
                  size: 13,
                  color: isFav ? Colors.redAccent : Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/* ================= YARDIMCI BİLEŞENLER ================= */
class _IconCount extends StatelessWidget {
  final IconData icon;
  final int count;
  const _IconCount({required this.icon, required this.count});
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 12, color: Colors.blueGrey),
        const SizedBox(width: 4),
        Text(
          "$count",
          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}

class _LocationChip extends StatelessWidget {
  final String text;
  const _LocationChip(this.text);
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      decoration: BoxDecoration(
        color: Colors.redAccent.withOpacity(0.08),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.location_on, size: 10, color: Colors.redAccent),
          const SizedBox(width: 3),
          Flexible(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 9,
                color: Colors.redAccent,
                fontWeight: FontWeight.w600,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();
  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(FontAwesomeIcons.mapLocationDot, size: 40, color: Colors.grey),
          SizedBox(height: 10),
          Text(
            "Bu bölgede işletme bulunmuyor",
            style: TextStyle(color: Colors.grey, fontSize: 13),
          ),
        ],
      ),
    );
  }
}
