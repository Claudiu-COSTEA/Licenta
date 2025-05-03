import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:wrestling_app/services/constants.dart';
import 'package:wrestling_app/services/notifications_services.dart';

class CustomCoachesList extends StatefulWidget {
  final List<Map<String, dynamic>> coaches;
  final int userUUID;
  final int competitionUUID;
  final String competitionDeadline;

  const CustomCoachesList({
    super.key,
    required this.coaches,
    required this.userUUID,
    required this.competitionUUID,
    required this.competitionDeadline,
  });

  @override
  State<CustomCoachesList> createState() => _CustomCoachesListState();
}

class _CustomCoachesListState extends State<CustomCoachesList> {
  String selectedStyle = "All"; // Default: Show all wrestling styles
  String invitationFilter = "All"; // Default: Show all invitations

  final List<String> wrestlingStyles = ["All", "Greco Roman", "Freestyle", "Women"];
  final List<String> invitationFilters = ["All", "Invited", "Not Invited"];

  NotificationsServices notificationService = NotificationsServices();

  @override
  Widget build(BuildContext context) {
    // Filter the list based on selected criteria
    List<Map<String, dynamic>>  filteredCoaches = widget.coaches.where((coach) {
      bool matchesStyle = selectedStyle == "All" || coach['wrestling_style'] == selectedStyle;
      bool matchesInvitation = (invitationFilter == "All") ||
          (invitationFilter == "Invited" && coach['invitation_status'] != null) ||
          (invitationFilter == "Not Invited" && coach['invitation_status'] == null);
      return matchesStyle && matchesInvitation;
    }).toList();

    return Column(
      children: [
        const SizedBox(height: 10),

        // **Wrestling Style Filter Buttons**
        _buildFilterButtons(wrestlingStyles, selectedStyle, (style) {
          setState(() {
            selectedStyle = style;
          });
        }),

        const SizedBox(height: 10),

        // **Invitation Status Filter Buttons**
        _buildFilterButtons(invitationFilters, invitationFilter, (filter) {
          setState(() {
            invitationFilter = filter;
          });
        }),

        const SizedBox(height: 10),

        // **Coaches ListView**
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
                      "Style: ${coach['wrestling_style']}\nStatus: ${coach['invitation_status'] ?? "Not Invited"}",
                      style: const TextStyle(color: Colors.white70),
                    ),
                    trailing: ElevatedButton(
                      onPressed: coach['invitation_status'] == null
                          ? () => _onSelectCoach(context, coach['coach_UUID'])
                          : null, // Disable button if already invited
                      style: ElevatedButton.styleFrom(
                        backgroundColor: coach['invitation_status'] == null ? Colors.black : Colors.grey,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      ),
                      child: const Text(
                        "Trimite invitație",
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                      ),
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

  // **Builds Filter Buttons (For Style & Invitation Status)**
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

  // **Handles Sending Coach Invitation**
  void _onSelectCoach(BuildContext context, int coachUUID) async {
    const _url = AppConstants.baseUrl + "wrestlingClub/sendCoachInvitation";

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
        Uri.parse(_url),
        headers: {"Content-Type": "application/json"},
        body: json.encode({
          "competition_UUID": widget.competitionUUID,
          "recipient_UUID": coachUUID,
          "invitation_deadline": formattedDeadline,
        }),
      );

      print("Response Status Code: ${response.statusCode}");
      print("Response Body: ${response.body}");

      Navigator.pop(context); // Close loading dialog

      print("Raw response.body: ${response.body}");

      if (response.statusCode == 200 || response.statusCode == 201) {
        final Map<String, dynamic> responseData = json.decode(response.body);

        if (responseData.containsKey("body") && responseData["body"] is Map<String, dynamic>) {
          final body = responseData["body"];

          if (body.containsKey("message")) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(body["message"]), backgroundColor: Colors.green),
            );

            setState(() {
              int index = widget.coaches.indexWhere((c) => c['coach_UUID'] == coachUUID);
              if (index != -1) {
                widget.coaches[index]['invitation_status'] = "Pending";
              }
            });

            String? token = await notificationService.getUserFCMToken(coachUUID);
            if (token != null) {
              notificationService.sendFCMMessage(token);
            }

          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Unexpected response format"), backgroundColor: Colors.red),
            );
          }
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Missing 'body' in response"), backgroundColor: Colors.red),
          );
        }
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
