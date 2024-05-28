import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:locksense/pages/home_page.dart';
import 'package:locksense/pages/login_or_register_page.dart';
import 'package:locksense/services/firebase_service.dart';

class AuthPage extends StatefulWidget {
  const AuthPage({
    super.key,
  });

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  late FirebaseService firebaseService;
  User? user;

  @override
  void initState() {
    super.initState();
    firebaseService = FirebaseService();
    FirebaseAuth.instance.authStateChanges().listen((User? user) async {
      setState(() {
        this.user = user;
      });
      if (user == null) {
        print('User is currently signed out!');
      } else {
        print('User is signed in!');
        storeUserData(user);
        await FirebaseService().initNotifications(user.uid);
      }
    });
  }

  Future<void> storeUserData(User user) async {
    Object? userData = await firebaseService.getData("users/${user.uid}");

    if (userData == null) {
      await firebaseService.writeData("users/${user.uid}", {
        'id': user.uid,
        'uid': user.uid,
        'email': user.email,
        'displayName': user.displayName ?? '',
        'locks': {},
        'notifications': {}
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: user == null ? const LoginOrRegisterPage() : const HomePage());
  }
}
