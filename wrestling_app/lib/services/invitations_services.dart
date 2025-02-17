import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/competition_invitation_model.dart';

class InvitationsService {
  final String _baseUrl = 'http://192.168.0.154/wrestling_app/get_invitations.php';

  Future<List<CompetitionInvitation>> fetchInvitations(int recipientUUID) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl?recipient_UUID=$recipientUUID'),
      );

      if (response.statusCode == 200) {
        print('Raw API Response: ${response.body}');  // Debugging

        List<dynamic> jsonData = json.decode(response.body);

        print('Decoded JSON: $jsonData');  // Debugging

        return jsonData
            .map((invitation) => CompetitionInvitation.fromJson(Map<String, dynamic>.from(invitation)))
            .toList();
      } else {
        throw Exception('Failed to load invitations. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching invitations: $e');
      return [];
    }
  }
}

