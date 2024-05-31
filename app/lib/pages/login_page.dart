import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:locksense/services/auth_service.dart';
import 'package:locksense/widgets/my_text_field.dart';

class LoginPage extends StatefulWidget {
  final Function()? onTap;
  const LoginPage({super.key, required this.onTap});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  void signUserIn() async {
    showDialog(
        context: context,
        builder: (context) {
          return const Center(child: CircularProgressIndicator());
        });

    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: emailController.text, password: passwordController.text);
      if (mounted) {
        Navigator.pop(context);
      }
    } on FirebaseAuthException catch (e) {
      if (mounted) {
        Navigator.pop(context);
      }

      String errorMessage = 'An error occurred. Please try again later.';
      print(e.code);
      if (e.code == 'invalid-email') {
        errorMessage = 'Invalid email. Please try again.';
      } else if (e.code == 'wrong-password') {
        errorMessage = 'Incorrect email or password. Please try again.';
      } else if (e.code == 'invalid-credential') {
        errorMessage = 'Incorrect email or password. Please try again.';
      }

      showErrorMessage(errorMessage);
    }
  }

  void signInWithDemo() async {
    showDialog(
        context: context,
        builder: (context) {
          return const Center(child: CircularProgressIndicator());
        });
    await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: "demo@gmail.com", password: "demopassword");
    if (mounted) {
      Navigator.pop(context);
    }
  }

  void showErrorMessage(String errorMessage) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Error'),
          content: Text(errorMessage),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15.0),
            child: SingleChildScrollView(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 400),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Icon(
                      Icons.lock,
                      size: 100,
                      color: colorScheme.primary,
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Sign in',
                          style: Theme.of(context).textTheme.headlineMedium,
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    MyTextField(
                      controller: emailController,
                      hintText: "Email",
                      obscureText: false,
                    ),
                    const SizedBox(height: 10),
                    MyTextField(
                      controller: passwordController,
                      hintText: "Password",
                      obscureText: true,
                    ),
                    const SizedBox(height: 10),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          MouseRegion(
                            cursor: SystemMouseCursors.click,
                            child: GestureDetector(
                              onTap: null,
                              child: Text("Forgot Password?",
                                  style:
                                      TextStyle(color: colorScheme.secondary)),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 30),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 15.0),
                      child: ElevatedButton(
                        onPressed: () {
                          signUserIn();
                        },
                        style: ElevatedButton.styleFrom(
                          foregroundColor: colorScheme.onPrimary,
                          backgroundColor: colorScheme.primary,
                          padding: const EdgeInsets.symmetric(vertical: 15.0),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                        ),
                        child: const Text(
                          'Sign in',
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                    ),
                    const SizedBox(height: 40),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 25.0),
                      child: Row(
                        children: [
                          Expanded(child: Divider(thickness: 0.5)),
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 10.0),
                            child: Text('Or continue with'),
                          ),
                          Expanded(child: Divider(thickness: 0.5)),
                        ],
                      ),
                    ),
                    const SizedBox(height: 40),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 15.0),
                      child: TextButton(
                        onPressed: () => signInWithDemo(),
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 17.0),
                          side: BorderSide(
                              color: colorScheme.primary, width: 0.5),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                        ),
                        child: Text(
                          'Sign in with Demo User',
                          style: TextStyle(
                            color: colorScheme.onSurface,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 15.0),
                      child: TextButton.icon(
                        onPressed: () => AuthService().signInWithGoogle(),
                        icon: Image.asset(
                          'assets/images/google-logo.png',
                          height: 24.0,
                          width: 24.0,
                        ),
                        label: Text(
                          'Google',
                          style: TextStyle(
                            color: colorScheme.onSurface,
                          ),
                        ),
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 15.0),
                          side: BorderSide(
                              color: colorScheme.primary, width: 0.5),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 40),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text("Not a member?"),
                        const SizedBox(width: 4),
                        MouseRegion(
                          cursor: SystemMouseCursors.click,
                          child: GestureDetector(
                            onTap: widget.onTap,
                            child: Text("Register now",
                                style: TextStyle(
                                    color: colorScheme.primary,
                                    fontWeight: FontWeight.bold)),
                          ),
                        )
                      ],
                    )
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
