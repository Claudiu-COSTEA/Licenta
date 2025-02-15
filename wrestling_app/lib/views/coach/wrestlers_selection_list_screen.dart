import 'package:flutter/material.dart';
import 'package:wrestling_app/views/shared/widgets/custom_list.dart';

class WrestlersSelectionListScreen extends StatefulWidget {
  const WrestlersSelectionListScreen({super.key});

  @override
  State<WrestlersSelectionListScreen> createState() => _WrestlersSelectionListScreen();
}

class _WrestlersSelectionListScreen extends State<WrestlersSelectionListScreen> {
  @override
  Widget build(BuildContext context) {
    final List<String> pendingCompetitions = [
      "Nume complet luptator 1",
      "Nume complet luptator 2",
      "Nume complet luptator 3",
    ];

    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 40),  // Top spacing
            Center(
              child: Text(
                'Lista luptatori pentru selectie',
                style: TextStyle(
                  fontSize: 25,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ),
            Expanded(
              child: CustomList(items: pendingCompetitions),  // Custom list widget
            ),
          ],
        ),
      ),
    );
  }
}
