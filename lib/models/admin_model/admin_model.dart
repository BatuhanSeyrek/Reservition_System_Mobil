class AdminModel {
  final int id;
  final String adminName;
  final String phoneNumber;
  final String storeName;
  final int chairCount;
  final bool status;
  final String startTime;
  final String endTime;
  final String password; // opsiyonel
  final String referenceId; // opsiyonel
  final bool referenceStatus; // true = girilmiş, false = girilmemiş

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
    this.referenceStatus = false, // default: false
  });

  factory AdminModel.fromJson(Map<String, dynamic> json) {
    return AdminModel(
      id: json['id'],
      adminName: json['adminName'],
      phoneNumber: json['phoneNumber'],
      storeName: json['storeName'],
      chairCount: json['chairCount'],
      status: json['status'],
      startTime: json['startTime'],
      endTime: json['endTime'],
      password: json['password'] ?? '',
      referenceId: json['referenceId'] ?? '',
      referenceStatus: json['referenceId'] != null && json['referenceId'] != '',
    );
  }

  Map<String, dynamic> toJson() {
    final data = {
      'id': id,
      'adminName': adminName,
      'phoneNumber': phoneNumber,
      'storeName': storeName,
      'chairCount': chairCount,
      'status': status,
      'startTime': startTime,
      'endTime': endTime,
    };

    if (password.isNotEmpty) data['password'] = password;
    if (referenceId.isNotEmpty) data['referenceId'] = referenceId;

    return data;
  }
}
