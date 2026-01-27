import 'package:geolocator/geolocator.dart';
import 'package:rezervasyon_mobil/core/secure_storage.dart';

Future<void> konumuAlVeKaydet() async {
  bool serviceEnabled;
  LocationPermission permission;

  // 1. GPS açık mı?
  serviceEnabled = await Geolocator.isLocationServiceEnabled();
  if (!serviceEnabled) {
    print("Abi telefonun GPS'i kapalı, aç gel.");
    return;
  }

  // 2. İzin kontrolü - BURASI KRİTİK
  permission = await Geolocator.checkPermission();

  // Eğer izin yoksa VEYA daha önce sorulmamışsa (denied), kutucuğu ÇIKART
  if (permission == LocationPermission.denied) {
    permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied) {
      print("Kullanıcı yine 'Hayır' dedi.");
      return;
    }
  }

  // 3. Eğer kullanıcı 'Ayarlardan kalıcı reddet' demişse (deniedForever)
  if (permission == LocationPermission.deniedForever) {
    print(
      "Kullanıcı kökten reddetmiş. Uygulamayı silip yükle ya da ayarlardan aç.",
    );
    return;
  }

  // 4. İzin 'whileInUse' (Kullanırken) veya 'always' (Her zaman) ise konumu al
  print("Konum alınıyor, lütfen bekle...");
  Position position = await Geolocator.getCurrentPosition(
    desiredAccuracy: LocationAccuracy.high,
  );

  // 5. Kasaya koy
  final storage = SecureStorage();
  await storage.saveLocation(position.latitude, position.longitude);

  print("İşlem başarılı! Kasaya kilitlendi.");
}
