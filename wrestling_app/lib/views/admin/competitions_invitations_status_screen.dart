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
  List<ClubInvitation> _allInvitations = [];
  String _selectedFilter = 'Toate';
  static const Color primaryColor = Color(0xFFB4182D);

  // Map between display label and underlying status value
  final Map<String, String?> _filterMap = {
    'Toate': null,
    'În așteptare': 'Pending',
    'Confirmate': 'Confirmed',
    'Refuzate': 'Postponed',
  };

  @override
  void initState() {
    super.initState();
    _futureInvitations = AdminServices().fetchClubsInvitationsStatus();
    _futureInvitations.then((list) {
      setState(() {
        _allInvitations = list;
      });
    });
  }

  List<ClubInvitation> get _filteredInvitations {
    final filterValue = _filterMap[_selectedFilter];
    if (filterValue == null) return _allInvitations;
    return _allInvitations
        .where((inv) => inv.invitationStatus == filterValue)
        .toList();
  }

  Widget _buildFilterButton(String label) {
    final isSelected = _selectedFilter == label;
    return ElevatedButton(
      onPressed: () => setState(() => _selectedFilter = label),
      style: ElevatedButton.styleFrom(
        backgroundColor: isSelected ? primaryColor : Colors.white,
        side: BorderSide(color: primaryColor),
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      ),
      child: Text(
        label,
        softWrap: false,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        textAlign: TextAlign.center,
        style: TextStyle(
          color: isSelected ? Colors.white : primaryColor,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          fontSize: 12,
        ),
      ),
    );
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
              'Cluburi Invitate',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Wrap(
              alignment: WrapAlignment.center,
              spacing: 8,
              runSpacing: 4,
              children: _filterMap.keys.map((label) {
                return _buildFilterButton(label);
              }).toList(),
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: _allInvitations.isEmpty
                ? FutureBuilder<List<ClubInvitation>>(
              future: _futureInvitations,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text('Eroare: ${snapshot.error}'));
                }
                return const SizedBox.shrink();
              },
            )
                : ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              itemCount: _filteredInvitations.length,
              itemBuilder: (context, index) {
                final inv = _filteredInvitations[index];
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
            ),
          ),
        ],
      ),
    );
  }
}
