class ChairModel {
  final int chairId;
  final String chairName;
  final Map<String, Map<String, bool>> slots;

  ChairModel({
    required this.chairId,
    required this.chairName,
    required this.slots,
  });

  factory ChairModel.fromJson(Map<String, dynamic> json) {
    final rawSlots = Map<String, dynamic>.from(json['slots'] ?? {});
    final parsed = <String, Map<String, bool>>{};

    rawSlots.forEach((date, times) {
      parsed[date] = Map<String, bool>.from(
        (times as Map).map((k, v) => MapEntry(k.toString(), v == true)),
      );
    });

    return ChairModel(
      chairId:
          json['chairId'] is int
              ? json['chairId']
              : int.parse(json['chairId'].toString()),
      chairName: json['chairName'] ?? '',
      slots: parsed,
    );
  }
}
