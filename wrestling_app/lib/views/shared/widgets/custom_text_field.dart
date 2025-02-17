import 'package:flutter/material.dart';

class CustomTextField extends StatelessWidget {
  final String label;
  final bool obscureText;
  final TextEditingController controller;

  const CustomTextField({
    super.key,
    required this.label,
    required this.obscureText,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      style: TextStyle(color: Colors.white),  // White text inside the field
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Colors.black), // Black label text
        filled: true,
        fillColor: Color(0xFFB4182D),  // Dark red background for the field
        contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20.0),
        ),
      ),
    );
  }
}
