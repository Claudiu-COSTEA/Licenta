import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../models/user_model.dart';

class UserService {
  final String _baseUrl = 'http://192.168.0.154/wrestling_app/get_user.php';

  Future<UserModel?> fetchUserByEmail(String email) async {
    try {
      final response = await http.get(Uri.parse('$_baseUrl?email=$email'));

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        if (jsonData.containsKey("message")) {
          return null; // User not found
        }
        return UserModel.fromJson(jsonData);
      } else {
        throw Exception('Failed to load user. Status code: ${response.statusCode}');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching user: $e');
      }
      return null;
    }
  }
}
