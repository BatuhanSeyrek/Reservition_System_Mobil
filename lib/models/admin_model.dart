class AdminModel {
  final int id;
  final String adminName;
  final String phoneNumber;
  final String storeName;
  final int chairCount;
  final bool status;
  final String startTime;
  final String endTime;

  AdminModel({
    required this.id,
    required this.adminName,
    required this.phoneNumber,
    required this.storeName,
    required this.chairCount,
    required this.status,
    required this.startTime,
    required this.endTime,
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
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'adminName': adminName,
      'phoneNumber': phoneNumber,
      'storeName': storeName,
      'chairCount': chairCount,
      'status': status,
      'startTime': startTime,
      'endTime': endTime,
    };
  }
}
