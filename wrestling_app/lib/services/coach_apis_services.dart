import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:wrestling_app/services/constants.dart';

class CoachService {
  final String _baseUrl = '${AppConstants.baseUrl}/coach/get_coache_wrestlers.php';

  Future<List<Map<String, dynamic>>> fetchWrestlersForCoach(int coachUUID,
      int competitionUUID) async {
    try {
      final response = await http.get(
        Uri.parse(
            '$_baseUrl?coach_UUID=$coachUUID&competition_UUID=$competitionUUID'),
      );

      if (response.statusCode == 200) {
        var decodedResponse = json.decode(response.body);

        // 🔹 Check if the response contains an error message
        if (decodedResponse is Map<String, dynamic> &&
            decodedResponse.containsKey("error")) {
          throw Exception(decodedResponse["error"]);
        }

        // 🔹 Ensure it's a List before mapping
        if (decodedResponse is List) {
          return decodedResponse.map((wrestler) =>
          Map<String, dynamic>.from(wrestler)).toList();
        } else {
          throw Exception("Unexpected API response format.");
        }
      } else {
        throw Exception(
            'Failed to load wrestlers. Status code: ${response.statusCode}');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching wrestlers: $e');
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
      // Show loading indicator
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator()),
      );

      // Prepare request body
      final response = await http.post(
        Uri.parse("https://rhybb6zgsb.execute-api.us-east-1.amazonaws.com/wrestling/sendInvitationResponse"),
        headers: {"Content-Type": "application/json"},
        body: json.encode({
          "competition_UUID": competitionUUID,
          "recipient_UUID": recipientUUID,
          "recipient_role": recipientRole,
          "invitation_status": invitationStatus,
        }),
      );

      // Close loading dialog
      if (context.mounted) Navigator.pop(context);

      // Handle response
      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);

        if (responseData.containsKey("message")) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text(responseData["message"]),
                backgroundColor: Colors.green),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text(responseData["error"] ?? "Unknown error"),
                backgroundColor: Colors.red),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text("Failed to update invitation"),
              backgroundColor: Colors.red),
        );
      }
    } catch (e) {
      if (context.mounted) Navigator.pop(context); // Close loading dialog if error occurs

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e"), backgroundColor: Colors.red),
      );
    }
  }
}
