import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rezervasyon_mobil/providers/reference_chair_provider.dart';
import 'package:rezervasyon_mobil/screens/admin_screen/admin_layout.dart';
import 'package:rezervasyon_mobil/screens/admin_screen/admin_sidebar.dart';

class ChairAvailabilityScreen extends StatefulWidget {
  @override
  State<ChairAvailabilityScreen> createState() =>
      _ChairAvailabilityScreenState();
}

class _ChairAvailabilityScreenState extends State<ChairAvailabilityScreen> {
  String name = '';
  String surname = '';
  String phone = '';

  Color primary = const Color(0xFF14183e);
  Color accent = const Color(0xFF9c1132);
  Color softAccent = const Color(0xFF821034);

  @override
  void initState() {
    super.initState();
    Future.microtask(() => context.read<RefenceChairProvider>().loadChairs());
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<RefenceChairProvider>(
      builder: (context, provider, _) {
        if (provider.isLoading) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        return AppLayout(
          body: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                _buildHeader(provider),

                const SizedBox(height: 20),

                Expanded(
                  child:
                      provider.selectedChairName.isEmpty
                          ? _buildEmptyPlaceholder()
                          : ListView(children: _buildChairSlots(provider)),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader(RefenceChairProvider provider) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: const [
          BoxShadow(
            offset: Offset(0, 3),
            blurRadius: 10,
            color: Colors.black12,
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(Icons.calendar_month, size: 35, color: accent),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Koltuk Durumu",
                  style: TextStyle(
                    fontSize: 20,
                    color: primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  "Tarih ve Sandalye seçerek müsaitlikleri görüntüleyin",
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              _styledDropdown(
                value:
                    provider.selectedDate.isEmpty
                        ? null
                        : provider.selectedDate,
                hint: "Tarih",
                items: provider.availableDates,
                onChange: provider.changeDate,
              ),
              const SizedBox(height: 8),
              _styledDropdown(
                value:
                    provider.selectedChairName.isEmpty
                        ? null
                        : provider.selectedChairName,
                hint: "Sandalye",
                items: provider.chairs.map((e) => e.chairName).toList(),
                onChange: provider.changeChairName,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _styledDropdown({
    required String? value,
    required String hint,
    required List<String> items,
    required Function(String) onChange,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(12),
      ),
      child: DropdownButton<String>(
        underline: const SizedBox(),
        hint: Text(hint),
        value: value,
        items:
            items
                .map((d) => DropdownMenuItem(value: d, child: Text(d)))
                .toList(),
        onChanged: (v) => onChange(v!),
      ),
    );
  }

  Widget _buildEmptyPlaceholder() {
    return Center(
      child: Text(
        "Lütfen bir sandalye seçin.",
        style: TextStyle(fontSize: 17, color: Colors.grey.shade600),
      ),
    );
  }

  List<Widget> _buildChairSlots(RefenceChairProvider provider) {
    final chair = provider.chairs.firstWhere(
      (c) => c.chairName == provider.selectedChairName,
    );

    final slots = chair.slots[provider.selectedDate] ?? {};

    return slots.entries.map((e) {
      final time = e.key;
      final available = e.value;

      return Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: available ? Colors.green.shade100 : Colors.red.shade100,
          borderRadius: BorderRadius.circular(14),
          boxShadow: const [
            BoxShadow(
              offset: Offset(0, 2),
              blurRadius: 6,
              color: Colors.black12,
            ),
          ],
        ),
        child: ListTile(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          title: Text(
            time,
            style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w500),
          ),
          trailing: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: available ? Colors.green : Colors.red,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              available ? "Müsait" : "Dolu",
              style: const TextStyle(color: Colors.white),
            ),
          ),
          onTap:
              available
                  ? () => _openReservationDialog(
                    context,
                    provider,
                    chair.chairId,
                    time,
                  )
                  : null,
        ),
      );
    }).toList();
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
      builder: (dctx) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text(
            "Müşteri Bilgileri",
            style: TextStyle(color: softAccent, fontWeight: FontWeight.bold),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _inputField("Ad", (v) => name = v),
              _inputField("Soyad", (v) => surname = v),
              _inputField("Telefon", (v) => phone = v, isPhone: true),
              const SizedBox(height: 8),
              Text("Seçilen Saat: $time"),
            ],
          ),
          actions: [
            TextButton(
              child: const Text("İptal"),
              onPressed: () => Navigator.pop(dctx),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: accent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text("Onayla"),
              onPressed: () async {
                if (name.isEmpty || surname.isEmpty || phone.isEmpty) {
                  ScaffoldMessenger.of(ctx).showSnackBar(
                    const SnackBar(content: Text("Tüm alanları doldurun!")),
                  );
                  return;
                }

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
                      ok
                          ? "Rezervasyon oluşturuldu!"
                          : "Rezervasyon başarısız oldu!",
                    ),
                  ),
                );
              },
            ),
          ],
        );
      },
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
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 10,
          ),
        ),
        onChanged: onChange,
      ),
    );
  }
}
