import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:rezervasyon_mobil/screens/admin_screen/admin_layout.dart';
import '../../providers/user_chair_provider.dart';

class ChairAvailabilityScreen extends StatefulWidget {
  final int adminId;

  const ChairAvailabilityScreen({Key? key, required this.adminId})
    : super(key: key);

  @override
  State<ChairAvailabilityScreen> createState() =>
      _ChairAvailabilityScreenState();
}

class _ChairAvailabilityScreenState extends State<ChairAvailabilityScreen> {
  final FlutterSecureStorage storage = const FlutterSecureStorage();
  ChairProvider? chairProvider;

  @override
  void initState() {
    super.initState();
    _initProvider();
  }

  Future<void> _initProvider() async {
    final token = await storage.read(key: "token") ?? "";
    final provider = ChairProvider(adminId: widget.adminId, token: token);
    await provider.fetchChairs();

    if (!mounted) return;
    setState(() {
      chairProvider = provider;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (chairProvider == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return ChangeNotifierProvider.value(
      value: chairProvider!,
      child: Consumer<ChairProvider>(
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
                provider.selectedChairName ??
                (provider.chairs.isNotEmpty
                    ? provider.chairs.first.chairName
                    : "");

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
                  // --- 1. SABİT HEADER KISMI ---
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
                          Container(
                            margin: const EdgeInsets.only(top: 5),
                            child: const Icon(
                              Icons.calendar_today_rounded,
                              color: Color(0xFFA81B39),
                              size: 32,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: const [
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
                                  "Tarih ve Sandalye seçerek müsaitlikleri görüntüleyin",
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 10),
                          Column(
                            children: [
                              _buildCustomDropdown(
                                value: currentDate,
                                items: provider.availableDates,
                                hint: "Tarih",
                                onChanged: (val) {
                                  if (val != null)
                                    provider.setSelectedDate(val);
                                },
                              ),
                              const SizedBox(height: 10),
                              _buildCustomDropdown(
                                value: currentChairName,
                                items:
                                    provider.chairs
                                        .map((c) => c.chairName)
                                        .toList(),
                                hint: "Sandalye",
                                onChanged: (val) {
                                  if (val != null)
                                    provider.setSelectedChair(val);
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),

                  // --- 2. KAYDIRILABİLİR LİSTE (DAHA İNCE) ---
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
                                  onTap:
                                      available
                                          ? () => _showReservationDialog(
                                            context,
                                            provider,
                                            selectedChair.chairId,
                                            selectedChair.chairName,
                                            time,
                                          )
                                          : null,
                                  child: Container(
                                    // Margin'i azalttım (Daha yakın duracaklar)
                                    margin: const EdgeInsets.only(bottom: 8),
                                    // Padding'i azalttım (Kutular daha ince olacak)
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 12,
                                      horizontal: 16,
                                    ),
                                    decoration: BoxDecoration(
                                      color:
                                          available
                                              ? const Color(0xFFCBEccB)
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
                                            fontSize:
                                                16, // Fontu biraz küçülttüm
                                            fontWeight: FontWeight.bold,
                                            color: Colors.black87,
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

          return AppLayout(body: bodyContent);
        },
      ),
    );
  }

  // --- YARDIMCI WIDGETLAR ---
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
          hint: Text(hint, style: const TextStyle(fontSize: 12)),
          icon: const Icon(Icons.arrow_drop_down, color: Colors.black54),
          style: const TextStyle(
            color: Colors.black87,
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
          items:
              items.map((item) {
                return DropdownMenuItem(
                  value: item,
                  child: Text(item, overflow: TextOverflow.ellipsis),
                );
              }).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }

  Future<void> _showReservationDialog(
    BuildContext context,
    ChairProvider provider,
    int chairId,
    String chairName,
    String time,
  ) async {
    bool? confirmed = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text("Rezervasyonu Onayla"),
            content: Text(
              "$chairName için $time saatini rezerve etmek istiyor musunuz?",
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text("Hayır"),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text("Evet"),
              ),
            ],
          ),
    );

    if (confirmed == true) {
      await provider.reserveSlot(chairId, time);
    }
  }
}
