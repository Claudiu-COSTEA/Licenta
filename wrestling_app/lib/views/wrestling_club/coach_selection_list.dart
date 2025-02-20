import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:wrestling_app/services/wrestling_clubs_apis_services.dart';
import 'package:wrestling_app/views/shared/widgets/custom_list_coaches_respond.dart';
import '../shared/widgets/custom_list_coaches.dart';

class CoachSelectionList extends StatefulWidget {
  final int userUUID;
  final int competitionUUID;
  final String competitionDeadline;
  final String invitationStatus;

  const CoachSelectionList(
      this.userUUID, {super.key, required this.competitionUUID, required this.competitionDeadline, required this.invitationStatus}
      );

  @override
  State<CoachSelectionList> createState() => _CoachSelectionListState();
}

class _CoachSelectionListState extends State<CoachSelectionList> {
  final WrestlingClubService _wrestlingClubService = WrestlingClubService();
  List<Map<String, dynamic>> wrestlingClubCoaches = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchWrestlingClubCoaches();
  }

  Future<void> _fetchWrestlingClubCoaches() async {
    try {
      List<Map<String, dynamic>> fetchedCoaches =
      await _wrestlingClubService.fetchCoachesForClub(widget.userUUID, widget.competitionUUID);

      setState(() {
        wrestlingClubCoaches = fetchedCoaches;
      });
    } catch (e) {
      if (kDebugMode) {
        print("Error fetching wrestling club coaches: $e");
      }
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
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 40),

          Align(
            alignment: Alignment.centerLeft,
            child: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.black, size: 28),
              onPressed: () {
                Navigator.pop(context); // Go back to the previous screen
              },
            ),
          ),

          const Center(
            child: Text(
              'Lista antrenorilor',
              style: TextStyle(
                fontSize: 25,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ),

          if(widget.invitationStatus == 'Pending')
          Expanded(
            child: CustomCoachesList(
              userUUID: widget.userUUID,
              competitionUUID: widget.competitionUUID,
              competitionDeadline: widget.competitionDeadline, coaches: wrestlingClubCoaches,
            ),
          )
          else
            Expanded(
              child: CustomListCoachesRespond(
                userUUID: widget.userUUID,
                competitionUUID: widget.competitionUUID,
                coaches: wrestlingClubCoaches,
              ),
            ),
        ],
      ),
    );
  }
}
