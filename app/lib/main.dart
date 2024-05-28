import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:locksense/pages/auth_page.dart';
import './theme/style.dart';
import './firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  Future<void> _initializeFirebase() async {
    await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _initializeFirebase(),
      builder: (context, snapshot) {
        return MaterialApp(
          title: 'LockSense',
          theme: AppTheme.themeData,
          darkTheme: AppTheme.darkThemeData,
          themeMode: ThemeMode.system,
          home: snapshot.connectionState == ConnectionState.waiting
              ? const Center(child: CircularProgressIndicator())
              : snapshot.hasError
                  ? const Center(child: Text('Error initializing Firebase'))
                  : const AuthPage(),
        );
      },
    );
  }
}
