import 'package:flutter/material.dart';
import 'package:wrestling_app/services/admin_apis_services.dart';

class PredictionScreen extends StatefulWidget {
  const PredictionScreen({Key? key}) : super(key: key);

  @override
  State<PredictionScreen> createState() => _PredictionScreenState();
}

class _PredictionScreenState extends State<PredictionScreen> {
  final _formKey = GlobalKey<FormState>();

  // Map de controllere pentru fiecare câmp numeric, cu valori default
  final Map<String, TextEditingController> _controllers = {
    "wrestler1_win_rate_last_50":
    TextEditingController(text: "0.5"),
    "wrestler1_experience_years":
    TextEditingController(text: "5"),
    "wrestler1_technical_points_won_last_50":
    TextEditingController(text: "230"),
    "wrestler1_technical_points_lost_last_50":
    TextEditingController(text: "140"),
    "wrestler1_wins_against_wrestler2":
    TextEditingController(text: "3"),
    "wrestler2_win_rate_last_50":
    TextEditingController(text: "0.6"),
    "wrestler2_experience_years":
    TextEditingController(text: "5"),
    "wrestler2_technical_points_won_last_50":
    TextEditingController(text: "250"),
    "wrestler2_technical_points_lost_last_50":
    TextEditingController(text: "120"),
    "wrestler2_wins_against_wrestler1":
    TextEditingController(text: "2"),
  };

  String? _winner;
  double? _probability;
  bool _loading = false;

  final AdminServices _adminServices = AdminServices();

  @override
  void dispose() {
    // Eliberăm controllerele când widget-ul este distrus
    for (final c in _controllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _handlePredict() async {
    // 1) Dacă Form-ul NU e valid, ieșim:
    if (!_formKey.currentState!.validate()) return;

    setState(() => _loading = true);
    try {
      // 2) Datele de intrare sunt garantat nenule și parse-abile datorită validării
      final result = await _adminServices.predictWinner(
        w1WinRate: double.parse(_controllers["wrestler1_win_rate_last_50"]!.text),
        w1Years: int.parse(_controllers["wrestler1_experience_years"]!.text),
        w1PointsWon: int.parse(_controllers["wrestler1_technical_points_won_last_50"]!.text),
        w1PointsLost: int.parse(_controllers["wrestler1_technical_points_lost_last_50"]!.text),
        w1WinsVsW2: int.parse(_controllers["wrestler1_wins_against_wrestler2"]!.text),
        w2WinRate: double.parse(_controllers["wrestler2_win_rate_last_50"]!.text),
        w2Years: int.parse(_controllers["wrestler2_experience_years"]!.text),
        w2PointsWon: int.parse(_controllers["wrestler2_technical_points_won_last_50"]!.text),
        w2PointsLost: int.parse(_controllers["wrestler2_technical_points_lost_last_50"]!.text),
        w2WinsVsW1: int.parse(_controllers["wrestler2_wins_against_wrestler1"]!.text),
      );

      setState(() {
        _winner = result['winner'] as String?;
        _probability = (result['probability'] as num).toDouble();
      });
    } catch (e) {
      // În caz de eroare (ex. rețea, parse-fail, server) afișăm un mesaj generic:
      setState(() {
        _winner = 'Eroare la predicție';
        _probability = 0.0;
      });
    } finally {
      setState(() => _loading = false);
    }
  }

  // Creează un TextFormField stilizat cu validare „nul sau gol”
  Widget _buildInputField(String label, String key) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: _controllers[key],
        keyboardType: TextInputType.number,
        style: const TextStyle(color: Colors.black),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Colors.black87),
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFFB4182D), width: 1.5),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFFB4182D), width: 2.5),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.red, width: 1.5),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.red, width: 2.5),
          ),
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Câmp obligatoriu';
          }
          // De aici poți adăuga validări stricte de tip numeric / interval, dacă vrei
          return null;
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const primaryRed = Color(0xFFB4182D);

    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: Form(
        key: _formKey, // 1) Legăm FormKey-ul aici
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
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
                    "Predicție luptă",
                    style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 28),
                  ),
                ),

                const SizedBox(height: 20,),
                // ─── Card „Luptător 1” ─────────────────────────────────
                Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  color: Colors.white,
                  elevation: 4,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Luptător 1",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: primaryRed,
                          ),
                        ),
                        const SizedBox(height: 12),
                        _buildInputField("Rata de câștig (ex. 0.5)", "wrestler1_win_rate_last_50"),
                        _buildInputField("Ani de experiență", "wrestler1_experience_years"),
                        _buildInputField("Puncte tehnice câștigate", "wrestler1_technical_points_won_last_50"),
                        _buildInputField("Puncte tehnice pierdute", "wrestler1_technical_points_lost_last_50"),
                        _buildInputField("Victorii vs. Luptător 2", "wrestler1_wins_against_wrestler2"),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // ─── Card „Luptător 2” ─────────────────────────────────
                Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  color: Colors.white,
                  elevation: 4,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Luptător 2",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: primaryRed,
                          ),
                        ),
                        const SizedBox(height: 12),
                        _buildInputField("Rata de câștig (ex. 0.5)", "wrestler2_win_rate_last_50"),
                        _buildInputField("Ani de experiență", "wrestler2_experience_years"),
                        _buildInputField("Puncte tehnice câștigate", "wrestler2_technical_points_won_last_50"),
                        _buildInputField("Puncte tehnice pierdute", "wrestler2_technical_points_lost_last_50"),
                        _buildInputField("Victorii vs. Luptător 1", "wrestler2_wins_against_wrestler1"),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // ─── Butonul de predicție ───────────────────────────────
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _loading ? null : _handlePredict,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryRed,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: _loading
                        ? const SizedBox(
                      height: 24,
                      width: 24,
                      child: CircularProgressIndicator(
                        color: primaryRed,
                        strokeWidth: 2,
                      ),
                    )
                        : const Text(
                      "Prezicere câștigătorul",
                      style: TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // ─── Afișarea rezultatului ─────────────────────────────
                if (_winner != null)
                  Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    color: Colors.white,
                    elevation: 4,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 16.0),
                      child: Column(
                        children: [
                          Text(
                            "Rezultat Predicție",
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: primaryRed,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            "Câștigător prezis: ${_winner == 'wrestler1' ? 'Luptător 1' : 'Luptător 2'}",
                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            "Probabilitate: ${(_probability ?? 0.0).toStringAsFixed(4)} %",
                            style: const TextStyle(fontSize: 16),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
