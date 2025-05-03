import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:wrestling_app/services/constants.dart';

import '../models/wrestler_weight_category_model.dart';
import '../models/wrestler_verification_model.dart';

class RefereeServices {


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
      if (context.mounted) Navigator.pop(
          context); // Close loading dialog if error occurs

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e"), backgroundColor: Colors.red),
      );
    }
  }


  Future<List<WrestlerVerification>> fetchWrestlers(String wrestlingStyle,
      String weightCategory,
      int competitionUUID,) async {
    const String _url = AppConstants.baseUrl + "referee/getVerifiedWrestlers";

    try {
      // Build the full URL with query parameters
      final uri = Uri.parse(
          '$_url?wrestling_style=$wrestlingStyle&weight_category=$weightCategory&competition_UUID=$competitionUUID');
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final decodedResponse = json.decode(response.body);

        // 🔹 Extract the "body" field from the top-level JSON
        final dynamic rawBody = decodedResponse["body"];
        // 🔹 If 'rawBody' is a string, decode it again. Otherwise, use directly.
        final body = rawBody is String ? json.decode(rawBody) : rawBody;

        // 🔹 Now 'body' should be a List of wrestlers OR an error message.
        if (body is List) {
          return body
              .map((item) =>
              WrestlerVerification.fromJson(Map<String, dynamic>.from(item)))
              .toList();
        } else if (body is Map<String, dynamic> && body.containsKey("error")) {
          throw Exception(body["error"]);
        } else {
          throw Exception(
              "Unexpected API response format (body is not a list).");
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

  Future<List<WrestlerWeightCategory>> fetchWeightCategories(
      int competitionUUID) async {
    try {

      const String _baseUrl = AppConstants.baseUrl + "referee/getCompetitionWeightCategories";

      final response = await http.get(
        Uri.parse("$_baseUrl?competition_UUID=$competitionUUID"),
      );

      if (response.statusCode == 200) {
        final decodedResponse = json.decode(response.body);

        // 1) Extract the "body" key
        final dynamic rawBody = decodedResponse["body"];

        // 2) If 'rawBody' is a string, decode it again. Otherwise use it directly.
        final body = rawBody is String ? json.decode(rawBody) : rawBody;

        // 3) Now 'body' should be a List (the array of weight categories)
        if (body is List) {
          return body
              .map((jsonItem) => WrestlerWeightCategory.fromJson(jsonItem))
              .toList();
        } else if (body is Map<String, dynamic> && body.containsKey("error")) {
          throw Exception(body["error"]);
        } else {
          throw Exception(
              "Unexpected API response format (body is not a list).");
        }
      } else {
        throw Exception(
            'Failed to load weight categories. Status code: ${response
                .statusCode}');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching weight categories: $e');
      }
      return [];
    }
  }

  Future<bool> updateRefereeVerification({
    required int competitionUUID,
    required int recipientUUID,
    required String recipientRole,
    required String refereeVerification, // Allowed values: "Confirmed", "Declined"
  }) async {
    const String url = AppConstants.baseUrl + "referee/sendWrestlerVerificationStatus";

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {"Content-Type": "application/json"},
        body: json.encode({
          "competition_UUID": competitionUUID,
          "recipient_UUID": recipientUUID,
          "recipient_role": recipientRole,
          "referee_verification": refereeVerification,
          // "Confirmed" or "Declined"
        }),
      );

      if (response.statusCode == 200) {
        final decodedResponse = json.decode(response.body);

        // Extract "body" from the top-level response
        final dynamic rawBody = decodedResponse["body"];
        // In some cases, 'rawBody' might be a string; decode again if needed
        final body = rawBody is String ? json.decode(rawBody) : rawBody;

        // Check for "success" or "error" in body
        if (body is Map<String, dynamic> && body.containsKey("success")) {
          return true; // Update successful
        } else if (body is Map<String, dynamic> && body.containsKey("error")) {
          throw Exception(body["error"]);
        } else {
          throw Exception("Unknown response format");
        }
      } else {
        throw Exception(
            "Failed to update referee verification. Status: ${response
                .statusCode}");
      }
    } catch (e) {
      if (kDebugMode) {
        print("Error updating referee verification: $e");
      }
      return false;
    }
  }
}

