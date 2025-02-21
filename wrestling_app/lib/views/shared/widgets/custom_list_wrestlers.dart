import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class CustomWrestlersList extends StatefulWidget {
  final List<Map<String, dynamic>> wrestlers;
  final int userUUID;
  final int competitionUUID;
  final String competitionDeadline;

  const CustomWrestlersList({
    super.key,
    required this.wrestlers,
    required this.userUUID,
    required this.competitionUUID,
    required this.competitionDeadline,
  });

  @override
  State<CustomWrestlersList> createState() => _CustomWrestlersListState();
}

class _CustomWrestlersListState extends State<CustomWrestlersList> {
  String invitationFilter = "All"; // Default: Show all invitations

  final List<String> invitationFilters = ["All", "Invited", "Not Invited"];

  @override
  Widget build(BuildContext context) {
    // Filter the list based on selected criteria
    List<Map<String, dynamic>> filteredWrestlers = widget.wrestlers.where((wrestler) {
      bool matchesInvitation = (invitationFilter == "All") ||
          (invitationFilter == "Invited" && wrestler['invitation_status'] != null) ||
          (invitationFilter == "Not Invited" && wrestler['invitation_status'] == null);
      return matchesInvitation;
    }).toList();

    return Column(
      children: [
        const SizedBox(height: 10),

        // **Invitation Status Filter Buttons**
        _buildFilterButtons(invitationFilters, invitationFilter, (filter) {
          setState(() {
            invitationFilter = filter;
          });
        }),

        const SizedBox(height: 10),

        // **Wrestlers ListView**
        Expanded(
          child: filteredWrestlers.isEmpty
              ? const Center(
            child: Text(
              "Nu există sportivi disponibili.",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          )
              : ListView.builder(
            itemCount: filteredWrestlers.length,
            itemBuilder: (context, index) {
              final wrestler = filteredWrestlers[index];
              TextEditingController weightController = TextEditingController(); // Controller for weight category

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
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start, // Ensures items align properly
                          children: [
                            Text(
                              "Status: ${wrestler['invitation_status'] ?? "Not Invited"}",
                              style: const TextStyle(color: Colors.white70),
                            ),

                            const SizedBox(width: 110), // Add spacing between status and weight category

                            if (wrestler["weight_category"] != null)
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                decoration: BoxDecoration(
                                  color: Colors.black,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  "${wrestler["weight_category"]} Kg", // Concatenated with "Kg"
                                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                                ),
                              ),
                          ],
                        ),

                        const SizedBox(height: 5), // Space between status and input field

                        // **Weight Category Input Field**
                        if (wrestler["weight_category"] == null)
                        TextField(
                          controller: weightController,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: Colors.white,
                            hintText: "Introduceți categoria de greutate",
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: const BorderSide(color: Colors.black),
                            ),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                          ),
                        ),

                        const SizedBox(height: 10), // **⬆️ Space added here between input & button**

                        // **Invitation Button (Now Moved Up)**
                          if (wrestler["weight_category"] == null)
                          ElevatedButton(
                            onPressed: () {
                              String weightCategory = weightController.text.trim();
                              if (weightCategory.isNotEmpty) {
                                _onSelectWrestler(context, wrestler['wrestler_UUID'], weightCategory);
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text("Introduceți o categorie de greutate!"),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                              }
                            }
                                , // Disable button if already invited
                            style: ElevatedButton.styleFrom(
                              backgroundColor: wrestler['invitation_status'] == null ? Colors.black : Colors.grey,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                            ),
                            child: const Text(
                              "Trimite invitație",
                              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                            ),
                          ),
                          const SizedBox(width: 96), // Add some spacing between button and weight category
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  // **Builds Filter Buttons (For Invitation Status)**
  Widget _buildFilterButtons(List<String> options, String selected, Function(String) onTap) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Wrap(
        spacing: 8,
        children: options.map((option) {
          return ElevatedButton(
            onPressed: () => onTap(option),
            style: ElevatedButton.styleFrom(
              backgroundColor: selected == option ? const Color(0xFFB4182D) : Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: const BorderSide(color: Color(0xFFB4182D), width: 2),
              ),
            ),
            child: Text(
              option,
              style: TextStyle(
                color: selected == option ? Colors.white : const Color(0xFFB4182D),
                fontWeight: FontWeight.bold,
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  void _onSelectWrestler(BuildContext context, int wrestlerUUID, String weightCategory) async {
    String apiUrl = "http://192.168.0.154/wrestling_app/coach/post_wrestler_invitation.php";

    try {
      // Convert String deadline to DateTime
      DateTime competitionDeadline = DateTime.parse(widget.competitionDeadline);

      // Subtract 7 days
      DateTime newDeadline = competitionDeadline.subtract(const Duration(days: 7));

      // Format to MySQL datetime format
      String formattedDeadline = DateFormat("yyyy-MM-dd HH:mm:ss").format(newDeadline);

      // Show loading indicator
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator()),
      );

      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {"Content-Type": "application/json"},
        body: json.encode({
          "competition_UUID": widget.competitionUUID,
          "recipient_UUID": wrestlerUUID,
          "invitation_deadline": formattedDeadline,
          "weight_category": weightCategory, // Added weight category
        }),
      );

      Navigator.pop(context); // Close loading dialog

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        if (responseData.containsKey("success")) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(responseData["success"]), backgroundColor: Colors.green),
          );
          setState(() {
            int index = widget.wrestlers.indexWhere((c) => c['wrestler_UUID'] == wrestlerUUID);
            if (index != -1) {
              widget.wrestlers[index]['invitation_status'] = "Pending"; // Update directly
              widget.wrestlers[index]['weight_category'] = weightCategory; // Update weight category
            }
          });
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(responseData["error"] ?? "Unknown error"), backgroundColor: Colors.red),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Failed to send invitation"), backgroundColor: Colors.red),
        );
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: $e"), backgroundColor: Colors.red),
        );
      }
    }
  }

}
