// ignore_for_file: avoid_print

import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:http/http.dart' as http;

import 'package:wrestling_app/models/competition_model.dart';
import 'package:wrestling_app/models/competitions_invitations_status.dart';
import 'package:wrestling_app/services/constants.dart';
import 'package:wrestling_app/services/notifications_services.dart';

/// Signature for a function that picks a PDF and returns the [PlatformFile]
/// or `null` if the user canceled the picker.
typedef PickPdfFn = Future<PlatformFile?> Function();

/// Signature for a function that reads a file's bytes given the path.
typedef ReadBytesFn = Future<List<int>> Function(String path);

/// Very small DTO returned by [addCompetition] & co. so UI can show a message
/// without parsing exceptions.
class ServiceResult {
  const ServiceResult({required this.success, this.message});

  final bool success;
  final String? message;
}

/// A refactored version of **AdminServices** that—through dependency
/// injection—removes direct Flutter UI calls.  Every external dependency is
/// injectable, so each public method is *purely* testable in isolation.
class AdminServices {
  AdminServices({
    http.Client? client,
    PickPdfFn? pickPdf,
    ReadBytesFn? readBytes,
    NotificationsServices? notifications,
  })  : _client = client ?? http.Client(),
        _pickPdf = pickPdf ?? _defaultPickPdf,
        _readBytes = readBytes ?? _defaultReadBytes,
        _notifications = notifications ?? NotificationsServices();

  //-------------------------------------------------------------------------
  // Dependencies (all injectable)
  //-------------------------------------------------------------------------
  final http.Client _client;
  final PickPdfFn _pickPdf;
  final ReadBytesFn _readBytes;
  final NotificationsServices _notifications;

  static Future<PlatformFile?> _defaultPickPdf() => FilePicker.platform.pickFiles(
    type: FileType.custom,
    allowedExtensions: const ['pdf'],
  ).then((result) => result?.files.single);

  static Future<List<int>> _defaultReadBytes(String path) => File(path).readAsBytes();

  //-------------------------------------------------------------------------
  // 1. Competition CRUD & related helpers
  //-------------------------------------------------------------------------

