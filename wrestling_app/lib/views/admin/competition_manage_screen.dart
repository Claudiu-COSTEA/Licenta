import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/competition_model.dart';
import 'package:wrestling_app/services/admin_apis_services.dart';
import '../../services/google_maps_lunch.dart';
import 'competitions_invitations_status_screen.dart';

class CompetitionManageScreen extends StatelessWidget {
  final Competition competition;
  const CompetitionManageScreen({Key? key, required this.competition}) : super(key: key);

  static const Color primaryColor = Color(0xFFB4182D);

  /// Translate English status to Romanian
  String _statusInRomana(String en) {
    switch (en) {
      case 'Pending':
        return 'În așteptare';
      case 'Confirmed':
        return 'Confirmată';
      case 'Postponed':
        return 'Amânată';
      case 'Finished':
        return 'Încheiată';
      default:
        return en;
    }
  }

  Widget _buildCard({
    required IconData icon,
    required String title,
    required String subtitle,
    VoidCallback? onTap,
  }) {
    return Card(
      elevation: 3,
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: primaryColor,
          child: Icon(icon, color: Colors.white, size: 20),
        ),
        title: Text(
          title,
          style: TextStyle(color: primaryColor, fontWeight: FontWeight.w600),
        ),
        subtitle: Text(subtitle, style: const TextStyle(fontSize: 15)),
        onTap: onTap,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final AdminServices _adminServices = AdminServices();
    final statusRo = _statusInRomana(competition.competitionStatus);

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 16),
        child: Column(
          children: [

            const SizedBox(height: 30),

            Align(
              alignment: Alignment.centerLeft,
              child: IconButton(
                icon: const Icon(Icons.arrow_back, size: 28, color: Colors.black),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
            ),

            const SizedBox(height: 20,),
            // Title card
            Card(
              elevation: 5,
              color: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
                child: Text(
                  competition.competitionName,
                  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
            const SizedBox(height: 50),

            _buildCard(
              icon: Icons.calendar_today,
              title: "Perioadă de desfășurare",
              subtitle:
              "${DateFormat('yyyy-MM-dd').format(competition.competitionStartDate)}  –  ${DateFormat('yyyy-MM-dd').format(competition.competitionEndDate)}",
            ),
            const SizedBox(height: 12),

            Card(
              elevation: 3,
              color: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: primaryColor,
                  child:
                  const Icon(Icons.place, color: Colors.white, size: 20),
                ),
                title: Text(
                  "Locație",
                  style: TextStyle(
                    color: primaryColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                subtitle: Padding(
                  padding: const EdgeInsets.only(top: 4.0),
                  child: Text(
                    competition.competitionLocation,
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
                trailing: IconButton(
                  icon: Icon(Icons.map, color: primaryColor),
                  onPressed: () {
                    openGoogleMaps(context, competition.competitionLocation);
                  },
                ),
              ),
            ),
            const SizedBox(height: 12),

            _buildCard(
              icon: Icons.info,
              title: "Status",
              subtitle: statusRo,
            ),
            const SizedBox(height: 80),

            // View invitations button
            ElevatedButton.icon(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const ClubInvitationsScreen()),
                );
              },
              icon: const Icon(Icons.group, color: Colors.white),
              label: const Text(
                "Vizualizare invitații",
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                minimumSize: const Size.fromHeight(50),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 110),
        child: Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () => _adminServices.updateCompetitionStatus(
                  status: "Confirmed",
                  competitionUUID: competition.competitionUUID,
                ),
                icon: const Icon(Icons.check, color: Colors.white),
                label: const Text(
                  "Confirmă",
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  minimumSize: const Size.fromHeight(48),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () => _adminServices.updateCompetitionStatus(
                  status: "Postponed",
                  competitionUUID: competition.competitionUUID,
                ),
                icon: const Icon(Icons.schedule, color: Colors.white),
                label: const Text(
                  "Amână",
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  minimumSize: const Size.fromHeight(48),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
