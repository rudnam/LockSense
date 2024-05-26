import 'package:flutter/material.dart';

class MyTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final bool obscureText;

  const MyTextField({
    super.key,
    required this.controller,
    required this.hintText,
    required this.obscureText,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15.0),
      child: TextField(
        controller: controller,
        obscureText: obscureText,
        decoration: InputDecoration(
          enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color: colorScheme.surface),
              borderRadius: BorderRadius.circular(8.0)),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: colorScheme.secondary),
            borderRadius: BorderRadius.circular(8.0),
          ),
          fillColor: colorScheme.onSurface.withOpacity(0.1),
          filled: true,
          hintText: hintText,
          hintStyle: TextStyle(color: colorScheme.onSurface.withOpacity(0.5)),
        ),
      ),
    );
  }
}
