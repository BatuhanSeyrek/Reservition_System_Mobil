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

  void _showRestrictedAccessAlert() {
    showDialog(
      context: context,
      builder:
          (ctx) => AlertDialog(
            backgroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
            ),
            title: const Text(
              "Giriş Yapın",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            content: const Text(
              "Randevu alabilmek için önce giriş yapmanız gerekmektedir.",
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text("Vazgeç"),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryGreen,
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
                  style: TextStyle(color: Colors.white),
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

          // 🔥 KRİTİK HATA ÇÖZÜMÜ: Sandalye yoksa direkt şık boş ekranı göster
          if (provider.chairs.isEmpty) {
            return _buildEmptyStateScaffold(
              "Bu işletmede şu an aktif bir hizmet alanı (sandalye) tanımlanmamıştır.",
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
            bottomNavigationBar: _buildFakeBottomBar(),
          );
        },
      ),
    );
  }

  // 🎨 Tasarımla uyumlu tam sayfa Boş Durum
  Widget _buildEmptyStateScaffold(String message) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.darkGrey,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: AppColors.primaryGreen,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Randevu Seçimi",
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: InkWell(
        onTap: _showInactiveAlert,
        child: Center(
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
      ),
    );
  }

  // Panel içindeki küçük boşluk uyarısı
  Widget _buildEmptyContentPlaceholder() {
    return InkWell(
      onTap: _showInactiveAlert,
      child: Center(
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
      ),
    );
  }

  Widget _buildSlotItem(String time, bool availableInDB, String selectedDate) {
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
        onTap: isActive ? _showRestrictedAccessAlert : _showInactiveAlert,
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
