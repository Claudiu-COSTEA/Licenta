import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:wrestling_app/services/constants.dart';
import '../models/competition_invitation_model.dart';


class InvitationsService {

  Future<List<CompetitionInvitation>> fetchInvitations(int recipientUUID) async {
    try {

      const String _url = AppConstants.baseUrl + "getInvitations";

      final response = await http.get(
        Uri.parse('$_url?recipient_UUID=$recipientUUID'),
      );

      if (response.statusCode == 200) {
        if (kDebugMode) {
          print('Raw API Response: ${response.body}');
        }  // Debugging

        // Parse the response body
        Map<String, dynamic> jsonResponse = json.decode(response.body);

        // Extract the "body" field
        if (jsonResponse.containsKey("body") && jsonResponse["body"] is List) {
          List<dynamic> invitationsData = jsonResponse["body"];

          if (kDebugMode) {
            print('Extracted Invitations Data: $invitationsData');
          }  // Debugging

          return invitationsData
              .map((invitation) => CompetitionInvitation.fromJson(Map<String, dynamic>.from(invitation)))
              .toList();
        } else {
          throw Exception("Invalid response format: 'body' field is missing or incorrect.");
        }
      } else {
        throw Exception('Failed to load invitations. Status code: ${response.statusCode}');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching invitations: $e');
      }
      return [];
    }
  }
}
