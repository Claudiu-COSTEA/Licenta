import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../../wrestling_club/wrestling_club_competition_manage_screen.dart';

class CustomList extends StatelessWidget {
  final List<Map<String, dynamic>> items; // List of competition invitations

  const CustomList({super.key, required this.items});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        final competitionName = item['competition_name'] ?? 'Unknown Competition';
        final invitationStatus = item['invitation_status'] ?? 'Unknown Status';

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Container(
            decoration: BoxDecoration(
              color: Color(0xFFB4182D), // Red background
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
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => WrestlingClubCompetitionManageScreen(competitionInvitation: item)), // Replace HomePage with your destination
                );
              },
            ),
          ),
        );
      },
    );
  }
}
