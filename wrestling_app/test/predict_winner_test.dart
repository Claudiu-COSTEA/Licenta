// test/admin_services_predict_winner_test.dart
import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/testing.dart';
import 'package:http/http.dart' as http;

import 'package:wrestling_app/services/admin_apis_services.dart';
import 'package:wrestling_app/services/notifications_services.dart';

/// Stub care neutralizează dependența de Firebase.
class _StubNotifications implements NotificationsServices {
  @override
  Future<String> getAccessToken() async => '';

  @override
  Future<void> initializeNotifications() async {}

  @override
  Future<String?> getUserFCMToken(int _) async => null;

  @override
  Future<void> saveTokenToServer(int _, {String? token}) async {}

  @override
  Future<void> sendFCMMessage(String _,
      {String? title, String? body}) async {}

  @override
  Future<void> storeFcmToken(int _, String __) async {}
}

void main() {
  group('AdminServices.predictWinner', () {
    test('HTTP 200 ⇒ întoarce winner & probability', () async {
      // Payload-ul pe care Lambda îl pune în „body”
      final body = {
        'predicted_winner': 123,
        'prediction_probability': 0.87,
      };
      final envelope = jsonEncode({'body': jsonEncode(body)});

      late http.Request captured;
      final admin = AdminServices(
        client: MockClient((req) async {
          captured = req;                                 // capturăm request-ul
          return http.Response(envelope, 200);
        }),
        notifications: _StubNotifications(),
      );

      final result = await admin.predictWinner(
        w1WinRate: 0.8,
        w1Years: 5,
        w1PointsWon: 120,
        w1PointsLost: 60,
        w1WinsVsW2: 3,
        w2WinRate: 0.7,
        w2Years: 4,
        w2PointsWon: 100,
        w2PointsLost: 70,
        w2WinsVsW1: 2,
      );

      // ✔️ a) s-a trimis POST la /admin/prediction
      expect(captured.url.path, contains('admin/prediction'));

      // ✔️ b) corpul conține parametrii necesari
      final sentPayload = json.decode(captured.body) as Map<String, dynamic>;
      expect(sentPayload['wrestler1_win_rate_last_50'], 0.8);
      expect(sentPayload['wrestler2_experience_years'], 4);

      // ✔️ c) rezultatul este cel din răspuns
      expect(result['winner'], 123);
      expect(result['probability'], closeTo(0.87, 1e-6));
    });

    test('HTTP 500 ⇒ fallback {"unknown", 0.0}', () async {
      final admin = AdminServices(
        client: MockClient(
              (req) async => http.Response('err', 500),
        ),
        notifications: _StubNotifications(),
      );

      final result = await admin.predictWinner(
        w1WinRate: 0.6,
        w1Years: 3,
        w1PointsWon: 80,
        w1PointsLost: 70,
        w1WinsVsW2: 1,
        w2WinRate: 0.5,
        w2Years: 2,
        w2PointsWon: 60,
        w2PointsLost: 80,
        w2WinsVsW1: 2,
      );

      expect(result, {'winner': 'unknown', 'probability': 0.0});
    });
  });
}
