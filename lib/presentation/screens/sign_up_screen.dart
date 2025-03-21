import 'package:campus_picks/presentation/viewmodels/user_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'create_account_screen.dart';

class SignUpScreen extends StatefulWidget {
  @override
  _SignUpScreenState createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();
  bool isPasswordVisible = false;

  void _togglePasswordVisibility() {
    setState(() {
      isPasswordVisible = !isPasswordVisible;
    });
  }

  void _signUp() {
    String username = usernameController.text.trim();
    String email = emailController.text.trim();
    String password = passwordController.text.trim();
    String confirmPassword = confirmPasswordController.text.trim();

    if (username.isEmpty || email.isEmpty || password.isEmpty || confirmPassword.isEmpty) {
      _showErrorDialog("All fields are required!");
      return;
    }
    if (password != confirmPassword) {
      _showErrorDialog("Passwords do not match!");
      return;
    }

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => ChangeNotifierProvider(create: (context) => UserViewModel(), child: CreateAccountScreen(username: username, email: email, password: password,)))
    );
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Error"),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("OK"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black, // Dark background
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset("assets/images/logo_symbol.png", height: 100), // Replace with your logo

            SizedBox(height: 20),

            _buildTextField(usernameController, Icons.person, "User name"),
            SizedBox(height: 10),
            _buildTextField(emailController, Icons.email, "Email"),
            SizedBox(height: 10),
            _buildTextField(passwordController, Icons.lock, "Password",
                isPassword: true),
            SizedBox(height: 10),
            _buildTextField(confirmPasswordController, Icons.lock, "Confirm password",
                isPassword: true),

            SizedBox(height: 20),

            ElevatedButton(
              onPressed: _signUp,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.purple,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                padding: EdgeInsets.symmetric(vertical: 15, horizontal: 80),
              ),
              child: Text("Continue", style: TextStyle(fontSize: 18)),
            ),

            SizedBox(height: 20),

            GestureDetector(
              onTap: () {
                Navigator.pop(context);
              },
              child: Text(
                "Already have an account? Sign In",
                style: TextStyle(color: Colors.white, fontSize: 14),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController controller, IconData icon, String hintText,
    {bool isPassword = false}) {
    return TextField(
      controller: controller,
      obscureText: isPassword && !isPasswordVisible,
      style: TextStyle(color: Colors.white),
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
        hintStyle: TextStyle(color: Colors.grey),
        filled: true,
        fillColor: Colors.grey[900],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}
