import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:wrestling_app/services/referee_api_services.dart';
import 'package:wrestling_app/views/shared/widgets/toast_helper.dart';
import '../../models/fight_model.dart';

class RefereeFightDashboard extends StatefulWidget {
  final int competitionUUID;
  final String wrestlingStyle;

  const RefereeFightDashboard({
    super.key,
    required this.competitionUUID,
    required this.wrestlingStyle,
  });

  @override
  State<RefereeFightDashboard> createState() => _RefereeFightDashboardState();
}

class _RefereeFightDashboardState extends State<RefereeFightDashboard> {
  final RefereeServices _refereeServices = RefereeServices();

  bool _isLoading = true;
  List<CompetitionFight> _fights = [];
  int _currentFightIndex = 0;
  String? _selectedWinner;
  int _wrestler1Points = 0;
  int _wrestler2Points = 0;

  @override
  void initState() {
    super.initState();
    // forțează landscape
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    _initFights();
  }

  Future<void> _initFights() async {
    setState(() => _isLoading = true);

    final mainCount = await _refereeServices.postFights(
      competitionUUID: widget.competitionUUID,
      wrestlingStyle: widget.wrestlingStyle,
    );
    if (mainCount > 0) {
      ToastHelper.succes("Au fost generate $mainCount lupte principale.");
    }

    final bronzeCount = await _refereeServices.generateBronzeRound(
      competitionUUID: widget.competitionUUID,
      wrestlingStyle: widget.wrestlingStyle,
    );
    if (bronzeCount > 0) {
      ToastHelper.succes("Au fost generate $bronzeCount lupte pentru bronz.");
    }

    final fights = await _refereeServices.fetchFights(
      competitionUUID: widget.competitionUUID,
      wrestlingStyle: widget.wrestlingStyle,
    );

    for (final f in fights) {
      final red = await _refereeServices.fetchWrestlerDetails(
        wrestlerUUID: f.wrestlerUUIDRed,
      );
      final blue = await _refereeServices.fetchWrestlerDetails(
        wrestlerUUID: f.wrestlerUUIDBlue,
      );
      f.wrestlerNameRed = red?.wrestlerName;
      f.coachNameRed = red?.coachName;
      f.clubNameRed = red?.clubName;
      f.wrestlerNameBlue = blue?.wrestlerName;
      f.coachNameBlue = blue?.coachName;
      f.clubNameBlue = blue?.clubName;
    }

    setState(() {
      _fights = fights;
      _isLoading = false;
      _currentFightIndex = 0;
      _wrestler1Points = 0;
      _wrestler2Points = 0;
      _selectedWinner = null;
    });
  }

  @override
  void dispose() {
    // readuce la portret la ieșire
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    super.dispose();
  }

  Future<void> _submitResult() async {
    final f = _fights[_currentFightIndex];
    await _refereeServices.postFightResult(
      context: context,
      competitionUUID: widget.competitionUUID,
      competitionFightUUID: f.competitionFightUUID,
      wrestlerPointsRed: _wrestler1Points,
      wrestlerPointsBlue: _wrestler2Points,
      wrestlerUUIDWinner:
      _selectedWinner == 'red' ? f.wrestlerUUIDRed : f.wrestlerUUIDBlue,
    );
  }

  void _onAdvance() async {
    await _submitResult();
    if (_currentFightIndex < _fights.length - 1) {
      setState(() {
        _currentFightIndex++;
        _wrestler1Points = 0;
        _wrestler2Points = 0;
        _selectedWinner = null;
      });
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => EndOfFightsScreen(
            competitionUUID: widget.competitionUUID,
            wrestlingStyle: widget.wrestlingStyle,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(color: Color(0xFFB4182D)),
        ),
      );
    }
    if (_fights.isEmpty) {
      return const Scaffold(
        body: Center(child: Text("Nu există lupte de afișat.")),
      );
    }

