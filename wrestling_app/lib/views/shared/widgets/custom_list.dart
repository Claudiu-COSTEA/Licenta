import 'package:flutter/material.dart';
import 'package:wrestling_app/views/referee/referee_competition_manage_screen.dart';
import 'package:wrestling_app/views/wrestler/wrestler_competition_manage_screen.dart';
import '../../coach/coach_competition_manage_screen.dart';
import '../../wrestling_club/wrestling_club_competition_manage_screen.dart';

class CustomList extends StatelessWidget {
  final List<Map<String, dynamic>> items; // List of competition invitations
  final int userUUID;
  final String userType;
  final String wrestlingStyle;
  final VoidCallback onRefresh; // ✅ Callback to refresh the parent screen

  const CustomList({
    super.key,
    required this.items,
    required this.userUUID,
    required this.userType,
    required this.onRefresh,
    required this.wrestlingStyle, // ✅ Receive callback
  });

  /// Traduce `invitation_status` din engleză în română
  String _roStatus(String en) {
    switch (en) {
      case 'Pending':
        return 'În așteptare';
      case 'Confirmed':
        return 'Confirmată';
      case 'Accepted':
        return 'Acceptată';
      case 'Declined':
        return 'Refuzată';
      default:
        return en;
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        final competitionName =
            item['competition_name'] ?? 'Competiție necunoscută';
        final invitationStatusRaw = item['invitation_status'] ?? 'Unknown';
        final invitationStatus = _roStatus(invitationStatusRaw);

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Container(
            decoration: BoxDecoration(
              color: const Color(0xFFB4182D), // Red background
              borderRadius: BorderRadius.circular(12),
            ),
            child: ListTile(
              title: Text(
                competitionName,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              subtitle: Text(
                'Status: $invitationStatus',
                style: const TextStyle(color: Colors.white70),
              ),
              onTap: () {
                if (userType == "Wrestling club") {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          WrestlingClubCompetitionManageScreen(
                            competitionInvitation: item,
                            userUUID: userUUID,
                          ),
                    ),
                  ).then((_) => onRefresh());
                } else if (userType == "Coach") {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => CoachCompetitionManageScreen(
                        competitionInvitation: item,
                        userUUID: userUUID,
                      ),
                    ),
                  ).then((_) => onRefresh());
                } else if (userType == "Wrestler") {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          WrestlerCompetitionManageScreen(
                            competitionInvitation: item,
                            userUUID: userUUID,
                          ),
                    ),
                  ).then((_) => onRefresh());
                } else if (userType == "Referee") {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          RefereeCompetitionManageScreen(
                            competitionInvitation: item,
                            userUUID: userUUID,
                            competitionUUID: item['competition_UUID'] as int,
                            wrestlingStyle: wrestlingStyle,
                          ),
                    ),
                  ).then((_) => onRefresh());
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Acces neautorizat"),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
            ),
          ),
        );
      },
    );
  }
}
