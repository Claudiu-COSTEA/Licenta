import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:wrestling_app/services/notifications_services.dart';

class AdminServices {
  final String _baseUrl = 'https://rhybb6zgsb.execute-api.us-east-1.amazonaws.com/wrestling/admin/addCompetition';

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
        headers: {
          "Content-Type": "application/json",
        },
        body: jsonEncode({
          "competition_name": competitionName,
          "competition_start_date": competitionStartDate, // Format: YYYY-MM-DD HH:MM:SS
          "competition_end_date": competitionEndDate,     // Format: YYYY-MM-DD HH:MM:SS
          "competition_location": competitionLocation,
        }),
      );

      print("Response Status Code: ${response.statusCode}");
      print("Response Body: ${response.body}");
      // Close loading dialog
      if (context.mounted) Navigator.pop(context);

      if (response.statusCode == 200) {
        // Decode the response body
        final responseData = json.decode(response.body);

        // Check if the 'body' field exists and contains the 'message'
        if (responseData.containsKey("body") && responseData["body"]["message"] == "Competition added successfully") {
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

  final String _baseUrlSend = 'https://rhybb6zgsb.execute-api.us-east-1.amazonaws.com/wrestling/admin/sendInvitation';

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

      print("Response Status Code: ${response.statusCode}");
      print("Response Body: ${response.body}");

      // Check for 200 or 201
      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseData = json.decode(response.body);

        // If your Lambda uses the standard "body" wrapping
        final dynamic rawBody = responseData["body"];
        // Might be a Map directly OR a JSON string. Let's handle both:
        final body = rawBody is String ? json.decode(rawBody) : rawBody;

        // Check "message" or "success"
        if (body is Map<String, dynamic>) {
          if (body.containsKey("message")) {
            print(body["message"]); // "Competition invitation sent successfully!"

            // Send FCM notification if needed
            NotificationsServices notificationService = NotificationsServices();
            String? token = await notificationService.getUserFCMToken(recipientUUID);
            if (token != null) {
              notificationService.sendFCMMessage(token);
            }

            return true; // Invitation was successfully created
          } else if (body.containsKey("error")) {
            throw Exception(body["error"]);
          } else {
            throw Exception("Unknown response format");
          }
        } else {
          throw Exception("Unexpected response format");
        }
      } else {
        throw Exception("Failed to send invitation. Status: ${response.statusCode}");
      }
    } catch (e) {
      print("Error sending invitation: $e");
      return false;
    }
  }

  Future<Map<String, dynamic>> predictWinner({
    required double w1WinRate,
    required int w1Years,
    required int w1PointsWon,
    required int w1PointsLost,
    required int w1WinsVsW2,
    required double w2WinRate,
    required int w2Years,
    required int w2PointsWon,
    required int w2PointsLost,
    required int w2WinsVsW1,
  }) async {
    const url = 'https://rhybb6zgsb.execute-api.us-east-1.amazonaws.com/wrestling/admin/prediction';

    final payload = {
      "wrestler1_win_rate_last_50": w1WinRate,
      "wrestler1_experience_years": w1Years,
      "wrestler1_technical_points_won_last_50": w1PointsWon,
      "wrestler1_technical_points_lost_last_50": w1PointsLost,
      "wrestler1_wins_against_wrestler2": w1WinsVsW2,
      "wrestler2_win_rate_last_50": w2WinRate,
      "wrestler2_experience_years": w2Years,
      "wrestler2_technical_points_won_last_50": w2PointsWon,
      "wrestler2_technical_points_lost_last_50": w2PointsLost,
      "wrestler2_wins_against_wrestler1": w2WinsVsW1,
    };

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode(payload),
      );

      if (response.statusCode == 200) {
        final body = json.decode(response.body);
        final prediction = json.decode(body['body']); // decode stringified JSON

        return {
          'winner': prediction['predicted_winner'],
          'probability': prediction['prediction_probability'],
        };
      } else {
        throw Exception('Failed with status: ${response.statusCode}');
      }
    } catch (e) {
      print('Error: $e');
      return {
        'winner': 'unknown',
        'probability': 0.0,
      };
    }
  }

}
