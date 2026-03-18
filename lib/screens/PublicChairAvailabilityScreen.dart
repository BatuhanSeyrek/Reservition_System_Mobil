import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rezervasyon_mobil/core/app_colors.dart';
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
    setState(() => chairProvider = provider);
  }

  // Tarihi Türk formatına çeviren yardımcı fonksiyon
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
              "Randevu alabilmek için önce giriş yapmanız gerekmektedir.",
              style: TextStyle(color: Colors.black54),
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
                  "Hemen Giriş Yap",
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
      child: Consumer<PublicChairProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading) {
            return const Scaffold(
              backgroundColor: AppColors.background,
              body: Center(
                child: CircularProgressIndicator(color: AppColors.primaryGreen),
              ),
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

          return Scaffold(
            backgroundColor: AppColors.background,
            appBar: AppBar(
              backgroundColor: AppColors.darkGrey,
              elevation: 0,
              leading: IconButton(
                icon: const Icon(
                  Icons.arrow_back_ios_new_rounded,
                  color: AppColors.primaryGreen,
                  size: 22,
                ),
                onPressed: () => Navigator.pop(context),
              ),
              title: const Text(
                "Randevu Seçimi",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            body: Column(
              children: [
                _buildHeaderCard(provider, currentDate, currentChairName),

                // 🔹 SAAT LİSTESİ PANELİ (Taşma sorunu giderildi)
                Expanded(
                  child: Container(
                    width: double.infinity,
                    margin: const EdgeInsets.fromLTRB(
                      20,
                      0,
                      20,
                      20,
                    ), // Alttan 20px boşluk bırakıldı
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(
                        32,
                      ), // Panel köşeleri tamamen yuvarlatıldı
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
                                  ? const Center(
                                    child: Text(
                                      "Seçili tarih için uygun saat bulunamadı.",
                                      style: TextStyle(color: Colors.grey),
                                    ),
                                  )
                                  : ListView.builder(
                                    physics: const BouncingScrollPhysics(),
                                    itemCount: slotsList.length,
                                    itemBuilder: (context, index) {
                                      return _buildSlotItem(
                                        slotsList[index].key,
                                        slotsList[index].value,
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
            bottomNavigationBar: _buildFakeBottomBar(),
          );
        },
      ),
    );
  }

  Widget _buildSlotItem(String time, bool available) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: _showRestrictedAccessAlert,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color:
                available
                    ? AppColors.background.withOpacity(0.4)
                    : Colors.grey.shade50,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color:
                  available
                      ? AppColors.primaryGreen.withOpacity(0.1)
                      : Colors.transparent,
            ),
          ),
          child: Row(
            children: [
              Icon(
                Icons.access_time_rounded,
                size: 20,
                color: available ? AppColors.primaryGreen : Colors.grey,
              ),
              const SizedBox(width: 12),
              Text(
                time,
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                  color: available ? AppColors.darkGrey : Colors.grey,
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
                      available ? AppColors.primaryGreen : Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  available ? "MÜSAİT" : "DOLU",
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
  }

  Widget _buildHeaderCard(
    PublicChairProvider provider,
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
                    currentDate,
                    provider.availableDates,
                    provider.setSelectedDate,
                    isDate: true,
                    icon: Icons.calendar_today_rounded,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _buildSmallDropdown(
                    currentChairName,
                    provider.chairs.map((c) => c.chairName).toList(),
                    provider.setSelectedChair,
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
    Function(String?) onChange, {
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
                onChanged: onChange,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFakeBottomBar() {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      backgroundColor: AppColors.darkGrey,
      selectedItemColor: AppColors.primaryGreen,
      unselectedItemColor: Colors.white54,
      showSelectedLabels: true,
      showUnselectedLabels: true,
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.store_rounded),
          label: 'Keşfet',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.calendar_month_rounded),
          label: 'Randevular',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person_outline_rounded),
          label: 'Profil',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.info_outline_rounded),
          label: 'Yardım',
        ),
      ],
      onTap: (i) => i != 0 ? _showRestrictedAccessAlert() : null,
    );
  }
}
