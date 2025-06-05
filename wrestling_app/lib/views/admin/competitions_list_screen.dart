// file: lib/screens/competitions_list_screen.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart'; // <- import necesar
import '../../models/competition_model.dart';
import '../../services/constants.dart';
import 'competition_manage_screen.dart';

class CompetitionsListScreen extends StatefulWidget {
  const CompetitionsListScreen({Key? key}) : super(key: key);

  @override
  _CompetitionsListScreenState createState() => _CompetitionsListScreenState();
}

class _CompetitionsListScreenState extends State<CompetitionsListScreen> {
  late Future<List<Competition>> _futureComps;
  static const Color primaryColor = Color(0xFFB4182D);

  @override
  void initState() {
    super.initState();
    // 1) Încărcăm datele de localizare pentru RO, apoi pornim fetch-ul:
    initializeDateFormatting('ro', null).then((_) {
      setState(() {
        _futureComps = fetchCompetitions();
      });
    });
  }

  Future<List<Competition>> fetchCompetitions() async {
    final res = await http.get(
      Uri.parse(AppConstants.baseUrl + 'admin/getCompetitions'),
    );
    if (res.statusCode != 200) {
      throw Exception('Failed to load competitions (${res.statusCode})');
    }
    final envelope = jsonDecode(utf8.decode(res.bodyBytes)) as Map<
        String,
        dynamic>;
    final bodyString = envelope['body'] as String;
    final List<dynamic> list = jsonDecode(bodyString) as List<dynamic>;
    return list
        .map((e) => Competition.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// Traducem status-ul din engleză în română
  String _statusInRomana(String statusEN) {
    switch (statusEN) {
      case 'Pending':
        return 'În așteptare';
      case 'Confirmed':
        return 'Confirmată';
      case 'Postponed':
        return 'Amânată';
      case 'Finished':
        return 'Încheiată';
      default:
        return statusEN;
    }
  }

  /// Formatează data în formatul românesc (5 iun. 2025, etc.)
  String _dataInRomana(DateTime date) {
    return DateFormat.yMMMd('ro').format(date);
  }

  @override
  Widget build(BuildContext context) {
    // Înainte să fi apelat initializeDateFormatting, _futureComps va fi nul
    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
        child: Column(
          children: [
            const SizedBox(height: 30),
            Align(
              alignment: Alignment.centerLeft,
              child: IconButton(
                icon: const Icon(Icons.arrow_back,
                    size: 28, color: Colors.black),
                onPressed: () => Navigator.pop(context),
              ),
            ),
            const Center(
              child: Text(
                "Listă competiții",
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                  fontSize: 28,
                ),
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: FutureBuilder<List<Competition>>(
                future: _futureComps,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(
                          color: primaryColor),
                    );
                  }
                  if (snapshot.hasError) {
                    return Center(child: Text('Eroare: ${snapshot.error}'));
                  }
                  final comps = snapshot.data!;
                  if (comps.isEmpty) {
                    return const Center(
                        child: Text('Nu există competiții'));
                  }
                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 8),
                    itemCount: comps.length,
                    itemBuilder: (context, i) {
                      final c = comps[i];
                      final statusRo = _statusInRomana(c.status);

                      // Dacă location e de forma "lat, lon", rotunjim la 7 zecimale:
                      String locRo;
                      final parts = c.location.split(',');
                      if (parts.length == 2) {
                        final lat = double.tryParse(parts[0].trim());
                        final lng = double.tryParse(parts[1].trim());
                        if (lat != null && lng != null) {
                          locRo =
                          '${lat.toStringAsFixed(7)}, ${lng.toStringAsFixed(
                              7)}';
                        } else {
                          locRo = c.location;
                        }
                      } else {
                        locRo = c.location;
                      }

                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  CompetitionManageScreen(competition: c),
                            ),
                          );
                        },
                        child: Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: primaryColor,
                              border: Border.all(color: primaryColor),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Column(
                              crossAxisAlignment:
                              CrossAxisAlignment.start,
                              children: [
                              Text(
                              c.name,
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                                '${_dataInRomana(c.startDate)} – ${_dataInRomana(c.endDate)}',
                                style: const TextStyle(color: Colors.white),
                      ),
                      const SizedBox(height: 4),
                      Text(
                      'Locație: $locRo',
                      style:
                      const TextStyle(color: Colors.white),
                      ),
                      const SizedBox(height: 4),
                      Text(
                      'Status: $statusRo',
                      style:
                      const TextStyle(color: Colors.white),
                      ),
                      ]
                      ,
                      )
                      ,
                      )
                      ,
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
