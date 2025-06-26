// file: lib/screens/generate_pdf_screen.dart
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import '../../models/competition_model.dart';
import '../../services/constants.dart';
import '../../services/admin_apis_services.dart';
import '../shared/widgets/toast_helper.dart';

class GeneratePdfScreen extends StatefulWidget {
  const GeneratePdfScreen({Key? key}) : super(key: key);

  @override
  State<GeneratePdfScreen> createState() => _GeneratePdfScreenState();
}

class _GeneratePdfScreenState extends State<GeneratePdfScreen> {
  final _service = AdminServices();
  late Future<List<Competition>> _futureComps;
  Competition? _selected;
  bool _isLoading = false;
  static const Color primary = Color(0xFFB4182D);

  @override
  void initState() {
    super.initState();
    _futureComps = _service.fetchCompetitions();
  }

  Future<void> _generatePdf() async {
    if (_selected == null) {
      ToastHelper.eroare('Vă rog selectați mai întâi o competiție');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final uri = Uri.parse(
        AppConstants.baseUrl + 'admin/generatePDF',
      );
      final res = await http.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'competition_UUID': _selected!.competitionUUID}),
      );

      setState(() => _isLoading = false);

      if (res.statusCode == 200) {
        final Map<String, dynamic> outer = jsonDecode(res.body);
        // Dacă API Gateway folosește Lambda Proxy, payload-ul real vine în câmpul "body"
        final Map<String, dynamic> payload = outer.containsKey('body')
            ? jsonDecode(outer['body'] as String)
            : outer;

        final String? pdfUrl = payload['pdfUrl'] as String?;
        if (pdfUrl == null) {
          ToastHelper.eroare('Link-ul PDF lipsește din răspuns');
          return;
        }

        ToastHelper.succes('PDF generat cu succes!');

        final uri2 = Uri.parse(pdfUrl);
        if (await canLaunchUrl(uri2)) {
          await launchUrl(uri2, mode: LaunchMode.externalApplication);
        } else {
          ToastHelper.eroare('Nu pot deschide URL-ul PDF');
        }
      } else {
        ToastHelper.eroare('Eroare la generarea PDF (cod HTTP: ${res.statusCode})');
      }
    } catch (e) {
      setState(() => _isLoading = false);
      ToastHelper.eroare('Eroare neașteptată: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: FutureBuilder<List<Competition>>(
          future: _futureComps,
          builder: (context, snap) {
            if (snap.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator(color: primary,));
            }
            if (snap.hasError) {
              return Center(child: Text('Eroare: ${snap.error}'));
            }
            final comps = snap.data!;
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [

                const SizedBox(height: 20,),

                Align(
                  alignment: Alignment.centerLeft,
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back, size: 28, color: Colors.black),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                ),
                Center(
                  child: Text(
                    "Generare PDF",
                    style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 28),
                  ),
                ),

                const SizedBox(height: 40,),

                const Text(
                  'Selectează competiția:',
                  style: TextStyle(fontSize: 18),
                ),

                const SizedBox(height: 8),
                DropdownButtonFormField<Competition>(
                  // ── DECORAȚIA (bordură + fundal) ───────────────────────────
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.white,
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(
                        color: primary, // bordură roșie când nu e focus
                        width: 1.5,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(
                        color: primary, // bordură roșie la focus
                        width: 2.5,
                      ),
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                  ),

                  // ── SĂGEATĂ ȘI TEXTE ───────────────────────────────────────
                  iconEnabledColor: primary,    // iconița dropdown pe roșu
                  dropdownColor: Colors.white,     // fundal alb pentru lista derulantă
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 16,
                  ), // stil text

                  // ── ITEM-ELE ────────────────────────────────────────────────
                  items: comps.map((c) {
                    return DropdownMenuItem<Competition>(
                      value: c,
                      child: Text(c.competitionName),
                    );
                  }).toList(),

                  // ── VALOAREA SELECTATĂ ──────────────────────────────────────
                  value: _selected,

                  // ── CÂND SE SCHIMBĂ ───────────────────────────────────────
                  onChanged: (c) => setState(() => _selected = c),

                  // ── PLACEHOLDER (dacă nu e selectat nimic) ────────────────
                  hint: const Text(
                    'Alege competiția',
                    style: TextStyle(color: Colors.black54),
                  ),
                ),

                const SizedBox(height: 50),

                _isLoading
                    ? const Center(child: CircularProgressIndicator(color: primary,))
                    : ElevatedButton.icon(
                  onPressed: _selected == null ? null : _generatePdf,
                  icon: const Icon(Icons.picture_as_pdf, color: Colors.white,),
                  label: const Text('Generează PDF',  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFB4182D),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),

                const SizedBox(height: 100),

                Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Image.asset(
                        'assets/images/wrestling_logo.png',
                        height: 300,
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
