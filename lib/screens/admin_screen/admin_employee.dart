import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rezervasyon_mobil/screens/admin_screen/admin_layout.dart';
import '../../models/admin_model/employee_model.dart';
import '../../providers/admin_provider/employee_provider.dart';
import '../../providers/admin_provider/chair_provider.dart';
import '../../models/admin_model/chair_model.dart';
import 'admin_sidebar.dart'; // AdminBottomBar

class EmployeeDeleteUpdateScreen extends StatefulWidget {
  @override
  State<EmployeeDeleteUpdateScreen> createState() =>
      _EmployeeDeleteUpdateScreenState();
}

class _EmployeeDeleteUpdateScreenState
    extends State<EmployeeDeleteUpdateScreen> {
  final TextEditingController _employeeNameController = TextEditingController();
  String? selectedChairId;

  bool showForm = false;
  bool editMode = false;
  int? editEmployeeId;

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<EmployeeProvider>().fetchEmployees();
      context.read<ChairProvider>().fetchChairs();
    });
  }

  void _handleEdit(Employee emp) {
    setState(() {
      showForm = true;
      editMode = true;
      editEmployeeId = emp.id;
      _employeeNameController.text = emp.employeeName;
      selectedChairId = emp.chairId.toString();
    });
  }

  void _resetForm() {
    _employeeNameController.clear();
    selectedChairId = null;
    editEmployeeId = null;
    editMode = false;
    showForm = false;
    setState(() {});
  }

  Future<void> _handleSubmit() async {
    final employeeName = _employeeNameController.text.trim();
    if (employeeName.isEmpty || selectedChairId == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Lütfen tüm alanları doldurun.")));
      return;
    }

    final provider = context.read<EmployeeProvider>();
    final employee = Employee(
      id: editEmployeeId ?? 0,
      employeeName: employeeName,
      chairId: int.parse(selectedChairId!),
      adminId: 0,
    );

    try {
      if (editMode) {
        await provider.updateEmployee(editEmployeeId!, employee);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Çalışan güncellendi.")));
      } else {
        await provider.addEmployee(employee);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Çalışan eklendi.")));
      }
      _resetForm();
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Hata: $e")));
    }
  }

  void _showDeleteConfirmation(BuildContext ctx, Employee emp) {
    showDialog(
      context: ctx,
      builder:
          (context) => AlertDialog(
            title: Text("Silme Onayı"),
            content: Text(
              "Bu çalışanı kalıcı olarak silmek istediğinize emin misiniz?",
            ),
            actions: [
              TextButton(
                child: Text("İptal", style: TextStyle(color: Colors.grey)),
                onPressed: () => Navigator.of(context).pop(),
              ),
              TextButton(
                child: Text("Sil", style: TextStyle(color: Colors.redAccent)),
                onPressed: () async {
                  await context.read<EmployeeProvider>().deleteEmployee(emp.id);
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text("Çalışan silindi.")));
                },
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final employees = context.watch<EmployeeProvider>().employees;
    final chairs = context.watch<ChairProvider>().chairs;

    Widget formCard = Card(
      elevation: 10,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                editMode ? "Çalışanı Düzenle" : "Yeni Çalışan Ekle",
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
                controller: _employeeNameController,
                decoration: InputDecoration(
                  contentPadding: EdgeInsets.symmetric(
                    vertical: 12,
                    horizontal: 12,
                  ),
                  labelText: "Çalışan Adı",
                  prefixIcon: Icon(Icons.person, color: Colors.grey[900]),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                validator:
                    (v) =>
                        (v == null || v.isEmpty)
                            ? "Lütfen bir isim giriniz."
                            : null,
              ),
              SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: selectedChairId,
                decoration: InputDecoration(
                  contentPadding: EdgeInsets.symmetric(
                    vertical: 6,
                    horizontal: 12,
                  ),
                  labelText: "Koltuk Seç",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                items:
                    chairs
                        .map(
                          (c) => DropdownMenuItem(
                            value: c.id.toString(),
                            child: Text(c.chairName),
                          ),
                        )
                        .toList(),
                onChanged: (val) => setState(() => selectedChairId = val),
                validator:
                    (v) =>
                        (v == null || v.isEmpty)
                            ? "Lütfen bir koltuk seçin."
                            : null,
              ),
              SizedBox(height: 22),
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
                        _handleSubmit();
                      },
                      style: FilledButton.styleFrom(
                        backgroundColor: Colors.grey[900],
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ),
                  if (editMode) SizedBox(width: 8),
                  if (editMode)
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
                        onPressed: _resetForm,
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
      ),
    );

    return AppLayout(
      body: Padding(
        padding: EdgeInsets.all(33),
        child: LayoutBuilder(
          builder: (context, constraints) {
            bool isSmallScreen = constraints.maxWidth < 900;

            Widget employeeList =
                employees.isEmpty
                    ? Center(
                      child: Text(
                        "Çalışan bulunamadı.",
                        style: TextStyle(color: Colors.grey[700]),
                      ),
                    )
                    : Scrollbar(
                      child: ListView.builder(
                        itemCount: employees.length,
                        itemBuilder: (_, i) {
                          final emp = employees[i];
                          final chairName =
                              chairs
                                  .firstWhere(
                                    (c) => c.id == emp.chairId,
                                    orElse:
                                        () => Chair(
                                          id: 0,
                                          chairName: "Bilinmiyor",
                                          openingTime: "",
                                          closingTime: "",
                                          islemSuresi: "",
                                        ),
                                  )
                                  .chairName;

                          return Card(
                            margin: EdgeInsets.only(bottom: 12),
                            elevation: 4,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: ListTile(
                              title: Text(
                                emp.employeeName,
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              subtitle: Text("Koltuk: $chairName"),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: Icon(
                                      Icons.edit_note,
                                      color: Colors.redAccent,
                                    ),
                                    onPressed: () => _handleEdit(emp),
                                  ),
                                  IconButton(
                                    icon: Icon(
                                      Icons.delete_forever,
                                      color: Colors.red.shade700,
                                    ),
                                    onPressed:
                                        () => _showDeleteConfirmation(
                                          context,
                                          emp,
                                        ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    );

            if (isSmallScreen) {
              return Column(
                children: [
                  Expanded(child: employeeList),
                  if (showForm) SizedBox(height: 12),
                  if (showForm) formCard,
                  SizedBox(height: 12),
                  if (!showForm)
                    ElevatedButton(
                      child: Text("Yeni Çalışan Ekle"),
                      onPressed: () => setState(() => showForm = true),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey[900],
                        foregroundColor: Colors.white,
                      ),
                    ),
                ],
              );
            } else {
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(flex: showForm ? 60 : 100, child: employeeList),
                  if (showForm) SizedBox(width: 33),
                  if (showForm)
                    Expanded(
                      flex: 40,
                      child: SizedBox(
                        height: constraints.maxHeight - 66,
                        child: formCard,
                      ),
                    ),
                ],
              );
            }
          },
        ),
      ),
      bottomBar: const AdminBottomBar(currentIndex: 2), // bottom bar eklendi
    );
  }
}
