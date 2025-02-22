import 'package:flutter/material.dart';

import '../../../models/wrestler_verification_model.dart';
import '../../../services/referee_api_services.dart';


class CustomWrestlersVerificationList extends StatefulWidget {
  final int competitionUUID;
  final String weightCategory;
  final String wrestlingStyle;

  const CustomWrestlersVerificationList({super.key, required this.competitionUUID, required this.weightCategory, required this.wrestlingStyle});

  @override
  State<CustomWrestlersVerificationList> createState() => _CustomWrestlersVerificationList();
}

class _CustomWrestlersVerificationList extends State<CustomWrestlersVerificationList> {
  late Future<List<WrestlerVerification>> _wrestlers;


  @override
  void initState() {
    super.initState();
    _fetchWrestlers();
  }

  void _fetchWrestlers() {
    setState(() {
      _wrestlers = RefereeServices().fetchWrestlers(widget.wrestlingStyle, widget.weightCategory, widget.competitionUUID);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 10),

        // Wrestler List
        Expanded(
          child: FutureBuilder<List<WrestlerVerification>>(
            future: _wrestlers,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return Center(child: Text("Error: ${snapshot.error}"));
              } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return const Center(
                  child: Text(
                    "Nu există sportivi pentru această categorie.",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                );
              }

              final wrestlers = snapshot.data!;
              return ListView.builder(
                itemCount: wrestlers.length,
                itemBuilder: (context, index) {
                  final wrestler = wrestlers[index];

                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFFB4182D),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Container(
                        decoration: BoxDecoration(
                          color: const Color(0xFFB4182D),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(12), // Add padding for better spacing
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Wrestler Info
                              Text(
                                wrestler.wrestlerName,
                                style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 18),
                              ),
                              const SizedBox(height: 5),
                              Text(
                                "Club: ${wrestler.wrestlingClubName}\nAntrenor: ${wrestler.coachName}\nGreutate: ${wrestler.weightCategory} Kg\nStil: ${wrestler.wrestlingStyle}",
                                style: const TextStyle(color: Colors.white70, fontSize: 14),
                              ),

                              const SizedBox(height: 10), // Space before buttons

                              // Buttons Row
                              // Buttons Row
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                children: [
                                  Expanded(
                                    child: ElevatedButton(
                                      onPressed: () => {}, // Add function here
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.black,
                                        // shape: RoundedRectangleBorder(
                                        //   borderRadius: BorderRadius.circular(20),
                                        //   side: const BorderSide(color: Colors.white, width: 3), // ✅ Add border
                                        // ),
                                      ),
                                      child: const Text(
                                        "Confirm",
                                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 10), // Spacing between buttons
                                  Expanded(
                                    child: ElevatedButton(
                                      onPressed: () => {}, // Add function here
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.black,
                                        // shape: RoundedRectangleBorder(
                                        //   borderRadius: BorderRadius.circular(20),
                                        //   side: const BorderSide(color: Colors.white, width: 3), // ✅ Add border
                                        // ),
                                      ),
                                      child: const Text(
                                        "Decline",
                                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}
