import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import '../../services/google_maps_lunch.dart';
import '../../services/wrestling_clubs_apis_services.dart';
import '../shared/widgets/toast_helper.dart';
import 'coach_selection_list.dart';

class WrestlingClubCompetitionManageScreen extends StatefulWidget {
  final Map<String, dynamic> competitionInvitation;
  final int userUUID;

  const WrestlingClubCompetitionManageScreen({
    required this.competitionInvitation,
    super.key,
    required this.userUUID,
  });

  @override
  State<WrestlingClubCompetitionManageScreen> createState() =>
      _WrestlingClubCompetitionManageScreen();
}

class _WrestlingClubCompetitionManageScreen
    extends State<WrestlingClubCompetitionManageScreen> {
  final WrestlingClubService _wrestlingClubService = WrestlingClubService();
  final bool _isLoading = false;
  static const Color primary = Color(0xFFB4182D);

  String _formatDateTime(String raw) {
    try {
      final dt = DateTime.parse(raw);
      return '${dt.day.toString().padLeft(2, '0')}.'
          '${dt.month.toString().padLeft(2, '0')}.'
          '${dt.year} '
          '${dt.hour.toString().padLeft(2, '0')}:'
          '${dt.minute.toString().padLeft(2, '0')}';
    } catch (_) {
      return raw;
    }
  }

  @override
  Widget build(BuildContext context) {
    final invitation = widget.competitionInvitation;
    final compName = invitation['competition_name'] ?? "Competiție necunoscută";
    final startFormatted =
    _formatDateTime(invitation['competition_start_date'] as String? ?? "");
    final endFormatted =
    _formatDateTime(invitation['competition_end_date'] as String? ?? "");
    final deadlineFormatted =
    _formatDateTime(invitation['invitation_deadline'] as String? ?? "");
    final location = invitation['competition_location'] ?? "";

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.black),
        title: const Text(
          "Detalii invitație",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12),
        child: _isLoading
            ? const Center(child: CircularProgressIndicator(color: primary))
            : Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 16),

            // Card: Nume competiție
            Card(
              elevation: 5,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              color: Colors.white,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                    vertical: 20, horizontal: 16),
                child: Column(
                  children: [
                    const SizedBox(height: 8),
                    Text(
                      compName,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 50),

            // Card: Perioadă
            Card(
              elevation: 3,
              color: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: primary,
                  child: const Icon(Icons.calendar_today,
                      color: Colors.white, size: 20),
                ),
                title: Text(
                  "Perioadă",
                  style: TextStyle(
                    color: primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                subtitle: Padding(
                  padding: const EdgeInsets.only(top: 4.0),
                  child: Text(
                    "$startFormatted  –  $endFormatted",
                    style: const TextStyle(fontSize: 15),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 12),

            // Card: Data limită răspuns
            Card(
              elevation: 3,
              color: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: primary,
                  child: const Icon(Icons.hourglass_bottom,
                      color: Colors.white, size: 20),
                ),
                title: Text(
                  "Data limită răspuns",
                  style: TextStyle(
                    color: primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                subtitle: Padding(
                  padding: const EdgeInsets.only(top: 4.0),
                  child: Text(
                    deadlineFormatted,
                    style: const TextStyle(fontSize: 15),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 12),

            // Card: Locație
            Card(
              elevation: 3,
              color: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: primary,
                  child:
                  const Icon(Icons.place, color: Colors.white, size: 20),
                ),
                title: Text(
                  "Locație",
                  style: TextStyle(
                    color: primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                subtitle: Padding(
                  padding: const EdgeInsets.only(top: 4.0),
                  child: Text(
                    location,
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
                trailing: IconButton(
                  icon: Icon(Icons.map, color: primary),
                  onPressed: () {
                    openGoogleMaps(context, location);
                  },
                ),
              ),
            ),

            const SizedBox(height: 60),

            // Buton lung: Selectia antrenorilor sau Antrenori selectați (cu iconiță)
            _buildIconButton(
              icon: Icons.group,
              text: invitation['invitation_status'] == "Pending"
                  ? "Selectează antrenorii"
                  : "Antrenori selectați",
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => CoachSelectionList(
                      widget.userUUID,
                      competitionUUID: invitation['competition_UUID'],
                      competitionDeadline: invitation['invitation_deadline'],
                      invitationStatus: invitation['invitation_status'],
                    ),
                  ),
                );
              },
            ),

            const SizedBox(height: 40),

              Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: ElevatedButton.icon(
                  onPressed: () => _getCompetitionPdf(
                      context, invitation['competition_UUID'] as int),
                  icon: const Icon(Icons.picture_as_pdf, color: Colors.white, size: 20),
                  label: const Text(
                    'Rezultate competiție',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primary,
                    padding: const EdgeInsets.symmetric(
                        vertical: 12, horizontal: 20),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),

            // Dacă starea e Pending, arată butoanele Acceptă/Refuză
            if (invitation['invitation_status'] == "Pending")
              Row(
                children: [
                  Expanded(
                    child: _buildIconButton(
                      icon: Icons.check,
                      text: "Acceptă",
                      onPressed: () {
                        _wrestlingClubService.updateInvitationStatus(
                          context: context,
                          competitionUUID: invitation['competition_UUID']
                          as int,
                          recipientUUID: widget.userUUID,
                          recipientRole: invitation['recipient_role'],
                          invitationStatus: 'Confirmed',
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildIconButton(
                      icon: Icons.close,
                      text: "Refuză",
                      onPressed: () {
                        _wrestlingClubService.updateInvitationStatus(
                          context: context,
                          competitionUUID: invitation['competition_UUID']
                          as int,
                          recipientUUID: widget.userUUID,
                          recipientRole: invitation['recipient_role'],
                          invitationStatus: 'Declined',
                        );
                      },
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _getCompetitionPdf(
      BuildContext context, int competitionUuid) async {
    final endpoint =
        'https://b0i2d55s30.execute-api.us-east-1.amazonaws.com/wrestling/getCompetitionURL';
    final uri = Uri.parse('$endpoint?competition_UUID=$competitionUuid');

    try {
      final res = await http.get(uri);
      if (res.statusCode != 200) {
        ToastHelper.eroare('Eroare server: HTTP ${res.statusCode}');
        return;
      }

      final outer = jsonDecode(res.body) as Map<String, dynamic>;
      final innerBody = outer.containsKey('body')
          ? outer['body'] as String
          : jsonEncode(outer);
      final payload = jsonDecode(innerBody) as Map<String, dynamic>;
      final url = payload['url'] as String?;

      if (url == null || url.isEmpty) {
        ToastHelper.eroare('Rezultatele nu au fost publicate!');
        return;
      }

      final pdfUri = Uri.parse(url);
      if (!await canLaunchUrl(pdfUri)) {
        ToastHelper.eroare('Nu pot deschide PDF-ul');
        return;
      }

      ToastHelper.succes('Deschidere rezultate...');
      await launchUrl(pdfUri, mode: LaunchMode.externalApplication);
    } catch (e) {
      ToastHelper.eroare('Eroare la generarea PDF: $e');
    }
  }

  // Buton lung cu iconiță pentru acțiuni
  Widget _buildIconButton(
      {required IconData icon, required String text, required VoidCallback onPressed}) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, color: Colors.white, size: 20),
      label: Text(
        text,
        style: const TextStyle(
            color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: primary,
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }
}
