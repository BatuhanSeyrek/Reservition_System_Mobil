class Chair {
  final int chairId;
  final String chairName;
  Map<String, Map<String, bool>> slots; // date -> time -> available

  Chair({required this.chairId, required this.chairName, required this.slots});

  factory Chair.fromJson(Map<String, dynamic> json) {
    Map<String, Map<String, bool>> slotMap = {};
    (json['slots'] as Map<String, dynamic>).forEach((date, times) {
      slotMap[date] = (times as Map<String, dynamic>).map(
        (time, available) => MapEntry(time, available as bool),
      );
    });

    return Chair(
      chairId: json['chairId'],
      chairName: json['chairName'],
      slots: slotMap,
    );
  }
}
