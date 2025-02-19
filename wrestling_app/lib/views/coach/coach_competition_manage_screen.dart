import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:wrestling_app/views/coach/wrestlers_selection_list.dart';
import 'package:wrestling_app/views/wrestling_club/coach_selection_list.dart';

import 'package:wrestling_app/services/google_maps_lunch.dart';


class CoachCompetitionManageScreen extends StatefulWidget {
  final Map<String, dynamic> competitionInvitation;
  final int userUUID;

  const CoachCompetitionManageScreen({required this.competitionInvitation, super.key, required this.userUUID});

  @override
  State<CoachCompetitionManageScreen> createState() => _CoachCompetitionManageScreen();
}

class _CoachCompetitionManageScreen extends State<CoachCompetitionManageScreen> {
  final bool _isLoading = false;

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
            Align(
              alignment: Alignment.centerLeft,
              child: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.black, size: 28),
                onPressed: () {
                  Navigator.pop(context); // Go back to the previous screen
                },
              ),
            ),
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
                openGoogleMaps(invitation['competition_location']);
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
            _buildActionButton("Selectia luptatorilor", () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => WrestlersSelectionList(widget.userUUID, competitionUUID: invitation['competition_UUID'], competitionDeadline: invitation['invitation_deadline'],)), // Replace HomePage with your destination
              );
            }),

            const SizedBox(height: 15),

            if (invitation['invitation_status'] == "Pending")
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly, // Ensures spacing between buttons
                children: [
                  Expanded( // Ensures buttons take equal width
                    child: _buildActionButton("Confirma", () {
                      updateInvitationStatus(
                        context: context,
                        competitionUUID: invitation['competition_UUID'],
                        recipientUUID: widget.userUUID,
                        recipientRole: invitation['recipient_role'],
                        invitationStatus: 'Confirmed',
                      );
                    }),
                  ),
                  const SizedBox(width: 10), // Spacing between buttons
                  Expanded(
                    child: _buildActionButton("Refuza", () {
                      updateInvitationStatus(
                        context: context,
                        competitionUUID: invitation['competition_UUID'],
                        recipientUUID: widget.userUUID,
                        recipientRole: invitation['recipient_role'],
                        invitationStatus: 'Declined',
                      );
                    }),
                  ),
                ],
              ),


          ],
        ),
      ),
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

Future<void> updateInvitationStatus({
  required BuildContext context,
  required int competitionUUID,
  required int recipientUUID,
  required String recipientRole,
  required String invitationStatus,
}) async {
  String apiUrl = "http://192.168.0.154/wrestling_app/wrestling_club/post_wrestling_club_invitation_response.php"; // Update with your API URL

  try {
    // Show loading indicator
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    // Prepare request body
    final response = await http.post(
      Uri.parse(apiUrl),
      headers: {"Content-Type": "application/json"},
      body: json.encode({
        "competition_UUID": competitionUUID,
        "recipient_UUID": recipientUUID,
        "recipient_role": recipientRole,
        "invitation_status": invitationStatus,
      }),
    );

    // Close loading dialog
    if (context.mounted) Navigator.pop(context);

    // Handle response
    if (response.statusCode == 200) {
      final responseData = json.decode(response.body);

      if (responseData.containsKey("success")) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(responseData["success"]), backgroundColor: Colors.green),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(responseData["error"] ?? "Unknown error"), backgroundColor: Colors.red),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Failed to update invitation"), backgroundColor: Colors.red),
      );
    }
  } catch (e) {
    if (context.mounted) Navigator.pop(context); // Close loading dialog if error occurs

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Error: $e"), backgroundColor: Colors.red),
    );
  }
}