import 'package:flutter/material.dart';
import '../../services/google_maps_lunch.dart';
import '../../services/wrestling_clubs_apis_services.dart';
import 'coach_selection_list.dart';


class WrestlingClubCompetitionManageScreen extends StatefulWidget {
  final Map<String, dynamic> competitionInvitation;
  final int userUUID;

  const WrestlingClubCompetitionManageScreen({required this.competitionInvitation, super.key, required this.userUUID});

  @override
  State<WrestlingClubCompetitionManageScreen> createState() => _WrestlingClubCompetitionManageScreen();
}

class _WrestlingClubCompetitionManageScreen extends State<WrestlingClubCompetitionManageScreen> {
  final WrestlingClubService _wrestlingClubService = WrestlingClubService();
  final bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    final invitation = widget.competitionInvitation;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.fromLTRB(16.0, 0.0, 16.0, 0.0),
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [

            const SizedBox(height: 40),

            Align(
              alignment: Alignment.centerLeft,
              child: IconButton(
                icon: const Icon(
                    Icons.arrow_back, color: Colors.black, size: 28),
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
                style: const TextStyle(
                    fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),

            const SizedBox(height: 30),

            // Invitation Deadline
            _buildInfoBox(
              child: Text(
                "Data limita : ${invitation['invitation_deadline']}",
                style: const TextStyle(
                    fontSize: 18, fontWeight: FontWeight.bold),
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
                style: TextStyle(color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFB4182D),
                padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 12),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
              ),
            ),

            const SizedBox(height: 100),


            // Selection Button
            _buildActionButton( invitation['invitation_status'] == "Pending" ? "Selectia antrenorilor" : "Antrenori selectati", () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) =>
                    CoachSelectionList(widget.userUUID,
                      competitionUUID: invitation['competition_UUID'],
                      competitionDeadline: invitation['invitation_deadline'], invitationStatus: invitation['invitation_status'],)), // Replace HomePage with your destination
              );
            }),

            const SizedBox(height: 15),

            if (invitation['invitation_status'] == "Pending")
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                // Ensures spacing between buttons
                children: [
                  Expanded( // Ensures buttons take equal width
                    child: _buildActionButton("Accepta", () {
                      _wrestlingClubService.updateWrestlingClubInvitationStatus(
                        context: context,
                        competitionUUID: invitation['competition_UUID'],
                        recipientUUID: widget.userUUID,
                        recipientRole: invitation['recipient_role'],
                        invitationStatus: 'Accepted',
                      );
                    }),
                  ),
                  const SizedBox(width: 10), // Spacing between buttons
                  Expanded(
                    child: _buildActionButton("Refuza", () {
                      _wrestlingClubService.updateWrestlingClubInvitationStatus(
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
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10)),
        ),
        child: Text(
          text,
          style: const TextStyle(
              color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}