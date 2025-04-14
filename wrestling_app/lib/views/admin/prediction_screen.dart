import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:wrestling_app/services/admin_apis_services.dart';
import 'package:http/http.dart' as http;

class PredictionScreen extends StatefulWidget {
  const PredictionScreen({super.key});

  @override
  State<PredictionScreen> createState() => _PredictionScreenState();
}

class _PredictionScreenState extends State<PredictionScreen> {
  final _formKey = GlobalKey<FormState>();
  final Map<String, TextEditingController> _controllers = {
    "wrestler1_win_rate_last_50": TextEditingController(),
    "wrestler1_experience_years": TextEditingController(),
    "wrestler1_technical_points_won_last_50": TextEditingController(),
    "wrestler1_technical_points_lost_last_50": TextEditingController(),
    "wrestler1_wins_against_wrestler2": TextEditingController(),
    "wrestler2_win_rate_last_50": TextEditingController(),
    "wrestler2_experience_years": TextEditingController(),
    "wrestler2_technical_points_won_last_50": TextEditingController(),
    "wrestler2_technical_points_lost_last_50": TextEditingController(),
    "wrestler2_wins_against_wrestler1": TextEditingController(),
  };

  String? _winner;
  double? _probability;
  bool _loading = false;

  AdminServices _adminServices = AdminServices();

  Future<void> _handlePredict() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _loading = true);

    try {
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
        _winner = result['winner'];
        _probability = result['probability'];
      });
    } catch (e) {
      setState(() {
        _winner = 'Eroare';
        _probability = 0.0;
      });
    } finally {
      setState(() => _loading = false);
    }
  }

  Widget _buildInput(String label, String key) {
    return TextFormField(
      controller: _controllers[key],
      keyboardType: TextInputType.number,
      decoration: InputDecoration(labelText: label),
      validator: (value) =>
      value == null || value.isEmpty ? 'Câmp obligatoriu' : null,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Predicție Meci Lupte")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              const Text("Luptător 1", style: TextStyle(fontWeight: FontWeight.bold)),
              _buildInput("Rata de câștig (ultimele 50)", "wrestler1_win_rate_last_50"),
              _buildInput("Ani de experiență", "wrestler1_experience_years"),
              _buildInput("Puncte tehnice câștigate", "wrestler1_technical_points_won_last_50"),
              _buildInput("Puncte tehnice pierdute", "wrestler1_technical_points_lost_last_50"),
              _buildInput("Victorii împotriva Luptătorului 2", "wrestler1_wins_against_wrestler2"),
              const SizedBox(height: 16),
              const Text("Luptător 2", style: TextStyle(fontWeight: FontWeight.bold)),
              _buildInput("Rata de câștig (ultimele 50)", "wrestler2_win_rate_last_50"),
              _buildInput("Ani de experiență", "wrestler2_experience_years"),
              _buildInput("Puncte tehnice câștigate", "wrestler2_technical_points_won_last_50"),
              _buildInput("Puncte tehnice pierdute", "wrestler2_technical_points_lost_last_50"),
              _buildInput("Victorii împotriva Luptătorului 1", "wrestler2_wins_against_wrestler1"),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _loading ? null : _handlePredict,
                child: _loading
                    ? const CircularProgressIndicator()
                    : const Text("Prezice câștigătorul", style: TextStyle(color: Colors.white),),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFB4182D),
                  padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 50),
                ),
              ),
              const SizedBox(height: 20),
              if (_winner != null)
                Text(
                  "Câștigător prezis: $_winner\nProbabilitate: ${_probability?.toStringAsFixed(4)}",
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
            ],
          ),
        ),
      ),
    );
  }
}