import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rezervasyon_mobil/core/app_colors.dart';
import '../../providers/admin_provider/chair_provider.dart';
import '../../models/admin_model/chair_model.dart';
import 'admin_layout.dart';
import 'admin_sidebar.dart';

class ChairDeleteUpdate extends StatefulWidget {
  const ChairDeleteUpdate({super.key});

  @override
  _ChairDeleteUpdateState createState() => _ChairDeleteUpdateState();
}

class _ChairDeleteUpdateState extends State<ChairDeleteUpdate> {
  final TextEditingController chairNameController = TextEditingController();
  TimeOfDay? openingTime;
  TimeOfDay? closingTime;

  // Süre Seçenekleri
  final List<Map<String, dynamic>> durationOptions = [
    {'label': '30 Dakika', 'value': '00:30:00'},
    {'label': '45 Dakika', 'value': '00:45:00'},
    {'label': '1 Saat', 'value': '01:00:00'},
    {'label': '1.5 Saat', 'value': '01:30:00'},
    {'label': '2 Saat', 'value': '02:00:00'},
  ];
  String? selectedDuration;

  bool editMode = false;
  bool isAdding = false;
  int? editChairId;

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ChairProvider>(context, listen: false).fetchChairs();
    });
  }

  void resetForm({bool keepAddingFlag = false}) {
    chairNameController.clear();
    openingTime = null;
    closingTime = null;
    selectedDuration = null;
    editChairId = null;
    if (!keepAddingFlag) {
      editMode = false;
      isAdding = false;
    }
    setState(() {});
  }

  Future<TimeOfDay?> pickTime(TimeOfDay? initialTime) async {
    return showTimePicker(
      context: context,
      initialTime: initialTime ?? const TimeOfDay(hour: 09, minute: 00),
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primaryGreen,
              onSurface: AppColors.darkGrey,
            ),
          ),
          child: child!,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final chairProvider = context.watch<ChairProvider>();
    bool showForm = editMode || isAdding;

    return AppLayout(
      body: Container(
        color: AppColors.background,
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const Padding(
              padding: EdgeInsets.only(bottom: 20),
              child: Row(
                children: [
                  Icon(Icons.chair_alt_rounded, color: AppColors.darkGrey),
                  SizedBox(width: 10),
                  Text(
                    "Koltuk Yönetimi",
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                      color: AppColors.darkGrey,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Stack(
                children: [
                  _buildChairList(chairProvider),
                  if (showForm)
                    Positioned.fill(
                      child: Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black26,
                              blurRadius: 30,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: _buildChairForm(chairProvider),
                      ),
                    ),
                ],
              ),
            ),
            if (!showForm)
              Padding(
                padding: const EdgeInsets.only(top: 10),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.add_rounded),
                    label: const Text("YENİ SANDALYE EKLE"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.darkGrey,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    onPressed: () => setState(() => isAdding = true),
                  ),
                ),
              ),
          ],
        ),
      ),
      bottomBar: const AdminBottomBar(currentIndex: 1),
    );
  }

  // --- LİSTELEME (TAŞMA SORUNU GİDERİLDİ) ---
  Widget _buildChairList(ChairProvider provider) {
    if (provider.isLoading)
      return const Center(
        child: CircularProgressIndicator(color: AppColors.primaryGreen),
      );
    if (provider.chairs.isEmpty)
      return const Center(child: Text("Henüz koltuk eklenmemiş."));

    return ListView.builder(
      itemCount: provider.chairs.length,
      padding: const EdgeInsets.only(bottom: 100),
      itemBuilder: (_, i) {
        final chair = provider.chairs[i];
        return Container(
          margin: const EdgeInsets.only(bottom: 14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.primaryGreen.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.event_seat_rounded,
                    color: AppColors.primaryGreen,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        chair.chairName,
                        style: const TextStyle(
                          fontWeight: FontWeight.w800,
                          color: AppColors.darkGrey,
                          fontSize: 16,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "${chair.openingTime.substring(0, 5)} - ${chair.closingTime.substring(0, 5)} | Süre: ${chair.islemSuresi.substring(0, 5)}",
                        style: const TextStyle(
                          fontSize: 11,
                          color: Colors.blueGrey,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(
                        Icons.edit_note_rounded,
                        color: Colors.blueAccent,
                      ),
                      onPressed: () {
                        setState(() {
                          editMode = true;
                          editChairId = chair.id;
                          chairNameController.text = chair.chairName;
                          openingTime = _parseTime(chair.openingTime);
                          closingTime = _parseTime(chair.closingTime);
                          selectedDuration = chair.islemSuresi;
                        });
                      },
                    ),
                    IconButton(
                      icon: const Icon(
                        Icons.delete_outline_rounded,
                        color: Colors.redAccent,
                      ),
                      onPressed: () => _confirmDelete(provider, chair.id),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // --- FORM TASARIMI (DROPDOWN EKLENDİ) ---
  Widget _buildChairForm(ChairProvider provider) {
    return Form(
      key: _formKey,
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              editMode ? "Düzenle" : "Yeni Ekle",
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w900,
                color: AppColors.darkGrey,
              ),
            ),
            const Divider(height: 30),

            _buildInputLabel("Koltuk Adı"),
            TextFormField(
              controller: chairNameController,
              decoration: _inputDeco(Icons.chair_rounded, "Örn: Koltuk 1"),
              validator: (v) => v!.isEmpty ? "Ad boş olamaz" : null,
            ),
            const SizedBox(height: 16),

            Row(
              children: [
                Expanded(
                  child: _timeBox("Açılış", openingTime, () async {
                    final t = await pickTime(openingTime);
                    if (t != null) setState(() => openingTime = t);
                  }),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _timeBox("Kapanış", closingTime, () async {
                    final t = await pickTime(closingTime);
                    if (t != null) setState(() => closingTime = t);
                  }),
                ),
              ],
            ),
            const SizedBox(height: 16),

            _buildInputLabel("İşlem Süresi"),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: AppColors.background.withOpacity(0.5),
                borderRadius: BorderRadius.circular(12),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButtonFormField<String>(
                  value: selectedDuration,
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    prefixIcon: Icon(
                      Icons.timer_outlined,
                      color: AppColors.primaryGreen,
                      size: 20,
                    ),
                  ),
                  items:
                      durationOptions
                          .map(
                            (e) => DropdownMenuItem<String>(
                              value: e['value'],
                              child: Text(
                                e['label'],
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          )
                          .toList(),
                  onChanged: (v) => setState(() => selectedDuration = v),
                  validator: (v) => v == null ? "Süre seçin" : null,
                ),
              ),
            ),

            const SizedBox(height: 30),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryGreen,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: () => _save(provider),
              child: Text(
                editMode ? "GÜNCELLE" : "KAYDET",
                style: const TextStyle(fontWeight: FontWeight.w800),
              ),
            ),
            TextButton(
              onPressed: resetForm,
              child: const Text("Vazgeç", style: TextStyle(color: Colors.grey)),
            ),
          ],
        ),
      ),
    );
  }

  // --- YARDIMCI METODLAR ---
  void _save(ChairProvider provider) {
    if (!_formKey.currentState!.validate() ||
        openingTime == null ||
        closingTime == null)
      return;
    final chair = Chair(
      id: editChairId ?? 0,
      chairName: chairNameController.text,
      openingTime: _toFullTime(openingTime!),
      closingTime: _toFullTime(closingTime!),
      islemSuresi: selectedDuration!,
    );
    editMode
        ? provider.updateChair(editChairId!, chair)
        : provider.addChair(chair);
    resetForm();
  }

  String _toFullTime(TimeOfDay t) =>
      "${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}:00";

  TimeOfDay _parseTime(String t) {
    final p = t.split(":");
    return TimeOfDay(hour: int.parse(p[0]), minute: int.parse(p[1]));
  }

  void _confirmDelete(ChairProvider provider, int id) {
    showDialog(
      context: context,
      builder:
          (c) => AlertDialog(
            title: const Text("Silinsin mi?"),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(c),
                child: const Text("Hayır"),
              ),
              TextButton(
                onPressed: () {
                  provider.deleteChair(id);
                  Navigator.pop(c);
                },
                child: const Text("Evet", style: TextStyle(color: Colors.red)),
              ),
            ],
          ),
    );
  }

  Widget _buildInputLabel(String label) => Padding(
    padding: const EdgeInsets.only(left: 4, bottom: 6),
    child: Text(
      label,
      style: const TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.bold,
        color: Colors.grey,
      ),
    ),
  );

  InputDecoration _inputDeco(IconData icon, String hint) => InputDecoration(
    hintText: hint,
    prefixIcon: Icon(icon, color: AppColors.primaryGreen, size: 20),
    filled: true,
    fillColor: AppColors.background.withOpacity(0.5),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide.none,
    ),
  );

  Widget _timeBox(String label, TimeOfDay? time, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.background.withOpacity(0.5),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 10,
                color: Colors.grey,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(
                  Icons.access_time_rounded,
                  size: 16,
                  color: AppColors.primaryGreen,
                ),
                const SizedBox(width: 8),
                Text(
                  time == null
                      ? "--:--"
                      : "${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}",
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
