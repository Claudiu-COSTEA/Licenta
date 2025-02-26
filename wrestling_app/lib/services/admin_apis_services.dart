import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:wrestling_app/services/constants.dart';

class AdminServices {
  final String _baseUrl = '${AppConstants.baseUrl}/admin/add_competition.php';

  Future<bool> addCompetition({
    required BuildContext context,
    required String competitionName,
    required String competitionStartDate,
    required String competitionEndDate,
    required String competitionLocation,
  }) async {
    try {
      // Show loading indicator
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator()),
      );

      final response = await http.post(
        Uri.parse(_baseUrl),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "competition_name": competitionName,
          "competition_start_date": competitionStartDate, // Format: YYYY-MM-DD HH:MM:SS
          "competition_end_date": competitionEndDate,     // Format: YYYY-MM-DD HH:MM:SS
          "competition_location": competitionLocation,
        }),
      );

      // Close loading dialog
      if (context.mounted) Navigator.pop(context);

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);

        if (responseData.containsKey("success")) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Competition added successfully!"), backgroundColor: Colors.green),
          );
          return true;
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(responseData["error"] ?? "Unknown error"), backgroundColor: Colors.red),
          );
          return false;
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Failed to add competition"), backgroundColor: Colors.red),
        );
        return false;
      }
    } catch (e) {
      if (context.mounted) Navigator.pop(context); // Close loading dialog if error occurs

      if (kDebugMode) {
        print("Error adding competition: $e");
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e"), backgroundColor: Colors.red),
      );

      return false;
    }
  }

  final String _baseUrlSend = '${AppConstants.baseUrl}/admin/send_invitation.php';

  Future<bool> sendInvitation({
    required int competitionUUID,
    required int recipientUUID,
    required String recipientRole,
    String? weightCategory, // Optional if role is not "Wrestler"
    required String invitationStatus,
    required String invitationDeadline,
    String? refereeVerification, // Optional field
  }) async {
    try {
      final response = await http.post(
        Uri.parse(_baseUrlSend),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "competition_UUID": competitionUUID,
          "recipient_UUID": recipientUUID,
          "recipient_role": recipientRole,
          "weight_category": weightCategory,
          "invitation_status": invitationStatus,
          "invitation_deadline": invitationDeadline,
          "referee_verification": refereeVerification,
        }),
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);

        if (responseData.containsKey("success")) {
          return true; // Invitation added successfully
        } else {
          throw Exception(responseData["error"] ?? "Unknown error occurred");
        }
      } else {
        throw Exception("Failed to send invitation. Status: ${response.statusCode}");
      }
    } catch (e) {
      print("Error sending invitation: $e");
      return false;
    }
  }
}
