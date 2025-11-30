class Store {
  final int id;
  final String storeName;
  final int chairCount;
  final int adminId;
  final int employeeId;
  final int reservationsId;

  Store({
    required this.id,
    required this.storeName,
    required this.chairCount,
    required this.adminId,
    required this.employeeId,
    required this.reservationsId,
  });
  factory Store.fromJson(Map<String, dynamic> json) {
    return Store(
      id: json['id'],
      storeName: json['storeName'],
      chairCount: json['chairCount'],
      adminId: json['adminId'],
      employeeId: json['employeeId'],
      reservationsId: json['reservationsId'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'storeName': storeName,
      'chairCount': chairCount,
      'adminId': adminId,
      'employeeId': employeeId,
      'reservationsId': reservationsId,
    };
  }
}
