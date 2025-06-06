import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../models/wrestler_verification_model.dart';
import '../../../services/referee_api_services.dart';

class CustomWrestlersVerificationList extends StatefulWidget {
  final int competitionUUID;
  final String weightCategory;
  final String wrestlingStyle;

  const CustomWrestlersVerificationList({
    super.key,
    required this.competitionUUID,
    required this.weightCategory,
    required this.wrestlingStyle,
  });

  @override
  State<CustomWrestlersVerificationList> createState() =>
      _CustomWrestlersVerificationList();
}

class _CustomWrestlersVerificationList extends State<CustomWrestlersVerificationList> {
  late Future<List<WrestlerVerification>> _wrestlers;
  final RefereeServices _refereeServices = RefereeServices();

  @override
  void initState() {
    super.initState();
    _fetchWrestlers();
  }

  void _fetchWrestlers() {
    setState(() {
      _wrestlers = _refereeServices.fetchWrestlers(
        widget.wrestlingStyle,
        widget.weightCategory,
        widget.competitionUUID,
      );
    });
  }

  String _roStyle(String en) {
    switch (en) {
      case 'Greco Roman':
        return 'Greco-romane';
      case 'Freestyle':
        return 'Libere';
      case 'Women':
        return 'Feminine';
      default:
        return en;
    }
  }

  @override
  Widget build(BuildContext context) {
    final wrestlingStyleRO = _roStyle(widget.wrestlingStyle);

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
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Wrestler Info
                            Text(
                              wrestler.wrestlerName,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                fontSize: 18,
                              ),
                            ),
                            const SizedBox(height: 5),
                            Text(
                              'Club: ${wrestler.wrestlingClubName}\n'
                                  'Antrenor: ${wrestler.coachName}\n'
                                  'Greutate: ${wrestler.weightCategory} Kg\n'
                                  'Stil: $wrestlingStyleRO',
                              style: GoogleFonts.roboto(
                                color: Colors.white70,
                                fontSize: 14,
                              ),
                            ),

                            const SizedBox(height: 10),

                            // Buttons Row or Status
                            if (wrestler.refereeVerification == "")
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                children: [
                                  Expanded(
                                    child: ElevatedButton(
                                      onPressed: () {
                                        _refereeServices.updateRefereeVerification(
                                          competitionUUID: widget.competitionUUID,
                                          recipientUUID: wrestler.wrestlerUUID,
                                          recipientRole: 'Wrestler',
                                          refereeVerification: "Confirmed",
                                        ).then((_) => _fetchWrestlers());
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.black,
                                      ),
                                      child: const Text(
                                        "Confirmă",
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: ElevatedButton(
                                      onPressed: () {
                                        _refereeServices.updateRefereeVerification(
                                          competitionUUID: widget.competitionUUID,
                                          recipientUUID: wrestler.wrestlerUUID,
                                          recipientRole: 'Wrestler',
                                          refereeVerification: "Declined",
                                        ).then((_) => _fetchWrestlers());
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.black,
                                      ),
                                      child: const Text(
                                        "Refuză",
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              )
                            else if (wrestler.refereeVerification == 'Confirmed')
                              const Text(
                                'Status verificare: Confirmat',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                  fontSize: 18,
                                ),
                              )
                            else if (wrestler.refereeVerification == 'Declined')
                                const Text(
                                  'Status verificare: Refuzat',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                    fontSize: 18,
                                  ),
                                ),
                          ],
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
