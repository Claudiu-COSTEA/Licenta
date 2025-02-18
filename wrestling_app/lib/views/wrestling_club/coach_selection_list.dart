import 'package:flutter/material.dart';
import 'package:wrestling_app/services/wrestling_clubs_apis_services.dart';
import '../shared/widgets/custom_list_coaches.dart';

class CoachSelectionList extends StatefulWidget {
  final int userUUID;
  final int competitionUUID;
  final String competitionDeadline;

  const CoachSelectionList(this.userUUID, {super.key, required this.competitionUUID, required this.competitionDeadline});

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
      await _wrestlingClubService.fetchCoachesForClub(widget.userUUID);

      setState(() {
        wrestlingClubCoaches = fetchedCoaches;
      });
    } catch (e) {
      print("Error fetching wrestling club coaches: $e");
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
            Expanded(
              child: CustomCoachesList(items: wrestlingClubCoaches, userUUID: widget.userUUID, competitionUUID: widget.competitionUUID, competitionDeadline: widget.competitionDeadline,),
            ),
          ],
        ),
      ),
    );
  }
}
