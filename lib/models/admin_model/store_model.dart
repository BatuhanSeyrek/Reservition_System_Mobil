class Store {
  final int id;
  final String storeName;
  final int chairCount;
  final int? adminId;
  final int? employeeId;
  final int? reservationsId;

  Store({
    required this.id,
    required this.storeName,
    required this.chairCount,
    this.adminId,
    this.employeeId,
    this.reservationsId,
  });

  factory Store.fromJson(Map<String, dynamic> json) {
    return Store(
      id: json['id'] as int,
      storeName: json['storeName'] as String,
      chairCount: json['chairCount'] as int,
      adminId: json['adminId'] as int?,
      employeeId: json['employeeId'] as int?,
      reservationsId: json['reservationsId'] as int?,
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
