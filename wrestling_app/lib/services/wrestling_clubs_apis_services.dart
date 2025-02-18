import 'dart:convert';
import 'package:http/http.dart' as http;

class WrestlingClubService {
  final String _baseUrl = 'http://192.168.0.154/wrestling_app/wrestling_club/get_wrestling_club_coaches.php';

  Future<List<Map<String, dynamic>>> fetchCoachesForClub(int wrestlingClubUUID) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl?wrestling_club_UUID=$wrestlingClubUUID'),
      );

      if (response.statusCode == 200) {
        var decodedResponse = json.decode(response.body);

        // 🔹 Check if the response is a Map (error message case)
        if (decodedResponse is Map<String, dynamic> && decodedResponse.containsKey("message")) {
          return []; // No coaches found
        }

        // 🔹 Ensure it's a List before mapping
        if (decodedResponse is List) {
          return decodedResponse.map((coach) => Map<String, dynamic>.from(coach)).toList();
        } else {
          throw Exception("Unexpected API response format.");
        }
      } else {
        throw Exception('Failed to load coaches. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching coaches: $e');
      return [];
    }
  }
}
