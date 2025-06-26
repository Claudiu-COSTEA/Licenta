// ignore_for_file: avoid_print

import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:http/http.dart' as http;

import 'package:wrestling_app/models/competition_model.dart';
import 'package:wrestling_app/models/competitions_invitations_status.dart';
import 'package:wrestling_app/models/referee_complete_model.dart';
import 'package:wrestling_app/services/constants.dart';
import 'package:wrestling_app/services/notifications_services.dart';

import '../models/coach_complete_model.dart';
import '../models/competition_invitation_model.dart';
import '../models/wrestler_complete_model.dart';
import '../models/wrestling_club_model.dart';
import '../views/shared/widgets/toast_helper.dart';

typedef PickPdfFn = Future<PlatformFile?> Function();

typedef ReadBytesFn = Future<List<int>> Function(String path);

class ServiceResult {
  const ServiceResult({required this.success, this.message});

  final bool success;
  final String? message;
}

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

  Future<void> updateCompetitionStatus({
    required int competitionUUID,
    required String status, // e.g. "Confirmed" | "Postponed"
  }) async {
    final uri = Uri.parse('${AppConstants.baseUrl}/admin/postCompetitionStatus');
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
        // if your API wraps the real body as a JSON string, you may need:
        final rawBody = decoded['body'];
        final body = rawBody is String ? json.decode(rawBody) : rawBody;
        final msg = (body is Map && body.containsKey('message'))
            ? body['message'] as String
            : 'Stare actualizată cu succes!';
        ToastHelper.succes(msg);
      } else {
        ToastHelper.eroare('Eroare server: HTTP ${res.statusCode}');
      }
    } catch (e) {
      ToastHelper.eroare('Eroare la actualizarea competiției: $e');
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

  Future<List<WrestlingClub>> fetchClubs() async {
    final res = await http.get(Uri.parse(AppConstants.baseUrl + "getWrestlingClubs"));

    if (res.statusCode != 200) {
      throw Exception('Failed to load clubs (${res.statusCode})');
    }

    // 1) Decode the raw body bytes as UTF-8:
    final decodedEnvelope = jsonDecode(utf8.decode(res.bodyBytes))
    as Map<String, dynamic>;

    // 2) Extract the inner `body`, which is itself a JSON-string:
    final bodyString = decodedEnvelope['body'] as String;

    // 3) Decode that string again as UTF-8 bytes (to preserve diacritics):
    final fixedBodyJson = utf8.decode(utf8.encode(bodyString));

    // 4) Parse into a Dart List:
    final List<dynamic> list = jsonDecode(fixedBodyJson) as List<dynamic>;

    // 5) Map into your model:
    return list
        .map((e) => WrestlingClub.fromJson(e as Map<String, dynamic>))
        .toList();
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

  /// După modificare, aceste metode nu mai întorc ServiceResult,
  /// ci doar Future<void>, pentru că intern folosesc toast-uri.
  Future<void> pickAndUploadLicensePdf() async {
    await _pickAndUploadPdf(
      folder: 'WrestlersLicenseDocuments',
      update: (uuid, url) => _updateWrestlerDoc(uuid: uuid, url: url, type: 'license'),
    );
  }

  Future<void> pickAndUploadMedicalPdf() async {
    await _pickAndUploadPdf(
      folder: 'WrestlersMedicalDocuments',
      update: (uuid, url) => _updateWrestlerDoc(uuid: uuid, url: url, type: 'medical'),
    );
  }

  /// Acum _pickAndUploadPdf întoarce Future<void> (_nu_ Future<ServiceResult>),
  /// pentru că afișează toast-uri intern și nu returnează un obiect ServiceResult.
  Future<void> _pickAndUploadPdf({
    required String folder,
    required Future<bool> Function(int uuid, String url) update,
  }) async {
    try {
      // 1) Alegerea fișierului PDF

      final picked = await _pickPdf();
      if (picked == null) {
        ToastHelper.eroare('Operațiune anulată');
        return;
      }

      // 2) Extragem UUID-ul din numele fișierului (prefix „11_…”)

      final fileName = picked.name; // ex: "11_Alex_Popescu.pdf"
      final parts = fileName.split('_');
      if (parts.isEmpty) {
        ToastHelper.eroare('Denumirea documentului incorectă !');
        return;
      }
      final uuid = int.tryParse(parts[0]);
      if (uuid == null) {
        ToastHelper.eroare('Denumirea documentului incorectă !');
        return;
      }

      // 3) Construim URI-ul pentru upload în S3
      // 4) Citim bytes și facem PUT către S3

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
        ToastHelper.eroare('Eroare la încărcare PDF (S3 HTTP ${uploadRes.statusCode})');
        return;
      }

      // 5) Actualizăm în baza de date URL-ul documentului
      final ok = await update(uuid, uploadUri.toString());
      if (ok) {
        ToastHelper.succes('Document încărcat cu succes !');
      } else {
        ToastHelper.eroare('Eroare la salvarea URL-ului în baza de date');
      }
    } catch (e) {
      // 6) Orice excepție neașteptată
      ToastHelper.eroare('Exception: $e');
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

  Future<List<CompetitionInvitation>> fetchInvitationsByRole({
    required String role,
    required String competitionUUID,
  }) async {
    final uri = Uri.parse(
      '${AppConstants.baseUrl}admin/getUsersInvitationsByRole'
          '?recipient_role=${Uri.encodeComponent(role)}'
          '&competition_UUID=$competitionUUID',
    );

    final res = await http.get(uri);
    if (res.statusCode != 200) {
      throw Exception(
          'Failed to load invitations (${res.statusCode}): ${res.body}');
    }

    // 1️⃣ API-ul tău îmbracă răspunsul în „envelope”:
    final envelope =
    jsonDecode(utf8.decode(res.bodyBytes)) as Map<String, dynamic>;

    // 2️⃣ „body” conține un JSON-string cu lista propriu-zisă
    final innerString = envelope['body'] as String;

    // 3️⃣ decodăm din nou – pentru a păstra diacriticele
    final List<dynamic> rawList =
    jsonDecode(utf8.decode(utf8.encode(innerString)));

    // 4️⃣ mapăm în model
    return rawList
        .map((e) => CompetitionInvitation.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<List<RefereeCompleteModel>> fetchReferees() async {
    final uri =
    Uri.parse('${AppConstants.baseUrl}admin/getReferees'); // ↩️  endpoint

    final res = await _client.get(uri);

    if (res.statusCode != 200) {
      throw Exception(
          'Failed to load referees (HTTP ${res.statusCode}): ${res.body}');
    }

    // ▸ API Gateway proxy: răspunsul real e string-ul din câmpul "body"
    final envelope = jsonDecode(utf8.decode(res.bodyBytes))
    as Map<String, dynamic>;

    final bodyString = envelope['body'] as String;

    // codificare/decodificare suplimentară → păstrează diacriticele
    final fixedBodyJson = utf8.decode(utf8.encode(bodyString));

    final List<dynamic> list = jsonDecode(fixedBodyJson) as List<dynamic>;

    // transformă în model
    return list
        .map((e) => RefereeCompleteModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<List<WrestlerCompleteModel>> fetchWrestlers() async {
    final uri = Uri.parse('${AppConstants.baseUrl}admin/getWrestlers');
    final res = await _client.get(uri);   // <== _client: http.Client definit deja în service

    if (res.statusCode != 200) {
      throw Exception('Eroare ${res.statusCode} când am încercat să citesc wrestlers');
    }

    // 1️⃣  decodăm UTF-8 pentru a păstra diacriticele
    final envelope = jsonDecode(utf8.decode(res.bodyBytes))
    as Map<String, dynamic>;

    // 2️⃣  API Gateway proxy îţi pune array-ul ca STRING în "body"
    final bodyString = envelope['body'] as String;

    // 3️⃣  iarăşi UTF-8 (diacritice)
    final listJson  = jsonDecode(utf8.decode(utf8.encode(bodyString)))
    as List<dynamic>;

    // 4️⃣  map-ăm în model
    final wrestlers = listJson
        .map((e) => WrestlerCompleteModel.fromJson(e as Map<String, dynamic>))
        .toList();

    // (opţional) le ordonăm alfabetic
    wrestlers.sort((a, b) => a.name.compareTo(b.name));
    return wrestlers;
  }

  Future<List<CoachCompleteModel>> fetchCoaches() async {
    final uri = Uri.parse('${AppConstants.baseUrl}admin/getCoaches');

    final response = await _client.get(uri, headers: {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    });

    if (response.statusCode != 200) {
      throw Exception(
        'Failed to load coaches (status: ${response.statusCode})',
      );
    }

    // 1) Decodăm răspunsul „envelope”:
    //    { "statusCode":200, "headers":{…}, "body":"[ { … }, { … } ]" }
    final envelope = jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;

    // 2) Extragem câmpul „body” (care e un JSON-string):
    final bodyString = envelope['body'] as String;

    // 3) Reconstruim corpul cu UTF-8 pentru a păstra diacriticele:
    final fixedJson = utf8.decode(utf8.encode(bodyString));

    // 4) Decodăm lista de obiecte:
    final List<dynamic> rawList = jsonDecode(fixedJson) as List<dynamic>;

    // 5) Mapăm fiecare element într-un CoachCompleteModel
    return rawList
        .map((e) => CoachCompleteModel.fromJson(e as Map<String, dynamic>))
        .toList();
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
