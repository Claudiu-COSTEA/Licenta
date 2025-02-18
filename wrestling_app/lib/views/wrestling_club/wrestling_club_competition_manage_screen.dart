import 'package:flutter/material.dart';
import 'package:wrestling_app/views/wrestling_club/coach_selection_list.dart';


class WrestlingClubCompetitionManageScreen extends StatefulWidget {
  final Map<String, dynamic> competitionInvitation;
  final int userUUID;

  const WrestlingClubCompetitionManageScreen({required this.competitionInvitation, super.key, required this.userUUID});

  @override
  State<WrestlingClubCompetitionManageScreen> createState() => _WrestlingClubCompetitionManageScreen();
}

class _WrestlingClubCompetitionManageScreen extends State<WrestlingClubCompetitionManageScreen> {
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    final invitation = widget.competitionInvitation;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 70),

            // Competition Name
            Center(
              child: Text(
                invitation['competition_name'] ?? "Unknown Competition",
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
                textAlign: TextAlign.center,
              ),
            ),

            const SizedBox(height: 30),

            // Competition Period
            _buildInfoBox(
              child: Text(
                "Perioada : ${invitation['competition_start_date']} - ${invitation['competition_end_date']}",
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),

            const SizedBox(height: 30),

            // Invitation Deadline
            _buildInfoBox(
              child: Text(
                "Data limita : ${invitation['invitation_deadline']}",
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),

            const SizedBox(height: 30),

            // Location Button
            ElevatedButton.icon(
              onPressed: () {
                _showLocationDialog(context, invitation['competition_location']);
              },
              icon: const Icon(Icons.location_on, color: Colors.white),
              label: const Text(
                "Vizualizare locatie",
                style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFB4182D),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),

            const SizedBox(height: 100),

            // Selection Button
            _buildActionButton("Selectia antrenorilor", () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => CoachSelectionList(widget.userUUID, competitionUUID: invitation['competition_UUID'], competitionDeadline: invitation['invitation_deadline'],)), // Replace HomePage with your destination
              );
            }),

            const SizedBox(height: 15),

            // Selected Coaches Button
            _buildActionButton("Antrenori selectati", () {
              // TODO: Implement navigation or functionality
            }),

            const SizedBox(height: 15),

            // Submit Response Button
            _buildActionButton("Trimite raspuns", () {
              // TODO: Implement response submission
            }),
          ],
        ),
      ),
    );
  }

  // Function to Show Location Dialog
  void _showLocationDialog(BuildContext context, String? location) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Competitie Locatie"),
          content: Text(location ?? "Locatie indisponibila"),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Inchide"),
            ),
          ],
        );
      },
    );
  }

  // Box Wrapper for Information Sections
  Widget _buildInfoBox({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFFB4182D), width: 2),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Center(child: child),
    );
  }

  // Button for Actions
  Widget _buildActionButton(String text, VoidCallback onPressed) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFB4182D),
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
        child: Text(
          text,
          style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
