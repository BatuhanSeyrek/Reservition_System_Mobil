class AdminModel {
  final int id;
  final String adminName;
  final String phoneNumber;
  final String storeName;
  final int chairCount;
  final bool status;
  final String startTime;
  final String endTime;
  final String password;
  final String referenceId;
  final bool referenceStatus;
  // --- Yeni Eklenen Alanlar ---
  final String city;
  final String district;
  final double latitude;
  final double longitude;
  AdminModel copyWith({
    int? id,
    String? adminName,
    String? phoneNumber,
    String? storeName,
    int? chairCount,
    bool? status,
    String? startTime,
    String? endTime,
    String? password,
    String? referenceId,
    bool? referenceStatus,
    String? city,
    String? district,
    double? latitude,
    double? longitude,
  }) {
    return AdminModel(
      id: id ?? this.id,
      adminName: adminName ?? this.adminName,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      storeName: storeName ?? this.storeName,
      chairCount: chairCount ?? this.chairCount,
      status: status ?? this.status,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      password: password ?? this.password,
      referenceId: referenceId ?? this.referenceId,
      referenceStatus: referenceStatus ?? this.referenceStatus,
      city: city ?? this.city,
      district: district ?? this.district,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
    );
  }

  AdminModel({
    required this.id,
    required this.adminName,
    required this.phoneNumber,
    required this.storeName,
    required this.chairCount,
    required this.status,
    required this.startTime,
    required this.endTime,
    this.password = '',
    this.referenceId = '',
    this.referenceStatus = false,
    this.city = '',
    this.district = '',
    this.latitude = 0.0,
    this.longitude = 0.0,
  });

  factory AdminModel.fromJson(Map<String, dynamic> json) {
    return AdminModel(
      id: json['id'],
      adminName: json['adminName'] ?? '',
      phoneNumber: json['phoneNumber'] ?? '',
      storeName: json['storeName'] ?? '',
      chairCount: json['chairCount'] ?? 0,
      status: json['status'] ?? false,
      startTime: json['startTime'] ?? '',
      endTime: json['endTime'] ?? '',
      password: json['password'] ?? '',
      referenceId: json['referenceId'] ?? '',
      referenceStatus: json['referenceStatus'] ?? false,
      // Backend'den gelen yeni alanlar (null kontrolü ile)
      city: json['city'] ?? '',
      district: json['district'] ?? '',
      latitude: (json['latitude'] as num?)?.toDouble() ?? 0.0,
      longitude: (json['longitude'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {
      'id': id,
      'adminName': adminName,
      'phoneNumber': phoneNumber,
      'storeName': storeName,
      'chairCount': chairCount,
      'status': status,
      'startTime': startTime,
      'endTime': endTime,
      'city': city,
      'district': district,
      'latitude': latitude,
      'longitude': longitude,
    };

    if (password.isNotEmpty) data['password'] = password;
    if (referenceId.isNotEmpty) data['referenceId'] = referenceId;
    // referenceStatus genellikle backend tarafından hesaplandığı için göndermene gerek olmayabilir
    // ama istersen ekleyebilirsin: data['referenceStatus'] = referenceStatus;

    return data;
  }
}
