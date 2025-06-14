// lib/services/referee_api_services.dart
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:wrestling_app/services/constants.dart';

import '../models/fight_model.dart';
import '../models/wrestler_fight_info.dart';
import '../models/wrestler_weight_category_model.dart';
import '../models/wrestler_verification_model.dart';
import '../views/shared/widgets/toast_helper.dart';

class RefereeServices {
  // ← acceptă client injectabil
  RefereeServices({http.Client? client}) : _client = client ?? http.Client();

  // folosește-l în loc de http.get/post direct
  final http.Client _client;
  static const Color primary  = Color(0xFFB4182D);

  Future<void> updateInvitationStatus({
    required BuildContext context,
    required int competitionUUID,
    required int recipientUUID,
    required String recipientRole,
    required String invitationStatus,
  }) async {
    try {
      // Afișează indicator de loading
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(color: primary),
        ),
      );

      // Trimite request-ul
      final response = await http.post(
        Uri.parse(AppConstants.baseUrl + "sendInvitationResponse"),
        headers: {"Content-Type": "application/json"},
        body: json.encode({
          "competition_UUID": competitionUUID,
          "recipient_UUID": recipientUUID,
          "recipient_role": recipientRole,
          "invitation_status": invitationStatus,
        }),
      );

      // Închide indicatorul de loading
      if (context.mounted) Navigator.pop(context);

