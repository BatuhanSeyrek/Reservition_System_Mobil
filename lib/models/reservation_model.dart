class Reservation {
  final int id;
  final int storeId;
  final int chairId;
  final String storeName;
  final String chairName;
  final String reservationDate;
  final String startTime;
  final String endTime;

  Reservation({
    required this.id,
    required this.storeId,
    required this.chairId,
    required this.storeName,
    required this.chairName,
    required this.reservationDate,
    required this.startTime,
    required this.endTime,
  });

  factory Reservation.fromJson(Map<String, dynamic> json) {
    return Reservation(
      id: json['id'],
      storeId: json['storeId'],
      chairId: json['chairId'],
      storeName: json['storeName'],
      chairName: json['chairName'],
      reservationDate: json['reservationDate'],
      startTime: json['startTime'],
      endTime: json['endTime'],
    );
  }
}
