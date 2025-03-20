import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'theme/app_theme.dart';
import 'presentation/screens/login_screen.dart'; // or your chosen path
import "presentation/screens/matches_view.dart";
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'presentation/viewmodels/user_viewmodel.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
  options: DefaultFirebaseOptions.currentPlatform,
  );

  await FirebaseFirestore.instance.disableNetwork();
  await FirebaseFirestore.instance.enableNetwork();

  runApp(MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => UserViewModel(), lazy: false),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // @override
  // Widget build(BuildContext context) {
  //   return MaterialApp(
  //     title: 'Campus Picks',
  //     debugShowCheckedModeBanner: false,
  //     theme: AppTheme.darkTheme,  // The dark theme from our design system
  //     home: const LoginScreen(),  // <--- Use LoginScreen here
  //   );
  // }

   @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Demo Matches',

      theme: AppTheme.darkTheme,
      home: const LoginScreen(),
    );
  }

}
