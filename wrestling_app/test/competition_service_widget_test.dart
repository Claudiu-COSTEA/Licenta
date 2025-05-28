import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/testing.dart';
import 'package:http/http.dart' as http;
import 'package:wrestling_app/services/admin_apis_services.dart';
import 'package:wrestling_app/services/notifications_services.dart';

class _StubNotifications implements NotificationsServices {
  @override
  Future<String> getAccessToken() async => '';

  @override
  Future<void> initializeNotifications() async {}

  @override
  Future<String?> getUserFCMToken(int _) async => null;

  @override
  Future<void> saveTokenToServer(int userId, {String? token}) async {}

  @override
  Future<void> sendFCMMessage(
      String token, {
        String? title,
        String? body,
      }) async {}

  @override
  Future<void> storeFcmToken(int userId, String token) async {}
}

class _Harness extends StatelessWidget {
  const _Harness({required this.service});
  final AdminServices service;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Center(
          child: Builder(
            builder: (ctx) => ElevatedButton(
              key: const Key('invoke'),
              onPressed: () async {
                final res = await service.addCompetition(
                  name: 'Demo',
                  startDate: '2025-06-01 10:00:00',
                  endDate: '2025-06-02 18:00:00',
                  location: 'Cluj',
                );

                ScaffoldMessenger.of(ctx).showSnackBar(
                  SnackBar(
                    content: Text(res.message ??
                        (res.success
                            ? 'Competition added successfully!'
                            : 'Failed to add competition.')),
                    backgroundColor:
                    res.success ? Colors.green : Colors.red,
                  ),
                );
              },
              child: const Text('CALL'),
            ),
          ),
        ),
      ),
    );
  }
}

void main() {
  group('AdminServices.addCompetition (refactor)', () {
    testWidgets('HTTP 200 => SnackBar verde', (tester) async {
      // răspuns fake al Lambda-ului
      final okJson = jsonEncode({
        'body': jsonEncode({'message': 'Competition added successfully'})
      });

      // injectăm MockClient + StubNotifications
      final admin = AdminServices(
        client: MockClient((req) async => http.Response(okJson, 200)),
        notifications: _StubNotifications(),
      );

      await tester.pumpWidget(_Harness(service: admin));
      await tester.tap(find.byKey(const Key('invoke')));
      await tester.pumpAndSettle();

      // SnackBar ar trebui să fie verde
      final snackBar = tester.widget<SnackBar>(find.byType(SnackBar));
      expect(snackBar.backgroundColor, Colors.green);
    });

    testWidgets('HTTP 500 => SnackBar roşu', (tester) async {
      final admin = AdminServices(
        client: MockClient((req) async => http.Response('err', 500)),
        notifications: _StubNotifications(),
      );

      await tester.pumpWidget(_Harness(service: admin));
      await tester.tap(find.byKey(const Key('invoke')));
      await tester.pumpAndSettle();

      final snackBar = tester.widget<SnackBar>(find.byType(SnackBar));
      expect(snackBar.backgroundColor, Colors.red);
    });
  });
}
