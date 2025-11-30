import 'package:rezervasyon_mobil/models/admin_model.dart';
import 'package:rezervasyon_mobil/models/chair_model.dart';
import 'package:rezervasyon_mobil/models/employee_model.dart';
import 'package:rezervasyon_mobil/models/store_model.dart';

class StoreAllModel {
  final AdminModel admin;
  final Store store;
  final List<Employee> employees;
  final List<Chair> chairs;

  StoreAllModel({
    required this.admin,
    required this.store,
    required this.employees,
    required this.chairs,
  });

  factory StoreAllModel.fromJson(Map<String, dynamic> json) {
    return StoreAllModel(
      admin: AdminModel.fromJson(json['admin']),
      store: Store.fromJson(json['store']),
      employees:
          (json['employees'] as List).map((e) => Employee.fromJson(e)).toList(),
      chairs: (json['chairs'] as List).map((e) => Chair.fromJson(e)).toList(),
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'admin': admin.toJson(),
      'store': store.toJson(),
      'employees': employees.map((e) => e.toJson()).toList(),
      'chairs': chairs.map((e) => e.toJson()).toList(),
    };
  }
}
