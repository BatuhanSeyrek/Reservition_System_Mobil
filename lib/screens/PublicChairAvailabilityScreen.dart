import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rezervasyon_mobil/screens/admin_screen/admin_layout.dart';
import 'package:rezervasyon_mobil/screens/user_login.dart';
import '../../providers/public_chair_provider.dart';

class PublicChairavailabilityscreen extends StatefulWidget {
  final int adminId;

  const PublicChairavailabilityscreen({Key? key, required this.adminId})
    : super(key: key);

  @override
  State<PublicChairavailabilityscreen> createState() =>
      _PublicchairavailabilityscreenState();
}

class _PublicchairavailabilityscreenState
    extends State<PublicChairavailabilityscreen> {
  PublicChairProvider? chairProvider;

  @override
  void initState() {
    super.initState();
    _initProvider();
  }

  Future<void> _initProvider() async {
    final provider = PublicChairProvider(adminId: widget.adminId);
    await provider.fetchChairs();

    if (!mounted) return;
    setState(() {
      chairProvider = provider;
    });
  }

  // 🔒 Giriş zorunlu alert
  void _showRestrictedAccessAlert() {
    showDialog(
      context: context,
      builder:
          (ctx) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            title: const Row(
              children: [
                Icon(Icons.warning_amber_rounded, color: Color(0xFF0F172A)),
                SizedBox(width: 10),
                Text("Giriş Yapmalısın"),
              ],
            ),
            content: const Text(
              "Bu işlemi gerçekleştirmek için lütfen giriş yapın.",
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

  // 🔻 Public fake bottom bar
  Widget _buildFakeBottomBar() {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      backgroundColor: const Color(0xFF1C1C1E),
      currentIndex: 0,
      selectedItemColor: const Color(0xFFB1123C),
      unselectedItemColor: Colors.white,
      onTap: (index) {
        if (index != 0) {
          _showRestrictedAccessAlert();
        }
      },
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

  @override
  Widget build(BuildContext context) {
    if (chairProvider == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return ChangeNotifierProvider.value(
      value: chairProvider!,
      child: Consumer<PublicChairProvider>(
        builder: (context, provider, _) {
          Widget bodyContent;

          if (provider.isLoading) {
            bodyContent = const Center(child: CircularProgressIndicator());
          } else if (provider.error != null) {
            bodyContent = Center(child: Text("Hata: ${provider.error}"));
          } else if (provider.chairs.isEmpty) {
            bodyContent = const Center(child: Text("Hiç koltuk bulunamadı."));
          } else {
            final currentChairName =
                provider.selectedChairName ?? provider.chairs.first.chairName;

            final selectedChair = provider.chairs.firstWhere(
              (c) => c.chairName == currentChairName,
              orElse: () => provider.chairs.first,
            );

            final currentDate = provider.selectedDate;

            final slots =
                (currentDate != null)
                    ? (selectedChair.slots[currentDate] ?? {})
                    : {};

            final slotsList = slots.entries.toList();

            bodyContent = Container(
              color: const Color(0xFFF9F5F9),
              child: Column(
                children: [
                  // 🔹 HEADER
                  Container(
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(
                            Icons.calendar_today_rounded,
                            color: Color(0xFFA81B39),
                            size: 32,
                          ),
                          const SizedBox(width: 16),
                          const Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Koltuk\nDurumu",
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF1A1F3D),
                                    height: 1.2,
                                  ),
                                ),
                                SizedBox(height: 8),
                                Text(
                                  "Tarih ve sandalye seçerek müsaitlikleri görüntüleyin",
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Column(
                            children: [
                              _buildCustomDropdown(
                                value: currentDate,
                                items: provider.availableDates,
                                hint: "Tarih",
                                onChanged: provider.setSelectedDate,
                              ),
                              const SizedBox(height: 10),
                              _buildCustomDropdown(
                                value: currentChairName,
                                items:
                                    provider.chairs
                                        .map((c) => c.chairName)
                                        .toList(),
                                hint: "Sandalye",
                                onChanged: provider.setSelectedChair,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),

                  // 🔹 SLOT LİSTESİ
                  Expanded(
                    child:
                        slots.isEmpty
                            ? const Center(
                              child: Text("Bu tarih için saat bulunamadı."),
                            )
                            : ListView.builder(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 10,
                              ),
                              itemCount: slotsList.length,
                              itemBuilder: (context, index) {
                                final entry = slotsList[index];
                                final time = entry.key;
                                final available = entry.value;

                                return GestureDetector(
                                  onTap: () {
                                    // 🔒 Saat seçimi → Login gerekli
                                    _showRestrictedAccessAlert();
                                  },
                                  child: Container(
                                    margin: const EdgeInsets.only(bottom: 8),
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 12,
                                      horizontal: 16,
                                    ),
                                    decoration: BoxDecoration(
                                      color:
                                          available
                                              ? const Color(0xFFCBECCB)
                                              : const Color(0xFFFFCDD2),
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          time,
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            vertical: 5,
                                            horizontal: 12,
                                          ),
                                          decoration: BoxDecoration(
                                            color:
                                                available
                                                    ? const Color(0xFF4CAF50)
                                                    : const Color(0xFFD32F2F),
                                            borderRadius: BorderRadius.circular(
                                              20,
                                            ),
                                          ),
                                          child: Text(
                                            available ? "Müsait" : "Dolu",
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 13,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                  ),
                ],
              ),
            );
          }

          return AppLayout(body: bodyContent, bottomBar: _buildFakeBottomBar());
        },
      ),
    );
  }

  // 🔽 Dropdown
  Widget _buildCustomDropdown({
    required String? value,
    required List<String> items,
    required Function(String?) onChanged,
    String hint = "Seçiniz",
  }) {
    String? effectiveValue = value;

    if (effectiveValue != null && !items.contains(effectiveValue)) {
      effectiveValue = null;
    }

    if (effectiveValue == null && items.isNotEmpty) {
      effectiveValue = items.first;
    }

    return Container(
      width: 140,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFEEEEEE),
        borderRadius: BorderRadius.circular(12),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: effectiveValue,
          isExpanded: true,
          hint: Text(hint),
          icon: const Icon(Icons.arrow_drop_down),
          items:
              items
                  .map(
                    (item) => DropdownMenuItem(
                      value: item,
                      child: Text(item, overflow: TextOverflow.ellipsis),
                    ),
                  )
                  .toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }
}
