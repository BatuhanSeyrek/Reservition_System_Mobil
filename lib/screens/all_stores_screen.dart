import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:rezervasyon_mobil/screens/user_chair_screen.dart';
import '../providers/store_provider.dart';
import 'admin_screen/admin_layout.dart'; // AppLayout

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
      final userToken = await secureStorage.read(key: "token"); // user token

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

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<StoreProvider>();

    return AppLayout(
      body:
          provider.isLoading
              ? const Center(child: CircularProgressIndicator())
              : provider.error != null
              ? Center(child: Text(provider.error!))
              : provider.stores.isEmpty
              ? const Center(child: Text('Hiç mağaza bulunamadı.'))
              : Padding(
                padding: const EdgeInsets.all(16.0),
                child: GridView.builder(
                  itemCount: provider.stores.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 3 / 2,
                  ),
                  itemBuilder: (context, index) {
                    final item = provider.stores[index];

                    return Card(
                      color: Colors.grey[500], // Daha koyu renk
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: InkWell(
                        onTap: () {
                          // Seçilen adminId ile ChairAvailabilityScreen'e git
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder:
                                  (_) => ChairAvailabilityScreen(
                                    adminId: item.admin.id,
                                  ),
                            ),
                          );
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item.store.storeName,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              Text(
                                'Admin: ${item.admin.adminName}',
                                style: const TextStyle(
                                  color: Colors.grey,
                                  fontSize: 13,
                                ),
                              ),
                              const Spacer(),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text('🪑 ${item.chairs.length}'),
                                  Text('👤 ${item.employees.length}'),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
    );
  }
}
