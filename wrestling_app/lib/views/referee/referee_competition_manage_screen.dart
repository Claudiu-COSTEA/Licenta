import 'package:flutter/material.dart';
import 'package:wrestling_app/services/referee_api_services.dart';
import 'package:wrestling_app/services/google_maps_lunch.dart';
import 'package:wrestling_app/views/referee/referee_weight_categories_verification.dart';

class RefereeCompetitionManageScreen extends StatefulWidget {
  final Map<String, dynamic> competitionInvitation;
  final int userUUID;

  const RefereeCompetitionManageScreen({required this.competitionInvitation, super.key, required this.userUUID});

  @override
  State<RefereeCompetitionManageScreen> createState() => _RefereeCompetitionManageScreen();
}

class _RefereeCompetitionManageScreen extends State<RefereeCompetitionManageScreen> {
  final RefereeServices _refereeServices = RefereeServices();
  final bool _isLoading = false; // Corrected: Ensure state updates

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
                  Navigator.of(context).pop();
                },
              ),
            ),
            const SizedBox(height: 70),

            // Competition Name
            Center(
              child: Text(
                invitation['competition_name'] ?? "Unknown Competition",
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black),
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

            const SizedBox(height: 50), // Adjusted spacing

            // **Action Buttons Based on Invitation Status**
            if (invitation['invitation_status'] == "Pending")
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                // Ensures spacing between buttons
                children: [
                  Expanded( // Ensures buttons take equal width
                    child: _buildActionButton("Accepta", () {
                      _refereeServices.updateRefereeInvitationStatus(
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
                      _refereeServices.updateRefereeInvitationStatus(
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

            if (invitation['invitation_status'] == "Accepted")
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildActionButton("Verificare sportivi", () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => RefereeWeightCategoriesVerification(competitionUUID: invitation['competition_UUID'],),
                      ),
                    );
                  }),
                  const SizedBox(height: 10),
                  _buildActionButton("Renunță la participare", () {
                  }),
                ],
              ),
          ],
        ),
      ),
    );
  }

  // **Box Wrapper for Information Sections**
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

  // **Button for Actions**
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
