import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:intl/intl.dart';
import 'package:rezervasyon_mobil/core/app_colors.dart';

import '../providers/reservation_provider.dart';
import '../models/reservation_model.dart';
import 'admin_screen/admin_layout.dart';
import 'user_sidebar.dart';

class ReservationUpdateDeleteScreen extends StatefulWidget {
  const ReservationUpdateDeleteScreen({Key? key}) : super(key: key);

  @override
  State<ReservationUpdateDeleteScreen> createState() =>
      _ReservationUpdateDeleteScreenState();
}

class _ReservationUpdateDeleteScreenState
    extends State<ReservationUpdateDeleteScreen> {
  final _storage = const FlutterSecureStorage();

  Reservation? editing;
  int? chairId;
  DateTime? date;
  TimeOfDay? time;
  String? token;
  bool _loaded = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_loaded) {
      _loaded = true;
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        token ??= await _storage.read(key: 'token');
        if (token == null) return;

        final p = context.read<ReservationUserProvider>();
        try {
          await p.loadReservations(token!);
          await p.loadStores(token!);
        } catch (e) {
          debugPrint("📍 Yükleme Hatası: $e");
        }
      });
    }
  }

  bool _isPastReservation(Reservation r) {
    try {
      final dt = DateTime.parse('${r.reservationDate} ${r.startTime}');
      return dt.isBefore(DateTime.now());
    } catch (e) {
      return false;
    }
  }

  Future<void> _edit(Reservation r) async {
    final p = context.read<ReservationUserProvider>();
    setState(() {
      editing = r;
      chairId = r.chairId;
      date = DateTime.parse(r.reservationDate);
      time = _parseTime(r.startTime);
    });
    await p.loadChairs(token!, r.storeId);
  }

  Future<void> _update() async {
    if (editing == null || date == null || time == null) return;
    try {
      await context
          .read<ReservationUserProvider>()
          .updateReservation(token!, editing!.id, {
            'storeId': editing!.storeId,
            'chairId': chairId,
            'reservationDate': DateFormat('yyyy-MM-dd').format(date!),
            'startTime': _formatTime(time!),
          });
      _cancelEdit();
      await context.read<ReservationUserProvider>().loadReservations(token!);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Randevu güncellendi!"),
            backgroundColor: AppColors.primaryGreen,
          ),
        );
      }
    } catch (e) {
      _cancelEdit();
      await context.read<ReservationUserProvider>().loadReservations(token!);
    }
  }

  void _cancelEdit() {
    setState(() {
      editing = null;
      chairId = null;
      date = null;
      time = null;
    });
    context.read<ReservationUserProvider>().clearChairs();
  }

  @override
  Widget build(BuildContext context) {
    final p = context.watch<ReservationUserProvider>();
    return AppLayout(
      body: editing == null ? _buildListView(p) : _buildEditView(p),
      bottomBar: const UserBottomBar(currentIndex: 1),
    );
  }

  // --- 1. LİSTE GÖRÜNÜMÜ ---
  Widget _buildListView(ReservationUserProvider p) {
    final reservations = p.reservations.reversed.take(7).toList();

    if (reservations.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.calendar_today_outlined,
              size: 60,
              color: Colors.grey.shade300,
            ),
            const SizedBox(height: 16),
            const Text(
              "Randevunuz bulunmuyor.",
              style: TextStyle(color: Colors.grey, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: reservations.length,
      itemBuilder: (_, i) {
        final r = reservations[i];
        final isPast = _isPastReservation(r);
        return isPast ? _buildPastCard(r) : _buildActiveCard(r, p);
      },
    );
  }

  // 🏛️ GEÇMİŞ RANDEVU TASARIMI (Daha Soft)
  Widget _buildPastCard(Reservation r) {
    return Opacity(
      opacity: 0.7,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.history_rounded,
                color: Colors.grey,
                size: 20,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    r.storeName,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: AppColors.darkGrey,
                    ),
                  ),
                  Text(
                    "${DateFormat('dd.MM.yyyy').format(DateTime.parse(r.reservationDate))} - ${_formatStringTime(r.startTime)}",
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
            ),
            const Text(
              "BİTTİ",
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w900,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ⚡ AKTİF RANDEVU TASARIMI (Premium Yeşil Temalı)
  Widget _buildActiveCard(Reservation r, ReservationUserProvider p) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.darkGrey.withOpacity(0.05),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: IntrinsicHeight(
          child: Row(
            children: [
              Container(width: 6, color: AppColors.primaryGreen),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              r.storeName,
                              style: const TextStyle(
                                fontWeight: FontWeight.w900,
                                fontSize: 17,
                                color: AppColors.darkGrey,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                _infoChip(
                                  Icons.calendar_today_rounded,
                                  DateFormat(
                                    'dd.MM.yyyy',
                                  ).format(DateTime.parse(r.reservationDate)),
                                ),
                                const SizedBox(width: 12),
                                _infoChip(
                                  Icons.access_time_filled_rounded,
                                  _formatStringTime(r.startTime),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      _actionButton(
                        Icons.edit_rounded,
                        Colors.blueAccent,
                        () => _edit(r),
                      ),
                      const SizedBox(width: 8),
                      _actionButton(
                        Icons.delete_sweep_rounded,
                        Colors.redAccent,
                        () async {
                          await p.deleteReservation(token!, r.id);
                          await p.loadReservations(token!);
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --- DÜZENLEME GÖRÜNÜMÜ (Modernize Edildi) ---
  Widget _buildEditView(ReservationUserProvider p) {
    return Container(
      width: double.infinity,
      color: AppColors.background,
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Container(
            constraints: const BoxConstraints(maxWidth: 450),
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(35),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.06),
                  blurRadius: 30,
                  offset: const Offset(0, 15),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.primaryGreen.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.edit_calendar_rounded,
                    size: 40,
                    color: AppColors.primaryGreen,
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  "Randevuyu Düzenle",
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    color: AppColors.darkGrey,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  editing?.storeName ?? "",
                  style: const TextStyle(
                    color: AppColors.primaryGreen,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 35),
                _buildModernDropdown(
                  label: "Hizmet Koltuğu",
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<int>(
                      value: chairId,
                      isExpanded: true,
                      borderRadius: BorderRadius.circular(20),
                      items:
                          p.chairs
                              .map(
                                (c) => DropdownMenuItem(
                                  value: c.id,
                                  child: Text(
                                    c.chairName,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              )
                              .toList(),
                      onChanged: (v) => setState(() => chairId = v),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: InkWell(
                        onTap: () async {
                          DateTime? picked = await showDatePicker(
                            context: context,
                            initialDate: date!,
                            firstDate: DateTime.now(),
                            lastDate: DateTime.now().add(
                              const Duration(days: 30),
                            ),
                          );
                          if (picked != null) setState(() => date = picked);
                        },
                        child: _buildValueBox(
                          "Tarih",
                          DateFormat('dd.MM.yyyy').format(date!),
                          Icons.calendar_month_rounded,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: InkWell(
                        onTap: () async {
                          TimeOfDay? picked = await showTimePicker(
                            context: context,
                            initialTime: time!,
                          );
                          if (picked != null) setState(() => time = picked);
                        },
                        child: _buildValueBox(
                          "Saat",
                          _formatTime(time!),
                          Icons.access_time_filled_rounded,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 40),
                _buildConfirmButton(),
                TextButton(
                  onPressed: _cancelEdit,
                  child: const Text(
                    "Vazgeç",
                    style: TextStyle(
                      color: Colors.grey,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // --- YARDIMCI WIDGETLAR ---

  Widget _infoChip(IconData icon, String label) {
    return Row(
      children: [
        Icon(icon, size: 14, color: AppColors.primaryGreen),
        const SizedBox(width: 4),
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Colors.blueGrey,
          ),
        ),
      ],
    );
  }

  Widget _actionButton(IconData icon, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Icon(icon, color: color, size: 22),
      ),
    );
  }

  Widget _buildModernDropdown({required String label, required Widget child}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.grey,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: AppColors.background.withOpacity(0.5),
            borderRadius: BorderRadius.circular(16),
          ),
          child: child,
        ),
      ],
    );
  }

  Widget _buildValueBox(String label, String value, IconData icon) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.grey,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.background.withOpacity(0.5),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              Icon(icon, size: 18, color: AppColors.primaryGreen),
              const SizedBox(width: 8),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w900,
                  color: AppColors.darkGrey,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildConfirmButton() {
    return SizedBox(
      width: double.infinity,
      height: 58,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryGreen,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
        ),
        onPressed: _update,
        child: const Text(
          "GÜNCELLEMEYİ ONAYLA",
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w900,
            letterSpacing: 0.5,
          ),
        ),
      ),
    );
  }

  String _formatStringTime(String t) {
    try {
      final parts = t.split(':');
      return "${parts[0].padLeft(2, '0')}:${parts[1].padLeft(2, '0')}";
    } catch (e) {
      return t;
    }
  }

  TimeOfDay _parseTime(String t) {
    final p = t.split(':');
    return TimeOfDay(hour: int.parse(p[0]), minute: int.parse(p[1]));
  }

  String _formatTime(TimeOfDay t) =>
      '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';
}
