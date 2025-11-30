// chair_model.dart
class Chair {
  final int id;
  final String chairName;
  final String openingTime;
  final String closingTime;
  final String islemSuresi;

  Chair({
    required this.id,
    required this.chairName,
    required this.openingTime,
    required this.closingTime,
    required this.islemSuresi,
  });

  factory Chair.fromJson(Map<String, dynamic> json) {
    return Chair(
      id: json['id'],
      chairName: json['chairName'],
      openingTime: json['openingTime'],
      closingTime: json['closingTime'],
      islemSuresi: json['islemSuresi'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "chairName": chairName,
      "openingTime": openingTime,
      "closingTime": closingTime,
      "islemSuresi": islemSuresi,
    };
  }
}
