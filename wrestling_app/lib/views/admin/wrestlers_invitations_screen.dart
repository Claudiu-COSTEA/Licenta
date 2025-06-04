import 'package:flutter/material.dart';

class WrestlersListScreen extends StatelessWidget {
  const WrestlersListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Luptători'),
        backgroundColor: const Color(0xFFB4182D),
      ),
      body: const Center(
        child: Text(
          'Ecran — LUPTĂTORI',
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
