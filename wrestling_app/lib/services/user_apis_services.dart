import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:googleapis/admob/v1.dart';
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
