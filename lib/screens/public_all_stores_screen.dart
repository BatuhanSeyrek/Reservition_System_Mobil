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
        color: AppColors.background, // Piramit açık gri zemin
        child: Column(
          children: [
            _buildLocationPicker(provider),
            Expanded(
              child:
                  provider.isLoading
                      ? const Center(
                        child: CircularProgressIndicator(
                          color: AppColors.primaryGreen,
                        ),
                      )
                      : stores.isEmpty
                      ? const Center(
                        child: Text(
                          "Bu bölgede dükkan bulunamadı.",
                          style: TextStyle(color: AppColors.darkGrey),
                        ),
                      )
                      : RefreshIndicator(
                        color: AppColors.primaryGreen,
                        onRefresh: _initializeData,
                        child: GridView.builder(
                          padding: const EdgeInsets.all(12),
                          itemCount: stores.length,
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                mainAxisExtent:
                                    195, // Kart boyutu hafif artırıldı
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
        border: Border.all(color: AppColors.lightGrey),
        boxShadow: [
          BoxShadow(color: AppColors.darkGrey.withOpacity(0.05), blurRadius: 8),
        ],
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
              icon: const Icon(Icons.refresh, color: AppColors.primaryGreen),
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
        hint: Text(
          hint,
          style: const TextStyle(fontSize: 12, color: AppColors.darkGrey),
        ),
        isExpanded: true,
        icon: const Icon(
          Icons.keyboard_arrow_down,
          size: 18,
          color: AppColors.primaryGreen,
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
            title: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.primaryGreen.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.lock_person_rounded,
                    color: AppColors.primaryGreen,
                  ),
                ),
                const SizedBox(width: 12),
                const Text(
                  "Giriş Yapın",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
              ],
            ),
            content: const Text(
              "Daha fazla işlem yapabilmek için lütfen hesabınıza giriş yapın.",
              style: TextStyle(color: Colors.grey),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text(
                  "Vazgeç",
                  style: TextStyle(
                    color: Colors.grey,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryGreen,
                  elevation: 0,
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
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
    );
  }
}

class _StoreCard extends StatelessWidget {
  final StoreResponse storeData;
  const _StoreCard({required this.storeData});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<StoreProvider>();
    String distanceText = "";

    // Mesafe hesaplama mantığı...
    if (provider.userLatitude != null &&
        provider.userLongitude != null &&
        storeData.address?.latitude != null &&
        storeData.address?.longitude != null &&
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
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.lightGrey.withOpacity(0.5)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              Container(
                height: 70,
                decoration: const BoxDecoration(
                  color: AppColors.primaryGreen,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                ),
                child: const Center(
                  child: Icon(
                    Icons.storefront_rounded,
                    color: Colors.white30,
                    size: 35,
                  ),
                ),
              ),
              if (distanceText.isNotEmpty)
                Positioned(
                  top: 8,
                  left: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.darkGrey.withOpacity(0.8),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      distanceText,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  storeData.store.storeName,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: AppColors.darkGrey,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(
                      Icons.location_on_rounded,
                      size: 12,
                      color: AppColors.primaryGreen,
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        "${storeData.address?.district}",
                        style: const TextStyle(
                          fontSize: 10,
                          color: AppColors.primaryGreen,
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _infoBadge(Icons.chair_alt, "${storeData.chairs.length}"),
                    _infoBadge(
                      Icons.person_search_rounded,
                      "${storeData.employees.length}",
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

  Widget _infoBadge(IconData icon, String label) {
    return Row(
      children: [
        Icon(icon, size: 14, color: AppColors.primaryGreen.withOpacity(0.7)),
        const SizedBox(width: 4),
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.bold,
            color: AppColors.darkGrey,
          ),
        ),
      ],
    );
  }
}
