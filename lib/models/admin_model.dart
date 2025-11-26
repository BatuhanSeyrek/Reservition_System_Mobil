class AdminModel {
  //MyAdmin için yaptım
  final int id;
  final String adminName;
  final String phoneNumber;
  final String storeName;
  final int chairCount;

  AdminModel({
    required this.adminName,
    required this.phoneNumber,
    required this.storeName,
    required this.chairCount,
    required this.id,
  });

  factory AdminModel.fromJson(Map<String, dynamic> json) {
    return AdminModel(
      id: json['id'],
      adminName: json['adminName'],
      phoneNumber: json['phoneNumber'],
      storeName: json['storeName'],
      chairCount: json['chairCount'],
    );
  }
}
