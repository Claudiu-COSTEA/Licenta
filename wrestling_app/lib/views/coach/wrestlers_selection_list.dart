import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:wrestling_app/services/coach_apis_services.dart';
import 'package:wrestling_app/views/shared/widgets/custom_list_wrestlers.dart';
import '../shared/widgets/custom_list_coaches.dart';

class WrestlersSelectionList extends StatefulWidget {
  final int userUUID;
  final int competitionUUID;
  final String competitionDeadline;

  const WrestlersSelectionList(
      this.userUUID, {super.key, required this.competitionUUID, required this.competitionDeadline}
      );

  @override
  State<WrestlersSelectionList> createState() => _WrestlersSelectionList();
}

class _WrestlersSelectionList extends State<WrestlersSelectionList> {
  final CoachService _coachService = CoachService();
  List<Map<String, dynamic>> coachWrestlers = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchWrestlingClubCoaches();
  }

  Future<void> _fetchWrestlingClubCoaches() async {
    try {
      List<Map<String, dynamic>> fetchedCoaches =
      await _coachService.fetchWrestlersForCoach(widget.userUUID, widget.competitionUUID);

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
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 40),

            // ✅ Back Arrow Button
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
                'Lista luptatorilor',
                style: TextStyle(
                  fontSize: 25,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ),

            Expanded(
              child: CustomWrestlersList(
                userUUID: widget.userUUID,
                competitionUUID: widget.competitionUUID,
                competitionDeadline: widget.competitionDeadline, wrestlers: coachWrestlers,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
