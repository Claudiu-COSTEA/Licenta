import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:wrestling_app/services/constants.dart';

class WrestlerService {
  final String _baseUrl = '${AppConstants.baseUrl}/post_invitation_response.php';

  Future<void> updateWrestlerInvitationStatus({
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
        Uri.parse(_baseUrl),
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

        if (responseData.containsKey("success")) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(responseData["success"]),
                backgroundColor: Colors.green),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(responseData["error"] ?? "Unknown error"),
                backgroundColor: Colors.red),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Failed to update invitation"),
              backgroundColor: Colors.red),
        );
      }
    } catch (e) {
      if (context.mounted) Navigator.pop(
          context); // Close loading dialog if error occurs

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e"), backgroundColor: Colors.red),
      );
    }
  }
}
