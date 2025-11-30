class Reservation {
  final int id;
  final String startTime;
  final String endTime;
  final String chairName;
  final int chairId;
  final String userName;
  final String employeeName;
  final String reservationDate;
  final String storeName;
  final int storeId;

  Reservation({
    required this.id,
    required this.startTime,
    required this.endTime,
    required this.chairName,
    required this.chairId,
    required this.userName,
    required this.employeeName,
    required this.reservationDate,
    required this.storeName,
    required this.storeId,
  });
  factory Reservation.fromJson(Map<String, dynamic> json) {
    return Reservation(
      id: json['id'],
      startTime: json['startTime'],
      endTime: json['endTime'],
      chairName: json['chairName'],
      chairId: json['chairId'],
      userName: json['userName'],
      employeeName: json['employeeName'],
      reservationDate: json['reservationDate'],
      storeName: json['storeName'],
      storeId: json['storeId'],
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'startTime': startTime,
      'endTime': endTime,
      'chairName': chairName,
      'chairId': chairId,
      'userName': userName,
      'employeeName': employeeName,
      'reservationDate': reservationDate,
      'storeName': storeName,
      'storeId': storeId,
    };
  }
}
