import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user.dart';

class UserRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<User>> fetchUsers() async {
    QuerySnapshot snapshot = await _firestore.collection('users').get();
    return snapshot.docs
        .map((doc) => User.fromFirestore(doc.data() as Map<String, dynamic>, doc.id))
        .toList();
  }

  Future<void> createUser(String username, String fullName, String phoneNumber, String email, int age, String gender) async {
    await _firestore.collection('users').add({
      'username': username,
      'fullName': fullName,
      'phoneNumber': phoneNumber,
      'email': email,
      'age': age,
      'gender': gender
    });
  }
}