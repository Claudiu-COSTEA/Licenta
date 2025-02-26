import 'package:flutter/material.dart';

class CustomListCoachesRespond extends StatefulWidget {
  final List<Map<String, dynamic>> coaches;
  final int userUUID;
  final int competitionUUID;

  const CustomListCoachesRespond({
    super.key,
    required this.coaches,
    required this.userUUID,
    required this.competitionUUID,
  });

  @override
  State<CustomListCoachesRespond> createState() => _CustomListCoachesRespondState();
}

class _CustomListCoachesRespondState extends State<CustomListCoachesRespond> {
  String selectedStyle = "All"; // Default to show all wrestling styles
  String selectedInvitationStatus = "All"; // Default to show all invitations

  final List<String> wrestlingStyles = ["All", "Greco Roman", "Freestyle", "Women"];
  final List<String> invitationStatuses = ["All", "Accepted", "Declined"];

  @override
  Widget build(BuildContext context) {
    // ✅ Filtering logic (Both filters applied)
    List<Map<String, dynamic>> filteredCoaches = widget.coaches.where((coach) {
      bool matchesStyle = selectedStyle == "All" || coach['wrestling_style'] == selectedStyle;
      bool matchesStatus = coach['invitation_status'] != null && ( selectedInvitationStatus == "All" || coach['invitation_status'] == selectedInvitationStatus );
      return matchesStyle && matchesStatus;
    }).toList();

    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          const SizedBox(height: 10),

          // Wrestling Style Filter Buttons
          _buildWrestlingStyleFilterButtons(),

          const SizedBox(height: 10),

          // Invitation Status Filter Buttons
          _buildInvitationStatusFilterButtons(),

          const SizedBox(height: 10),

          //  Coaches ListView
          Expanded(
            child: filteredCoaches.isEmpty
                ? const Center(
              child: Text(
                "Nu există antrenori disponibili.",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            )
                : ListView.builder(
              itemCount: filteredCoaches.length,
              itemBuilder: (context, index) {
                final coach = filteredCoaches[index];

                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFFB4182D),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ListTile(
                      title: Text(
                        coach['coach_name'],
                        style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                      subtitle: Text(
                        "Style: ${coach['wrestling_style']}\nStatus: ${coach['invitation_status']}",
                        style: const TextStyle(color: Colors.white70),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // ✅ Builds Wrestling Style Filter Buttons
  Widget _buildWrestlingStyleFilterButtons() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Wrap(
        spacing: 8,
        children: wrestlingStyles.map((style) {
          return ElevatedButton(
            onPressed: () {
              setState(() {
                selectedStyle = style;
              });
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: selectedStyle == style ? const Color(0xFFB4182D) : Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: const BorderSide(color: Color(0xFFB4182D), width: 2),
              ),
            ),
            child: Text(
              style,
              style: TextStyle(
                color: selectedStyle == style ? Colors.white : const Color(0xFFB4182D),
                fontWeight: FontWeight.bold,
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  // ✅ Builds Invitation Status Filter Buttons
  Widget _buildInvitationStatusFilterButtons() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Wrap(
        spacing: 8,
        children: invitationStatuses.map((status) {
          return ElevatedButton(
            onPressed: () {
              setState(() {
                selectedInvitationStatus = status;
              });
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: selectedInvitationStatus == status ? const Color(0xFFB4182D) : Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: const BorderSide(color: Color(0xFFB4182D), width: 2),
              ),
            ),
            child: Text(
              status,
              style: TextStyle(
                color: selectedInvitationStatus == status ? Colors.white : const Color(0xFFB4182D),
                fontWeight: FontWeight.bold,
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
