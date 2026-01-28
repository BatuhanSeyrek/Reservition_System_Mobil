class Address {
  final String city;
  final String district;

  Address({required this.city, required this.district});

  factory Address.fromJson(Map<String, dynamic> json) {
    return Address(
      // Backend'deki @Column isimlerine göre küçük harf city ve district
      city: json['city'] ?? '',
      district: json['district'] ?? '',
    );
  }
}

class Admin {
  final int id;
  final String adminName;
  final Address? address;

  Admin({required this.id, required this.adminName, this.address});

  factory Admin.fromJson(Map<String, dynamic> json) {
    return Admin(
      id: json['id'],
      adminName: json['adminName'],
      address:
          json['address'] != null ? Address.fromJson(json['address']) : null,
    );
  }
}

class StoreResponse {
  final Admin admin;
  final List<Chair> chairs;
  final List<Employee> employees;
  final Store store;

  StoreResponse({
    required this.admin,
    required this.chairs,
    required this.employees,
    required this.store,
  });

  factory StoreResponse.fromJson(Map<String, dynamic> json) {
    return StoreResponse(
      admin: Admin.fromJson(json['admin']),
      chairs: (json['chairs'] as List).map((e) => Chair.fromJson(e)).toList(),
      employees:
          (json['employees'] as List).map((e) => Employee.fromJson(e)).toList(),
      store: Store.fromJson(json['store']),
    );
  }
}

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

class Chair {
  final int id;
  final String chairName;
  Chair({required this.id, required this.chairName});
  factory Chair.fromJson(Map<String, dynamic> json) =>
      Chair(id: json['id'], chairName: json['chairName']);
}

class Employee {
  final int id;
  final String employeeName;
  Employee({required this.id, required this.employeeName});
  factory Employee.fromJson(Map<String, dynamic> json) =>
      Employee(id: json['id'], employeeName: json['employeeName']);
}
