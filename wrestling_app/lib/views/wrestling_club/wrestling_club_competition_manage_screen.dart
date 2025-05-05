import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import 'package:wrestling_app/services/constants.dart';
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
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(16.0, 0.0, 16.0, 0.0),
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [

            const SizedBox(height: 30),

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

            ElevatedButton(
              onPressed: () => generateCompetitionPdf(context, invitation['competition_UUID']),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFB4182D),
                padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
              ),
              child: const Text(
                'Rezultate competiție',
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
            ),

            const SizedBox(height: 50),

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
                      _wrestlingClubService.updateInvitationStatus(
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
                      _wrestlingClubService.updateInvitationStatus(
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

  Future<void> generateCompetitionPdf(BuildContext context, int competitionUuid) async {
    final endpoint = 'https://b0i2d55s30.execute-api.us-east-1.amazonaws.com/wrestling/getCompetitionURL';
    final uri = Uri.parse('$endpoint?competition_UUID=$competitionUuid');

    try {
      final res = await http.get(uri);
      if (res.statusCode != 200) {
        throw Exception('HTTP ${res.statusCode}');
      }

      // 1) Decode outer wrapper
      final outer = jsonDecode(res.body) as Map<String, dynamic>;

      // 2) Unwrap the inner `body` string (if present)
      final String innerBody = outer.containsKey('body')
          ? outer['body'] as String
          : jsonEncode(outer);

      // 3) Decode that inner JSON
      final payload = jsonDecode(innerBody) as Map<String, dynamic>;

      // 4) Now grab `url`
      final url = payload['url'] as String?;
      if (url == null) throw Exception('URL not found in response');

      final pdfUri = Uri.parse(url);
      if (!await canLaunchUrl(pdfUri)) {
        throw Exception('Nu pot deschide URL-ul PDF');
      }
      await launchUrl(pdfUri, mode: LaunchMode.externalApplication);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Eroare la generarea PDF: $e')),
      );
    }
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