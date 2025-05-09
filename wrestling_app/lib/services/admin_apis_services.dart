import 'dart:convert';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:wrestling_app/services/notifications_services.dart';
import 'package:wrestling_app/models/competition_model.dart';
import 'package:wrestling_app/services/constants.dart';

import '../models/competitions_invitations_status.dart';

class AdminServices {

  Future<bool> addCompetition({
    required BuildContext context,
    required String competitionName,
    required String competitionStartDate,
    required String competitionEndDate,
    required String competitionLocation,
  }) async {
    try {
      const String _url = AppConstants.baseUrl + 'admin/addCompetition';

      // Show loading indicator
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator()),
      );


      final response = await http.post(
        Uri.parse(_url),
        headers: {
          "Content-Type": "application/json",
        },
        body: jsonEncode({
          "competition_name": competitionName,
          "competition_start_date": competitionStartDate,
          // Format: YYYY-MM-DD HH:MM:SS
          "competition_end_date": competitionEndDate,
          // Format: YYYY-MM-DD HH:MM:SS
          "competition_location": competitionLocation,
        }),
      );

      // Close loading dialog
      if (context.mounted) Navigator.pop(context);

      if (response.statusCode == 200) {
        // Decode the response body
        final responseData = json.decode(response.body);

        // Check if the 'body' field exists and contains the 'message'
        if (responseData.containsKey("body") &&
            responseData["body"]["message"] ==
                "Competition added successfully") {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Competiție adăugată cu succes !"),
                backgroundColor: Colors.green),
          );
          return true;
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(responseData["error"] ?? "Unknown error"),
                backgroundColor: Colors.red),
          );
          return false;
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Eșuare la adăugarea competiției !"),
              backgroundColor: Colors.red),
        );
        return false;
      }
    } catch (e) {
      if (context.mounted) Navigator.pop(
          context); // Close loading dialog if error occurs

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e"), backgroundColor: Colors.red),
      );

      return false;
    }
  }


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
      const String _url = AppConstants.baseUrl + 'admin/sendInvitation';

      final response = await http.post(
        Uri.parse(_url),
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
            // Send FCM notification if needed
            NotificationsServices notificationService = NotificationsServices();
            String? token = await notificationService.getUserFCMToken(
                recipientUUID);
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
        throw Exception(
            "Failed to send invitation. Status: ${response.statusCode}");
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
    const url = AppConstants.baseUrl + 'admin/prediction';

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

  static Future<bool> updateLicenseDocument({
    required int wrestlerUUID,
    required String url,
  }) async {
    final uri = Uri.parse(
        AppConstants.baseUrl + "admin/postWrestlerUrl"
    );
    final payload = {
      'wrestler_UUID': wrestlerUUID,
      'type': 'license',
      'url': url,
    };
    final res = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(payload),
    );
    return res.statusCode == 200;
  }

  Future<void> pickAndUploadLicensePdf() async {
    // 1. Alege fișierul .pdf
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );
    if (result == null) return;

    final file = File(result.files.single.path!);
    final fileName = result.files.single.name; // ex: "11_Alex_Popescu.pdf"
    final encodedName = Uri.encodeComponent(fileName);

    // 2. Extrage wrestlerUUID din prefix (înainte de underscore)
    final parts = fileName.split('_');
    if (parts.isEmpty) {
      debugPrint('Numele fișierului nu conține "_" pentru UUID!');
      return;
    }
    final idPart = parts[0];
    final wrestlerUUID = int.tryParse(idPart);
    if (wrestlerUUID == null) {
      debugPrint('Prefix-ul "$idPart" nu e un integer valid!');
      return;
    }

    // 3. Construiește URI-ul pentru PUT în S3
    final uploadUri = Uri.https(
      'wrestlingdocumentsbucket.s3.us-east-1.amazonaws.com',
      '/WrestlersLicenseDocuments/$encodedName',
    );

    // 4. Încarcă PDF-ul
    final bytes = await file.readAsBytes();
    final res = await http.put(
      uploadUri,
      headers: {
        'Content-Type': 'application/pdf',
        'x-amz-acl': 'bucket-owner-full-control',
      },
      body: bytes,
    );

    if (res.statusCode != 200) {
      debugPrint('Eroare la upload S3: ${res.statusCode}');
      return;
    }
    final fileUrl = uploadUri.toString();
    debugPrint('Upload licență reușit: $fileUrl');

    // 5. Trimite URL-ul și UUID-ul la Lambda/API Gateway
    final ok = await AdminServices.updateLicenseDocument(
      wrestlerUUID: wrestlerUUID,
      url: fileUrl,
    );
    if (ok) {
      debugPrint('DB actualizat cu license_document pentru wrestler $wrestlerUUID');
    } else {
      debugPrint('Eroare la actualizarea DB-ului pentru license_document');
    }
  }

  static Future<bool> updateMedicalDocument({
    required int wrestlerUUID,
    required String url,
  }) async {
    final uri = Uri.parse(
        AppConstants.baseUrl + "admin/postWrestlerUrl"
    );
    final payload = {
      'wrestler_UUID': wrestlerUUID,
      'type': 'medical',
      'url': url,
    };
    final res = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(payload),
    );
    return res.statusCode == 200;
  }

