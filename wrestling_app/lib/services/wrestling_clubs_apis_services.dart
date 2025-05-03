import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:wrestling_app/services/constants.dart';

class WrestlingClubService {


  Future<List<Map<String, dynamic>>?> fetchCoachesForClub(
      int wrestlingClubUUID, int competitionUUID) async {
    try {
      const String _url = AppConstants.baseUrl + "wrestlingClub/getCoaches";

      final uri = Uri.parse(
        '$_url?wrestling_club_UUID=$wrestlingClubUUID&competition_UUID=$competitionUUID',
      );

      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);

        if (responseData.containsKey("body")) {
          final String rawBody = responseData["body"];

          // Decode the JSON string inside 'body'
          final dynamic decodedBody = json.decode(rawBody);

          if (decodedBody is List) {
            return decodedBody
                .map((item) => Map<String, dynamic>.from(item))
                .toList(); // will return [] if empty
          } else {
            if (kDebugMode) {
              print("Unexpected body format: $decodedBody");
            }
            return [];
          }
        } else {
          if (kDebugMode) {
            print("Missing 'body' in response: $responseData");
          }
          return [];
        }
      } else {
        if (kDebugMode) {
          print("Error fetching coaches: ${response.statusCode}, ${response.body}");
        }
        return [];
      }
    } catch (e) {
      if (kDebugMode) {
        print("Exception while fetching coaches: $e");
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