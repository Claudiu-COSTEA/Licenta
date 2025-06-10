import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../models/user_model.dart';
import 'package:wrestling_app/services/constants.dart';

class UserService {
  final String _url = AppConstants.baseUrl + "getUserByEmail";

  Future<UserModel?> fetchUserByEmail(String email) async {
    try {
      final response = await http.get(Uri.parse("$_url?email=$email"));

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);

        if (responseData.containsKey("body") &&
            responseData["body"] is Map<String, dynamic>) {
          final userData = responseData["body"] as Map<String, dynamic>;

          // Ensure wrestling_style is a String (empty if null)
          userData['wrestling_style'] =
              (userData['wrestling_style'] as String?) ?? '';

          return UserModel.fromJson(userData);
        } else {
          if (kDebugMode) {
            print("Invalid response format: $responseData");
          }
          return null;
        }
      } else {
        if (kDebugMode) {
          print(
              "Error fetching user: ${response.statusCode}, ${response.body}");
        }
        return null;
      }
    } catch (e) {
      if (kDebugMode) {
        print("Exception while fetching user: $e");
      }
      return null;
    }
  }
}
