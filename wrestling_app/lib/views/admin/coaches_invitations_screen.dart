import 'package:flutter/material.dart';

class CoachesListScreen extends StatelessWidget {
  const CoachesListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Antrenori'),
        backgroundColor: const Color(0xFFB4182D),
      ),
      body: const Center(
        child: Text(
          'Ecran — ANTRENORI',
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
