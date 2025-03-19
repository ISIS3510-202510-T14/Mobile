import 'package:flutter/material.dart';
import '../../data/models/user.dart';
import '../../data/repositories/user_repository.dart';

class UserViewModel extends ChangeNotifier {
  final UserRepository _userRepository = UserRepository();
  List<User> _users = [];
  bool _isLoading = false;

  List<User> get users => _users;
  bool get isLoading => _isLoading;

  Future<void> loadUsers() async {
    _isLoading = true;
    notifyListeners();

    try {
      _users = await _userRepository.fetchUsers();
    } catch (e) {
      print("Error loading users: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addUser(String username, String fullName, String phoneNumber, String email, int age, String gender) async {
    try {
      await _userRepository.createUser(username, fullName, phoneNumber, email, age, gender);
      loadUsers();
    } catch (e) {
      print("Error adding user: $e");
    }
  }
}
