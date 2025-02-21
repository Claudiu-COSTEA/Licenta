import 'package:flutter/material.dart';

class CustomLabel extends StatefulWidget {
  final String text;

  const CustomLabel({super.key, required this.text});

  @override
  State<CustomLabel> createState() => _CustomLabelState();
}

class _CustomLabelState extends State<CustomLabel> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4.0),
      child: Text(
        widget.text,
        style: TextStyle(
          color: Colors.black,
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
