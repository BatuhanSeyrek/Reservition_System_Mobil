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
  int? storeId;
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
        await p.loadReservations(token!);
        await p.loadStores(token!);
      });
    }
  }

  bool _isPastReservation(Reservation r) {
    final dt = DateTime.parse('${r.reservationDate} ${r.startTime}');
    return dt.isBefore(DateTime.now());
  }

  Future<void> _edit(Reservation r) async {
    final p = context.read<ReservationUserProvider>();

    setState(() {
      editing = r;
      storeId = r.storeId;
      chairId = r.chairId;
      date = DateTime.parse(r.reservationDate);
      time = _parseTime(r.startTime);
    });

    await p.loadChairs(token!, r.storeId);
  }

  Future<void> _update() async {
    if (editing == null) return;

    await context
        .read<ReservationUserProvider>()
        .updateReservation(token!, editing!.id, {
          'storeId': storeId,
          'chairId': chairId,
          'reservationDate': _formatDate(date!),
          'startTime': _formatTime(time!),
        });

    _cancelEdit();
    await context.read<ReservationUserProvider>().loadReservations(token!);
  }

  void _cancelEdit() {
    setState(() {
      editing = null;
      storeId = null;
      chairId = null;
      date = null;
      time = null;
    });

    context.read<ReservationUserProvider>().clearChairs();
  }

  @override
  Widget build(BuildContext context) {
    final p = context.watch<ReservationUserProvider>();

    /// =======================
    /// 🔹 LİSTE MODU
    /// =======================
    if (editing == null) {
      final lastFive = p.reservations.reversed.take(5).toList();

      return AppLayout(
        body: ListView.builder(
          padding: const EdgeInsets.all(12),
          itemCount: lastFive.length,
          itemBuilder: (_, i) {
            final r = lastFive[i];
            final isPast = _isPastReservation(r);

            return Container(
              width: double.infinity,
              margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 4,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          r.storeName,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Icon(Icons.calendar_today, size: 16),
                            const SizedBox(width: 4),
                            Flexible(
                              child: Text(
                                DateFormat(
                                  'dd.MM.yyyy',
                                ).format(DateTime.parse(r.reservationDate)),
                                style: const TextStyle(fontSize: 12),
                              ),
                            ),
                            const SizedBox(width: 16),
                            const Icon(Icons.access_time, size: 16),
                            const SizedBox(width: 4),
                            Flexible(
                              child: Text(
                                r.startTime,
                                style: const TextStyle(fontSize: 12),
                              ),
                            ),
                          ],
                        ),
                        if (isPast)
                          const Padding(
                            padding: EdgeInsets.only(top: 4),
                            child: Text(
                              'Geçmiş randevu',
                              style: TextStyle(fontSize: 11, color: Colors.red),
                            ),
                          ),
                      ],
                    ),
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, size: 24), // 🔹 Daha büyük
                        color: Colors.blue,
                        onPressed: isPast ? null : () => _edit(r),
                      ),
                      IconButton(
                        icon: const Icon(
                          Icons.delete,
                          size: 24,
                        ), // 🔹 Daha büyük
                        color: isPast ? Colors.grey : Colors.red,
                        onPressed:
                            isPast
                                ? null
                                : () async {
                                  await context
                                      .read<ReservationUserProvider>()
                                      .deleteReservation(token!, r.id);
                                  await context
                                      .read<ReservationUserProvider>()
                                      .loadReservations(token!);
                                },
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        ),
        bottomBar: const UserBottomBar(currentIndex: 1),
      );
    }

    /// =======================
    /// 🔹 EDIT MODU
    /// =======================
    return AppLayout(
      body: Center(
        child: Card(
          margin: const EdgeInsets.all(16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Randevuyu Düzenle',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),
                DropdownButtonFormField<int>(
                  value: storeId,
                  items:
                      p.stores
                          .map(
                            (s) => DropdownMenuItem(
                              value: s.id,
                              child: Text(s.storeName),
                            ),
                          )
                          .toList(),
                  onChanged: (v) async {
                    storeId = v;
                    chairId = null;
                    await p.loadChairs(token!, v!);
                    setState(() {});
                  },
                  decoration: const InputDecoration(labelText: 'Mağaza Seç'),
                ),
                const SizedBox(height: 14),
                DropdownButtonFormField<int>(
                  value: chairId,
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
                  decoration: const InputDecoration(labelText: 'Koltuk Seç'),
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        readOnly: true,
                        controller: TextEditingController(
                          text: DateFormat('dd.MM.yyyy').format(date!),
                        ),
                        decoration: const InputDecoration(
                          labelText: 'Tarih',
                          prefixIcon: Icon(Icons.calendar_today),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextFormField(
                        readOnly: true,
                        controller: TextEditingController(
                          text: time!.format(context),
                        ),
                        decoration: const InputDecoration(
                          labelText: 'Saat',
                          prefixIcon: Icon(Icons.access_time),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: _update,
                        icon: const Icon(Icons.check),
                        label: const Text('Güncelle'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.grey,
                        ),
                        onPressed: _cancelEdit,
                        icon: const Icon(Icons.close),
                        label: const Text('İptal'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
      bottomBar: const UserBottomBar(currentIndex: 1),
    );
  }

  TimeOfDay _parseTime(String t) {
    final p = t.split(':');
    return TimeOfDay(hour: int.parse(p[0]), minute: int.parse(p[1]));
  }

  String _formatTime(TimeOfDay t) =>
      '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';

  String _formatDate(DateTime d) => DateFormat('dd.MM.yyyy').format(d);
}
