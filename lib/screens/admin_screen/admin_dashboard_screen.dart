import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/admin_provider/reservation_provider.dart';
import 'admin_layout.dart';
import 'admin_sidebar.dart'; // AdminBottomBar
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

class AdminDashboardScreen extends StatefulWidget {
  @override
  _AdminDashboardScreenState createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  String? selectedId;
  String? selectedUser;
  String? selectedEmployee;
  String? selectedChair;
  DateTime? startDate;
  DateTime? endDate;
  bool isTodayActive = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ReservationProvider>(
        context,
        listen: false,
      ).fetchReservations();
    });
  }

  Future<void> downloadExcelLast6Months() async {
    try {
      if (Platform.isAndroid) {
        var status = await Permission.storage.request();
        if (!status.isGranted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text("Dosya izinleri verilmedi!")));
          return;
        }
      }

      final now = DateTime.now();
      final sixMonthsAgo = DateTime(now.year, now.month - 6, now.day);

      final url = Uri.parse(
        "https://YOUR_BACKEND_URL/store/exportReservations?startDate=${sixMonthsAgo.toIso8601String()}&endDate=${now.toIso8601String()}",
      );

      final response = await http.get(url);

      if (response.statusCode == 200) {
        Directory dir =
            Platform.isAndroid
                ? (await getExternalStorageDirectory())!
                : await getApplicationDocumentsDirectory();

        final filePath = "${dir.path}/reservations_last6months.xlsx";
        File file = File(filePath);
        await file.writeAsBytes(response.bodyBytes);

        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Excel kaydedildi: $filePath")));
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Excel indirilemedi!")));
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Hata: $e")));
    }
  }

  void handleTodayFilter() {
    setState(() {
      if (isTodayActive) {
        startDate = null;
        endDate = null;
        isTodayActive = false;
      } else {
        final today = DateTime.now();
        startDate = today;
        endDate = today;
        isTodayActive = true;
      }
    });
  }

  List filteredReservations(List reservations) {
    return reservations.where((r) {
      final resDate = DateTime.parse(r.reservationDate);
      final resDateOnly = DateTime(resDate.year, resDate.month, resDate.day);

      if (startDate != null && endDate != null) {
        final startOnly = DateTime(
          startDate!.year,
          startDate!.month,
          startDate!.day,
        );
        final endOnly = DateTime(endDate!.year, endDate!.month, endDate!.day);
        if (!(resDateOnly.isAtLeast(startOnly) &&
            resDateOnly.isAtMost(endOnly))) {
          return false;
        }
      }

      if (selectedId != null && selectedId != r.id.toString()) return false;
      if (selectedUser != null && selectedUser != r.userName) return false;
      if (selectedEmployee != null && selectedEmployee != r.employeeName)
        return false;
      if (selectedChair != null && selectedChair != r.chairName) return false;

      return true;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return AppLayout(
      body: Consumer<ReservationProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading)
            return Center(child: CircularProgressIndicator());

          final reservations = filteredReservations(provider.reservations);

          final ids =
              provider.reservations
                  .map((r) => r.id.toString())
                  .toSet()
                  .toList();
          final users =
              provider.reservations.map((r) => r.userName).toSet().toList();
          final employees =
              provider.reservations.map((r) => r.employeeName).toSet().toList();
          final chairs =
              provider.reservations.map((r) => r.chairName).toSet().toList();

          int todayCount() {
            final today = DateTime.now();
            return reservations.where((r) {
              final d = DateTime.parse(r.reservationDate);
              return d.year == today.year &&
                  d.month == today.month &&
                  d.day == today.day;
            }).length;
          }

          int upcomingCount() {
            final today = DateTime.now();
            return reservations
                .where((r) => DateTime.parse(r.reservationDate).isAfter(today))
                .length;
          }

          int totalUsers() =>
              reservations.map((r) => r.userName).toSet().length;
          int totalEmployees() =>
              reservations.map((r) => r.employeeName).toSet().length;

          return SingleChildScrollView(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Admin Dashboard",
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 20),

                Column(
                  children: [
                    _statCard(
                      "Toplam Rezervasyon",
                      reservations.length,
                      Colors.green,
                      Icons.list_alt,
                    ),
                    SizedBox(height: 12),
                    _statCard(
                      "Gelecek Rezervasyon",
                      upcomingCount(),
                      Colors.blue,
                      Icons.schedule,
                    ),
                    SizedBox(height: 12),
                    _statCard(
                      "Bugünün Rezervasyonu",
                      todayCount(),
                      Colors.orange,
                      Icons.today,
                    ),
                    SizedBox(height: 12),
                    _statCard(
                      "Toplam Kullanıcı",
                      totalUsers(),
                      Colors.purple,
                      Icons.people,
                    ),
                    SizedBox(height: 12),
                    _statCard(
                      "Toplam Çalışan",
                      totalEmployees(),
                      Colors.red,
                      Icons.person,
                    ),
                  ],
                ),

                SizedBox(height: 20),

                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _dropdownFilter(
                      "ID",
                      selectedId,
                      ids,
                      (val) => setState(() => selectedId = val),
                    ),
                    SizedBox(height: 10),
                    _dropdownFilter(
                      "Kullanıcı",
                      selectedUser,
                      users,
                      (val) => setState(() => selectedUser = val),
                    ),
                    SizedBox(height: 10),
                    _dropdownFilter(
                      "Çalışan",
                      selectedEmployee,
                      employees,
                      (val) => setState(() => selectedEmployee = val),
                    ),
                    SizedBox(height: 10),
                    _dropdownFilter(
                      "Koltuk",
                      selectedChair,
                      chairs,
                      (val) => setState(() => selectedChair = val),
                    ),
                    SizedBox(height: 20),

                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () async {
                              DateTime? picked = await showDatePicker(
                                context: context,
                                initialDate: DateTime.now(),
                                firstDate: DateTime(2020),
                                lastDate: DateTime(2100),
                              );
                              if (picked != null)
                                setState(() => startDate = picked);
                            },
                            child: Text(
                              startDate == null
                                  ? "Başlangıç Tarihi"
                                  : "Başlangıç: ${startDate!.day}/${startDate!.month}/${startDate!.year}",
                            ),
                          ),
                        ),
                        SizedBox(width: 10),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () async {
                              DateTime? picked = await showDatePicker(
                                context: context,
                                initialDate: DateTime.now(),
                                firstDate: DateTime(2020),
                                lastDate: DateTime(2100),
                              );
                              if (picked != null)
                                setState(() => endDate = picked);
                            },
                            child: Text(
                              endDate == null
                                  ? "Bitiş Tarihi"
                                  : "Bitiş: ${endDate!.day}/${endDate!.month}/${endDate!.year}",
                            ),
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: 10),

                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: handleTodayFilter,
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                                  isTodayActive ? Colors.red : Colors.orange,
                            ),
                            child: Text(
                              isTodayActive ? "Bugün Filtreyi Kapat" : "Bugün",
                            ),
                          ),
                        ),
                        SizedBox(width: 10),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: downloadExcelLast6Months,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                            ),
                            child: Text("Son 6 Ay Excel İndir"),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),

                SizedBox(height: 20),

                ListView.builder(
                  physics: NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  itemCount: reservations.length,
                  itemBuilder: (context, index) {
                    final r = reservations[index];
                    return Card(
                      margin: EdgeInsets.symmetric(vertical: 6),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: ListTile(
                        title: Text("ID: ${r.id} - ${r.reservationDate}"),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Başlangıç: ${r.startTime} - Bitiş: ${r.endTime}",
                            ),
                            Text("Koltuk: ${r.chairName}"),
                            Text("Kullanıcı: ${r.userName}"),
                            Text("Çalışan: ${r.employeeName}"),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          );
        },
      ),
      bottomBar: const AdminBottomBar(currentIndex: 0), // bottom bar eklendi
    );
  }

  Widget _statCard(String title, int value, Color color, IconData icon) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 5)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Colors.white, size: 28),
          SizedBox(height: 10),
          Text(title, style: TextStyle(color: Colors.white70)),
          SizedBox(height: 5),
          Text(
            value.toString(),
            style: TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _dropdownFilter(
    String label,
    String? selectedValue,
    List<String> items,
    Function(String?) onChanged,
  ) {
    return InputDecorator(
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          isExpanded: true,
          value: selectedValue,
          items:
              [null, ...items]
                  .map(
                    (e) =>
                        DropdownMenuItem(value: e, child: Text(e ?? "Seçiniz")),
                  )
                  .toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }
}

extension DateTimeComparison on DateTime {
  bool isAtLeast(DateTime other) => !isBefore(other);
  bool isAtMost(DateTime other) => !isAfter(other);
}
