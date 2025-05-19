class CurrentUser {
  final String id;
  final String name;
  final String email;
  final String? country;

  CurrentUser({
    required this.id,
    required this.name,
    required this.email,
    this.country,
  });

  factory CurrentUser.fromJson(Map<String, dynamic> json) {
    return CurrentUser(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      country: json['country'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'country': country,
    };
  }
}
