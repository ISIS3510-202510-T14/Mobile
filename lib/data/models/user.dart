class User {
  String id;
  String username;
  String fullName;
  String phoneNumber;
  String email;
  int age;
  String gender;

  User({required this.id, required this.username, required this.fullName, required this.phoneNumber, required this.email, required this.age, required this.gender});

  factory User.fromFirestore(Map<String, dynamic> json, String id) {
    return User(
      id: id,
      username: json['username'] ?? '',
      fullName: json['fullName'] ?? '',
      phoneNumber: json['phoneNumber'] ?? '',
      email: json['email'] ?? '',
      age: json['age'] ?? 0,
      gender: json['gender'] ?? '',
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'username': username,
      'fullName': fullName,
      'phoneNumber': phoneNumber,
      'email': email,
      'age': age,
      'gender': gender,
    };
  }
}


