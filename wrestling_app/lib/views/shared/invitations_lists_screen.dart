import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:wrestling_app/views/shared/widgets/custom_list.dart';
import 'package:wrestling_app/views/shared/widgets/toast_helper.dart';
import '../../models/competition_invitation_model.dart';
import '../../services/clubs_map_screen.dart';
import '../../services/invitations_services.dart'; // Ajustează calea dacă e necesar
import '../../models/user_model.dart';
import 'package:wrestling_app/services/auth_service.dart';
import '../../services/wrestler_apis_services.dart';
import '../wrestler/get_qr_code.dart';

class InvitationsListsScreen extends StatefulWidget {
  final UserModel? user;

  const InvitationsListsScreen({required this.user, super.key});

  @override
  State<InvitationsListsScreen> createState() =>
      _InvitationsListsScreenState();
}

class _InvitationsListsScreenState extends State<InvitationsListsScreen> {
  final InvitationsService _eventsService = InvitationsService();
  final AuthService _authService = AuthService();
  final WrestlerService _wrestlerService = WrestlerService();

  List<Map<String, dynamic>> _pendingCompetitions = [];
  List<Map<String, dynamic>> _respondedCompetitions = [];
  bool _isLoading = false;

  static const Color _primaryColor = Color(0xFFB4182D);

  @override
  void initState() {
    super.initState();
    _fetchInvitations();
  }

  Future<void> _fetchInvitations() async {
    setState(() => _isLoading = true);
    try {
      // 1) Aducem toate invitațiile
      List<CompetitionInvitation> invitations =
      await _eventsService.fetchInvitations(widget.user!.userUUID);

      // 2) Separăm invitațiile „Pending” de cele cu răspuns
      final pending = <Map<String, dynamic>>[];
      final responded = <Map<String, dynamic>>[];

      for (var inv in invitations) {
        final mapa = {
          'invitationUUID': inv.invitationUUID,
          'competition_UUID': inv.competitionUUID,
          'recipient_UUID': inv.recipientUUID,
          'recipient_role': inv.recipientRole,
          'weight_category': inv.weightCategory,
          'competition_name': inv.competitionName,
          'competition_start_date': inv.competitionStartDate.toString(),
          'competition_end_date': inv.competitionEndDate.toString(),
          'competition_location': inv.competitionLocation,
          'invitation_status': inv.invitationStatus,
          'invitation_date': inv.invitationDate.toString(),
          'invitation_deadline': inv.invitationDeadline.toString(),
          'invitation_response_date':
          inv.invitationResponseDate?.toString() ?? "No Response",
        };

        if (inv.invitationStatus == 'Pending') {
          pending.add(mapa);
        } else {
          responded.add(mapa);
        }
      }

      setState(() {
        _pendingCompetitions = pending;
        _respondedCompetitions = responded;
      });
    } catch (e) {
      if (kDebugMode) print('Error fetching invitations: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Widget _buildGridCard({ required IconData icon, required String label, required VoidCallback onTap,})
  {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      color: _primaryColor,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Center(
          child: Padding(
            padding:
            const EdgeInsets.symmetric(vertical: 16.0, horizontal: 8.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, size: 36, color: Colors.white),
                const SizedBox(height: 12),
                Text(
                  label,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    height: 1.2,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String? get _userTypeLabel {
    switch (widget.user?.userType) {
      case 'Wrestler':       return 'Luptător';
      case 'Wrestling club': return 'Club Sportiv';
      case 'Coach':          return 'Antrenor';
      case 'Referee':        return 'Arbitru';
      default:               return widget.user?.userType;
    }
  }

  @override
  Widget build(BuildContext context) {
    final userType = widget.user!.userType.toLowerCase();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        automaticallyImplyLeading: false,
        // give the leading slot enough width for your label
        leadingWidth: 160,
        leading: Padding(
          padding: const EdgeInsets.only(left: 25),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              _userTypeLabel!,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Colors.black,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.black),
            onPressed: () => _authService.signOut(context),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: _isLoading
            ? const Center(
          child: CircularProgressIndicator(color: _primaryColor),
        )
            : Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // ───────── GRID ─────────
            if (userType == 'wrestler')
              ...[
                // Pentru luptător afișăm TOATE cele 3 carduri
                SizedBox(
                  height: 150,
                  child: GridView.count(
                    crossAxisCount: 3,
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    childAspectRatio: 0.8,
                    children: [
                      _buildGridCard(
                        icon: Icons.map,
                        label: 'Locații\ncluburi\nsportive',
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const ClubsMapScreen(),
                            ),
                          );
                        },
                      ),
                      // 2) Document Medical (QR)
                      _buildGridCard(
                        icon: Icons.medical_services,
                        label: 'Document\nMedical',
                        onTap: () async {
                          final docs = await _wrestlerService
                              .fetchWrestlerUrls(
                              widget.user!.userUUID);
                          final medicalUrl = docs?.medicalDocument;
                          if (medicalUrl == null ||
                              medicalUrl.isEmpty) {
                            ToastHelper.eroare(
                                'Fără document medical !');
                            return;
                          }
                          if (!context.mounted) return;
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => QRCodeScreen(
                                url: medicalUrl,
                                docType: DocType.medical,
                              ),
                            ),
                          );
                        },
                      ),
                      // 3) Document Sportiv (QR)
                      _buildGridCard(
                        icon: Icons.sports_martial_arts,
                        label: 'Document\nSportiv',
                        onTap: () async {
                          final docs = await _wrestlerService
                              .fetchWrestlerUrls(
                              widget.user!.userUUID);
                          final sportivUrl = docs?.licenseDocument;
                          if (sportivUrl == null ||
                              sportivUrl.isEmpty) {
                            ToastHelper.eroare(
                                'Fără Document sportiv !');
                            return;
                          }
                          if (!context.mounted) return;
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => QRCodeScreen(
                                url: sportivUrl,
                                docType: DocType.sportive,
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
              ]
            else
              ...[
                // Buton full‐width cu iconiță și text, culoare roșie
                Center(
                  child: SizedBox(
                    width: 250,
                    height: 40,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const ClubsMapScreen()),
                        );
                      },
                      icon: const Icon(
                        Icons.map,
                        color: Colors.white,
                        size: 25,
                      ),
                      label: const Text(
                        'Locații cluburi sportive',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFB4182D),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(50),
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 20),
              ],

            // ───────── TITLU INVITAȚII FĂRĂ RĂSPUNS ─────────
            const Center(
              child: Text(
                'Lista invitații fără răspuns',
                style: TextStyle(
                  fontSize: 25,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ),
            Expanded(
              child: CustomList(
                items: _pendingCompetitions,
                userUUID: widget.user!.userUUID,
                userType: widget.user!.userType,
                wrestlingStyle: widget.user!.wrestlingStyle,
                onRefresh: _fetchInvitations,
              ),
            ),

            const SizedBox(height: 10),

            // ───────── TITLU INVITAȚII CU RĂSPUNS ─────────
            const Center(
              child: Text(
                'Lista invitații cu răspuns',
                style: TextStyle(
                  fontSize: 25,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ),
            Expanded(
              child: CustomList(
                items: _respondedCompetitions,
                userUUID: widget.user!.userUUID,
                userType: widget.user!.userType,
                wrestlingStyle: widget.user!.wrestlingStyle,
                onRefresh: _fetchInvitations,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
