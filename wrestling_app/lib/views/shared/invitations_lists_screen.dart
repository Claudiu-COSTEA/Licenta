import 'package:flutter/material.dart';
import 'package:wrestling_app/views/shared/widgets/custom_list.dart';

class InvitationsListsScreen extends StatefulWidget {
  const InvitationsListsScreen({super.key});

  @override
  State<InvitationsListsScreen> createState() => _InvitationsListsScreenState();
}

class _InvitationsListsScreenState extends State<InvitationsListsScreen> {
  @override
  Widget build(BuildContext context) {
    final List<String> pendingCompetitions = [
      "Competitie 1",
      "Competitie 2",
      "Competitie 3",
    ];

    final List<String> respondedCompetitions = [
      "Competitie 7",
      "Competitie 8",
      "Competitie 9",
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
                'Lista invitatii fara raspuns',
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
            Center(
              child: Text(
                'Lista invitatii cu raspuns',
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
