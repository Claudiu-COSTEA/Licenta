import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import 'package:wrestling_app/services/referee_api_services.dart';
import 'package:wrestling_app/services/google_maps_lunch.dart';
import 'package:wrestling_app/views/referee/referee_weight_categories_verification.dart';
import 'package:wrestling_app/views/referee/referee_competitions_fights.dart';

import '../shared/widgets/toast_helper.dart';

class RefereeCompetitionManageScreen extends StatefulWidget {
  final Map<String, dynamic> competitionInvitation;
  final int userUUID;
  final int competitionUUID;
  final String wrestlingStyle;

  const RefereeCompetitionManageScreen({
    required this.competitionInvitation,
    super.key,
    required this.userUUID,
    required this.competitionUUID,
    required this.wrestlingStyle,
  });

  @override
  State<RefereeCompetitionManageScreen> createState() =>
      _RefereeCompetitionManageScreenState();
}

class _RefereeCompetitionManageScreenState
    extends State<RefereeCompetitionManageScreen> {
  final RefereeServices _refereeServices = RefereeServices();
  bool _isLoading = false;
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
    final compName =
        invitation['competition_name'] ?? "Competiție necunoscută";
    final startFormatted = _formatDateTime(
        invitation['competition_start_date'] as String? ?? "");
    final endFormatted =
    _formatDateTime(invitation['competition_end_date'] as String? ?? "");
    final deadlineFormatted =
    _formatDateTime(invitation['invitation_deadline'] as String? ?? "");
    final location = invitation['competition_location'] ?? "";

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar:  AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.black),
        title: const Text(
          "Detalii invitație",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: _isLoading
                ? const Center(
                child: CircularProgressIndicator(color: Color(0xFFB4182D)))
                : Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 16),
        
                // Card: Nume competiție
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: const [
                      BoxShadow(
                          color: Colors.black12,
                          blurRadius: 4,
                          offset: Offset(0, 2))
                    ],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding:
                  const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
                  child: Text(
                    compName,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
        
                const SizedBox(height: 50),
        
                // Card: Perioadă
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: const [
                      BoxShadow(
                          color: Colors.black12,
                          blurRadius: 4,
                          offset: Offset(0, 2))
                    ],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: const Color(0xFFB4182D),
                      child: const Icon(Icons.calendar_today,
                          color: Colors.white, size: 20),
                    ),
                    title: Text(
                      "Perioadă",
                      style: TextStyle(
                          color: const Color(0xFFB4182D),
                          fontWeight: FontWeight.w600),
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
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: const [
                      BoxShadow(
                          color: Colors.black12,
                          blurRadius: 4,
                          offset: Offset(0, 2))
                    ],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: const Color(0xFFB4182D),
                      child: const Icon(Icons.hourglass_bottom,
                          color: Colors.white, size: 20),
                    ),
                    title: Text(
                      "Data limită răspuns",
                      style: TextStyle(
                          color: const Color(0xFFB4182D),
                          fontWeight: FontWeight.w600),
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
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: const [
                      BoxShadow(
                          color: Colors.black12,
                          blurRadius: 4,
                          offset: Offset(0, 2))
                    ],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: const Color(0xFFB4182D),
                      child: const Icon(Icons.place,
                          color: Colors.white, size: 20),
                    ),
                    title: Text(
                      "Locație",
                      style: TextStyle(
                          color: const Color(0xFFB4182D),
                          fontWeight: FontWeight.w600),
                    ),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 4.0),
                      child: Text(
                        location,
                        style: const TextStyle(fontSize: 16),
                      ),
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.map, color: Color(0xFFB4182D)),
                      onPressed: () {
                        openGoogleMaps(context, location);
                      },
                    ),
                  ),
                ),
        
                const SizedBox(height: 50),
        
                // Butoane Acceptă/Refuză dacă status == Pending
                if (invitation['invitation_status'] == "Pending")
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            _refereeServices.updateInvitationStatus(
                              context: context,
                              competitionUUID:
                              invitation['competition_UUID'] as int,
                              recipientUUID: widget.userUUID,
                              recipientRole: invitation['recipient_role'],
                              invitationStatus: 'Confirmed',
                            );
                          },
                          icon: const Icon(Icons.check,
                              color: Colors.white, size: 20),
                          label: const Text(
                            "Acceptă",
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFB4182D),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10)),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            _refereeServices.updateInvitationStatus(
                              context: context,
                              competitionUUID:
                              invitation['competition_UUID'] as int,
                              recipientUUID: widget.userUUID,
                              recipientRole: invitation['recipient_role'],
                              invitationStatus: 'Declined',
                            );
                          },
                          icon: const Icon(Icons.close,
                              color: Colors.white, size: 20),
                          label: const Text(
                            "Refuză",
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFB4182D),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10)),
                          ),
                        ),
                      ),
                    ],
                  ),
        
                // Dacă status == Confirmed, arătăm butoanele suplimentare
                if (invitation['invitation_status'] == "Confirmed")
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      ElevatedButton.icon(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  RefereeWeightCategoriesVerification(
                                      competitionUUID:
                                      invitation['competition_UUID']),
                            ),
                          );
                        },
                        icon: const Icon(Icons.verified, color: Colors.white, size: 20),
                        label: const Text(
                          "Verificare sportivi",
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFB4182D),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)),
                        ),
                      ),
                      const SizedBox(height: 50),
                      ElevatedButton.icon(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => RefereeFightDashboard(competitionUUID: widget.competitionUUID, wrestlingStyle: widget.wrestlingStyle,),
                            ),
                          );
                        },
                        icon: const Icon(Icons.sports_martial_arts_outlined,
                            color: Colors.white, size: 20),
                        label: const Text(
                          "Lista lupte",
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFB4182D),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)),
                        ),
                      ),
        
                      const SizedBox(height: 50),
        
                      Padding(
                        padding: const EdgeInsets.only(bottom: 12),
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
                                vertical: 16, horizontal: 20),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),
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
}
