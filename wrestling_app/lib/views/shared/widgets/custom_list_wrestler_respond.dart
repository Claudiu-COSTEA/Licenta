import 'package:flutter/material.dart';

class CustomListWrestlerRespond extends StatefulWidget {
  final List<Map<String, dynamic>> wrestlers;
  final int userUUID;
  final int competitionUUID;

  const CustomListWrestlerRespond({
    super.key,
    required this.wrestlers,
    required this.userUUID,
    required this.competitionUUID,
  });

  @override
  State<CustomListWrestlerRespond> createState() => _CustomListWrestlerRespondState();
}

class _CustomListWrestlerRespondState extends State<CustomListWrestlerRespond> {
  String invitationFilter = "All"; // Default: Show all wrestlers
  final List<String> invitationFilters = ["All", "Accepted", "Declined"];

  @override
  Widget build(BuildContext context) {
    // **Filter Wrestlers** Based on Invitation Status
    List<Map<String, dynamic>> filteredWrestlers = widget.wrestlers.where((wrestler) {
      bool matchesInvitation = invitationFilter == "All" ||
          (invitationFilter == "Accepted" && wrestler['invitation_status'] == 'Accepted') ||
          (invitationFilter == "Declined" && wrestler['invitation_status'] == 'Declined');
      return matchesInvitation;
    }).toList();

    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          const SizedBox(height: 10),

          // **Invitation Status Filter Buttons**
          _buildFilterButtons(),

          const SizedBox(height: 10),

          // **Wrestlers ListView**
          Expanded(
            child: filteredWrestlers.isEmpty
                ? const Center(
              child: Text(
                "Nu există luptători disponibili.",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            )
                : ListView.builder(
              itemCount: filteredWrestlers.length,
              itemBuilder: (context, index) {
                final wrestler = filteredWrestlers[index];

                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFFB4182D),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ListTile(
                      title: Text(
                        wrestler['wrestler_name'],
                        style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                      subtitle: Row(
                        mainAxisAlignment: MainAxisAlignment.start, // Ensures items align properly
                        children: [
                          Text(
                            "Status: ${wrestler['invitation_status'] ?? "Not Invited"}",
                            style: const TextStyle(color: Colors.white70),
                          ),

                          const SizedBox(width: 130), // Add spacing between status and weight category

                          if (wrestler["weight_category"] != null)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              decoration: BoxDecoration(
                                color: Colors.black,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                "${wrestler["weight_category"]}",
                                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                              ),
                            ),
                        ],
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

  // **Builds Filter Buttons (For Invitation Status)**
  Widget _buildFilterButtons() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Wrap(
        spacing: 8,
        children: invitationFilters.map((filter) {
          return ElevatedButton(
            onPressed: () {
              setState(() {
                invitationFilter = filter;
              });
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: invitationFilter == filter ? const Color(0xFFB4182D) : Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: const BorderSide(color: Color(0xFFB4182D), width: 2),
              ),
            ),
            child: Text(
              filter,
              style: TextStyle(
                color: invitationFilter == filter ? Colors.white : const Color(0xFFB4182D),
                fontWeight: FontWeight.bold,
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
