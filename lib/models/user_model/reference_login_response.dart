class ReferenceLoginResponse {
  final String referenceId;
  final String adminName;
  final int adminId;
  final String storeName;

  ReferenceLoginResponse({
    required this.referenceId,
    required this.adminName,
    required this.adminId,
    required this.storeName,
  });

  factory ReferenceLoginResponse.fromJson(Map<String, dynamic> json) {
    return ReferenceLoginResponse(
      referenceId: json["referenceId"],
      adminName: json["adminName"],
      adminId: json["id"],
      storeName: json["storeName"],
    );
  }
}
