import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import './main_screen.dart';
import './theme/style.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});


  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'LockSense',
      theme: AppTheme.themeData,
      darkTheme: AppTheme.darkThemeData,
      themeMode: ThemeMode.system,
      home: const MainScreen(),
    );
  }
}