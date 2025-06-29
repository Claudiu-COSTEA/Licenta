import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:wrestling_app/services/coach_apis_services.dart';
import 'package:wrestling_app/views/shared/widgets/custom_list_wrestlers.dart';
import '../shared/widgets/custom_list_wrestler_respond.dart';

class WrestlersSelectionList extends StatefulWidget {
  final int userUUID;
  final int competitionUUID;
  final String competitionDeadline;
  final String invitationStatus;

  const WrestlersSelectionList(
      this.userUUID, {super.key, required this.competitionUUID, required this.competitionDeadline, required this.invitationStatus}
      );

  @override
  State<WrestlersSelectionList> createState() => _WrestlersSelectionList();
}

class _WrestlersSelectionList extends State<WrestlersSelectionList> {
  final CoachService _coachService = CoachService();
  List<Map<String, dynamic>> coachWrestlers = [];
  bool _isLoading = true;
  static const Color primaryColor = Color(0xFFB4182D);

  @override
  void initState() {
    super.initState();
    _fetchWrestlingClubCoaches();
  }

  Future<void> _fetchWrestlingClubCoaches() async {
    try {
      List<Map<String, dynamic>> fetchedCoaches =
      await _coachService.fetchCoachWrestlers(coachUUID: widget.userUUID, competitionUUID: widget.competitionUUID);

      setState(() {
        coachWrestlers = fetchedCoaches;
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
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: _isLoading
            ? const Center(child: CircularProgressIndicator(color: primaryColor))
            : Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 30),

            const Center(
              child: Text(
                'Lista luptatorilor',
                style: TextStyle(
                  fontSize: 25,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ),

            const SizedBox(height: 20,),

            if(widget.invitationStatus == 'Pending')
              Expanded(
                child: CustomWrestlersList(
                  userUUID: widget.userUUID,
                  competitionUUID: widget.competitionUUID,
                  competitionDeadline: widget.competitionDeadline, wrestlers: coachWrestlers,
                ),
              )
            else
              Expanded(
                child: CustomListWrestlerRespond(
                  userUUID: widget.userUUID,
                  competitionUUID: widget.competitionUUID,
                  wrestlers: coachWrestlers,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
