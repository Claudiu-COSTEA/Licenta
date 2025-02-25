import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:wrestling_app/views/shared/widgets/custom_list.dart';
import '../../models/competition_invitation_model.dart';
import '../../services/invitations_services.dart'; // Adjust path if necessary
import '../../models/user_model.dart';
import 'package:wrestling_app/services/auth_service.dart';

class InvitationsListsScreen extends StatefulWidget {
  final UserModel? user;

  const InvitationsListsScreen({required this.user, super.key});

  @override
  State<InvitationsListsScreen> createState() => _InvitationsListsScreenState();
}

class _InvitationsListsScreenState extends State<InvitationsListsScreen> {
  final InvitationsService _eventsService = InvitationsService();
  final AuthService _authService = AuthService();
  List<Map<String, dynamic>> pendingCompetitions = [];
  List<Map<String, dynamic>> respondedCompetitions = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchInvitations();
  }

  Future<void> _fetchInvitations() async {
    try {
      // Fetch all invitations
      List<CompetitionInvitation> invitations =
      await _eventsService.fetchInvitations(widget.user!.userUUID);

      if (kDebugMode) {
        print(invitations);
      }

      setState(() {
        // Separate pending invitations (invitationStatus == "Pending")
        pendingCompetitions = invitations
            .where((invitation) => invitation.invitationStatus == 'Pending')
            .map((invitation) => {
          'invitationUUID': invitation.invitationUUID,
          'competition_UUID': invitation.competitionUUID,
          'recipient_UUID': invitation.recipientUUID,
          'recipient_role': invitation.recipientRole,
          'weight_category': invitation.weightCategory,
          'competition_name': invitation.competitionName,
          'competition_start_date': invitation.competitionStartDate.toString(),
          'competition_end_date': invitation.competitionEndDate.toString(),
          'competition_location': invitation.competitionLocation,
          'invitation_status': invitation.invitationStatus,
          'invitation_date': invitation.invitationDate.toString(),
          'invitation_deadline': invitation.invitationDeadline.toString(),
          'invitation_response_date': invitation.invitationResponseDate?.toString() ?? "No Response"
        })
            .toList();

        // Separate responded invitations (invitationStatus != "Pending")
        respondedCompetitions = invitations
            .where((invitation) => invitation.invitationStatus != 'Pending')
            .map((invitation) => {
          'invitationUUID': invitation.invitationUUID,
          'competition_UUID': invitation.competitionUUID,
          'recipient_UUID': invitation.recipientUUID,
          'recipient_role': invitation.recipientRole,
          'weight_category': invitation.weightCategory,
          'competition_name': invitation.competitionName,
          'competition_start_date': invitation.competitionStartDate.toString(),
          'competition_end_date': invitation.competitionEndDate.toString(),
          'competition_location': invitation.competitionLocation,
          'invitation_status': invitation.invitationStatus,
          'invitation_date': invitation.invitationDate.toString(),
          'invitation_deadline': invitation.invitationDeadline.toString(),
          'invitation_response_date': invitation.invitationResponseDate?.toString() ?? "No Response"
        })
            .toList();
      });
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching invitations: $e');
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }

    setState(() {
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
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
            ? const Center(child: CircularProgressIndicator())
            : Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 10),
            const Center(
              child: Text(
                'Lista invitații fără răspuns',
                style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold, color: Colors.black),
              ),
            ),
            Expanded(
              child: CustomList(items: pendingCompetitions, userUUID: widget.user!.userUUID, userType: widget.user!.userType, onRefresh: _fetchInvitations,),
            ),

            const SizedBox(height: 10),
            const Center(
              child: Text(
                'Lista invitații cu răspuns',
                style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold, color: Colors.black),
              ),
            ),
            Expanded(
              child: CustomList(items: respondedCompetitions, userUUID: widget.user!.userUUID, userType: widget.user!.userType, onRefresh: _fetchInvitations,),
            ),
          ],
        ),
      ),
    );
  }

}
