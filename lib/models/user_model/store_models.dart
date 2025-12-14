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

class Admin {
  final int id;
  final String adminName;

  Admin({required this.id, required this.adminName});

  factory Admin.fromJson(Map<String, dynamic> json) {
    return Admin(id: json['id'], adminName: json['adminName']);
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

  factory Chair.fromJson(Map<String, dynamic> json) {
    return Chair(id: json['id'], chairName: json['chairName']);
  }
}

class Employee {
  final int id;
  final String employeeName;

  Employee({required this.id, required this.employeeName});

  factory Employee.fromJson(Map<String, dynamic> json) {
    return Employee(id: json['id'], employeeName: json['employeeName']);
  }
}
