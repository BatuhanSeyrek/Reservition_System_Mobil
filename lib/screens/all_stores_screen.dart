import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../providers/store_provider.dart';
import '../models/user_model/store_models.dart';
import 'user_chair_screen.dart';
import 'admin_screen/admin_layout.dart';
import 'user_sidebar.dart';

class AllStoresScreen extends StatefulWidget {
  const AllStoresScreen({super.key});

  @override
  State<AllStoresScreen> createState() => _AllStoresScreenState();
}

class _AllStoresScreenState extends State<AllStoresScreen> {
  final FlutterSecureStorage secureStorage = const FlutterSecureStorage();
  String? _cachedToken;

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    final token = await secureStorage.read(key: "token");
    if (token != null && mounted) {
      setState(() => _cachedToken = token);
      context.read<StoreProvider>().fetchStores(token: token);
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<StoreProvider>();
    // ✅ Favoriye göre sıralanmış listeyi buradan alıyoruz
    final sortedList = provider.sortedStores;

    return AppLayout(
      body:
          provider.isLoading
              ? const Center(
                child: CircularProgressIndicator(color: Color(0xFF0F172A)),
              )
              : RefreshIndicator(
                onRefresh: _loadInitialData,
                child: GridView.builder(
                  padding: const EdgeInsets.only(
                    top: 16,
                    left: 12,
                    right: 12,
                    bottom: 16,
                  ),
                  itemCount: sortedList.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    mainAxisExtent: 210,
                  ),
                  itemBuilder: (context, index) {
                    return _AnimatedStoreCard(
                      // ✅ Sıralanmış listedeki elemanı gönderiyoruz
                      storeData: sortedList[index],
                      index: index,
                      token: _cachedToken ?? "",
                    );
                  },
                ),
              ),
      bottomBar: const UserBottomBar(currentIndex: 0),
    );
  }
}

class _AnimatedStoreCard extends StatefulWidget {
  final StoreResponse storeData;
  final int index;
  final String token;

  const _AnimatedStoreCard({
    required this.storeData,
    required this.index,
    required this.token,
  });

  @override
  State<_AnimatedStoreCard> createState() => _AnimatedStoreCardState();
}

class _AnimatedStoreCardState extends State<_AnimatedStoreCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _favController;

  @override
  void initState() {
    super.initState();
    _favController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
  }

  @override
  void dispose() {
    _favController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<StoreProvider>();
    final isFav = provider.isFavorite(widget.storeData.store.id);

    return TweenAnimationBuilder(
      duration: Duration(milliseconds: 300 + (widget.index * 100)),
      tween: Tween<double>(begin: 0, end: 1),
      builder: (context, double value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, 20 * (1 - value)),
            child: child,
          ),
        );
      },
      child: Stack(
        children: [
          GestureDetector(
            onTap:
                () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder:
                        (_) => ChairAvailabilityScreen(
                          adminId: widget.storeData.admin.id,
                        ),
                  ),
                ),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    height: 65,
                    decoration: const BoxDecoration(
                      color: Color.fromARGB(255, 38, 38, 38),
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(20),
                        topRight: Radius.circular(20),
                      ),
                    ),
                    child: Center(
                      child: Icon(
                        FontAwesomeIcons.store,
                        color: Colors.white.withOpacity(0.1),
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
                          widget.storeData.store.storeName,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            color: Color(0xFF0F172A),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "Yönetici: ${widget.storeData.admin.adminName}",
                          style: TextStyle(
                            color: Colors.grey.shade500,
                            fontSize: 11,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 14),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _miniBadge(
                              FontAwesomeIcons.chair,
                              "${widget.storeData.chairs.length}",
                              Colors.blue,
                            ),
                            _miniBadge(
                              FontAwesomeIcons.userCheck,
                              "${widget.storeData.employees.length}",
                              Colors.green,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            top: 6,
            right: 6,
            child: _FavoriteButton(
              isFav: isFav,
              onTap: () {
                if (widget.token.isNotEmpty) {
                  if (!isFav) _favController.forward(from: 0);
                  provider.toggleFavorite(
                    token: widget.token,
                    storeId: widget.storeData.store.id,
                  );
                }
              },
              controller: _favController,
            ),
          ),
        ],
      ),
    );
  }

  Widget _miniBadge(IconData icon, String label, Color color) {
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

class _FavoriteButton extends StatelessWidget {
  final bool isFav;
  final VoidCallback onTap;
  final AnimationController controller;

  const _FavoriteButton({
    required this.isFav,
    required this.onTap,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        if (isFav)
          ScaleTransition(
            scale: Tween<double>(begin: 0.8, end: 2.0).animate(
              CurvedAnimation(parent: controller, curve: Curves.easeOut),
            ),
            child: FadeTransition(
              opacity: Tween<double>(begin: 0.4, end: 0.0).animate(controller),
              child: Container(
                width: 32,
                height: 32,
                decoration: const BoxDecoration(
                  color: Colors.redAccent,
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ),
        GestureDetector(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              transitionBuilder:
                  (child, anim) => ScaleTransition(scale: anim, child: child),
              child: Icon(
                isFav ? FontAwesomeIcons.solidHeart : FontAwesomeIcons.heart,
                key: ValueKey(isFav),
                color: isFav ? Colors.redAccent : Colors.white,
                size: 16,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
