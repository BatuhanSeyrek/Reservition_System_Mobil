import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:rezervasyon_mobil/core/secure_storage.dart';
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
  final SecureStorage _myStorage = SecureStorage();

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
      debugPrint("Public Konum Hatası: $e");
    }
  }

  void _showLoginAlert() {
    showDialog(
      context: context,
      builder:
          (ctx) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            title: const Row(
              children: [
                Icon(
                  FontAwesomeIcons.circleExclamation,
                  color: Color(0xFF0F172A),
                ),
                SizedBox(width: 10),
                Text("Giriş Yapmalısın"),
              ],
            ),
            content: const Text(
              "Tüm özellikleri kullanabilmek için lütfen giriş yapın.",
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text(
                  "Vazgeç",
                  style: TextStyle(color: Colors.grey),
                ),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0F172A),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
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
                    ? const Center(child: CircularProgressIndicator())
                    : stores.isEmpty
                    ? const Center(child: Text("Bu bölgede dükkan bulunamadı."))
                    : RefreshIndicator(
                      onRefresh: _initializeData,
                      child: GridView.builder(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        itemCount: stores.length,
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              mainAxisExtent:
                                  170, // Kartın toplam yüksekliği daraltıldı
                              crossAxisSpacing: 10,
                              mainAxisSpacing: 10,
                            ),
                        itemBuilder:
                            (context, index) => GestureDetector(
                              onTap: _showLoginAlert,
                              child: _StoreCard(storeData: stores[index]),
                            ),
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
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8),
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
              onChanged: (val) {
                if (val != null) provider.updateLocationFilter(val, "");
              },
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
              onChanged: (val) {
                if (val != null)
                  provider.updateLocationFilter(provider.selectedCity, val);
              },
            ),
          ),
          if (provider.selectedCity.isNotEmpty)
            IconButton(
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
              onPressed: () => provider.clearFilters(),
              icon: const Icon(
                Icons.refresh,
                color: Colors.redAccent,
                size: 20,
              ),
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
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          hint: Text(
            hint,
            style: const TextStyle(fontSize: 11, color: Colors.black54),
          ),
          isExpanded: true,
          icon: const Icon(Icons.keyboard_arrow_down, size: 14),
          items:
              items
                  .map(
                    (e) => DropdownMenuItem(
                      value: e,
                      child: Text(e, style: const TextStyle(fontSize: 11)),
                    ),
                  )
                  .toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }

  Widget _buildFakeBottomBar() {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      backgroundColor: const Color(0xFF1C1C1E),
      currentIndex: 0,
      selectedItemColor: const Color(0xFFB1123C),
      unselectedItemColor: Colors.white,
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.store, size: 20),
          label: 'Mağazalar',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.calendar_today, size: 20),
          label: 'Randevular',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person, size: 20),
          label: 'Kullanıcı',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.info, size: 20),
          label: 'Hakkında',
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
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 50,
            width: double.infinity,
            decoration: const BoxDecoration(
              color: Color(0xFF1E293B),
              borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
            ),
            child: Stack(
              children: [
                const Center(
                  child: Icon(
                    Icons.storefront,
                    color: Colors.white10,
                    size: 28,
                  ),
                ),
                Positioned(
                  top: 5,
                  right: 5,
                  child: Icon(
                    Icons.favorite_border,
                    color: Colors.white.withOpacity(0.5),
                    size: 15,
                  ),
                ),
              ],
            ),
          ),
          // Sadece beyaz alanı etkileyen sıkılaştırılmış Padding
          Padding(
            padding: const EdgeInsets.fromLTRB(
              8,
              4,
              8,
              4,
            ), // Dikey boşluklar 4'e düşürüldü
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  storeData.store.storeName,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                    color: Color(0xFF1E293B),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  storeData.admin.adminName,
                  style: const TextStyle(fontSize: 10, color: Colors.blueGrey),
                ),
                const SizedBox(height: 4), // Bilgi arası boşluk azaltıldı
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 4,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFEAEA),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.location_on,
                        size: 9,
                        color: Colors.redAccent,
                      ),
                      const SizedBox(width: 2),
                      Flexible(
                        child: Text(
                          "${storeData.address?.city ?? ''} / ${storeData.address?.district ?? ''}",
                          style: const TextStyle(
                            color: Colors.redAccent,
                            fontSize: 8,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(
                  height: 4,
                ), // Alt ikonlar ile üst arası boşluk azaltıldı
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _badgeItem(Icons.chair_alt, "${storeData.chairs.length}"),
                    _badgeItem(
                      Icons.person_outline,
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

  Widget _badgeItem(IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 12, color: const Color(0xFF64748B)),
        const SizedBox(width: 2),
        Text(
          text,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 10,
            color: Color(0xFF334155),
          ),
        ),
      ],
    );
  }
}
