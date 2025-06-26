import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:wrestling_app/services/constants.dart';

import '../models/wrestler_documents_model.dart';
import '../views/shared/widgets/toast_helper.dart';

class WrestlerService {

  static const Color primary = Color(0xFFB4182D);

  Future<void> updateInvitationStatus({
    required BuildContext context,
    required int competitionUUID,
    required int recipientUUID,
    required String recipientRole,
    required String invitationStatus,
  }) async {
    try {
      // 1) Afișează dialogul de loading
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator(color: primary,)),
      );

      // 2) Trimite cererea POST către API
      final response = await http.post(
        Uri.parse(AppConstants.baseUrl + "sendInvitationResponse"),
        headers: {"Content-Type": "application/json"},
        body: json.encode({
          "competition_UUID": competitionUUID,
          "recipient_UUID": recipientUUID,
          "recipient_role": recipientRole,
          "invitation_status": invitationStatus,
        }),
      );

      // 3) Închide dialogul de loading
      if (context.mounted) Navigator.pop(context);

      // 4) Decodează răspunsul
      final responseData = json.decode(response.body);
      final body = responseData["body"];

      // 5) Verifică formatul răspunsului și afișează toast corespunzător
      if (body is Map<String, dynamic>) {
        if (body.containsKey("message")) {
          ToastHelper.succes("Răspunsul invitației a fost trimis cu succes!");
        } else if (body.containsKey("error")) {
          ToastHelper.eroare("A apărut o eroare la actualizarea invitației!");
        } else {
          ToastHelper.eroare("Răspuns necunoscut de la server");
        }
      } else {
        ToastHelper.eroare("Format de răspuns neașteptat");
      }
    } catch (e) {
      // 6) Dacă apare o excepție, închide dialogul și afișează toast de eroare
      if (context.mounted) Navigator.pop(context);
      ToastHelper.eroare("Eroare: $e");
    }
  }

  Future<WrestlerDocuments?> fetchWrestlerUrls(int wrestlerUUID) async {
    final uri = Uri.parse(
      '${AppConstants.baseUrl}wrestler/getWrestlerUrls?wrestler_UUID=$wrestlerUUID',
    );

    try {
      final response = await http.get(uri);

      /* ───────────────────────────────────────────────────────── status check */
      if (response.statusCode != 200) {
        if (kDebugMode) {
          print('Failed to load documents. Status code: ${response.statusCode}');
        }
        return null;
      }

      /* ────────────────────────────────────────────────────────── JSON parse */
      final decoded = jsonDecode(response.body);
      final body = decoded['body'];

      if (body is! Map<String, dynamic>) {
        if (kDebugMode) print('Unexpected response structure: $body');
        return null;
      }

      /* ───────────────────────────────────────────── build model regardless */
      final docs = WrestlerDocuments.fromJson(body);

      // If *both* URLs are missing, treat this as “nothing useful”.
      if (docs.medicalDocument == null && docs.licenseDocument == null) {
        if (kDebugMode) print('No documents returned for $wrestlerUUID');
        return null;
      }

      return docs;                       // everything went fine
    } catch (e, s) {
      if (kDebugMode) {
        print('Exception fetching documents: $e');
        print(s);
      }
      return null;
    }
  }
}
