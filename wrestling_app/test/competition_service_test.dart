

import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:wrestling_app/services/admin_apis_services.dart';
import 'package:wrestling_app/services/notifications_services.dart';
import 'package:wrestling_app/services/constants.dart';

import 'competition_service_test.mocks.dart';

@GenerateMocks([http.Client, NotificationsServices])


void main() {
  group('AdminServices.addCompetition', () {
    late MockClient mockClient;
    late AdminServices adminServices;

    setUp(() {
      mockClient = MockClient();
      adminServices = AdminServices(
        client: mockClient,
        notifications: _StubNotifications(),
      );
    });

    test('returnează succes când serverul răspunde cu status 200', () async {
      final responseBody = jsonEncode({
        'body': jsonEncode({'message': 'Competition added successfully'}),
      });

      when(mockClient.post(
        Uri.parse('${AppConstants.baseUrl}admin/addCompetition'),
        headers: {'Content-Type': 'application/json'},
        body: anyNamed('body'),
      )).thenAnswer((_) async => http.Response(responseBody, 200));

      final result = await adminServices.addCompetition(
        name: 'Demo',
        startDate: '2025-06-01 10:00:00',
        endDate: '2025-06-02 18:00:00',
        location: 'Cluj',
      );

      expect(result.success, isTrue);
      expect(result.message, 'Competition added successfully');
    });

    test('returnează eșec când serverul răspunde cu status diferit de 200', () async {
      when(mockClient.post(
        Uri.parse('${AppConstants.baseUrl}admin/addCompetition'),
        headers: {'Content-Type': 'application/json'},
        body: anyNamed('body'),
      )).thenAnswer((_) async => http.Response('Internal Server Error', 500));

      final result = await adminServices.addCompetition(
        name: 'Demo',
        startDate: '2025-06-01 10:00:00',
        endDate: '2025-06-02 18:00:00',
        location: 'Cluj',
      );

      expect(result.success, isFalse);
      expect(result.message, 'HTTP 500');
    });

    test('returnează eșec când apare o excepție (ex: problemă de rețea)', () async {
      when(mockClient.post(
        Uri.parse('${AppConstants.baseUrl}admin/addCompetition'),
        headers: {'Content-Type': 'application/json'},
        body: anyNamed('body'),
      )).thenThrow(Exception('Network error'));

      final result = await adminServices.addCompetition(
        name: 'Demo',
        startDate: '2025-06-01 10:00:00',
        endDate: '2025-06-02 18:00:00',
        location: 'Cluj',
      );

      expect(result.success, isFalse);
      expect(result.message, contains('Exception'));
    });
  });
}

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
