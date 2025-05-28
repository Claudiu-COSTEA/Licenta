// lib/services/referee_api_services.dart
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:wrestling_app/services/constants.dart';

import '../models/wrestler_weight_category_model.dart';
import '../models/wrestler_verification_model.dart';

class RefereeServices {
  // ← acceptă client injectabil
  RefereeServices({http.Client? client}) : _client = client ?? http.Client();

  // folosește-l în loc de http.get/post direct
  final http.Client _client;

  Future<void> updateInvitationStatus({
    required BuildContext context,
    required int competitionUUID,
    required int recipientUUID,
    required String recipientRole,
    required String invitationStatus,
  }) async {
    try {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => const Center(child: CircularProgressIndicator()),
      );

      final response = await _client.post(
        Uri.parse(AppConstants.baseUrl + "sendInvitationResponse"),
        headers: {"Content-Type": "application/json"},
        body: json.encode({
          "competition_UUID": competitionUUID,
          "recipient_UUID": recipientUUID,
          "recipient_role": recipientRole,
          "invitation_status": invitationStatus,
        }),
      );

      if (context.mounted) Navigator.pop(context);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final color = data.containsKey("message") ? Colors.green : Colors.red;
        final text = data["message"] ?? data["error"] ?? "Unknown error";
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(text), backgroundColor: color));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Failed to update invitation"),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e"), backgroundColor: Colors.red),
      );
    }
  }

  Future<List<WrestlerVerification>> fetchWrestlers(
      String wrestlingStyle,
      String weightCategory,
      int competitionUUID,
      ) async {
    final uri = Uri.parse('${AppConstants.baseUrl}referee/getVerifiedWrestlers')
        .replace(queryParameters: {
      'wrestling_style': wrestlingStyle,
      'weight_category': weightCategory,
      'competition_UUID': competitionUUID.toString(),
    });

    try {
      final response = await _client.get(uri);
      if (response.statusCode != 200) {
        throw Exception('Failed to load wrestlers – status ${response.statusCode}');
      }
      final decoded = json.decode(utf8.decode(response.bodyBytes));
      final body = decoded['body'];
      if (body is String) {
        return (json.decode(body) as List)
            .map((e) => WrestlerVerification.fromJson(Map.from(e)))
            .toList();
      }
      if (body is List) {
        return body
            .map((e) => WrestlerVerification.fromJson(Map.from(e)))
            .toList();
      }
      if (body is Map && body.containsKey('error')) {
        throw Exception(body['error']);
      }
      throw Exception('Unexpected API response format');
    } catch (e) {
      if (kDebugMode) print('Error fetching wrestlers: $e');
      return [];
    }
  }

  Future<List<WrestlerWeightCategory>> fetchWeightCategories(
      int competitionUUID,
      ) async {
    final uri = Uri.parse(
        '${AppConstants.baseUrl}referee/getCompetitionWeightCategories?competition_UUID=$competitionUUID');
    try {
      final response = await _client.get(uri);
      if (response.statusCode != 200) {
        throw Exception('Failed to load weight categories. Status: ${response.statusCode}');
      }
      final decoded = json.decode(response.body);
      final rawBody = decoded['body'];
      final body = rawBody is String ? json.decode(rawBody) : rawBody;
      if (body is List) {
        return body
            .map((e) => WrestlerWeightCategory.fromJson(Map.from(e)))
            .toList();
      }
      if (body is Map && body.containsKey('error')) {
        throw Exception(body['error']);
      }
      throw Exception('Unexpected response format');
    } catch (e) {
      if (kDebugMode) print('Error fetching weight categories: $e');
      return [];
    }
  }

  Future<bool> updateRefereeVerification({
    required int competitionUUID,
    required int recipientUUID,
    required String recipientRole,
    required String refereeVerification,
  }) async {
    final uri = Uri.parse(
        '${AppConstants.baseUrl}referee/sendWrestlerVerificationStatus');
    try {
      final response = await _client.post(
        uri,
        headers: {"Content-Type": "application/json"},
        body: json.encode({
          "competition_UUID": competitionUUID,
          "recipient_UUID": recipientUUID,
          "recipient_role": recipientRole,
          "referee_verification": refereeVerification,
        }),
      );
      if (response.statusCode == 200) {
        final decoded = json.decode(response.body);
        final rawBody = decoded['body'];
        final body = rawBody is String ? json.decode(rawBody) : rawBody;
        if (body is Map && body.containsKey('success')) return true;
        if (body is Map && body.containsKey('error')) throw Exception(body['error']);
        throw Exception('Unknown response format');
      } else {
        throw Exception('Failed status: ${response.statusCode}');
      }
    } catch (e) {
      if (kDebugMode) print('Error updating referee verification: $e');
      return false;
    }
  }
}
