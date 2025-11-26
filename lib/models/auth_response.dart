class AuthResponse {
  final int id;
  final String name; // Admin için 'name', user için 'userName' farkı var
  final String token;

  AuthResponse({required this.id, required this.name, required this.token});

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      id: json['id'],
      name: json['name'] ?? json['userName'] ?? '',
      token: json['token'],
    );
  }
}
