import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../models/user_model.dart';

class UserService {
  final String _baseUrl = "https://rhybb6zgsb.execute-api.us-east-1.amazonaws.com/wrestling/getUser";

  Future<UserModel?> fetchUserByEmail(String email) async {
    try {
      final response = await http.get(Uri.parse("$_baseUrl?email=$email"));

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);

        if (responseData.containsKey("body")) {
          final userData = responseData["body"];
          return UserModel.fromJson(userData);
        } else {
          if (kDebugMode) {
            print("Invalid response format: $responseData");
          }
          return null;
        }
      } else {
        if (kDebugMode) {
          print("Error fetching user: ${response.statusCode}, ${response.body}");
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
