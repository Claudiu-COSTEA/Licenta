import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/competition_model.dart';
import 'package:wrestling_app/services/admin_apis_services.dart';

import 'competitions_invitations_status_screen.dart';

class CompetitionManageScreen extends StatelessWidget {
  final Competition competition;
  const CompetitionManageScreen({Key? key, required this.competition}) : super(key: key);

  static const Color primaryColor = Color(0xFFB4182D);

  Widget _buildInfoBox({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: primaryColor, width: 2),
        borderRadius: BorderRadius.circular(10),
      ),
      child: child,
    );
  }

  @override
  Widget build(BuildContext context) {

    AdminServices _adminServices = new AdminServices();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [

            Center(
              child: Text(
                competition.name,
                style: const TextStyle(
          color: Colors.black,
          fontSize: 25.0,
          fontWeight: FontWeight.bold,
        ),

      ),
            ),

            const SizedBox(height: 40),
            _buildInfoBox(
              child: Text(
                'Data start: ${DateFormat('yyyy-MM-dd').format(competition.startDate)}',
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 16),
              ),
            ),
            const SizedBox(height: 12),
            _buildInfoBox(
              child: Text(
                'Data sfârșit: ${DateFormat('yyyy-MM-dd').format(competition.endDate)}',
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 16),
              ),
            ),
            const SizedBox(height: 12),
            _buildInfoBox(
              child: Text(
                'Locație: ${competition.location}',
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 16),
              ),
            ),
            const SizedBox(height: 12),
            _buildInfoBox(
              child: Text(
                'Status: ${competition.status}',
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 16),
              ),
            ),


            const SizedBox(height: 50),


            ElevatedButton(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (ctx) => const ClubInvitationsScreen()),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                ),
                child: const Text(
                  'Vizualizare status invitații',
                  style: TextStyle(color: Colors.white),
                ),
              ),

            const SizedBox(height: 50,),

            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      _adminServices.updateCompetitionStatus(status: "Confirmed", competitionUUID: competition.uuid);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                    ),
                    child: const Text(
                      'Confirmă',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      _adminServices.updateCompetitionStatus(competitionUUID: competition.uuid, status: "Postponed");
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                    ),
                    child: const Text(
                      'Amână',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
