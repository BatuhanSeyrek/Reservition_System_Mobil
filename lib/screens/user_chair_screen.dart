import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:rezervasyon_mobil/core/app_colors.dart';
import 'package:rezervasyon_mobil/screens/admin_screen/admin_layout.dart';
import 'package:rezervasyon_mobil/screens/user_sidebar.dart';
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

  String formatTurkishDate(String dateStr) {
    try {
      DateTime dt = DateTime.parse(dateStr);
      List<String> months = [
        "",
        "Ocak",
        "Şubat",
        "Mart",
        "Nisan",
        "Mayıs",
        "Haziran",
        "Temmuz",
        "Ağustos",
        "Eylül",
        "Ekim",
        "Kasım",
        "Aralık",
      ];
      return "${dt.day} ${months[dt.month]} ${dt.year}";
    } catch (e) {
      return dateStr;
    }
  }

  void _showInactiveAlert() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text(
          "Şu an aktif değil",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.orange.shade800,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (chairProvider == null) {
      return const Scaffold(
        backgroundColor: AppColors.background,
        body: Center(
          child: CircularProgressIndicator(color: AppColors.primaryGreen),
        ),
      );
    }

    return ChangeNotifierProvider.value(
      value: chairProvider!,
      child: Consumer<ChairProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading) {
            return const Scaffold(
              backgroundColor: AppColors.background,
              body: Center(
                child: CircularProgressIndicator(color: AppColors.primaryGreen),
              ),
            );
          }

          if (provider.error != null) {
            return Scaffold(
              body: Center(child: Text("Hata: ${provider.error}")),
            );
          }

          if (provider.chairs.isEmpty) {
            return _buildEmptyStateScaffold(
              "Bu işletmede şu an aktif bir sandalye tanımlanmamıştır.",
            );
          }

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

          return AppLayout(
            bottomBar: const UserBottomBar(currentIndex: 0),
            body: Column(
              children: [
                _buildHeaderCard(provider, currentDate, currentChairName),
                Expanded(
                  child: Container(
                    width: double.infinity,
                    margin: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(32),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 20,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Padding(
                          padding: EdgeInsets.only(left: 4, bottom: 15),
                          child: Text(
                            "Müsaitlik Durumu",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              color: AppColors.darkGrey,
                            ),
                          ),
                        ),
                        Expanded(
                          child:
                              slotsList.isEmpty
                                  ? _buildEmptyContentPlaceholder()
                                  : ListView.builder(
                                    physics: const BouncingScrollPhysics(),
                                    itemCount: slotsList.length,
                                    itemBuilder: (context, index) {
                                      return _buildSlotItem(
                                        context,
                                        provider,
                                        selectedChair.chairId,
                                        selectedChair.chairName,
                                        slotsList[index].key,
                                        slotsList[index].value,
                                        provider.selectedDate ?? "",
                                      );
                                    },
                                  ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSlotItem(
    BuildContext context,
    ChairProvider provider,
    int chairId,
    String chairName,
    String time,
    bool availableInDB,
    String selectedDate,
  ) {
    DateTime now = DateTime.now();
    String todayStr = now.toString().split(' ')[0];
    bool isToday = selectedDate == todayStr;
    String currentTime =
        "${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}";

    bool isExpired = isToday && time.compareTo(currentTime) < 0;
    bool isActive = availableInDB && !isExpired;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap:
            isActive
                ? () => _showReservationDialog(
                  context,
                  provider,
                  chairId,
                  chairName,
                  time,
                )
                : _showInactiveAlert,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color:
                isActive
                    ? AppColors.background.withOpacity(0.4)
                    : Colors.grey.shade100,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color:
                  isActive
                      ? AppColors.primaryGreen.withOpacity(0.1)
                      : Colors.transparent,
            ),
          ),
          child: Row(
            children: [
              Icon(
                Icons.access_time_rounded,
                size: 20,
                color: isActive ? AppColors.primaryGreen : Colors.grey,
              ),
              const SizedBox(width: 12),
              Text(
                time,
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                  color: isActive ? AppColors.darkGrey : Colors.grey,
                  decoration: isExpired ? TextDecoration.lineThrough : null,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(
                  vertical: 6,
                  horizontal: 12,
                ),
                decoration: BoxDecoration(
                  color:
                      isActive
                          ? AppColors.primaryGreen
                          : (isExpired
                              ? Colors.orange.shade300
                              : Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  isActive ? "MÜSAİT" : (isExpired ? "GEÇMİŞ" : "DOLU"),
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 10,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderCard(
    ChairProvider provider,
    String? currentDate,
    String? currentChairName,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 15),
          ],
        ),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.primaryGreen.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.event_available_rounded,
                    color: AppColors.primaryGreen,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                const Text(
                  "Hızlı Planlama",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: AppColors.darkGrey,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 15),
            Row(
              children: [
                Expanded(
                  child: _buildSmallDropdown(
                    val: currentDate,
                    items: provider.availableDates,
                    // 🔥 Hata burada düzeltildi: val geliyorsa provider metodunu çağır
                    onChanged: (val) {
                      if (val != null) provider.setSelectedDate(val);
                    },
                    isDate: true,
                    icon: Icons.calendar_today_rounded,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _buildSmallDropdown(
                    val: currentChairName,
                    items: provider.chairs.map((c) => c.chairName).toList(),
                    // 🔥 Hata burada düzeltildi
                    onChanged: (val) {
                      if (val != null) provider.setSelectedChair(val);
                    },
                    icon: Icons.chair_alt_rounded,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // 🔥 Dropdown yapısı null-safe ve esnek hale getirildi
  Widget _buildSmallDropdown({
    required String? val,
    required List<String> items,
    required Function(String?) onChanged,
    bool isDate = false,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
      decoration: BoxDecoration(
        color: AppColors.background.withOpacity(0.8),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, size: 14, color: AppColors.primaryGreen),
          const SizedBox(width: 6),
          Expanded(
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value:
                    items.contains(val)
                        ? val
                        : (items.isNotEmpty ? items.first : null),
                isExpanded: true,
                icon: const Icon(
                  Icons.arrow_drop_down_rounded,
                  color: AppColors.primaryGreen,
                ),
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.darkGrey,
                  fontWeight: FontWeight.bold,
                ),
                items:
                    items
                        .map(
                          (e) => DropdownMenuItem(
                            value: e,
                            child: Text(
                              isDate ? formatTurkishDate(e) : e,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        )
                        .toList(),
                onChanged:
                    onChanged, // Parametre olarak geçilen fonksiyonu çalıştırır
              ),
            ),
          ),
        ],
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
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
            ),
            title: const Text(
              "Rezervasyonu Onayla",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            content: Text(
              "$chairName için $time saatini rezerve etmek istiyor musunuz?",
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text("Hayır"),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryGreen,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () => Navigator.pop(context, true),
                child: const Text(
                  "Evet",
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
    );

    if (confirmed == true) {
      await provider.reserveSlot(chairId, time);
    }
  }

  Widget _buildEmptyStateScaffold(String message) {
    return AppLayout(
      bottomBar: const UserBottomBar(currentIndex: 0),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(30),
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.event_busy_rounded,
                size: 60,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              "Şu An Aktif Değil",
              style: TextStyle(
                color: AppColors.darkGrey,
                fontSize: 20,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: Text(
                message,
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey.shade500, fontSize: 14),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyContentPlaceholder() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          Icon(Icons.hourglass_empty_rounded, size: 40, color: Colors.grey),
          SizedBox(height: 10),
          Text(
            "Uygun saat bulunamadı.",
            style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
