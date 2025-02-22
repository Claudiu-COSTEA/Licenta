import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:wrestling_app/services/constants.dart';

import '../models/wrestler_weight_category_model.dart';
import '../models/wrestler_verification_model.dart';

class RefereeServices {


  Future<void> updateRefereeInvitationStatus({
    required BuildContext context,
    required int competitionUUID,
    required int recipientUUID,
    required String recipientRole,
    required String invitationStatus,
  }) async {

    final String baseUrl = '${AppConstants.baseUrl}/post_invitation_response.php';

    try {
      // Show loading indicator
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator()),
      );

      // Prepare request body
      final response = await http.post(
        Uri.parse(baseUrl),
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
      if (context.mounted) {
        Navigator.pop(
          context); // Close loading dialog if error occurs
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e"), backgroundColor: Colors.red),
      );
    }
  }


  Future<List<WrestlerVerification>> fetchWrestlers(String wrestlingStyle, String weightCategory, int competitionUUID) async {
    final String baseUrl = '${AppConstants.baseUrl}/referee/wrestlers_verification.php';

    try {
      final response = await http.get(
        Uri.parse('$baseUrl?wrestling_style=$wrestlingStyle&weight_category=$weightCategory&competition_UUID=$competitionUUID'),
      );

      if (response.statusCode == 200) {
        final decodedResponse = json.decode(response.body);

        if (decodedResponse is List) {
          return decodedResponse.map((wrestler) => WrestlerVerification.fromJson(wrestler)).toList();
        } else if (decodedResponse is Map<String, dynamic> && decodedResponse.containsKey("error")) {
          throw Exception(decodedResponse["error"]);
        } else {
          throw Exception("Unexpected API response format.");
        }
      } else {
        throw Exception('Failed to load wrestlers. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching wrestlers: $e');
      return [];
    }
  }

  final String _baseUrl = "${AppConstants.baseUrl}/referee/get_competition_weight_categories.php";

  Future<List<WrestlerWeightCategory>> fetchWeightCategories(int competitionUUID) async {
    try {
      final response = await http.get(
        Uri.parse("$_baseUrl?competition_UUID=$competitionUUID"),
      );

      if (response.statusCode == 200) {
        var decodedResponse = json.decode(response.body);

        // ✅ Check if the response is a Map (Error Case)
        if (decodedResponse is Map<String, dynamic> && decodedResponse.containsKey("error")) {
          throw Exception(decodedResponse["error"]);
        }

        // ✅ Ensure it's a List before mapping
        if (decodedResponse is List) {
          return decodedResponse.map((json) => WrestlerWeightCategory.fromJson(json)).toList();
        } else {
          throw Exception("Unexpected API response format.");
        }
      } else {
        throw Exception('Failed to load weight categories. Status code: ${response.statusCode}');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching weight categories: $e');
      }
      return [];
    }
  }


}