Future<void> pickAndUploadMedicalPdf() async {
  // 1. Alege fișierul PDF
  final result = await FilePicker.platform.pickFiles(
    type: FileType.custom,
    allowedExtensions: ['pdf'],
  );
  if (result == null) return;

  final file = File(result.files.single.path!);
  final fileName = result.files.single.name; // ex: "11_Alex_Popescu.pdf"
  final encodedName = Uri.encodeComponent(fileName);

  // 2. Extrage wrestlerUUID din prefix (înainte de '_')
  final parts = fileName.split('_');
  if (parts.isEmpty) {
    debugPrint('Numele fișierului nu conține underscore!');
    return;
  }
  final idPart = parts[0];
  final wrestlerUUID = int.tryParse(idPart);
  if (wrestlerUUID == null) {
    debugPrint('Prefix-ul "$idPart" nu e un integer valid!');
    return;
  }

  // 3. Construiește URI-ul de PUT în S3
  final uploadUri = Uri.https(
    'wrestlingdocumentsbucket.s3.us-east-1.amazonaws.com',
    '/WrestlersMedicalDocuments/$encodedName',
  );

  // 4. Încarcă PDF-ul
  final bytes = await file.readAsBytes();
  final uploadRes = await http.put(
    uploadUri,
    headers: {
      'Content-Type': 'application/pdf',
      'x-amz-acl': 'bucket-owner-full-control',
    },
    body: bytes,
  );

  if (uploadRes.statusCode != 200) {
    debugPrint('Eroare upload S3: ${uploadRes.statusCode}');
    return;
  }
  final fileUrl = uploadUri.toString();
  debugPrint('Upload reușit la: $fileUrl');

  // 5. Trimite URL-ul și UUID-ul la Lambda
  final ok = await AdminServices.updateMedicalDocument(
    wrestlerUUID: wrestlerUUID,
    url: fileUrl,
  );
  if (ok) {
    debugPrint('DB actualizat cu URL-document medical pentru $wrestlerUUID');
  } else {
    debugPrint('Eroare la actualizarea DB-ului');
  }
}

  Future<List<Competition>> fetchCompetitions() async {
    final res = await http.get(Uri.parse(
        AppConstants.baseUrl + 'admin/getCompetitions'
    ));
    if (res.statusCode != 200) {
      throw Exception('Failed to load competitions (${res.statusCode})');
    }

    // Decode UTF-8 raw bytes to preserve diacritics
    final envelope = jsonDecode(utf8.decode(res.bodyBytes))
    as Map<String, dynamic>;

    // The API Gateway proxy wraps the real array as a JSON-string in "body"
    final bodyString = envelope['body'] as String;

    // Parse that string into a List<dynamic>
    final List<dynamic> list = jsonDecode(bodyString) as List<dynamic>;

    // Map each entry into your Competition model
    return list
        .map((e) => Competition.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<void> updateCompetitionStatus(BuildContext context, {
    required int competitionId,
    required String status,
  }) async {
    final uri = Uri.parse(AppConstants.baseUrl + "admin/postCompetitionStatus");
    final payload = {
      'competition_UUID': competitionId,
      'competition_status': status,
    };

    try {
      final res = await http.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(payload),
      );
      if (res.statusCode != 200) {
        throw Exception('HTTP ${res.statusCode}: ${res.body}');
      }

      // Decode both proxy‐wrapped and direct bodies:
      final decoded = jsonDecode(res.body) as Map<String, dynamic>;
      final dynamic body = decoded['body'] ?? decoded;
      final result = body is String
          ? jsonDecode(body) as Map<String, dynamic>
          : body as Map<String, dynamic>;

      if (result['message'] != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(result['message'] as String)),
        );
      } else {
        throw Exception(result['error'] ?? 'Unknown error');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error updating status: $e')),
      );
    }
  }

  Future<List<ClubInvitation>> fetchClubsInvitationsStatus() async {
    final uri = Uri.parse(
        '${AppConstants.baseUrl}admin/getCompetitionsInvitationsStatus'
    );

    final res = await http.get(uri, headers: {
      'Content-Type': 'application/json',
    });

    if (res.statusCode != 200) {
      throw Exception(
          'Failed to load invitations (${res.statusCode}): ${res.body}');
    }

    // Decode UTF-8 to preserve diacritics
    final envelope = jsonDecode(utf8.decode(res.bodyBytes))
    as Map<String, dynamic>;

    // The proxy wraps the real array as a JSON string in "body"
    final bodyString = envelope['body'] as String;

    // Parse that string into a List<dynamic>
    final List<dynamic> list = jsonDecode(bodyString) as List<dynamic>;

    // Map each element into your model
    return list
        .map((e) => ClubInvitation.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}
