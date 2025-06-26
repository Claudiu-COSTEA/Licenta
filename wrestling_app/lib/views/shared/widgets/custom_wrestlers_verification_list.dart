import 'package:flutter/material.dart';
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
                            // ───────────── Wrestler Details ─────────────
                            Text(
                              wrestler.wrestlerName,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                fontSize: 18,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'Club: ${wrestler.wrestlingClubName}',
                              style: const TextStyle(color: Colors.white70),
                            ),
                            Text(
                              'Antrenor: ${wrestler.coachName}',
                              style: const TextStyle(color: Colors.white70),
                            ),
                            const SizedBox(height: 12),

                            // ───────────── Buttons or Status ─────────────
                            if (wrestler.refereeVerification == null || wrestler.refereeVerification!.isEmpty) ...[
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: ElevatedButton(
                                      onPressed: () {
                                        _refereeServices
                                            .updateRefereeVerification(
                                          competitionUUID: widget.competitionUUID,
                                          recipientUUID: wrestler.wrestlerUUID,
                                          recipientRole: 'Wrestler',
                                          refereeVerification: "Confirmed",
                                        )
                                            .then((_) => _fetchWrestlers());
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.black,
                                        padding: const EdgeInsets.symmetric(vertical: 12),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(50),
                                        ),
                                      ),
                                      child: const Text(
                                        "Confirmă",
                                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: ElevatedButton(
                                      onPressed: () {
                                        _refereeServices
                                            .updateRefereeVerification(
                                          competitionUUID: widget.competitionUUID,
                                          recipientUUID: wrestler.wrestlerUUID,
                                          recipientRole: 'Wrestler',
                                          refereeVerification: "Declined",
                                        )
                                            .then((_) => _fetchWrestlers());
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.black,
                                        padding: const EdgeInsets.symmetric(vertical: 12),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(50),
                                        ),
                                      ),
                                      child: const Text(
                                        "Refuză",
                                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ] else ...[
                              Text(
                                wrestler.refereeVerification == 'Confirmed'
                                    ? 'Status verificare: Confirmat'
                                    : 'Status verificare: Refuzat',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                  fontSize: 18,
                                ),
                              ),
                            ],
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
