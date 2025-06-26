import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:wrestling_app/services/constants.dart';

import '../views/shared/widgets/toast_helper.dart';

class CoachService {

  static const Color primary  = Color(0xFFB4182D);

  Future<List<Map<String, dynamic>>> fetchCoachWrestlers({
    required int coachUUID,
    required int competitionUUID,
  }) async {
    try {

      const String _url = AppConstants.baseUrl + "coach/getCoachWrestlers";

      final uri = Uri.parse(
          '$_url?coach_UUID=$coachUUID&competition_UUID=$competitionUUID');

      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final decoded = json.decode(response.body);

        if (decoded is Map<String, dynamic>) {
          final body = decoded["body"];

          // 'body' is already a List
          if (body is List) {
            return body
                .map((item) => Map<String, dynamic>.from(item))
                .toList();
          }

          // Optional: handle API message
          if (body is Map<String, dynamic> && body.containsKey("message")) {
            if (kDebugMode) print("Message: ${body['message']}");
            return [];
          }
        }

        throw Exception("Unexpected response format.");
      } else {
        throw Exception(
            'Failed to fetch wrestlers. Status code: ${response.statusCode}');
      }
    } catch (e) {
      if (kDebugMode) {
        print("Error fetching coach wrestlers: $e");
      }
      return [];
    }
  }

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
}
