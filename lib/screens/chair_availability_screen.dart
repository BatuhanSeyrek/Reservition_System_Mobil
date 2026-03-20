import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rezervasyon_mobil/core/app_colors.dart';
import 'package:rezervasyon_mobil/providers/reference_chair_provider.dart';
import 'package:rezervasyon_mobil/screens/admin_screen/admin_layout.dart';

class ChairAvailabilityScreen extends StatefulWidget {
  @override
  State<ChairAvailabilityScreen> createState() =>
      _ChairAvailabilityScreenState();
}

class _ChairAvailabilityScreenState extends State<ChairAvailabilityScreen> {
  String name = '';
  String surname = '';
  String phone = '';

  @override
  void initState() {
    super.initState();
    Future.microtask(() async {
      final provider = context.read<RefenceChairProvider>();
      await provider.loadChairs();

      // Otomatik ilk sandalyeyi seçme mantığı
      if (provider.chairs.isNotEmpty && provider.selectedChairName.isEmpty) {
        provider.changeChairName(provider.chairs.first.chairName);
      }
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

  @override
  Widget build(BuildContext context) {
    return Consumer<RefenceChairProvider>(
      builder: (context, provider, _) {
        if (provider.isLoading) {
          return const Scaffold(
            backgroundColor: AppColors.background,
            body: Center(
              child: CircularProgressIndicator(color: AppColors.primaryGreen),
            ),
          );
        }

        return AppLayout(
          body: Column(
            children: [
              _buildHeaderCard(provider),

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
                            provider.chairs.isEmpty
                                ? _buildNoChairPlaceholder()
                                : provider.selectedChairName.isEmpty
                                ? const Center(
                                  child: CircularProgressIndicator(
                                    color: AppColors.primaryGreen,
                                  ),
                                )
                                : ListView(
                                  physics: const BouncingScrollPhysics(),
                                  children: _buildChairSlots(provider),
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
    );
  }

  Widget _buildHeaderCard(RefenceChairProvider provider) {
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
                    Icons.event_seat_rounded,
                    color: AppColors.primaryGreen,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                const Text(
                  "Koltuk Durumu",
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
                    provider.selectedDate.isEmpty
                        ? null
                        : provider.selectedDate,
                    provider.availableDates,
                    provider.changeDate,
                    isDate: true,
                    icon: Icons.calendar_today_rounded,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _buildSmallDropdown(
                    provider.selectedChairName.isEmpty
                        ? null
                        : provider.selectedChairName,
                    provider.chairs.map((e) => e.chairName).toList(),
                    provider.changeChairName,
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

  Widget _buildSmallDropdown(
    String? val,
    List<String> items,
    Function(String) onChange, {
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
                onChanged: (v) => onChange(v!),
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildChairSlots(RefenceChairProvider provider) {
    if (provider.selectedChairName.isEmpty) return [];

    final chair = provider.chairs.firstWhere(
      (c) => c.chairName == provider.selectedChairName,
      orElse: () => provider.chairs.first,
    );
    final slots = chair.slots[provider.selectedDate] ?? {};

    // --- ZAMAN KONTROLÜ MANTIĞI ---
    DateTime now = DateTime.now();
    String todayStr = now.toString().split(' ')[0]; // yyyy-MM-dd
    bool isToday = provider.selectedDate == todayStr;
    String currentTime =
        "${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}";

    return slots.entries.map((e) {
      final time = e.key;
      bool isAvailableInDB = e.value;

      // Bugünse ve saati geçmişse 'expired' olur
      bool isExpired = isToday && time.compareTo(currentTime) < 0;
      bool canSelect = isAvailableInDB && !isExpired;

      return Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: InkWell(
          onTap:
              canSelect
                  ? () => _openReservationDialog(
                    context,
                    provider,
                    chair.chairId,
                    time,
                  )
                  : null,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color:
                  canSelect
                      ? AppColors.background.withOpacity(0.4)
                      : Colors.grey.shade100,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color:
                    canSelect
                        ? AppColors.primaryGreen.withOpacity(0.1)
                        : Colors.transparent,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.access_time_rounded,
                  size: 20,
                  color:
                      canSelect ? AppColors.primaryGreen : Colors.grey.shade400,
                ),
                const SizedBox(width: 12),
                Text(
                  time,
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    color:
                        canSelect ? AppColors.darkGrey : Colors.grey.shade400,
                    decoration:
                        isExpired
                            ? TextDecoration.lineThrough
                            : null, // Geçmişse üstünü çiz
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
                        canSelect
                            ? AppColors.primaryGreen
                            : (isExpired
                                ? Colors.orange.shade300
                                : Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    canSelect ? "MÜSAİT" : (isExpired ? "GEÇMİŞ" : "DOLU"),
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 10,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }).toList();
  }

  Widget _buildNoChairPlaceholder() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.chair_alt_rounded, size: 48, color: Colors.grey),
          SizedBox(height: 10),
          Text(
            "Henüz bir sandalye tanımlanmamış.",
            style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  void _openReservationDialog(
    BuildContext ctx,
    RefenceChairProvider provider,
    int chairId,
    String time,
  ) {
    name = '';
    surname = '';
    phone = '';
    showDialog(
      context: ctx,
      builder:
          (dctx) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
            ),
            title: const Text(
              "Müşteri Kaydı",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: AppColors.darkGrey,
              ),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _inputField("Ad", (v) => name = v),
                _inputField("Soyad", (v) => surname = v),
                _inputField("Telefon", (v) => phone = v, isPhone: true),
                const SizedBox(height: 10),
                Text(
                  "Saat: $time",
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryGreen,
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dctx),
                child: const Text(
                  "İptal",
                  style: TextStyle(color: Colors.grey),
                ),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryGreen,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () async {
                  if (name.isEmpty || surname.isEmpty || phone.isEmpty) return;
                  final ok = await provider.makeReservation(
                    chairId: chairId,
                    time: time,
                    name: name,
                    surname: surname,
                    phone: phone,
                  );
                  Navigator.pop(dctx);
                  ScaffoldMessenger.of(ctx).showSnackBar(
                    SnackBar(
                      content: Text(
                        ok ? "Rezervasyon Başarılı" : "Hata Oluştu",
                      ),
                    ),
                  );
                },
                child: const Text(
                  "Onayla",
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
    );
  }

  Widget _inputField(
    String label,
    Function(String) onChange, {
    bool isPhone = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        keyboardType: isPhone ? TextInputType.phone : TextInputType.text,
        decoration: InputDecoration(
          labelText: label,
          filled: true,
          fillColor: AppColors.background.withOpacity(0.5),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
        ),
        onChanged: onChange,
      ),
    );
  }
}