    final fight = _fights[_currentFightIndex];

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.only(
            left: 16,
            right: 16,
            bottom: MediaQuery.of(context).padding.bottom + 16,
          ),
          child: Column(
            children: [
              // Header row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _infoBox("Ordine: ${fight.competitionFightOrderNumber}"),
                  _infoBox(fight.competitionRound),
                  _infoBox(fight.wrestlingStyle),
                  _infoBox("${fight.competitionFightWeightCategory} Kg"),
                ],
              ),
              const SizedBox(height: 16),
              // Main fight UI — aici am înlocuit Expanded cu un SizedBox pentru a nu crește prea mult
              SizedBox(
                height: 200,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _wrestlerBox("Roșu", fight, true),
                    _pointsColumn(),
                    _wrestlerBox("Albastru", fight, false),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              // Winner selector
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    "Câștigător:",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(width: 12),
                  DropdownButton<String>(
                    hint: const Text("Selectează"),
                    value: _selectedWinner,
                    items: const [
                      DropdownMenuItem(value: "red", child: Text("Roșu")),
                      DropdownMenuItem(value: "blue", child: Text("Albastru")),
                    ],
                    onChanged: (v) => setState(() => _selectedWinner = v),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // Advance button
              ElevatedButton(
                onPressed: () {
                  if (_selectedWinner == null) {
                    ToastHelper.eroare("Selectează câștigător !");
                    return;
                  }
                  _onAdvance();
                },
                style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFB4182D)),
                child: Text(
                  _currentFightIndex < _fights.length - 1
                      ? "Finalizează lupta"
                      : "Finalizează ultima luptă",
                  style: const TextStyle(color: Colors.white, fontSize: 18),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _infoBox(String txt) => Container(
    padding: const EdgeInsets.all(10),
    decoration: BoxDecoration(
      color: Colors.white,
      border: Border.all(color: const Color(0xFFB4182D), width: 2),
      borderRadius: BorderRadius.circular(10),
    ),
    child: Text(txt,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
  );

  Widget _wrestlerBox(String label, CompetitionFight f, bool isRed) {
    final name = isRed ? f.wrestlerNameRed : f.wrestlerNameBlue;
    final coach = isRed ? f.coachNameRed : f.coachNameBlue;
    final club = isRed ? f.clubNameRed : f.clubNameBlue;
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFFB4182D), width: 2),
        borderRadius: BorderRadius.circular(10),
      ),
      constraints: const BoxConstraints(minWidth: 150, maxWidth: 250),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 6),
          Text("Luptător: ${name ?? '—'}", textAlign: TextAlign.center),
          Text("Antrenor: ${coach ?? '—'}", textAlign: TextAlign.center),
          Text("Club: ${club ?? '—'}", textAlign: TextAlign.center),
        ],
      ),
    );
  }

  Widget _pointsColumn() => Row(
    children: [
      _pointControl(_wrestler1Points, (v) => setState(() => _wrestler1Points = v)),
      const SizedBox(width: 100),
      _pointControl(_wrestler2Points, (v) => setState(() => _wrestler2Points = v)),
    ],
  );

  Widget _pointControl(int pts, void Function(int) onChanged) => Row(
    children: [
      IconButton(
        icon: const Icon(Icons.remove_circle, color: Colors.red),
        onPressed: () => onChanged(pts > 0 ? pts - 1 : 0),
      ),
      Text(pts.toString(),
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
      IconButton(
        icon: const Icon(Icons.add_circle, color: Colors.green),
        onPressed: () => onChanged(pts + 1),
      ),
    ],
  );
}

class EndOfFightsScreen extends StatelessWidget {
  final int competitionUUID;
  final String wrestlingStyle;
  const EndOfFightsScreen({
    super.key,
    required this.competitionUUID,
    required this.wrestlingStyle,
  });

  @override
  Widget build(BuildContext context) {
    final services = RefereeServices();
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            const SizedBox(height: 30),
            Align(
              alignment: Alignment.centerLeft,
              child: IconButton(
                icon: const Icon(Icons.arrow_back, size: 28, color: Colors.black),
                onPressed: () => Navigator.pop(context),
              ),
            ),
            const SizedBox(height: 250),
            const Text(
              "Ai finalizat toate luptele din rundă!",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFB4182D),
                minimumSize: const Size.fromHeight(50),
              ),
              child: const Text("Finalizează turneu",
                  style: TextStyle(fontSize: 18, color: Colors.white)),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () async {
                final count = await services.postFights(
                  competitionUUID: competitionUUID,
                  wrestlingStyle: wrestlingStyle,
                );
                if (count > 0) {
                  ToastHelper.succes("Au fost generate $count lupte noi");
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(
                      builder: (_) => RefereeFightDashboard(
                        competitionUUID: competitionUUID,
                        wrestlingStyle: wrestlingStyle,
                      ),
                    ),
                  );
                } else {
                  ToastHelper.succes('Nu mai există lupte !');
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                minimumSize: const Size.fromHeight(50),
              ),
              child: const Text("Runda următoare",
                  style: TextStyle(fontSize: 18, color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }
}
