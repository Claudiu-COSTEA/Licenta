// test/admin_services_send_invitation_test.dart

import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/testing.dart';
import 'package:http/http.dart' as http;
import 'package:wrestling_app/services/admin_apis_services.dart';

import 'package:wrestling_app/services/notifications_services.dart';

// ───────────────────────── Stub / Spy Notifications ─────────────────────────
/// 1. NU accesează Firebase.
/// 2. Înregistrează apelurile ca să le putem verifica în teste.
class _SpyNotifications implements NotificationsServices {
  _SpyNotifications({this.tokenToReturn});

  /// ce valoare returnează getUserFCMToken
  final String? tokenToReturn;

  /// userId pentru care s-a cerut token
  int? gotTokenForUser;

  /// tokenul trimis mai departe în sendFCMMessage
  String? sentToken;

  // ——— metode folosite de AdminServices ———
  @override
  Future<String?> getUserFCMToken(int userId) async {
    gotTokenForUser = userId;
    return tokenToReturn;
  }

  @override
  Future<void> sendFCMMessage(String token,
      {String? title, String? body}) async {
    sentToken = token;
  }

  // ——— metode suplimentare, goale ———
  @override
  Future<String> getAccessToken() async => '';

  @override
  Future<void> initializeNotifications() async {}

  @override
  Future<void> saveTokenToServer(int userId, {String? token}) async {}

  @override
  Future<void> storeFcmToken(int userId, String token) async {}
}

void main() {
  group('AdminServices.sendInvitation', () {
    test('HTTP 201 → success true + trimite notificare când există token',
            () async {
          // 1. Client fake ce răspunde OK
          final okBody = jsonEncode({
            'body': jsonEncode({'message': 'Invitation created'})
          });
          final client =
          MockClient((req) async => http.Response(okBody, 201));

          // 2. Spy-ul pentru notificări (returnează un token dummy)
          final spy = _SpyNotifications(tokenToReturn: 'xyz-token');

          // 3. Service cu dependențele injectate
          final admin = AdminServices(client: client, notifications: spy);

          // 4. Rulează metoda
          final res = await admin.sendInvitation(
            competitionUUID: 1,
            recipientUUID: 42,
            recipientRole: 'Wrestler',
            weightCategory: '65 kg',
            status: 'pending',
            deadline: '2025-05-31 23:59:59',
          );

          // 5. Asserții
          expect(res.success, isTrue);
          expect(spy.gotTokenForUser, 42);
          expect(spy.sentToken, 'xyz-token');
        });

    test('HTTP 500 → success false, NU se trimit notificări', () async {
      final client =
      MockClient((req) async => http.Response('server error', 500));

      final spy = _SpyNotifications(tokenToReturn: 'xyz-token');

      final admin = AdminServices(client: client, notifications: spy);

      final res = await admin.sendInvitation(
        competitionUUID: 1,
        recipientUUID: 42,
        recipientRole: 'Coach',
        status: 'pending',
        deadline: '2025-05-31 23:59:59',
      );

      expect(res.success, isFalse);
      // metodele de notificare NU ar trebui chemate
      expect(spy.gotTokenForUser, isNull);
      expect(spy.sentToken, isNull);
    });
  });
}
