import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import '../../providers/admin_provider/reservation_provider.dart';
import 'admin_layout.dart';
import 'admin_sidebar.dart';

class AdminDashboardScreen extends StatefulWidget {
  @override
  _AdminDashboardScreenState createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  Map<String, String> search = {"user": "", "employee": "", "chair": ""};

  DateTime? startDate;
  DateTime? endDate;
  bool isTodayActive = false;

  String typedTitle = "";
  final String fullTitle = "Yönetim Paneli";
  Timer? _typingTimer;

  @override
  void initState() {
    super.initState();
    _initializeLocale();
    _startTypingEffect();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ReservationProvider>(
        context,
        listen: false,
      ).fetchReservations();
    });
  }

  void _initializeLocale() async {
    await initializeDateFormatting('tr_TR', null);
  }

  void _startTypingEffect() {
    int i = 0;
    _typingTimer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      if (i < fullTitle.length) {
        if (mounted) setState(() => typedTitle = fullTitle.substring(0, i + 1));
        i++;
      } else {
        timer.cancel();
      }
    });
  }

  @override
  void dispose() {
    _typingTimer?.cancel();
    super.dispose();
  }

  String _formatTRTime(String time) {
    try {
      if (time.contains(':')) {
        final parts = time.split(':');
        return "${parts[0].padLeft(2, '0')}:${parts[1].padLeft(2, '0')}";
      }
      return time;
    } catch (e) {
      return time;
    }
  }

  List filteredReservations(List reservations) {
    return reservations.where((r) {
      if (search["user"]!.isNotEmpty &&
          !r.userName.toString().toLowerCase().contains(
            search["user"]!.toLowerCase(),
          ))
        return false;
      if (search["employee"]!.isNotEmpty &&
          !r.employeeName.toString().toLowerCase().contains(
            search["employee"]!.toLowerCase(),
          ))
        return false;
      if (search["chair"]!.isNotEmpty &&
          !r.chairName.toString().toLowerCase().contains(
            search["chair"]!.toLowerCase(),
          ))
        return false;

      if (startDate != null && endDate != null) {
        final resDate = DateTime.parse(r.reservationDate);
        final resDateOnly = DateTime(resDate.year, resDate.month, resDate.day);
        final startOnly = DateTime(
          startDate!.year,
          startDate!.month,
          startDate!.day,
        );
        final endOnly = DateTime(endDate!.year, endDate!.month, endDate!.day);
        if (!(resDateOnly.isAtLeast(startOnly) &&
            resDateOnly.isAtMost(endOnly)))
          return false;
      }
      return true;
    }).toList();
  }

  void toggleToday() {
    setState(() {
      if (isTodayActive) {
        startDate = null;
        endDate = null;
        isTodayActive = false;
      } else {
        final now = DateTime.now();
        startDate = DateTime(now.year, now.month, now.day);
        endDate = startDate;
        isTodayActive = true;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return AppLayout(
      body: Consumer<ReservationProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading)
            return const Center(child: CircularProgressIndicator());

          final reservations = filteredReservations(provider.reservations);
          final allRes = provider.reservations;
          final todayStr = DateFormat('yyyy-MM-dd').format(DateTime.now());

          // İstatistikler
          int upcoming =
              allRes
                  .where((r) => r.reservationDate.compareTo(todayStr) >= 0)
                  .length;
          int todayCount =
              allRes.where((r) => r.reservationDate.contains(todayStr)).length;
          int totalUsers = allRes.map((r) => r.userName).toSet().length;
          int totalEmployees = allRes.map((r) => r.employeeName).toSet().length;
          int totalChairs = allRes.map((r) => r.chairName).toSet().length;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  typedTitle,
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.1,
                  ),
                ),
                const SizedBox(height: 25),

                // 6 ADET MODERN STAT KARTLARI
                GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 3,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 0.85,
                  children: [
                    _buildStatCard(
                      "Toplam",
                      allRes.length,
                      const Color(0xFF6366f1),
                      Icons.analytics,
                    ),
                    _buildStatCard(
                      "Gelecek",
                      upcoming,
                      const Color(0xFF10b981),
                      Icons.event_available,
                    ),
                    _buildStatCard(
                      "Bugün",
                      todayCount,
                      const Color(0xFFf59e0b),
                      Icons.today,
                    ),
                    _buildStatCard(
                      "Müşteri",
                      totalUsers,
                      const Color(0xFFec4899),
                      Icons.people,
                    ),
                    _buildStatCard(
                      "Personel",
                      totalEmployees,
                      const Color(0xFF8b5cf6),
                      Icons.badge,
                    ),
                    _buildStatCard(
                      "Koltuk",
                      totalChairs,
                      const Color(0xFF06b6d4),
                      Icons.event_seat,
                    ),
                  ],
                ),

                const SizedBox(height: 30),
                _buildSearchFilters(),
                const SizedBox(height: 25),

                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: reservations.length,
                  itemBuilder:
                      (context, index) =>
                          _buildReservationCard(reservations[index]),
                ),
              ],
            ),
          );
        },
      ),
      bottomBar: const AdminBottomBar(currentIndex: 0),
    );
  }

  Widget _buildReservationCard(dynamic r) {
    // SADECE TARİH: Gün Ay Yıl (Örn: 13.01.2026)
    String dateLabel = "";
    try {
      dateLabel = DateFormat(
        'dd.MM.yyyy',
      ).format(DateTime.parse(r.reservationDate));
    } catch (e) {
      dateLabel = r.reservationDate.toString().split("T")[0];
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Column(
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: Colors.indigo.shade50,
                child: const Icon(Icons.person, color: Colors.indigo, size: 26),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      r.userName,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 17,
                        color: Color(0xFF1e293b),
                      ),
                    ),
                    const SizedBox(height: 4),
                    // Aktif rezervasyon durumu kaldırıldı, sadece tarih eklendi
                    Text(
                      dateLabel,
                      style: TextStyle(
                        color: Colors.indigo.shade400,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: Colors.grey),
            ],
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 15),
            child: Divider(height: 1, thickness: 0.6),
          ),
          Row(
            children: [
              _cardDetailItem(
                Icons.access_time_filled,
                "Saat",
                "${_formatTRTime(r.startTime)} - ${_formatTRTime(r.endTime)}",
              ),
              _cardDetailItem(Icons.event_seat_rounded, "Koltuk", r.chairName),
            ],
          ),
          const SizedBox(height: 15),
          Row(
            children: [
              _cardDetailItem(Icons.badge_outlined, "Personel", r.employeeName),
              const Expanded(child: SizedBox()),
            ],
          ),
        ],
      ),
    );
  }

  Widget _cardDetailItem(IconData icon, String label, String value) {
    return Expanded(
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: Colors.indigo.withOpacity(0.05),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 18, color: Colors.indigo.shade400),
          ),
          const SizedBox(width: 10),
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 10,
                    color: Colors.grey,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF334155),
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchFilters() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(child: _miniInput("Müşteri Ara", "user")),
            const SizedBox(width: 12),
            Expanded(child: _miniInput("Personel Ara", "employee")),
          ],
        ),
        const SizedBox(height: 12),
        _miniInput("Koltuk / Alan Ara", "chair"),
        const SizedBox(height: 15),
        GestureDetector(
          onTap: toggleToday,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors:
                    isTodayActive
                        ? [Colors.red.shade400, Colors.red.shade600]
                        : [const Color(0xFF6366f1), const Color(0xFF4f46e5)],
              ),
              borderRadius: BorderRadius.circular(15),
              boxShadow: [
                BoxShadow(
                  color: (isTodayActive ? Colors.red : Colors.indigo)
                      .withOpacity(0.3),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Center(
              child: Text(
                isTodayActive
                    ? "Filtreleri Sıfırla"
                    : "Bugünün Programını Göster",
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _miniInput(String hint, String key) {
    return TextField(
      onChanged: (v) => setState(() => search[key] = v),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
        isDense: true,
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.all(14),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: Colors.grey.shade200),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Colors.indigo, width: 1.5),
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, int value, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: Colors.white, size: 20),
          const SizedBox(height: 8),
          Text(
            value.toString(),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            title,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 10,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

extension DateTimeComparison on DateTime {
  bool isAtLeast(DateTime other) => !isBefore(other);
  bool isAtMost(DateTime other) => !isAfter(other);
}
