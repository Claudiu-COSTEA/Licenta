// file: lib/screens/clubs_list_screen.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:wrestling_app/models/wrestling_club_model.dart';
import 'package:wrestling_app/services/admin_apis_services.dart';
import '../shared/widgets/toast_helper.dart';

class ClubsListScreen extends StatefulWidget {
  final int competitionUUID;
  const ClubsListScreen({super.key, required this.competitionUUID});

  @override
  State<ClubsListScreen> createState() => _ClubsListScreenState();
}

class _ClubsListScreenState extends State<ClubsListScreen> {
  final _service = AdminServices();
  late Future<void> _initFuture;
  List<WrestlingClub> _clubs = [];
  final Set<int> _sent = {};

  static const Color primaryRed = Color(0xFFB4182D);
  static const Color disabledGrey = Color(0xFF444444);

  @override
  void initState() {
    super.initState();
    _initFuture = _loadClubsAndInvites();
  }

  Future<void> _loadClubsAndInvites() async {
    final clubs = await _service.fetchClubs();
    final invites = await _service.fetchInvitationsByRole(
      role: 'Wrestling Club',
      competitionUUID: widget.competitionUUID.toString(),
    );
    _sent.addAll(invites.map((inv) => inv.recipientUUID));
    setState(() => _clubs = clubs);
  }

  Future<void> _sendInvite(WrestlingClub club) async {
    if (_sent.contains(club.uuid)) return;
    final deadline = DateFormat('yyyy-MM-dd HH:mm:ss')
        .format(DateTime.now().add(const Duration(hours: 72)));
    final res = await _service.sendInvitation(
      competitionUUID: widget.competitionUUID,
      recipientUUID: club.uuid,
      recipientRole: 'Wrestling Club',
      status: 'Pending',
      deadline: deadline,
    );
    if (res.success) {
      ToastHelper.succes('Invitație trimisă!');
      setState(() => _sent.add(club.uuid));
    } else {
      ToastHelper.eroare('Eroare la trimitere');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.black),
        title: const Text(
          'Cluburi participante',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
      ),
      body: FutureBuilder<void>(
        future: _initFuture,
        builder: (context, snap) {
          if (snap.connectionState != ConnectionState.done) {
            return const Center(
              child: CircularProgressIndicator(color: primaryRed),
            );
          }
          if (snap.hasError) {
            return Center(child: Text('Eroare: ${snap.error}'));
          }
          if (_clubs.isEmpty) {
            return const Center(child: Text('Niciun club găsit'));
          }
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: _clubs.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, i) {
              final c = _clubs[i];
              final sent = _sent.contains(c.uuid);
              return Card(
                elevation: 3,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                color: primaryRed,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        c.clubName,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Oraș: ${c.city}',
                        style: const TextStyle(color: Colors.white70),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Coordonate: ${c.latitude.toStringAsFixed(5)}, ${c.longitude.toStringAsFixed(5)}',
                        style: const TextStyle(color: Colors.white70),
                      ),
                      const SizedBox(height: 12),
                      Align(
                        alignment: Alignment.centerRight,
                        child: ElevatedButton(
                          onPressed: sent ? null : () => _sendInvite(c),
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                            sent ? disabledGrey : Colors.black,
                            padding: const EdgeInsets.symmetric(
                                vertical: 10, horizontal: 20),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: Text(
                            sent ? 'Invitație trimisă' : 'Trimite invitație',
                            style: const TextStyle(color: Colors.white),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
