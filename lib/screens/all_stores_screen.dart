import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:rezervasyon_mobil/providers/store_provider.dart';
import 'package:rezervasyon_mobil/models/user_model/store_models.dart';
import 'package:rezervasyon_mobil/screens/user_chair_screen.dart';
import 'package:rezervasyon_mobil/screens/user_sidebar.dart';
import 'package:rezervasyon_mobil/screens/admin_screen/admin_layout.dart';

class AllStoresScreen extends StatefulWidget {
  const AllStoresScreen({super.key});

  @override
  State<AllStoresScreen> createState() => _AllStoresScreenState();
}

class _AllStoresScreenState extends State<AllStoresScreen> {
  @override
  Widget build(BuildContext context) {
    final provider = context.watch<StoreProvider>();
    final stores = provider.sortedStores;

    return AppLayout(
      bottomBar: const UserBottomBar(currentIndex: 0),
      body: Column(
        children: [
          _FilterBar(provider),
          Expanded(
            child:
                provider.isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : stores.isEmpty
                    ? const _EmptyState()
                    : GridView.builder(
                      padding: const EdgeInsets.all(14),
                      itemCount: stores.length,
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 14,
                            mainAxisSpacing: 14,
                            mainAxisExtent: 245,
                          ),
                      itemBuilder: (_, i) => _StoreCard(store: stores[i]),
                    ),
          ),
        ],
      ),
    );
  }
}

/* ================= FILTER BAR ================= */
class _FilterBar extends StatelessWidget {
  final StoreProvider provider;
  const _FilterBar(this.provider);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
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
            icon: const Icon(Icons.restart_alt, color: Colors.blueGrey),
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
    return DropdownButtonFormField<String>(
      value: value,
      hint: Text(hint, style: const TextStyle(fontSize: 13)),
      items:
          items.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
      onChanged: onChanged,
      decoration: InputDecoration(
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 10,
          vertical: 10,
        ),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}

/* ================= STORE CARD ================= */
class _StoreCard extends StatelessWidget {
  final StoreResponse store;
  const _StoreCard({required this.store});

  @override
  Widget build(BuildContext context) {
    final isFav = context.select<StoreProvider, bool>(
      (p) => p.isFavorite(store.store.id),
    );

    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ChairAvailabilityScreen(adminId: store.admin.id),
          ),
        );
      },
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
                Container(
                  height: 44,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFF1E293B), Color(0xFF334155)],
                    ),
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(18),
                    ),
                  ),
                  child: const Center(
                    child: Icon(
                      FontAwesomeIcons.store,
                      color: Colors.white70,
                      size: 18,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        store.store.storeName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        store.admin.adminName,
                        style: const TextStyle(
                          fontSize: 11,
                          color: Colors.blueGrey,
                        ),
                      ),
                      if (store.address != null) ...[
                        const SizedBox(height: 6),
                        _LocationChip(
                          "${store.address!.city} / ${store.address!.district}",
                        ),
                      ],
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          _IconCount(
                            icon: FontAwesomeIcons.chair,
                            count: store.chairs.length,
                          ),
                          const Spacer(),
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
          Positioned(
            top: 8,
            right: 8,
            child: GestureDetector(
              onTap:
                  () => context.read<StoreProvider>().toggleFavorite(
                    store.store.id,
                  ),
              child: CircleAvatar(
                radius: 15,
                backgroundColor: isFav ? Colors.white : Colors.black26,
                child: Icon(
                  isFav ? FontAwesomeIcons.solidHeart : FontAwesomeIcons.heart,
                  size: 14,
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

/* ================= HELPERS ================= */
class _IconCount extends StatelessWidget {
  final IconData icon;
  final int count;
  const _IconCount({required this.icon, required this.count});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 14, color: Colors.blueGrey),
        const SizedBox(width: 4),
        Text(
          "$count",
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
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
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.redAccent.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            FontAwesomeIcons.locationDot,
            size: 10,
            color: Colors.redAccent,
          ),
          const SizedBox(width: 4),
          Flexible(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 10,
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
          Icon(FontAwesomeIcons.mapLocationDot, size: 50, color: Colors.grey),
          SizedBox(height: 10),
          Text(
            "Bu filtreye uygun işletme bulunamadı",
            style: TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }
}
