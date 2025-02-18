import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class CustomCoachesList extends StatefulWidget {
  final List<Map<String, dynamic>> items; // List of coaches
  final int userUUID;
  final int competitionUUID;
  final String competitionDeadline;

  const CustomCoachesList({super.key, required this.items, required this.userUUID, required this.competitionUUID, required this.competitionDeadline});

  @override
  State<CustomCoachesList> createState() => _CustomCoachesListState();
}

class _CustomCoachesListState extends State<CustomCoachesList> {
  String selectedStyle = "All"; // Default to show all coaches
  final List<String> wrestlingStyles = ["Greco Roman", "Freestyle", "Women"]; // Fixed naming

  @override
  Widget build(BuildContext context) {
    // Filtered List Based on Selected Style
    List<Map<String, dynamic>> filteredCoaches = widget.items
        .where((coach) =>
    selectedStyle == "All" || coach['wrestling_style'] == selectedStyle)
        .toList();

    return Column(
      children: [
        const SizedBox(height: 10),

        // "All" Button (Higher than other buttons)
        ElevatedButton(
          onPressed: () {
            setState(() {
              selectedStyle = "All";
            });
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: selectedStyle == "All"
                ? const Color(0xFFB4182D) // Selected color (red)
                : Colors.white, // Default button color
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(50), // Fully rounded button
              side: const BorderSide(color: Color(0xFFB4182D), width: 2), // Border
            ),
          ),
          child: Text(
            "All",
            style: TextStyle(
              color: selectedStyle == "All" ? Colors.white : const Color(0xFFB4182D),
              fontWeight: FontWeight.bold,
            ),
          ),
        ),

        const SizedBox(height: 10),

        // Filter Buttons with Horizontal Scrolling
        SingleChildScrollView(
          scrollDirection: Axis.horizontal, // Allow scrolling
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Wrap(
              spacing: 8, // Space between buttons
              children: wrestlingStyles.map((style) {
                return ElevatedButton(
                  onPressed: () {
                    setState(() {
                      selectedStyle = style;
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: selectedStyle == style
                        ? const Color(0xFFB4182D) // Selected button color (red)
                        : Colors.white, // Default button color
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                      side: const BorderSide(color: Color(0xFFB4182D), width: 2), // Border
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
          ),
        ),

        const SizedBox(height: 10),

        // ListView for Coaches
        Expanded(
          child: filteredCoaches.isEmpty
              ? const Center(
            child: Text(
              "Nu există antrenori disponibili pentru acest stil.",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          )
              : ListView.builder(
            itemCount: filteredCoaches.length,
            itemBuilder: (context, index) {
              final item = filteredCoaches[index];
              final coachFullName = item['coach_name'] ?? 'Unknown Coach';
              final wrestlingStyle = item['wrestling_style'] ?? 'Unknown Style';

              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFFB4182D), // Red background
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ListTile(
                    title: Text(
                      coachFullName,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    subtitle: Text(
                      "Style: $wrestlingStyle",
                      style: const TextStyle(color: Colors.white70),
                    ),
                    trailing: ElevatedButton(
                      onPressed: () {
                       _onSelectCoach(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black, // Black button
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20), // Rounded shape
                        ),
                      ),
                      child: const Text(
                        "Trimite invitație",
                        style: TextStyle(
                          color: Colors.white, // White text
                          fontWeight: FontWeight.bold,
                        ),
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

  void _onSelectCoach(BuildContext context) async {
    String apiUrl = "http://192.168.0.154/wrestling_app/wrestling_club/post_coach_invitation.php";

    try {
      // ✅ Convert String deadline to DateTime
      DateTime competitionDeadline = DateTime.parse(widget.competitionDeadline);

      // ✅ Subtract 7 days
      DateTime newDeadline = competitionDeadline.subtract(const Duration(days: 7));

      // ✅ Format to MySQL datetime format
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
          "recipient_UUID": widget.userUUID,
          "invitation_deadline": formattedDeadline, // ✅ Fixed deadline format
        }),
      );

      Navigator.pop(context); // Close loading dialog

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        if (responseData.containsKey("success")) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(responseData["success"]), backgroundColor: Colors.green),
          );
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
      Navigator.pop(context); // Close loading dialog
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e"), backgroundColor: Colors.red),
      );
    }
  }
}
