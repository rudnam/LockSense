import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:locksense/pages/auth_page.dart';
import 'package:locksense/services/firebase_service.dart';
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
    await FirebaseService().initNotifications();
  }

@override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _initializeFirebase(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const MaterialApp(
            home: Scaffold(
              body: Center(child: CircularProgressIndicator()),
            ),
          );
        } else if (snapshot.hasError) {
          return const MaterialApp(
            home: Scaffold(
              body: Center(child: Text('Error initializing Firebase')),
            ),
          );
        } else {
          return MaterialApp(
            title: 'LockSense',
            theme: AppTheme.themeData,
            darkTheme: AppTheme.darkThemeData,
            themeMode: ThemeMode.system,
            home: const AuthPage(),
          );
        }
      },
    );
  }
}
