// test/services_http_test.dart
import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/testing.dart';
import 'package:http/http.dart' as http;

import 'package:wrestling_app/services/referee_api_services.dart';
import 'package:wrestling_app/models/wrestler_verification_model.dart';

void main() {
  group('RefereeServices HTTP-only', () {
    test('fetchWrestlers → mapare corectă', () async {
      // 2 exemple de luptători conform modelului real
      final wrestlers = [
        {
          "wrestler_UUID": 10,
          "wrestler_name": "Vlad Popa",
          "wrestling_style": "Greco Roman",
          "weight_category": "72",
          "coach_UUID": 19,
          "coach_name": "Radu Moldovan",
          "wrestling_club_UUID": 28,
          "wrestling_club_name": "CSM București",
          "competition_UUID": 1,
          "competition_name": "Cupa Primaverii",
          "invitation_status": "Confirmed",
          "referee_verification": "Confirmed",
        },
        {
          "wrestler_UUID": 11,
          "wrestler_name": "Ionel Marin",
          "wrestling_style": "Greco Roman",
          "weight_category": "72",
          "coach_UUID": 20,
          "coach_name": "Constantin Petrescu",
          "wrestling_club_UUID": 29,
          "wrestling_club_name": "CS Rapid Cluj",
          "competition_UUID": 1,
          "competition_name": "Cupa Primaverii",
          "invitation_status": "Confirmed",
          "referee_verification": "Confirmed",
        },
      ];

      // Envelope exact ca din API: 'body' e o listă, nu un string
      final envelope = json.encode({
        'statusCode': 200,
        'body': wrestlers,
      });

      final svc = RefereeServices(
        client: MockClient((_) async =>
            http.Response(envelope, 200, headers: {
              'content-type': 'application/json; charset=utf-8'
            })
        ),
      );

      final list = await svc.fetchWrestlers('Greco Roman', '72', 1);

      expect(list, isA<List<WrestlerVerification>>());
      expect(list.length, 2);

      final first = list.first;
      expect(first.wrestlerUUID, 10);
      expect(first.wrestlerName, 'Vlad Popa');
      expect(first.wrestlingStyle, 'Greco Roman');
      expect(first.weightCategory, '72');
      expect(first.coachName, 'Radu Moldovan');
      expect(first.wrestlingClubName, 'CSM București');
      expect(first.invitationStatus, 'Confirmed');
      expect(first.refereeVerification, 'Confirmed');
    });

    test('fetchWeightCategories → mapare corectă', () async {
      final cats = [
        {'wrestling_style': 'Greco Roman', 'weight_category': '72'},
        {'wrestling_style': 'Greco Roman', 'weight_category': '77'},
      ];

      // Envelope cu body = listă direct
      final envelope = json.encode({
        'statusCode': 200,
        'body': cats,
      });

      final svc = RefereeServices(
        client: MockClient((_) async =>
            http.Response(envelope, 200, headers: {
              'content-type': 'application/json; charset=utf-8'
            })
        ),
      );

      final list = await svc.fetchWeightCategories(1);

      expect(list.length, 2);
      expect(list[0].weightCategory, '72');
      expect(list[1].weightCategory, '77');
    });

    test('updateRefereeVerification → true la success', () async {
      final envelope = json.encode({
        'statusCode': 200,
        'body': {'success': true},
      });

      final svc = RefereeServices(
        client: MockClient((_) async =>
            http.Response(envelope, 200, headers: {
              'content-type': 'application/json; charset=utf-8'
            })
        ),
      );

      final ok = await svc.updateRefereeVerification(
        competitionUUID: 1,
        recipientUUID: 2,
        recipientRole: 'Wrestler',
        refereeVerification: 'Confirmed',
      );
      expect(ok, isTrue);
    });

    test('updateRefereeVerification → false la HTTP 500', () async {
      final svc = RefereeServices(
        client: MockClient((_) async => http.Response('err', 500)),
      );

      final ok = await svc.updateRefereeVerification(
        competitionUUID: 1,
        recipientUUID: 2,
        recipientRole: 'Wrestler',
        refereeVerification: 'Confirmed',
      );
      expect(ok, isFalse);
    });
  });
}
