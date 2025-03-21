import 'package:campus_picks/data/services/auth.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/user_viewmodel.dart';

class CreateAccountScreen extends StatefulWidget {
  final String username;
  final String email;
  final String password;

  const CreateAccountScreen({
    Key? key,
    required this.username,
    required this.email,
    required this.password,
  }) : super(key: key);

  @override
  _CreateAccountScreenState createState() => _CreateAccountScreenState();
}

class _CreateAccountScreenState extends State<CreateAccountScreen> {
  final TextEditingController fullNameController = TextEditingController();
  final TextEditingController phoneNumberController = TextEditingController();
  int? selectedAge;
  String selectedGender = 'Male';

  void _submitForm() async {
    UserViewModel userViewModel = Provider.of<UserViewModel>(context, listen: false);


    if (fullNameController.text.isEmpty || phoneNumberController.text.isEmpty || selectedAge == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all fields')),
      );
      return;
    }

    userViewModel.addUser(
      widget.username,
      fullNameController.text,
      phoneNumberController.text,
      widget.email,
      selectedAge!,
      selectedGender,
    );

    try {
      await authService.value.createUserWithEmailAndPassword(email: widget.email, password: widget.password);
    } on FirebaseAuthException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    }

    userViewModel.clearData();
    Navigator.popUntil(context, (route) => route.isFirst);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Create An Account",
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            GestureDetector(
              onTap: () {},
              child: CircleAvatar(
                radius: 40,
                backgroundColor: Colors.purple,
                child: const Icon(Icons.camera_alt, color: Colors.white),
              ),
            ),
            const SizedBox(height: 20),
            _buildTextField(fullNameController, "Full name", Icons.person),
            _buildTextField(phoneNumberController, "Phone number", Icons.phone),
            _buildDropdownAge(),
            _buildDropdownGender(),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _submitForm,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.purple,
                minimumSize: const Size(double.infinity, 50),
              ),
              child: const Text("Submit", style: TextStyle(color: Colors.white, fontSize: 16)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String hint, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: TextField(
        controller: controller,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          filled: true,
          fillColor: Colors.grey[900],
          hintText: hint,
          hintStyle: const TextStyle(color: Colors.white70),
          prefixIcon: Icon(icon, color: Colors.white70),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }

  Widget _buildDropdownAge() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: DropdownButtonFormField<int>(
        value: selectedAge,
        dropdownColor: Colors.black,
        style: const TextStyle(color: Colors.white),
        items: List.generate(100, (index) => index + 1)
            .map((age) => DropdownMenuItem<int>(
                  value: age,
                  child: Text(age.toString(), style: const TextStyle(color: Colors.white)),
                ))
            .toList(),
        onChanged: (value) => setState(() => selectedAge = value),
        decoration: InputDecoration(
          filled: true,
          fillColor: Colors.grey[900],
          hintText: "Age",
          hintStyle: const TextStyle(color: Colors.white70),
          prefixIcon: const Icon(Icons.calendar_today, color: Colors.white70),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }

  Widget _buildDropdownGender() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: DropdownButtonFormField<String>(
        value: selectedGender,
        dropdownColor: Colors.black,
        style: const TextStyle(color: Colors.white),
        items: ["Male", "Female", "Other"]
            .map((gender) => DropdownMenuItem<String>(
                  value: gender,
                  child: Text(gender, style: const TextStyle(color: Colors.white)),
                ))
            .toList(),
        onChanged: (value) => setState(() => selectedGender = value!),
        decoration: InputDecoration(
          filled: true,
          fillColor: Colors.grey[900],
          hintText: "Gender",
          hintStyle: const TextStyle(color: Colors.white70),
          prefixIcon: const Icon(Icons.person_outline, color: Colors.white70),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }
}