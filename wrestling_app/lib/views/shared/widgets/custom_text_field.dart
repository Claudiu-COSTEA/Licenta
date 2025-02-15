import 'package:flutter/material.dart';

class CustomTextField extends StatelessWidget {
  final String label;
  final bool obscureText;

  const CustomTextField({super.key, required this.label, required this.obscureText});

  @override
  Widget build(BuildContext context) {
    return TextField(
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