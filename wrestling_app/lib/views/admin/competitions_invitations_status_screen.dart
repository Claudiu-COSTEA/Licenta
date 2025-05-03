// file: lib/screens/club_invitations_screen.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/competitions_invitations_status.dart';
import '../../services/admin_apis_services.dart';

class ClubInvitationsScreen extends StatefulWidget {
  const ClubInvitationsScreen({Key? key}) : super(key: key);

  @override
  State<ClubInvitationsScreen> createState() => _ClubInvitationsScreenState();
}

class _ClubInvitationsScreenState extends State<ClubInvitationsScreen> {
  late Future<List<ClubInvitation>> _futureInvitations;
  static const Color primaryColor = Color(0xFFB4182D);

  @override
  void initState() {
    super.initState();
    _futureInvitations = AdminServices().fetchClubsInvitationsStatus();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 16),
          const Center(
            child: Text(
              'Cluburi invitate',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: FutureBuilder<List<ClubInvitation>>(
              future: _futureInvitations,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text('Eroare: ${snapshot.error}'));
                }
                final invitations = snapshot.data!;
                if (invitations.isEmpty) {
                  return const Center(child: Text('Nicio invitație găsită'));
                }
                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  itemCount: invitations.length,
                  itemBuilder: (context, index) {
                    final inv = invitations[index];
                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: primaryColor,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            inv.clubName,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Oraș: ${inv.city}',
                            style: const TextStyle(color: Colors.white),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Stare: ${inv.invitationStatus}',
                            style: const TextStyle(color: Colors.white),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Termen: ${DateFormat('yyyy-MM-dd HH:mm').format(inv.invitationDeadline)}',
                            style: const TextStyle(color: Colors.white),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
