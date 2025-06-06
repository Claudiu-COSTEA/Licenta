import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:wrestling_app/services/referee_api_services.dart';
import 'package:wrestling_app/views/shared/widgets/toast_helper.dart';

class RefereeFightDashboard extends StatefulWidget {
  final int competitionUUID;

  const RefereeFightDashboard({super.key, required this.competitionUUID});

  @override
  State<RefereeFightDashboard> createState() => _RefereeFightDashboardState();
}

class _RefereeFightDashboardState extends State<RefereeFightDashboard> {
  int currentFightIndex = 0;
  String? selectedWinner;
  int wrestler1Points = 0;
  int wrestler2Points = 0;

  final RefereeServices _refereeServices = RefereeServices();

  // Sample fights list
  final List<Map<String, String>> fights = [
    {
      "round": "Round 16",
      "fightNumber": "123",
      "style": "Greco-Roman",
      "weight": "74 Kg",
      "wrestler1": "John Doe",
      "coach1": "Coach 1",
      "club1": "Red Lions",
      "wrestler2": "Alex Smith",
      "coach2": "Coach 2",
      "club2": "Blue Warriors"
    },
    {
      "round": "Round 8",
      "fightNumber": "124",
      "style": "Freestyle",
      "weight": "82 Kg",
      "wrestler1": "Mike Tyson",
      "coach1": "Coach 3",
      "club1": "Iron Fighters",
      "wrestler2": "Jake Paul",
      "coach2": "Coach 4",
      "club2": "YouTube Warriors"
    },
    {
      "round": "Round 4",
      "fightNumber": "125",
      "style": "Greco-Roman",
      "weight": "60 Kg",
      "wrestler1": "Bruce Lee",
      "coach1": "Master Wong",
      "club1": "Dragon Club",
      "wrestler2": "Chuck Norris",
      "coach2": "Sensei Tanaka",
      "club2": "Texas Rangers"
    }
  ];

  @override
  void initState() {
    super.initState();
    // Force landscape mode
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    _generateFights();
  }

  @override
  void dispose() {
    // Reset orientation when leaving
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    super.dispose();
  }

  Future<void> _generateFights() async {
    final count = await _refereeServices.postFights(/* competitionUUID */ 0);
    if (count > 0) {
      ToastHelper.succes("Au fost inserate $count lupte.");
    }
  }

  void _finalizeFight() {
    if (selectedWinner == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select a winner before finalizing!")),
      );
      return;
    }
    if (currentFightIndex < fights.length - 1) {
      setState(() {
        currentFightIndex++;
        wrestler1Points = 0;
        wrestler2Points = 0;
        selectedWinner = null;
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("All fights completed!")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final fight = fights[currentFightIndex];
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              // Top Row: Fight Round - Wrestling Style - Weight Category
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildInfoBox(fight["fightNumber"]!),
                  _buildInfoBox(fight["round"]!),
                  _buildInfoBox(fight["style"]!),
                  _buildInfoBox(fight["weight"]!),
                ],
              ),
              // Wrestlers Information
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    _buildWrestler(fight["wrestler1"]!, fight["coach1"]!, fight["club1"]!),
                    _buildPointsColumn(),
                    _buildWrestler(fight["wrestler2"]!, fight["coach2"]!, fight["club2"]!),
                  ],
                ),
              ),
              // Select Winner Row
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    "Castigator:",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(width: 10),
                  DropdownButton<String>(
                    value: selectedWinner,
                    items: const [
                      DropdownMenuItem(value: "Luptator 1", child: Text("Luptator 1 (Red)")),
                      DropdownMenuItem(value: "Luptator 2", child: Text("Luptator 2 (Blue)")),
                    ],
                    onChanged: (value) {
                      setState(() {
                        selectedWinner = value;
                      });
                    },
                    hint: const Text("Selecteaza castigator"),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: _finalizeFight,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFB4182D),
                ),
                child: Text(
                  currentFightIndex < fights.length - 1 ? "Finalizeaza lupta" : "Finalizare turneu",
                  style: const TextStyle(color: Colors.white, fontSize: 18),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Box for displaying fight info
  Widget _buildInfoBox(String value) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFFB4182D), width: 2),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  // Wrestler Information Box
  Widget _buildWrestler(String wrestlerName, String coachName, String wrestlingClubName) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFFB4182D), width: 2),
        borderRadius: BorderRadius.circular(10),
      ),
      constraints: const BoxConstraints(
        minWidth: 150,
        maxWidth: 250,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text("Luptator: $wrestlerName", style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
          const SizedBox(height: 4),
          Text("Antrenor: $coachName", style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
          const SizedBox(height: 4),
          Text("Club: $wrestlingClubName", style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
        ],
      ),
    );
  }

  // Points Column
  Widget _buildPointsColumn() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildPointCounter("Puncte", wrestler1Points, (value) {
          setState(() {
            wrestler1Points = value;
          });
        }),
        const SizedBox(width: 100),
        _buildPointCounter("Puncte", wrestler2Points, (value) {
          setState(() {
            wrestler2Points = value;
          });
        }),
      ],
    );
  }

  // Counter for Points
  Widget _buildPointCounter(String label, int points, Function(int) onChanged) {
    return Row(
      children: [
        IconButton(
          icon: const Icon(Icons.remove_circle, color: Colors.red),
          onPressed: () => onChanged(points > 0 ? points - 1 : points),
        ),
        Text(points.toString(), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        IconButton(
          icon: const Icon(Icons.add_circle, color: Colors.green),
          onPressed: () => onChanged(points + 1),
        ),
      ],
    );
  }
}
