import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class CoachService {
  final String _baseUrl =
      'http://192.168.0.154/wrestling_app/coach/get_coache_wrestlers.php';

  Future<List<Map<String, dynamic>>> fetchWrestlersForCoach(
      int coachUUID, int competitionUUID) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl?coach_UUID=$coachUUID&competition_UUID=$competitionUUID'),
      );

      if (response.statusCode == 200) {
        var decodedResponse = json.decode(response.body);

        // 🔹 Check if the response contains an error message
        if (decodedResponse is Map<String, dynamic> && decodedResponse.containsKey("error")) {
          throw Exception(decodedResponse["error"]);
        }

        // 🔹 Ensure it's a List before mapping
        if (decodedResponse is List) {
          return decodedResponse.map((wrestler) => Map<String, dynamic>.from(wrestler)).toList();
        } else {
          throw Exception("Unexpected API response format.");
        }
      } else {
        throw Exception('Failed to load wrestlers. Status code: ${response.statusCode}');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching wrestlers: $e');
      }
      return [];
    }
  }
}
