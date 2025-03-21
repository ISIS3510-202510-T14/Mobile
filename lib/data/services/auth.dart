import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

ValueNotifier<AuthService> authService = ValueNotifier(AuthService());

class AuthService{
  final FirebaseAuth auth = FirebaseAuth.instance;

  User? get currentUser => auth.currentUser;

  Stream<User?> get authStateChanges => auth.authStateChanges();

  Future<void> signInWithEmailAndPassword({required String email, required String password}) async {
    await auth.signInWithEmailAndPassword(email: email, password: password);
  }

  Future<void> createUserWithEmailAndPassword({required String email, required String password}) async {
    await auth.createUserWithEmailAndPassword(email: email, password: password);
  }

  Future<void> signOut() async {
    await auth.signOut();
  }
}