      // Procesare răspuns API
      if (response.statusCode == 200) {
        final responseData = json.decode(response.body) as Map<String, dynamic>;

        if (responseData.containsKey("body") &&
            responseData["body"] is Map<String, dynamic>) {
          final body = responseData["body"] as Map<String, dynamic>;

          if (body.containsKey("message")) {
            ToastHelper.succes("Raspuns trimis cu succes !");
          } else {
            // Dacă nu există câmpul "message" în interiorul "body"
            ToastHelper.eroare("Eroare la trimiterea raspunsului !");
          }
        } else {
          // Dacă nu există câmpul "body" în răspunsul JSON
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Răspuns neașteptat de la server"),
              backgroundColor: Colors.red,
            ),
          );
        }
      } else {
        // Dacă status code != 200
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Nu s-a putut actualiza starea invitației"),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) Navigator.pop(context); // Închide indicatorul de loading

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Eroare: $e"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<List<WrestlerVerification>> fetchWrestlers(
      String wrestlingStyle,
      String weightCategory,
      int competitionUUID,
      ) async {
    final uri = Uri.parse('${AppConstants.baseUrl}referee/getVerifiedWrestlers')
        .replace(queryParameters: {
      'wrestling_style': wrestlingStyle,
      'weight_category': weightCategory,
      'competition_UUID': competitionUUID.toString(),
    });

    try {
      final response = await _client.get(uri);
      if (response.statusCode != 200) {
        throw Exception('Failed to load wrestlers – status ${response.statusCode}');
      }
      final decoded = json.decode(utf8.decode(response.bodyBytes));
      final body = decoded['body'];
      if (body is String) {
        return (json.decode(body) as List)
            .map((e) => WrestlerVerification.fromJson(Map.from(e)))
            .toList();
      }
      if (body is List) {
        return body
            .map((e) => WrestlerVerification.fromJson(Map.from(e)))
            .toList();
      }
      if (body is Map && body.containsKey('error')) {
        throw Exception(body['error']);
      }
      throw Exception('Unexpected API response format');
    } catch (e) {
      if (kDebugMode) print('Error fetching wrestlers: $e');
      return [];
    }
  }

  Future<List<WrestlerWeightCategory>> fetchWeightCategories(
      int competitionUUID,
      ) async {
    final uri = Uri.parse(
        '${AppConstants.baseUrl}referee/getCompetitionWeightCategories?competition_UUID=$competitionUUID');
    try {
      final response = await _client.get(uri);
      if (response.statusCode != 200) {
        throw Exception('Failed to load weight categories. Status: ${response.statusCode}');
      }
      final decoded = json.decode(response.body);
      final rawBody = decoded['body'];
      final body = rawBody is String ? json.decode(rawBody) : rawBody;
      if (body is List) {
        return body
            .map((e) => WrestlerWeightCategory.fromJson(Map.from(e)))
            .toList();
      }
      if (body is Map && body.containsKey('error')) {
        throw Exception(body['error']);
      }
      throw Exception('Unexpected response format');
    } catch (e) {
      if (kDebugMode) print('Error fetching weight categories: $e');
      return [];
    }
  }

  Future<bool> updateRefereeVerification({
    required int competitionUUID,
    required int recipientUUID,
    required String recipientRole,
    required String refereeVerification,
  }) async {
    final uri = Uri.parse(
      '${AppConstants.baseUrl}referee/sendWrestlerVerificationStatus',
    );
    try {
      final response = await _client.post(
        uri,
        headers: {"Content-Type": "application/json"},
        body: json.encode({
          "competition_UUID": competitionUUID,
          "recipient_UUID": recipientUUID,
          "recipient_role": recipientRole,
          "referee_verification": refereeVerification,
        }),
      );

      if (response.statusCode == 200) {
        final decoded = json.decode(response.body);
        final rawBody = decoded['body'];
        final body = rawBody is String ? json.decode(rawBody) : rawBody;

        if (body is Map && body.containsKey('success')) {
          ToastHelper.succes('Verificare trimisă cu succes !');
          return true;
        }
        if (body is Map && body.containsKey('error')) {
          ToastHelper.eroare('Eroare la trimiterea răspunsului !');
          throw Exception(body['error']);
        }

        ToastHelper.eroare('Răspuns neașteptat de la server');
        throw Exception('Unknown response format');
      } else {
        final errorMsg = 'Eroare server: HTTP ${response.statusCode}';
        ToastHelper.eroare(errorMsg);
        throw Exception('Failed status: ${response.statusCode}');
      }
    } catch (e) {
      if (kDebugMode) print('Error updating referee verification: $e');
      ToastHelper.eroare('Nu s-a putut actualiza statusul. Încearcă din nou.');
      return false;
    }
  }

  Future<int> postFights({
    required int competitionUUID,
    required String wrestlingStyle,
  }) async {
    final uri = Uri.parse('${AppConstants.baseUrl}referee/postFights');
    try {
      final response = await _client.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'competition_UUID': competitionUUID,
          'wrestling_style': wrestlingStyle,
        }),
      );

      if (response.statusCode == 200) {
        final decoded = json.decode(response.body);
        final rawBody = decoded['body'];
        final body = rawBody is String ? json.decode(rawBody) : rawBody;
        if (body is Map<String, dynamic> && body.containsKey('inserted_fights')) {
          final count = body['inserted_fights'] as int;
          return count;
        }

        return 0;
      } else if (response.statusCode == 404) {
        final decoded = json.decode(response.body);
        final rawBody = decoded['body'];
        final body = rawBody is String ? json.decode(rawBody) : rawBody;
        final message = (body is Map<String, dynamic> && body.containsKey('message'))
            ? body['message']
            : 'No fights generated';
        ToastHelper.eroare(message);
        return 0;
      } else {
        ToastHelper.eroare('Nu s-a putut genera luptele.');
        return 0;
      }
    } catch (e) {
      if (kDebugMode) print('Error calling postFights: $e');
      ToastHelper.eroare('Nu s-a putut genera luptele.');
      return 0;
    }
  }

  Future<List<CompetitionFight>> fetchFights({
    required int competitionUUID,
    required String wrestlingStyle,
  }) async {
    final uri = Uri.parse(
        '${AppConstants.baseUrl}referee/getFights'
            '?competition_UUID=$competitionUUID'
            '&wrestling_style=${Uri.encodeComponent(wrestlingStyle)}'
    );

    try {
      final response = await _client.get(uri);
      if (response.statusCode == 200) {
        final decoded = json.decode(response.body);
        if (decoded is Map<String, dynamic> && decoded['body'] is List) {
          final List<dynamic> body = decoded['body'];
          return body
              .map((item) => CompetitionFight.fromJson(item as Map<String, dynamic>))
              .toList();
        } else {
          if (kDebugMode) {
            print('Unexpected response format: ${response.body}');
          }
          return [];
        }
      } else {
        if (kDebugMode) {
          print('Error ${response.statusCode}: ${response.body}');
        }
        return [];
      }
    } catch (e) {
      if (kDebugMode) {
        print('Exception fetching fights: $e');
      }
      return [];
    }
  }

  Future<WrestlerDetails?> fetchWrestlerDetails({
    required int wrestlerUUID,
  }) async {
    final uri = Uri.parse(
        '${AppConstants.baseUrl}referee/getWrestlerCoachWClub'
            '?wrestler_UUID=$wrestlerUUID'
    );

    try {
      final response = await _client.get(uri);
      if (response.statusCode == 200) {
        final decoded = json.decode(response.body);
        if (decoded is Map<String, dynamic> && decoded['body'] is Map<String, dynamic>) {
          return WrestlerDetails.fromJson(
              decoded['body'] as Map<String, dynamic>
          );
        } else {
          return null;
        }
      } else {
        return null;
      }
    } catch (e) {
      return null;
    }
  }

  Future<void> postFightResult({
    required BuildContext context,
    required int competitionUUID,
    required int competitionFightUUID,
    required int wrestlerPointsRed,
    required int wrestlerPointsBlue,
    required int wrestlerUUIDWinner,
  }) async {
    const _url = AppConstants.baseUrl + "referee/postFightResult";

    // Construim body-ul cererii
    final body = {
      "competition_UUID": competitionUUID,
      "competition_fight_UUID": competitionFightUUID,
      "wrestler_points_red": wrestlerPointsRed,
      "wrestler_points_blue": wrestlerPointsBlue,
      "wrestler_UUID_winner": wrestlerUUIDWinner,
    };

    try {
      // Afișăm indicator de încărcare
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => const Center(
          child: CircularProgressIndicator(),
        ),
      );

      final response = await http.post(
        Uri.parse(_url),
        headers: {"Content-Type": "application/json"},
        body: json.encode(body),
      );

      // Închidem indicatorul
      if (context.mounted) Navigator.of(context).pop();

      if (response.statusCode == 200) {
        // Așteptăm un JSON de forma:
        // { "statusCode": 200, "body": "{\"message\":\"...\"}" }
        final decoded = json.decode(response.body) as Map<String, dynamic>;
        // `body` aici e un string JSON, îl mai decodăm o dată:
        final rawBody = decoded["body"];
        final payload = rawBody is String ? json.decode(rawBody) : rawBody;

        if (payload is Map<String, dynamic> && payload.containsKey("message")) {
          ToastHelper.succes("Rezultatul a fost trimis cu succes.");
        } else {
          // fallback generic
          ToastHelper.succes("Rezultatul a fost trimis cu succes.");
        }
      } else {
        // orice cod ≠200
        ToastHelper.eroare(
          "Eroare server (${response.statusCode}). Încearcă din nou.",
        );
      }
    } catch (e) {
      // Închidem indicatorul dacă era încă deschis
      if (context.mounted) Navigator.of(context).pop();
      ToastHelper.eroare("Eroare la transmitere: $e");
      if (kDebugMode) print("postFightResult error: $e");
    }
  }

  Future<int> generateBronzeRound({
    required int competitionUUID,
    required String wrestlingStyle,
  }) async {
    final uri = Uri.parse('${AppConstants.baseUrl}referee/genBronze');
    try {
      final response = await _client.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'competition_UUID': competitionUUID,
          'wrestling_style': wrestlingStyle,
        }),
      );

      if (response.statusCode == 200) {
        final decoded = json.decode(response.body) as Map<String, dynamic>;
        final rawBody = decoded['body'];
        final body = rawBody is String ? json.decode(rawBody) : rawBody;
        if (body is Map<String, dynamic> && body.containsKey('inserted_fights')) {
          return body['inserted_fights'] as int;
        }
        throw Exception('Unexpected response payload');
      } else {
        throw Exception('Server error ${response.statusCode}');
      }
    } catch (e) {
      if (kDebugMode) print('genBronze error: $e');
      return 0;
    }
  }

}
