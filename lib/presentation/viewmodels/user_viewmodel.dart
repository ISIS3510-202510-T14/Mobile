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

  Future<void> addUser(String name, String email) async {
    try {
      await _userRepository.createUser(name, email);
      loadUsers(); // Refresh user list after adding
    } catch (e) {
      print("Error adding user: $e");
    }
  }
}
