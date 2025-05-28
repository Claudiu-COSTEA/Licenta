// test/admin_services_fetch_invitations_test.dart
import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/testing.dart';
import 'package:http/http.dart' as http;

import 'package:wrestling_app/services/admin_apis_services.dart';
import 'package:wrestling_app/services/notifications_services.dart';
import 'package:wrestling_app/models/competitions_invitations_status.dart';

/// ───────────────── Stub Notifications (nu pornește Firebase) ─────────────────
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
  Future<void> sendFCMMessage(
      String _,
      {String? title, String? body}) async {}

  @override
  Future<void> storeFcmToken(int _, String __) async {}
}

void main() {
  group('AdminServices.fetchClubsInvitationsStatus', () {
    test('HTTP 200 ⇒ parsează lista corect', () async {
      // lista reală de invitații (doar două elemente pt. test)
      final listJson = [
        {
          'club_name': 'CSM București',
          'city': 'București',
          'invitation_status': 'Confirmed',
          'invitation_deadline': '2025-05-15 23:59:59',
        },
        {
          'club_name': 'CS Rapid Cluj',
          'city': 'Cluj-Napoca',
          'invitation_status': 'Confirmed',
          'invitation_deadline': '2025-05-15 23:59:59',
        },
      ];

      // Lambda → proxy envelope  { body:  "[ ... ]" }
      final envelope = jsonEncode({'body': jsonEncode(listJson)});

      final admin = AdminServices(
        client: MockClient(
              (req) async => http.Response.bytes(
            utf8.encode(envelope),
            200,
            headers: {
              'content-type': 'application/json; charset=utf-8',
            },
          ),
        ),
        notifications: _StubNotifications(),
      );

      final result = await admin.fetchClubsInvitationsStatus();

      expect(result, isA<List<ClubInvitation>>());
      expect(result.length, 2);
      expect(result.first.clubName, 'CSM București');
      expect(result.first.invitationStatus, 'Confirmed');
      expect(result.first.city, 'București');
    });

    test('HTTP 500 ⇒ aruncă Exception', () async {
      final admin = AdminServices(
        client: MockClient(
              (req) async => http.Response('server error', 500),
        ),
        notifications: _StubNotifications(),
      );

      expectLater(
        admin.fetchClubsInvitationsStatus(),
        throwsA(isA<Exception>()),
      );
    });
  });
}
