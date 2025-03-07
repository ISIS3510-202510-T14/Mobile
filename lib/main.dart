import 'package:flutter/material.dart';
import 'theme/app_theme.dart';
import 'login_screen.dart'; // or your chosen path

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Campus Picks',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,  // The dark theme from our design system
      home: const LoginScreen(),  // <--- Use LoginScreen here
    );
  }
}
