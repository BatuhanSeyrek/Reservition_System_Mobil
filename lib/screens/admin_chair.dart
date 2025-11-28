import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/chair_provider.dart';
import '../models/chair_model.dart';
import 'admin_layout.dart';

class ChairDeleteUpdate extends StatefulWidget {
  @override
  _ChairDeleteUpdateState createState() => _ChairDeleteUpdateState();
}

class _ChairDeleteUpdateState extends State<ChairDeleteUpdate> {
  TextEditingController chairNameController = TextEditingController();
  TimeOfDay? openingTime;
  TimeOfDay? closingTime;
  TimeOfDay? islemSuresi;

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

  String _formatTimeOfDay(TimeOfDay? time) {
    if (time == null) return '--:--';
    return time.format(context);
  }

  Future<TimeOfDay?> pickTime(TimeOfDay? initialTime) async {
    return showTimePicker(
      context: context,
      initialTime: initialTime ?? TimeOfDay.now(),
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            primaryColor: Colors.grey[900],
            colorScheme: ColorScheme.light(
              primary: Colors.grey[900]!,
              secondary: Colors.redAccent,
              onSurface: Colors.black87,
            ),
            buttonTheme: ButtonThemeData(textTheme: ButtonTextTheme.primary),
          ),
          child: child!,
        );
      },
    );
  }

  void resetForm({bool keepAddingFlag = false}) {
    chairNameController.clear();
    openingTime = null;
    closingTime = null;
    islemSuresi = null;
    editChairId = null;
    if (!keepAddingFlag) {
      editMode = false;
      isAdding = false;
    }
    setState(() {});
  }

  Widget buildChairList(ChairProvider chairProvider) {
    return chairProvider.isLoading
        ? Center(child: CircularProgressIndicator(color: Colors.grey[900]))
        : Scrollbar(
          child: ListView.builder(
            itemCount: chairProvider.chairs.length,
            itemBuilder: (_, i) {
              final chair = chairProvider.chairs[i];
              return Card(
                margin: EdgeInsets.only(bottom: 12),
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                child: ListTile(
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  title: Text(
                    chair.chairName,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: Colors.grey[900],
                    ),
                  ),
                  subtitle: Padding(
                    padding: const EdgeInsets.only(top: 4.0),
                    child: Text(
                      "Açılış: ${chair.openingTime} - Kapanış: ${chair.closingTime} | İşlem Süresi: ${chair.islemSuresi}",
                      style: TextStyle(color: Colors.grey[700]),
                    ),
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(Icons.edit_note, color: Colors.redAccent),
                        onPressed: () {
                          setState(() {
                            editMode = true;
                            isAdding = false;
                            editChairId = chair.id;
                            chairNameController.text = chair.chairName;

                            final openParts = chair.openingTime.split(":");
                            openingTime = TimeOfDay(
                              hour: int.parse(openParts[0]),
                              minute: int.parse(openParts[1]),
                            );

                            final closeParts = chair.closingTime.split(":");
                            closingTime = TimeOfDay(
                              hour: int.parse(closeParts[0]),
                              minute: int.parse(closeParts[1]),
                            );

                            final islemParts = chair.islemSuresi.split(":");
                            islemSuresi = TimeOfDay(
                              hour: int.parse(islemParts[0]),
                              minute: int.parse(islemParts[1]),
                            );
                          });
                        },
                      ),
                      IconButton(
                        icon: Icon(
                          Icons.delete_forever,
                          color: Colors.red.shade700,
                        ),
                        onPressed:
                            () => _showDeleteConfirmation(
                              context,
                              chairProvider,
                              chair.id,
                            ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        );
  }

  void _showDeleteConfirmation(
    BuildContext context,
    ChairProvider chairProvider,
    int chairId,
  ) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Silme Onayı"),
          content: const Text(
            "Bu sandalyeyi kalıcı olarak silmek istediğinizden emin misiniz?",
          ),
          actions: [
            TextButton(
              child: const Text("İptal", style: TextStyle(color: Colors.grey)),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: const Text(
                "Sil",
                style: TextStyle(color: Colors.redAccent),
              ),
              onPressed: () {
                chairProvider.deleteChair(chairId);
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Widget buildChairFormContent(ChairProvider chairProvider) {
    return SingleChildScrollView(
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              editMode ? "Sandalyeyi Düzenle" : "Yeni Sandalye Ekle",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: Colors.grey[900],
              ),
            ),
            Divider(
              height: 24,
              thickness: 1.5,
              color: Colors.grey[900]!.withOpacity(0.3),
            ),
            TextFormField(
              controller: chairNameController,
              decoration: InputDecoration(
                contentPadding: EdgeInsets.symmetric(
                  vertical: 10,
                  horizontal: 10,
                ),
                labelText: "Sandalye Adı",
                prefixIcon: Icon(Icons.chair_alt, color: Colors.grey[900]),
                border: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey.shade400),
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              validator: (value) {
                if (value == null || value.isEmpty)
                  return 'Lütfen bir sandalye adı giriniz.';
                return null;
              },
            ),
            SizedBox(height: 12),
            _buildTimePickerListTile(
              title: "Açılış Saati",
              time: openingTime,
              onTap: () async {
                final time = await pickTime(openingTime);
                if (time != null) setState(() => openingTime = time);
              },
            ),
            SizedBox(height: 8),
            _buildTimePickerListTile(
              title: "Kapanış Saati",
              time: closingTime,
              onTap: () async {
                final time = await pickTime(closingTime);
                if (time != null) setState(() => closingTime = time);
              },
            ),
            SizedBox(height: 8),
            _buildTimePickerListTile(
              title: "İşlem Süresi",
              time: islemSuresi,
              onTap: () async {
                final time = await pickTime(islemSuresi);
                if (time != null) setState(() => islemSuresi = time);
              },
            ),
            SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: FilledButton.icon(
                    icon: Icon(
                      editMode ? Icons.update : Icons.add_circle,
                      size: 20,
                    ),
                    label: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10.0),
                      child: Text(
                        editMode ? "Güncelle" : "Ekle",
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                    onPressed: () {
                      if (!_formKey.currentState!.validate()) return;

                      if (openingTime == null ||
                          closingTime == null ||
                          islemSuresi == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text("Lütfen tüm saatleri seçiniz."),
                            backgroundColor: Colors.redAccent,
                          ),
                        );
                        return;
                      }

                      final chair = Chair(
                        id: editChairId ?? 0,
                        chairName: chairNameController.text,
                        openingTime:
                            "${openingTime!.hour.toString().padLeft(2, '0')}:${openingTime!.minute.toString().padLeft(2, '0')}:00",
                        closingTime:
                            "${closingTime!.hour.toString().padLeft(2, '0')}:${closingTime!.minute.toString().padLeft(2, '0')}:00",
                        islemSuresi:
                            "${islemSuresi!.hour.toString().padLeft(2, '0')}:${islemSuresi!.minute.toString().padLeft(2, '0')}:00",
                      );

                      if (editMode) {
                        chairProvider.updateChair(editChairId!, chair);
                      } else {
                        chairProvider.addChair(chair);
                      }

                      resetForm();
                    },
                    style: FilledButton.styleFrom(
                      backgroundColor: Colors.grey[900],
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
                if (editMode || isAdding) SizedBox(width: 8),
                if (editMode || isAdding)
                  Expanded(
                    child: OutlinedButton.icon(
                      icon: Icon(
                        Icons.cancel_outlined,
                        color: Colors.grey[900],
                        size: 20,
                      ),
                      label: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 10.0),
                        child: Text(
                          "İptal",
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[900],
                          ),
                        ),
                      ),
                      onPressed: resetForm,
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(
                          color: Colors.grey[900]!.withOpacity(0.5),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimePickerListTile({
    required String title,
    required TimeOfDay? time,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 1,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: ListTile(
        dense: true,
        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 0),
        title: Text(
          "$title: ${_formatTimeOfDay(time)}",
          style: TextStyle(
            fontWeight: FontWeight.w500,
            fontSize: 14,
            color: Colors.grey[900],
          ),
        ),
        trailing: Icon(Icons.access_time, color: Colors.redAccent, size: 20),
        onTap: onTap,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        tileColor: Colors.grey.shade50,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final chairProvider = context.watch<ChairProvider>();
    Widget formCard = Card(
      elevation: 10,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: EdgeInsets.all(24),
        child: buildChairFormContent(chairProvider),
      ),
    );

    return AdminLayout(
      body: Padding(
        padding: EdgeInsets.all(33),
        child: LayoutBuilder(
          builder: (context, constraints) {
            bool showForm = editMode || isAdding;
            bool isSmallScreen = constraints.maxWidth < 900;

            if (isSmallScreen) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (!showForm) Expanded(child: buildChairList(chairProvider)),
                  if (showForm) Expanded(child: formCard),
                  if (!showForm)
                    Padding(
                      padding: const EdgeInsets.only(top: 16.0),
                      child: ElevatedButton(
                        child: Text(
                          "Yeni Sandalye Ekle",
                          style: TextStyle(fontSize: 16),
                        ),
                        onPressed:
                            () => setState(() {
                              isAdding = true;
                              editMode = false;
                              resetForm(keepAddingFlag: true);
                            }),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.grey[900],
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ),
                ],
              );
            } else {
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (showForm)
                    Expanded(
                      flex: 40,
                      child: SizedBox(
                        height: constraints.maxHeight - 66,
                        child: formCard,
                      ),
                    ),
                  if (showForm) SizedBox(width: 33),
                  Expanded(
                    flex: showForm ? 60 : 100,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Expanded(child: buildChairList(chairProvider)),
                        if (!showForm)
                          Padding(
                            padding: const EdgeInsets.only(top: 16.0),
                            child: ElevatedButton(
                              child: Text(
                                "Yeni Sandalye Ekle",
                                style: TextStyle(fontSize: 16),
                              ),
                              onPressed:
                                  () => setState(() {
                                    isAdding = true;
                                    editMode = false;
                                    resetForm(keepAddingFlag: true);
                                  }),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.grey[900],
                                foregroundColor: Colors.white,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              );
            }
          },
        ),
      ),
    );
  }
}
