import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:wrestling_app/services/wrestler_apis_services.dart';
import 'package:wrestling_app/services/google_maps_lunch.dart';

class WrestlerCompetitionManageScreen extends StatefulWidget {
  final Map<String, dynamic> competitionInvitation;
  final int userUUID;

  const WrestlerCompetitionManageScreen({
    required this.competitionInvitation,
    super.key,
    required this.userUUID,
  });

  @override
  State<WrestlerCompetitionManageScreen> createState() =>
      _WrestlerCompetitionManageScreen();
}

class _WrestlerCompetitionManageScreen extends State<WrestlerCompetitionManageScreen> {
  final WrestlerService _wrestlerService = WrestlerService();
  final bool _isLoading = false;
  static const Color primary = Color(0xFFB4182D);

  String _formatDateTime(String raw) {
    try {
      final dt = DateTime.parse(raw);
      return DateFormat('dd.MM.yyyy HH:mm').format(dt);
    } catch (_) {
      return raw;
    }
  }

  @override
  Widget build(BuildContext context) {
    final invitation = widget.competitionInvitation;

    final compName = invitation['competition_name'] ?? "Competiție necunoscută";
    final startRaw = invitation['competition_start_date'] as String? ?? "";
    final endRaw = invitation['competition_end_date'] as String? ?? "";
    final deadlineRaw = invitation['invitation_deadline'] as String? ?? "";
    final weightCat = invitation['weight_category'] ?? "-";
    final location = invitation['competition_location'] ?? "";

    final startFormatted = _formatDateTime(startRaw);
    final endFormatted = _formatDateTime(endRaw);
    final deadlineFormatted = _formatDateTime(deadlineRaw);

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
            ? const Center(
          child: CircularProgressIndicator(color: primary),
        )
            : Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 16),

            // Competition Name Card
            Card(
              elevation: 5,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              color: Colors.white,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
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

            const SizedBox(height: 60),

            // Competition Period Card
            Card(
              color: Colors.white,
              elevation: 3,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: primary,
                  child: const Icon(Icons.calendar_today, color: Colors.white, size: 20),
                ),
                title: Text(
                  "Perioada",
                  style: TextStyle(
                    color: primary,
                    fontWeight: FontWeight.bold,
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

            // Invitation Deadline Card
            Card(
              color: Colors.white,
              elevation: 3,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: primary,
                  child: const Icon(Icons.hourglass_bottom, color: Colors.white, size: 20),
                ),
                title: Text(
                  "Data limită de răspuns",
                  style: TextStyle(
                    color: primary,
                    fontWeight: FontWeight.bold,
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

            // Weight Category Card
            Card(
              color: Colors.white,
              elevation: 3,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: primary,
                  child: const Icon(Icons.fitness_center, color: Colors.white, size: 20),
                ),
                title: Text(
                  "Categoriea de greutate",
                  style: TextStyle(
                    color: primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                subtitle: Padding(
                  padding: const EdgeInsets.only(top: 4.0),
                  child: Text(
                    '$weightCat' + ' Kg',
                    style: const TextStyle(fontSize: 15),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 12),

            // Location Card
            Card(
              color: Colors.white,
              elevation: 3,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: primary,
                  child: const Icon(Icons.place, color: Colors.white, size: 20),
                ),
                title: Text(
                  "Locație competiție",
                  style: TextStyle(
                    color: primary,
                    fontWeight: FontWeight.bold,
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

            if (invitation['invitation_status'] == "Pending")
              Row(
                children: [
                  const SizedBox(height: 200),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        _wrestlerService.updateInvitationStatus(
                          context: context,
                          competitionUUID: invitation['competition_UUID'],
                          recipientUUID: widget.userUUID,
                          recipientRole: invitation['recipient_role'],
                          invitationStatus: 'Confirmed',
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primary,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text(
                        "Acceptă",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 32),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        _wrestlerService.updateInvitationStatus(
                          context: context,
                          competitionUUID: invitation['competition_UUID'],
                          recipientUUID: widget.userUUID,
                          recipientRole: invitation['recipient_role'],
                          invitationStatus: 'Declined',
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primary,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text(
                        "Refuză",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              )
            else
              Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Image.asset(
                      'assets/images/wrestling_logo.png',
                      height: 250,
                    ),
                  ],
                ),
              ),

          ],
        ),
      ),
    );
  }
}
