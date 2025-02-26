import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

// Custom Button Widget
class CustomButton extends StatefulWidget {
  final String label;
  final VoidCallback onPressed;

  const CustomButton({super.key, required this.label, required this.onPressed});

  @override
  State<CustomButton> createState() => _CustomButtonState();
}

class _CustomButtonState extends State<CustomButton> {
  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: widget.onPressed,
      style: ElevatedButton.styleFrom(
        padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(50),
        ),
        backgroundColor: Color(0xFFB4182D),
        elevation: 5,
      ),
      child: Text(
        widget.label,
        style: TextStyle(fontSize: 16, color: Colors.white),
      ),
    );
  }
}


