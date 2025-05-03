import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:wrestling_app/services/constants.dart';

class CoachService {


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
      // Show loading indicator
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator()),
      );

      // Prepare request body
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
