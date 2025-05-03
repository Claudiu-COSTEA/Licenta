// file: lib/screens/competitions_list_screen.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
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
    _futureComps = fetchCompetitions();
  }

  Future<List<Competition>> fetchCompetitions() async {
    final res = await http.get(
      Uri.parse(AppConstants.baseUrl + 'admin/getCompetitions'),
    );
    if (res.statusCode != 200) {
      throw Exception('Failed to load competitions (${res.statusCode})');
    }
    final envelope = jsonDecode(utf8.decode(res.bodyBytes)) as Map<String, dynamic>;
    final bodyString = envelope['body'] as String;
    final List<dynamic> list = jsonDecode(bodyString) as List<dynamic>;
    return list
        .map((e) => Competition.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: Column(
        children: [
          const SizedBox(height: 16),
          const Center(
            child: Text(
              'Lista Competiții',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: FutureBuilder<List<Competition>>(
              future: _futureComps,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text('Eroare: ${snapshot.error}'));
                }
                final comps = snapshot.data!;
                if (comps.isEmpty) {
                  return const Center(child: Text('Nu există competiții'));
                }
                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  itemCount: comps.length,
                  itemBuilder: (context, i) {
                    final c = comps[i];
                    return GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => CompetitionManageScreen(competition: c),
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
                          crossAxisAlignment: CrossAxisAlignment.start,
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
                              '${DateFormat.yMMMd().format(c.startDate)} – ${DateFormat.yMMMd().format(c.endDate)}',
                              style: const TextStyle(color: Colors.white),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Locație: ${c.location}',
                              style: const TextStyle(color: Colors.white),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Status: ${c.status}',
                              style: const TextStyle(color: Colors.white),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}