import 'package:flutter/material.dart';
import 'package:wrestling_app/views/shared/widgets/custom_list.dart';
import '../../models/competition_invitation_model.dart';
import '../../services/invitations_services.dart'; // Adjust path if necessary
import '../../models/user_model.dart';

class InvitationsListsScreen extends StatefulWidget {
  final UserModel? user;

  const InvitationsListsScreen({required this.user, super.key});

  @override
  State<InvitationsListsScreen> createState() => _InvitationsListsScreenState();
}

class _InvitationsListsScreenState extends State<InvitationsListsScreen> {
  final InvitationsService _eventsService = InvitationsService();

  List<Map<String, dynamic>> pendingCompetitions = [];
  List<Map<String, dynamic>> respondedCompetitions = [];
  bool _isLoading = true;

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

      print(invitations);

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
      print('Error fetching invitations: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: _isLoading
            ? Center(child: CircularProgressIndicator())
            : Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 40),
            Center(
              child: Text(
                'Lista invitatii fara raspuns',
                style: TextStyle(
                  fontSize: 25,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ),
            Expanded(
              child: CustomList(items: pendingCompetitions),
            ),
            Center(
              child: Text(
                'Lista invitatii cu raspuns',
                style: TextStyle(
                  fontSize: 25,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ),
            Expanded(
              child: CustomList(items: respondedCompetitions),
            ),
          ],
        ),
      ),
    );
  }
}
