import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

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
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Randevu güncellendi!")));
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

  // --- 1. LİSTE GÖRÜNÜMÜ (7 ÖĞE İLE SINIRLANDIRILDI) ---
  Widget _buildListView(ReservationUserProvider p) {
    // ✅ Listeyi ters çevirip (en yeni en üstte) sadece ilk 7 tanesini alıyoruz
    final reservations = p.reservations.reversed.take(7).toList();

    if (reservations.isEmpty) {
      return const Center(
        child: Text(
          "Randevunuz bulunmuyor.",
          style: TextStyle(color: Colors.grey),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: reservations.length,
      itemBuilder: (_, i) {
        final r = reservations[i];
        final isPast = _isPastReservation(r);

        return isPast ? _buildPastCard(r) : _buildActiveCard(r, p);
      },
    );
  }

  // 🏛️ GEÇMİŞ RANDEVU TASARIMI
  Widget _buildPastCard(Reservation r) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        children: [
          const Icon(Icons.history, color: Colors.grey, size: 24),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  r.storeName,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade600,
                  ),
                ),
                Text(
                  "${DateFormat('dd.MM.yyyy').format(DateTime.parse(r.reservationDate))} - ${_formatStringTime(r.startTime)}",
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
                ),
              ],
            ),
          ),
          const Text(
            "GEÇMİŞ",
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  // ⚡ AKTİF RANDEVU TASARIMI
  Widget _buildActiveCard(Reservation r, ReservationUserProvider p) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.red.withOpacity(0.08),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: IntrinsicHeight(
          child: Row(
            children: [
              Container(width: 6, color: Colors.red.shade600),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              r.storeName,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: Color(0xFF1E293B),
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 8),
                            Wrap(
                              spacing: 12,
                              runSpacing: 4,
                              children: [
                                _infoRow(
                                  Icons.calendar_month_outlined,
                                  DateFormat(
                                    'dd.MM.yyyy',
                                  ).format(DateTime.parse(r.reservationDate)),
                                  false,
                                ),
                                _infoRow(
                                  Icons.access_time_rounded,
                                  _formatStringTime(r.startTime),
                                  false,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(
                          Icons.edit_calendar_rounded,
                          color: Colors.blueAccent,
                        ),
                        onPressed: () => _edit(r),
                      ),
                      IconButton(
                        icon: const Icon(
                          Icons.delete_outline_rounded,
                          color: Colors.redAccent,
                        ),
                        onPressed: () async {
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

  // --- DÜZENLEME GÖRÜNÜMÜ ---
  Widget _buildEditView(ReservationUserProvider p) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      alignment: Alignment.center,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Container(
          width: MediaQuery.of(context).size.width * 0.9,
          constraints: const BoxConstraints(maxWidth: 400),
          padding: const EdgeInsets.all(28),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.95),
            borderRadius: BorderRadius.circular(35),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.edit_calendar_rounded,
                size: 50,
                color: Colors.red.shade700,
              ),
              const SizedBox(height: 12),
              Text(
                "Randevuyu Düzenle",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  color: Colors.blueGrey.shade900,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                editing?.storeName ?? "",
                style: TextStyle(
                  color: Colors.red.shade700,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 25),
              _buildModernDropdown(
                label: "Koltuk Seçin",
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<int>(
                    value: chairId,
                    isExpanded: true,
                    items:
                        p.chairs
                            .map(
                              (c) => DropdownMenuItem(
                                value: c.id,
                                child: Text(c.chairName),
                              ),
                            )
                            .toList(),
                    onChanged: (v) => setState(() => chairId = v),
                  ),
                ),
              ),
              const SizedBox(height: 16),
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
                        Icons.calendar_month,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
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
                        Icons.access_time,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                height: 58,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red.shade600,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                    elevation: 5,
                  ),
                  onPressed: _update,
                  child: const Text(
                    "GÜNCELLEMEYİ ONAYLA",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
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
    );
  }

  // --- UI YARDIMCILARI ---

  Widget _infoRow(IconData icon, String text, bool isPast) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: 16,
          color: isPast ? Colors.grey.shade400 : Colors.red.shade400,
        ),
        const SizedBox(width: 4),
        Text(
          text,
          style: TextStyle(
            fontSize: 13,
            color: isPast ? Colors.grey.shade500 : Colors.blueGrey,
          ),
        ),
      ],
    );
  }

  Widget _buildModernDropdown({required String label, required Widget child}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 8, bottom: 4),
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.grey,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: Colors.grey.shade300),
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
        Padding(
          padding: const EdgeInsets.only(left: 8, bottom: 4),
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.grey,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: Row(
            children: [
              Icon(icon, size: 18, color: Colors.red.shade400),
              const SizedBox(width: 8),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ],
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
