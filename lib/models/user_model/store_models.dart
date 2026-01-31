// =========================
// ADDRESS MODEL
// =========================
class Address {
  final String city;
  final String district;

  Address({required this.city, required this.district});

  factory Address.fromJson(Map<String, dynamic> json) {
    return Address(city: json['city'] ?? '', district: json['district'] ?? '');
  }
}

// =========================
// ADMIN MODEL
// =========================
class Admin {
  final int id;
  final String adminName;

  Admin({required this.id, required this.adminName});

  factory Admin.fromJson(Map<String, dynamic> json) {
    return Admin(id: json['id'], adminName: json['adminName']);
  }
}

// =========================
// STORE RESPONSE (ANA MODEL)
// =========================
class StoreResponse {
  final Admin admin;
  final Store store;
  final Address? address;
  final List<Chair> chairs;
  final List<Employee> employees;

  StoreResponse({
    required this.admin,
    required this.store,
    required this.chairs,
    required this.employees,
    this.address,
  });

  factory StoreResponse.fromJson(Map<String, dynamic> json) {
    return StoreResponse(
      admin: Admin.fromJson(json['admin']),
      store: Store.fromJson(json['store']),
      chairs: (json['chairs'] as List).map((e) => Chair.fromJson(e)).toList(),
      employees:
          (json['employees'] as List).map((e) => Employee.fromJson(e)).toList(),
      address:
          json['address'] != null ? Address.fromJson(json['address']) : null,
    );
  }
}

// =========================
// STORE MODEL
// =========================
class Store {
  final int id;
  final String storeName;
  final int chairCount;

  Store({required this.id, required this.storeName, required this.chairCount});

  factory Store.fromJson(Map<String, dynamic> json) {
    return Store(
      id: json['id'],
      storeName: json['storeName'],
      chairCount: json['chairCount'],
    );
  }
}

// =========================
// CHAIR MODEL
// =========================
class Chair {
  final int id;
  final String chairName;

  Chair({required this.id, required this.chairName});

  factory Chair.fromJson(Map<String, dynamic> json) {
    return Chair(id: json['id'], chairName: json['chairName']);
  }
}

// =========================
// EMPLOYEE MODEL
// =========================
class Employee {
  final int id;
  final String employeeName;

  Employee({required this.id, required this.employeeName});

  factory Employee.fromJson(Map<String, dynamic> json) {
    return Employee(id: json['id'], employeeName: json['employeeName']);
  }
}
