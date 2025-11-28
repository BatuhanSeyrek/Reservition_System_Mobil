class Employee {
  final int id;
  final String employeeName;
  final int chairId;
  final int adminId;

  Employee({
    required this.id,
    required this.employeeName,
    required this.chairId,
    required this.adminId,
  });

  factory Employee.fromJson(Map<String, dynamic> json) {
    return Employee(
      id: json['id'],
      employeeName: json['employeeName'],
      adminId: json['adminId'],
      chairId: json['chairId'],
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      "employeeName": employeeName,
      "chairId": chairId,
      "adminId": adminId,
    };
  }
}
