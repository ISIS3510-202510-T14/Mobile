class User {
  String id;
  String name;
  String email;

  User({required this.id, required this.name, required this.email});

  factory User.fromFirestore(Map<String, dynamic> json, String id) {
    return User(
      id: id,
      name: json['name'] ?? '',
      email: json['email'] ?? '',
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'email': email,
    };
  }
}

}
