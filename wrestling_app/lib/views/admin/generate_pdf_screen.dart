// file: lib/screens/generate_pdf_screen.dart
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import '../../models/competition_model.dart';
import '../../services/constants.dart';
import '../../services/admin_apis_services.dart';

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

  @override
  void initState() {
    super.initState();
    _futureComps = _service.fetchCompetitions();
  }

  Future<void> _generatePdf() async {
    if (_selected == null) return;
    setState(() => _isLoading = true);

    final uri = Uri.parse(
      AppConstants.baseUrl + 'admin/generatePDF',
    );
    final res = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'competition_UUID': _selected!.uuid}),
    );

    setState(() => _isLoading = false);

    if (res.statusCode == 200) {
      final Map<String, dynamic> outer = jsonDecode(res.body);
      // If your API Gateway is using Lambda Proxy, it'll wrap your body as a string:
      final Map<String, dynamic> payload = outer.containsKey('body')
          ? jsonDecode(outer['body'] as String)
          : outer;
      final String? pdfUrl = payload['pdfUrl'] as String?;
      if (pdfUrl == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('PDF URL missing in response')),
        );
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('PDF generat cu succes!')),
      );
      final uri2 = Uri.parse(pdfUrl);
      if (await canLaunchUrl(uri2)) {
        await launchUrl(uri2, mode: LaunchMode.externalApplication);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Nu pot deschide URL-ul PDF')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Eroare la generarea PDF: ${res.statusCode}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: FutureBuilder<List<Competition>>(
          future: _futureComps,
          builder: (context, snap) {
            if (snap.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snap.hasError) {
              return Center(child: Text('Eroare: ${snap.error}'));
            }
            final comps = snap.data!;
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [

                Center(
                  child: Text(
                    'Lista Competiții',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ),

                const SizedBox(height: 50),

                const Text(
                  'Selectează competiția:',
                  style: TextStyle(fontSize: 18),
                ),

                const SizedBox(height: 8),
                DropdownButtonFormField<Competition>(
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                  ),
                  items: comps
                      .map((c) => DropdownMenuItem(
                    value: c,
                    child: Text(c.name),
                  ))
                      .toList(),
                  value: _selected,
                  onChanged: (c) => setState(() => _selected = c),
                  hint: const Text('Alege competiția'),
                ),

                const SizedBox(height: 50),

                _isLoading
                    ? const Center(child: CircularProgressIndicator())
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
              ],
            );
          },
        ),
      ),
    );
  }
}
