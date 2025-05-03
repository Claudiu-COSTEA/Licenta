import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:wrestling_app/services/constants.dart';

import '../models/wrestler_documents_model.dart';

class WrestlerService {

  Future<void> updateInvitationStatus({
    required BuildContext context,
    required int competitionUUID,
    required int recipientUUID,
    required String recipientRole,
    required String invitationStatus,
  }) async {
    try {
      // Show loading dialog
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator()),
      );

      // Make the POST request
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

      // Close the loading dialog
      if (context.mounted) Navigator.pop(context);

      // Decode response
      final responseData = json.decode(response.body);
      final body = responseData["body"];

      if (body is Map<String, dynamic>) {
        if (body.containsKey("message")) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text(body["message"]), backgroundColor: Colors.green),
          );
        } else if (body.containsKey("success")) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text(body["success"]), backgroundColor: Colors.green),
          );
        } else if (body.containsKey("error")) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(body["error"]), backgroundColor: Colors.red),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Unknown response format"),
                backgroundColor: Colors.red),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Unexpected response format"),
              backgroundColor: Colors.red),
        );
      }
    } catch (e) {
      if (context.mounted) Navigator.pop(context); // close dialog on error
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e"), backgroundColor: Colors.red),
      );
    }
  }

  Future<WrestlerDocuments?> fetchWrestlerUrls(int wrestlerUUID) async {
    try {
      final uri = Uri.parse(AppConstants.baseUrl + "wrestler/getWrestlerUrls?wrestler_UUID=$wrestlerUUID");

      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final decoded = json.decode(response.body);

        final body = decoded['body'];

        if (body is Map<String, dynamic> &&
            body.containsKey("medical_document") &&
            body.containsKey("license_document")) {
          return WrestlerDocuments.fromJson(body);
        } else if (body is Map<String, dynamic> && body.containsKey("error")) {
          if (kDebugMode) print("API error: ${body["error"]}");
        } else {
          if (kDebugMode) print("Unexpected response structure: $body");
        }
      } else {
        if (kDebugMode) {
          print(
              "Failed to load documents. Status code: ${response.statusCode}");
        }
      }
    } catch (e) {
      if (kDebugMode) print("Exception fetching documents: $e");
    }

    return null; // In case of any error
  }
}
