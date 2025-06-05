// file: lib/screens/clubs_list_screen.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:wrestling_app/models/wrestling_club_model.dart';
import 'package:wrestling_app/services/admin_apis_services.dart';
import '../shared/widgets/toast_helper.dart';

class ClubsListScreen extends StatefulWidget {
  final int competitionUUID;                       // ← competiția curentă
  const ClubsListScreen({super.key, required this.competitionUUID});

  @override
  State<ClubsListScreen> createState() => _ClubsListScreenState();
}

class _ClubsListScreenState extends State<ClubsListScreen> {
  final _service = AdminServices();

  late Future<void> _initFuture;                   // inițializare simultană
  List<WrestlingClub> _clubs = [];
  final Set<int> _sent = {};                       // cluburi deja invitate

  static const Color kRed  = Color(0xFFB4182D);
  static const Color kGrey = Color(0xFF444444);

  //──────────────────────────────────────── init
  @override
  void initState() {
    super.initState();
    _initFuture = _loadClubsAndInvites();
  }

  Future<void> _loadClubsAndInvites() async {
    // 1) ia TOATE cluburile
    final clubs = await _service.fetchClubs();

    // 2) ia invitațiile DEJA trimise pt. rol „Wrestling Club”
    final invites = await _service.fetchInvitationsByRole(
      role: 'Wrestling Club',
      competitionUUID: widget.competitionUUID.toString(),
    );

    // 3) pune recipient_UUID-urile în setul _sent
    _sent.addAll(invites.map((inv) => inv.recipientUUID));

    setState(() => _clubs = clubs);
  }

  //──────────────────────────────────────── trimitere
  Future<void> _sendInvite(WrestlingClub club) async {
    if (_sent.contains(club.uuid)) return;         // deja trimis

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
      setState(() => _sent.add(club.uuid));        // dezactivează butonul
    } else {
      ToastHelper.eroare('Eroare la trimitere');
    }
  }

  //──────────────────────────────────────── UI
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
          title: const Text('Cluburi sportive', style: TextStyle(fontWeight: FontWeight.bold),),
          backgroundColor: Colors.transparent),
      body: FutureBuilder<void>(
        future: _initFuture,
        builder: (_, snap) {
          if (snap.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator(color: kRed,));
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
            itemBuilder: (_, i) {
              final c = _clubs[i];
              final sent = _sent.contains(c.uuid);

              return Container(
                decoration: BoxDecoration(color: kRed, borderRadius: BorderRadius.circular(12)),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(c.clubName,
                        style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 6),
                    Text('Oraș: ${c.city}', style: const TextStyle(color: Colors.white)),
                    const SizedBox(height: 4),
                    Text('Lat: ${c.latitude.toStringAsFixed(5)}   Lng: ${c.longitude.toStringAsFixed(5)}',
                        style: const TextStyle(color: Colors.white70)),
                    const SizedBox(height: 12),
                    Align(
                      alignment: Alignment.centerRight,
                      child: ElevatedButton(
                        onPressed: sent ? null : () => _sendInvite(c),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: sent ? kGrey : Colors.black,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
                        ),
                        child: Text(sent ? 'Invitație trimisă' : 'Trimite invitație',
                            style: const TextStyle(color: Colors.white)),
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