  Future<ServiceResult> addCompetition({
    required String name,
    required String startDate, // YYYY-MM-DD HH:MM:SS
    required String endDate,   // YYYY-MM-DD HH:MM:SS
    required String location,
  }) async {
    final uri = Uri.parse('${AppConstants.baseUrl}admin/addCompetition');

    try {
      final res = await _client.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'competition_name': name,
          'competition_start_date': startDate,
          'competition_end_date': endDate,
          'competition_location': location,
        }),
      );

      if (res.statusCode == 200) {
        final decoded = json.decode(res.body) as Map<String, dynamic>;
        final body = _unwrapProxy(decoded);
        return ServiceResult(success: true, message: body['message'] as String?);
      }
      return ServiceResult(success: false, message: 'HTTP ${res.statusCode}');
    } catch (e) {
      return ServiceResult(success: false, message: '$e');
    }
  }

  Future<ServiceResult> updateCompetitionStatus({
    required int competitionUUID,
    required String status, // e.g. "open" | "closed"
  }) async {
    final uri = Uri.parse('${AppConstants.baseUrl}admin/postCompetitionStatus');

    try {
      final res = await _client.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'competition_UUID': competitionUUID,
          'competition_status': status,
        }),
      );

      if (res.statusCode == 200) {
        final decoded = json.decode(res.body) as Map<String, dynamic>;
        final body = _unwrapProxy(decoded);
        return ServiceResult(success: true, message: body['message'] as String?);
      }
      return ServiceResult(success: false, message: 'HTTP ${res.statusCode}');
    } catch (e) {
      return ServiceResult(success: false, message: '$e');
    }
  }

  Future<List<Competition>> fetchCompetitions() async {
    final uri = Uri.parse('${AppConstants.baseUrl}admin/getCompetitions');
    final res = await _client.get(uri);
    if (res.statusCode != 200) {
      throw Exception('HTTP ${res.statusCode}: ${res.body}');
    }

    final envelope = json.decode(utf8.decode(res.bodyBytes)) as Map<String, dynamic>;
    final body = _unwrapProxy(envelope) as List<dynamic>;
    return body.map((e) => Competition.fromJson(e as Map<String, dynamic>)).toList();
  }

  //-------------------------------------------------------------------------
  // 2. Invitations
  //-------------------------------------------------------------------------

  Future<ServiceResult> sendInvitation({
    required int competitionUUID,
    required int recipientUUID,
    required String recipientRole,
    String? weightCategory,
    required String status,
    required String deadline,
    String? refereeVerification,
  }) async {
    final uri = Uri.parse('${AppConstants.baseUrl}admin/sendInvitation');

    try {
      final res = await _client.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'competition_UUID': competitionUUID,
          'recipient_UUID': recipientUUID,
          'recipient_role': recipientRole,
          'weight_category': weightCategory,
          'invitation_status': status,
          'invitation_deadline': deadline,
          'referee_verification': refereeVerification,
        }),
      );

      if (res.statusCode == 200 || res.statusCode == 201) {
        final decoded = json.decode(res.body) as Map<String, dynamic>;
        final body = _unwrapProxy(decoded);

        // send notification (fire-and-forget)
        try {
          final String? token = await _notifications.getUserFCMToken(recipientUUID);
          if (token != null) await _notifications.sendFCMMessage(token);
        } catch (_) {
          // swallow notification errors in service layer
        }

        return ServiceResult(success: true, message: body['message'] as String?);
      }
      return ServiceResult(success: false, message: 'HTTP ${res.statusCode}');
    } catch (e) {
      return ServiceResult(success: false, message: '$e');
    }
  }

  Future<List<ClubInvitation>> fetchClubsInvitationsStatus() async {
    final uri = Uri.parse('${AppConstants.baseUrl}admin/getCompetitionsInvitationsStatus');

    final res = await _client.get(uri, headers: {'Content-Type': 'application/json'});
    if (res.statusCode != 200) {
      throw Exception('HTTP ${res.statusCode}: ${res.body}');
    }

    final envelope = json.decode(utf8.decode(res.bodyBytes)) as Map<String, dynamic>;
    final body = _unwrapProxy(envelope) as List<dynamic>;
    return body.map((e) => ClubInvitation.fromJson(e as Map<String, dynamic>)).toList();
  }

  //-------------------------------------------------------------------------
  // 3. ML prediction endpoint
  //-------------------------------------------------------------------------

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
    final uri = Uri.parse('${AppConstants.baseUrl}admin/prediction');

    try {
      final res = await _client.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'wrestler1_win_rate_last_50': w1WinRate,
          'wrestler1_experience_years': w1Years,
          'wrestler1_technical_points_won_last_50': w1PointsWon,
          'wrestler1_technical_points_lost_last_50': w1PointsLost,
          'wrestler1_wins_against_wrestler2': w1WinsVsW2,
          'wrestler2_win_rate_last_50': w2WinRate,
          'wrestler2_experience_years': w2Years,
          'wrestler2_technical_points_won_last_50': w2PointsWon,
          'wrestler2_technical_points_lost_last_50': w2PointsLost,
          'wrestler2_wins_against_wrestler1': w2WinsVsW1,
        }),
      );

      if (res.statusCode == 200) {
        final decoded = json.decode(res.body) as Map<String, dynamic>;
        final body = _unwrapProxy(decoded) as Map<String, dynamic>;
        return {
          'winner': body['predicted_winner'],
          'probability': body['prediction_probability'],
        };
      }
      throw Exception('HTTP ${res.statusCode}: ${res.body}');
    } catch (e) {
      return {'winner': 'unknown', 'probability': 0.0};
    }
  }

  //-------------------------------------------------------------------------
  // 4. Wrestler documents (license & medical)  -----------------------------
  //-------------------------------------------------------------------------

  Future<ServiceResult> pickAndUploadLicensePdf() async {
    return _pickAndUploadPdf(
      folder: 'WrestlersLicenseDocuments',
      update: (uuid, url) => _updateWrestlerDoc(uuid: uuid, url: url, type: 'license'),
    );
  }

  Future<ServiceResult> pickAndUploadMedicalPdf() async {
    return _pickAndUploadPdf(
      folder: 'WrestlersMedicalDocuments',
      update: (uuid, url) => _updateWrestlerDoc(uuid: uuid, url: url, type: 'medical'),
    );
  }

  // Internal helper that does the heavy lifting for both licence & medical.
  Future<ServiceResult> _pickAndUploadPdf({
    required String folder,
    required Future<bool> Function(int uuid, String url) update,
  }) async {
    try {
      final picked = await _pickPdf();
      if (picked == null) return ServiceResult(success: false, message: 'cancelled');

      final fileName = picked.name; // e.g. "11_Alex_Popescu.pdf"
      final parts = fileName.split('_');
      if (parts.isEmpty) {
        return ServiceResult(success: false, message: 'Filename must start with wrestler UUID');
      }
      final uuid = int.tryParse(parts[0]);
      if (uuid == null) {
        return ServiceResult(success: false, message: 'Invalid UUID prefix');
      }

      final uploadUri = Uri.https(
        'wrestlingdocumentsbucket.s3.us-east-1.amazonaws.com',
        '/$folder/${Uri.encodeComponent(fileName)}',
      );

      final bytes = await _readBytes(picked.path!);
      final uploadRes = await _client.put(
        uploadUri,
        headers: {
          'Content-Type': 'application/pdf',
          'x-amz-acl': 'bucket-owner-full-control',
        },
        body: bytes,
      );

      if (uploadRes.statusCode != 200) {
        return ServiceResult(success: false, message: 'S3 HTTP ${uploadRes.statusCode}');
      }

      final ok = await update(uuid, uploadUri.toString());
      return ServiceResult(success: ok, message: ok ? 'uploaded' : 'db-error');
    } catch (e) {
      return ServiceResult(success: false, message: '$e');
    }
  }

  Future<bool> _updateWrestlerDoc({required int uuid, required String url, required String type}) async {
    final uri = Uri.parse('${AppConstants.baseUrl}admin/postWrestlerUrl');
    final res = await _client.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'wrestler_UUID': uuid, 'type': type, 'url': url}),
    );
    return res.statusCode == 200;
  }

  //-------------------------------------------------------------------------
  // Helpers
  //-------------------------------------------------------------------------

  /// Lambda proxy integrations wrap the *real* payload in a string-encoded
  /// JSON found in the "body" key.  This helper unwraps it automatically.
  static dynamic _unwrapProxy(Map<String, dynamic> maybeWrapped) {
    final dynamic rawBody = maybeWrapped['body'];
    if (rawBody == null) return maybeWrapped;
    return rawBody is String ? json.decode(rawBody) : rawBody;
  }
}
