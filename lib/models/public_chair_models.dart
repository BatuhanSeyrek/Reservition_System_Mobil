class PublicChairModel {
  final int chairId;
  final String chairName;
  final Map<String, Map<String, bool>> slots;

  PublicChairModel({
    required this.chairId,
    required this.chairName,
    required this.slots,
  });

  factory PublicChairModel.fromJson(Map<String, dynamic> json) {
    Map<String, Map<String, bool>> parsedSlots = {};

    final rawSlots = json["slots"] as Map<String, dynamic>;

    rawSlots.forEach((date, times) {
      parsedSlots[date] = Map<String, bool>.from(times);
    });

    return PublicChairModel(
      chairId: json["chairId"],
      chairName: json["chairName"],
      slots: parsedSlots,
    );
  }
}
