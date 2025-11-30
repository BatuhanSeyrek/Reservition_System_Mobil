import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:rezervasyon_mobil/core/constants.dart';

Future<void> downloadExcelLast6Months(BuildContext context) async {
  final String baseUrl = Constants.baseUrl;
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

    // Backend URL’inizi yazın
    final url = Uri.parse(
      "$baseUrl/store/exportReservations?startDate=${sixMonthsAgo.toIso8601String()}&endDate=${now.toIso8601String()}",
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
