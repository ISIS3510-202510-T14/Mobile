// lib/presentation/screens/sign_up_screen.dart

import 'package:campus_picks/presentation/viewmodels/user_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'create_account_screen.dart';
import 'package:campus_picks/data/services/auth.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final TextEditingController usernameController   = TextEditingController();
  final TextEditingController emailController      = TextEditingController();
  final TextEditingController passwordController   = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();
  bool isPasswordVisible = false;

  void _togglePasswordVisibility() {
    setState(() => isPasswordVisible = !isPasswordVisible);
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Error'),
        content: Text(message),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('OK')),
        ],
      ),
    );
  }

  Future<void> _signUp() async {
    final username = usernameController.text.trim();
    final email    = emailController.text.trim();
    final password = passwordController.text.trim();
    final confirm  = confirmPasswordController.text.trim();

    // ───── Local validation ─────
    if ([username, email, password, confirm].any((s) => s.isEmpty)) {
      _showErrorDialog('All fields are required!');
      return;
    }
    if (username.length > 20) {
      _showErrorDialog('User name cannot exceed 20 characters');
      return;
    }
    if (password != confirm) {
      _showErrorDialog('Passwords do not match!');
      return;
    }
    if (password.length < 6) { // optional UX guard (Firebase will also enforce)
      _showErrorDialog('Password must be at least 6 characters');
      return;
    }
    if (password.length > 50) {
      _showErrorDialog('Password cannot exceed 50 characters');
      return;
    }

    // ───── Remote call ─────
    try {
      await authService.value.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // ───── Success path ─────
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => ChangeNotifierProvider(
            create: (_) => UserViewModel(),
            child: CreateAccountScreen(
              username: username,
              email: email,
              password: password,
            ),
          ),
        ),
      );
    } on FirebaseAuthException catch (e) {
      _showErrorDialog(e.message ?? 'Authentication error');
      return; // stop on failure
    } catch (e) {
      _showErrorDialog(e.toString());
      return;
    }
  }

  Widget _buildTextField(
    TextEditingController controller,
    IconData icon,
    String hintText, {
    bool isPassword = false,
    int? maxLength,
    TextInputType? keyboardType,
  }) {
    return TextField(
      controller: controller,
      obscureText: isPassword && !isPasswordVisible,
      keyboardType: keyboardType,
      maxLength: maxLength,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        prefixIcon: Icon(icon, color: Colors.white),
        suffixIcon: isPassword
            ? IconButton(
                icon: Icon(
                  isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                  color: Colors.white,
                ),
                onPressed: _togglePasswordVisibility,
              )
            : null,
        hintText: hintText,
        hintStyle: const TextStyle(color: Colors.grey),
        filled: true,
        fillColor: Colors.grey[900],
        counterText: '',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset('assets/images/logo_symbol.png', height: 100),
            const SizedBox(height: 20),

            _buildTextField(
              usernameController,
              Icons.person,
              'User name',
              maxLength: 20,
            ),
            const SizedBox(height: 10),
            _buildTextField(emailController, Icons.email, 'Email', maxLength: 50,),
            const SizedBox(height: 10),
            _buildTextField(
              passwordController,
              Icons.lock,
              'Password',
              isPassword: true,
              maxLength: 50,
            ),
            const SizedBox(height: 10),
            _buildTextField(
              confirmPasswordController,
              Icons.lock,
              'Confirm password',
              isPassword: true,
              maxLength: 50,
            ),
            const SizedBox(height: 20),

            ElevatedButton(
              onPressed: _signUp,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.purple,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 80),
              ),
              child: const Text('Continue', style: TextStyle(fontSize: 18)),
            ),
            const SizedBox(height: 20),
            GestureDetector(
              onTap: () => Navigator.pop(context),
              child: const Text(
                'Already have an account? Sign In',
                style: TextStyle(color: Colors.white, fontSize: 14),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
