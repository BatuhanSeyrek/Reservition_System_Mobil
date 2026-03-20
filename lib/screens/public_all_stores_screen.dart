import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:rezervasyon_mobil/core/app_colors.dart';
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
      body: Container(
        color: AppColors.background,
        child: Column(
          children: [
            // Profesyonel Filtre Çubuğu
            _FilterBar(provider: provider),
            Expanded(
              child:
                  provider.isLoading
                      ? const Center(
                        child: CircularProgressIndicator(
                          color: AppColors.primaryGreen,
                        ),
                      )
                      : stores.isEmpty
                      ? const _EmptyState()
                      : RefreshIndicator(
                        color: AppColors.primaryGreen,
                        onRefresh: _initializeData,
                        child: GridView.builder(
                          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                          itemCount: stores.length,
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                crossAxisSpacing: 16,
                                mainAxisSpacing: 16,
                                mainAxisExtent: 235,
                              ),
                          itemBuilder: (context, index) {
                            return _StoreCard(store: stores[index]);
                          },
                        ),
                      ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFakeBottomBar() {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      backgroundColor: AppColors.darkGrey,
      selectedItemColor: AppColors.primaryGreen,
      unselectedItemColor: Colors.white54,
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.store_rounded),
          label: 'Mağazalar',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.calendar_today_rounded),
          label: 'Randevular',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person_rounded),
          label: 'Kullanıcı',
        ),
      ],
      onTap: (_) => _showRestrictedAccessAlert(),
    );
  }

  void _showRestrictedAccessAlert() {
    showDialog(
      context: context,
      builder:
          (ctx) => AlertDialog(
            backgroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
            ),
            title: const Text(
              "Giriş Yapın",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            content: const Text(
              "Daha fazla işlem yapabilmek için lütfen hesabınıza giriş yapın.",
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text("Vazgeç"),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryGreen,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () {
                  Navigator.pop(ctx);
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
}

/* ================= PROFESYONEL FİLTRELEME ÇUBUĞU ================= */
class _FilterBar extends StatelessWidget {
  final StoreProvider provider;
  const _FilterBar({required this.provider});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.darkGrey.withOpacity(0.08),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          const Icon(
            Icons.tune_rounded,
            color: AppColors.primaryGreen,
            size: 20,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _Dropdown(
              hint: "İl Seçin",
              value:
                  provider.selectedCity.isEmpty ? null : provider.selectedCity,
              items: provider.availableCities,
              onChanged: (v) => provider.updateLocationFilter(v ?? "", ""),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Container(width: 1, height: 20, color: Colors.grey.shade200),
          ),
          Expanded(
            child: _Dropdown(
              hint: "İlçe Seçin",
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
          if (provider.selectedCity.isNotEmpty)
            IconButton(
              icon: const Icon(
                Icons.refresh_rounded,
                color: AppColors.primaryGreen,
                size: 20,
              ),
              onPressed: () => provider.clearFilters(),
            ),
        ],
      ),
    );
  }
}

/* ================= ÖZEL DROPDOWN BİLEŞENİ ================= */
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
        hint: Text(
          hint,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.grey,
            fontWeight: FontWeight.w500,
          ),
        ),
        icon: const Icon(
          Icons.keyboard_arrow_down_rounded,
          size: 16,
          color: Colors.grey,
        ),
        items:
            items
                .map(
                  (e) => DropdownMenuItem(
                    value: e,
                    child: Text(
                      e,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: AppColors.darkGrey,
                      ),
                    ),
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
    }

    return InkWell(
      onTap:
          () => Navigator.push(
            context,
            MaterialPageRoute(
              builder:
                  (_) => PublicChairavailabilityscreen(adminId: store.admin.id),
            ),
          ),
      borderRadius: BorderRadius.circular(24),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: AppColors.darkGrey.withOpacity(0.06),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          children: [
            Stack(
              children: [
                Container(
                  height: 80,
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [AppColors.darkGrey, Color(0xFF475569)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(24),
                    ),
                  ),
                  child: Center(
                    child: Icon(
                      FontAwesomeIcons.store,
                      color: Colors.white.withOpacity(0.15),
                      size: 32,
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    store.store.storeName,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w900,
                      color: AppColors.darkGrey,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  if (store.address != null)
                    _LocationBadge(text: store.address!.district),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      if (distanceText.isNotEmpty)
                        Row(
                          children: [
                            const Icon(
                              Icons.near_me_rounded,
                              size: 12,
                              color: AppColors.primaryGreen,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              distanceText,
                              style: const TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w900,
                                color: AppColors.primaryGreen,
                              ),
                            ),
                          ],
                        ),
                      _infoBadge(
                        FontAwesomeIcons.chair,
                        "${store.chairs.length}",
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoBadge(IconData icon, String label) {
    return Row(
      children: [
        Icon(icon, size: 10, color: Colors.blueGrey),
        const SizedBox(width: 4),
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w900,
            color: AppColors.darkGrey,
          ),
        ),
      ],
    );
  }
}

class _LocationBadge extends StatelessWidget {
  final String text;
  const _LocationBadge({required this.text});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.primaryGreen.withOpacity(0.08),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 10,
          color: AppColors.primaryGreen,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            FontAwesomeIcons.mapLocationDot,
            size: 50,
            color: Colors.grey.shade300,
          ),
          const SizedBox(height: 20),
          const Text(
            "Seçili bölgede işletme bulunamadı",
            style: TextStyle(
              color: AppColors.darkGrey,
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
