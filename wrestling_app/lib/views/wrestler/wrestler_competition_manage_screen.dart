import 'package:flutter/material.dart';
import 'package:wrestling_app/models/wrestler_documents_model.dart';
import 'package:wrestling_app/services/wrestler_apis_services.dart';

import 'package:wrestling_app/services/google_maps_lunch.dart';

import 'get_qr_code.dart';


class WrestlerCompetitionManageScreen extends StatefulWidget {
  final Map<String, dynamic> competitionInvitation;
  final int userUUID;

  const WrestlerCompetitionManageScreen({required this.competitionInvitation, super.key, required this.userUUID});

  @override
  State<WrestlerCompetitionManageScreen> createState() => _WrestlerCompetitionManageScreen();
}

class _WrestlerCompetitionManageScreen extends State<WrestlerCompetitionManageScreen> {

  final WrestlerService _wrestlerService = WrestlerService();
  final bool _isLoading = false;
  static const Color primary  = Color(0xFFB4182D);

  @override
  Widget build(BuildContext context) {
    final invitation = widget.competitionInvitation;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: _isLoading
            ? const Center(child: CircularProgressIndicator(color: primary,))
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

            // Invitation Deadline
            _buildInfoBox(
              child: Text(
                "Categoria de greutate : ${invitation['weight_category']}",
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

            if (invitation['invitation_status'] == "Pending")
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                // Ensures spacing between buttons
                children: [
                  Expanded( // Ensures buttons take equal width
                    child: _buildActionButton("Accepta", () {
                      _wrestlerService.updateInvitationStatus(
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
                      _wrestlerService.updateInvitationStatus(
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