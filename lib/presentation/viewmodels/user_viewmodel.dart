import 'package:flutter/material.dart';
import '../../data/models/user.dart';
import '../../data/repositories/user_repository.dart';

class UserViewModel extends ChangeNotifier {
  String _username = '';
  String _email = '';
  String _password = '';

  String get username => _username;
  String get email => _email;
  String get password => _password;

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
    }
  }

  Future<void> addUser(String username, String fullName, String phoneNumber, String email, int age, String gender) async {
    
    _isLoading = true;
    notifyListeners();

    try {
      await _userRepository.createUser(username, fullName, phoneNumber, email, age, gender);
    } catch (e) {
      print("Error adding user: $e");
    } finally {
      _isLoading = false;
    }
  }

  void updateUserData({String? username, String? email, String? password}) {
    if (username != null) _username = username;
    if (email != null) _email = email;
    if (password != null) _password = password;
    notifyListeners();
  }

  void clearData() {
    _username = '';
    _email = '';
    _password = '';
    notifyListeners();
  }  
}
