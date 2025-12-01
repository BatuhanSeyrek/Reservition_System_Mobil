class User {
  final String email;
  final String phoneNumber;
  final String notificationType;
  final String userName;
  final String password;

  User({
    required this.email,
    required this.phoneNumber,
    required this.notificationType,
    required this.userName,
    required this.password,
  });
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      email: json['email'],
      phoneNumber: json['phoneNumber'],
      notificationType: json['notificationType'],
      userName: json['userName'],
      password: json['password'],
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'phoneNumber': phoneNumber,
      'notificationType': notificationType,
      'userName': userName,
      'password': password,
    };
  }
}
