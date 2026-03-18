import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rezervasyon_mobil/core/app_colors.dart'; // Renk paleti
import 'package:rezervasyon_mobil/screens/admin_screen/admin_layout.dart';
import '../../models/admin_model/employee_model.dart';
import '../../providers/admin_provider/employee_provider.dart';
import '../../providers/admin_provider/chair_provider.dart';
import '../../models/admin_model/chair_model.dart';
import 'admin_sidebar.dart';

class EmployeeDeleteUpdateScreen extends StatefulWidget {
  const EmployeeDeleteUpdateScreen({super.key});

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
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Lütfen tüm alanları doldurun."),
          backgroundColor: Colors.orange,
        ),
      );
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
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Çalışan güncellendi."),
            backgroundColor: AppColors.primaryGreen,
          ),
        );
      } else {
        await provider.addEmployee(employee);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Çalışan başarıyla eklendi."),
            backgroundColor: AppColors.primaryGreen,
          ),
        );
      }
      _resetForm();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Hata: $e"), backgroundColor: Colors.redAccent),
      );
    }
  }

  void _showDeleteConfirmation(BuildContext ctx, Employee emp) {
    showDialog(
      context: ctx,
      builder:
          (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            title: const Text(
              "Silme Onayı",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            content: Text(
              "${emp.employeeName} isimli çalışanı silmek istediğinize emin misiniz?",
            ),
            actions: [
              TextButton(
                child: const Text(
                  "İptal",
                  style: TextStyle(color: Colors.grey),
                ),
                onPressed: () => Navigator.of(context).pop(),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent,
                  elevation: 0,
                ),
                child: const Text("Sil", style: TextStyle(color: Colors.white)),
                onPressed: () async {
                  await context.read<EmployeeProvider>().deleteEmployee(emp.id);
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Çalışan silindi.")),
                  );
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

    // --- MODERN FORM KARTI ---
    Widget formCard = Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Icon(
                  editMode ? Icons.edit_note_rounded : Icons.person_add_rounded,
                  color: AppColors.primaryGreen,
                ),
                const SizedBox(width: 8),
                Text(
                  editMode ? "Çalışanı Düzenle" : "Yeni Çalışan Ekle",
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    color: AppColors.darkGrey,
                  ),
                ),
              ],
            ),
            const Divider(height: 32),
            _buildTextField(
              "Çalışan Adı Soyadı",
              _employeeNameController,
              Icons.badge_outlined,
            ),
            const SizedBox(height: 16),
            _buildDropdown(chairs),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryGreen,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: _handleSubmit,
                    child: Text(
                      editMode ? "GÜNCELLE" : "KAYDET",
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                if (editMode) const SizedBox(width: 10),
                if (editMode)
                  IconButton(
                    onPressed: _resetForm,
                    icon: const Icon(Icons.close_rounded, color: Colors.grey),
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.grey.shade100,
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );

    return AppLayout(
      body: Container(
        color: AppColors.background,
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Üst Başlık
            const Padding(
              padding: EdgeInsets.only(bottom: 20),
              child: Row(
                children: [
                  Icon(Icons.people_alt_rounded, color: AppColors.darkGrey),
                  SizedBox(width: 10),
                  Text(
                    "Personel Yönetimi",
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
              child:
                  employees.isEmpty
                      ? const Center(
                        child: Text(
                          "Henüz personel eklenmemiş.",
                          style: TextStyle(color: Colors.grey),
                        ),
                      )
                      : ListView.builder(
                        itemCount: employees.length,
                        itemBuilder: (_, i) {
                          final emp = employees[i];
                          final chair = chairs.firstWhere(
                            (c) => c.id == emp.chairId,
                            orElse:
                                () => Chair(
                                  id: 0,
                                  chairName: "Atanmamış",
                                  openingTime: "",
                                  closingTime: "",
                                  islemSuresi: "",
                                ),
                          );

                          return Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.03),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: ListTile(
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 8,
                              ),
                              leading: CircleAvatar(
                                backgroundColor: AppColors.primaryGreen
                                    .withOpacity(0.1),
                                child: const Icon(
                                  Icons.person_rounded,
                                  color: AppColors.primaryGreen,
                                ),
                              ),
                              title: Text(
                                emp.employeeName,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.darkGrey,
                                ),
                              ),
                              subtitle: Text(
                                "Hizmet Noktası: ${chair.chairName}",
                                style: const TextStyle(fontSize: 12),
                              ),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: const Icon(
                                      Icons.edit_outlined,
                                      color: Colors.blueAccent,
                                      size: 22,
                                    ),
                                    onPressed: () => _handleEdit(emp),
                                  ),
                                  IconButton(
                                    icon: const Icon(
                                      Icons.delete_outline_rounded,
                                      color: Colors.redAccent,
                                      size: 22,
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
            ),
            if (showForm) const SizedBox(height: 20),
            if (showForm) formCard,
            if (!showForm)
              Padding(
                padding: const EdgeInsets.only(top: 10),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.add_rounded),
                    label: const Text("YENİ PERSONEL EKLE"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.darkGrey,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    onPressed: () => setState(() => showForm = true),
                  ),
                ),
              ),
          ],
        ),
      ),
      bottomBar: const AdminBottomBar(currentIndex: 2),
    );
  }

  // --- YARDIMCI GİRİŞ BİLEŞENLERİ ---
  Widget _buildTextField(
    String label,
    TextEditingController controller,
    IconData icon,
  ) {
    return TextFormField(
      controller: controller,
      style: const TextStyle(fontWeight: FontWeight.w600),
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: AppColors.primaryGreen, size: 20),
        filled: true,
        fillColor: AppColors.background.withOpacity(0.5),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  Widget _buildDropdown(List<Chair> chairs) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: AppColors.background.withOpacity(0.5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: DropdownButtonFormField<String>(
        value: selectedChairId,
        decoration: const InputDecoration(
          labelText: "Hizmet Koltuğu",
          prefixIcon: Icon(
            Icons.chair_alt_rounded,
            color: AppColors.primaryGreen,
            size: 20,
          ),
          border: InputBorder.none,
        ),
        items:
            chairs
                .map(
                  (c) => DropdownMenuItem(
                    value: c.id.toString(),
                    child: Text(
                      c.chairName,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                )
                .toList(),
        onChanged: (val) => setState(() => selectedChairId = val),
      ),
    );
  }
}
