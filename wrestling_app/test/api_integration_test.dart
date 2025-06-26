
import 'dart:convert';
import 'package:test/test.dart';
import 'package:http/http.dart' as http;

void main() {
  // URL-ul de bază către API-ul tău de staging / test
  const baseUrl = 'https://b0i2d55s30.execute-api.us-east-1.amazonaws.com/wrestling/';

  group('API Integration Tests', () {

    test('GET getUserFcmToken – user 18', () async {
      final uri = Uri.parse('${baseUrl}getUserFcmToken?user_UUID=18');
      final response = await http.get(uri);

      expect(response.statusCode, 200);

      final decoded = json.decode(response.body) as Map<String, dynamic>;
      // „body” vine deja ca obiect JSON
      final body = decoded['body'] as Map<String, dynamic>;
      expect(body.containsKey('fcm_token'), isTrue);
      expect((body['fcm_token'] as String).isNotEmpty, isTrue);
    });

    test('POST storeFcmToken – store and retrieve', () async {
      final storeUri = Uri.parse('${baseUrl}storeFcmToken');
      final token = 'dummyTokenForTest';
      final storeResponse = await http.post(
        storeUri,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'user_UUID': 999,
          'fcm_token': token,
        }),
      );

      expect(storeResponse.statusCode, anyOf([200, 201]));

      // acum citim înapoi cu GET
      final getUri = Uri.parse('${baseUrl}getUserFcmToken?user_UUID=999');
      final getResponse = await http.get(getUri);

      expect(getResponse.statusCode, 200);
      final getDecoded = json.decode(getResponse.body) as Map<String, dynamic>;
      final getBody = getDecoded['body'] as Map<String, dynamic>;
      expect(getBody['fcm_token'], equals(token));
    });

    test('POST addCompetition – create new comp', () async {
      final uri = Uri.parse('${baseUrl}admin/addCompetition');
      final now = DateTime.now();
      final res = await http.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'competition_name': 'Test ${now.toIso8601String()}',
          'competition_start_date': '2025-07-01 10:00:00',
          'competition_end_date': '2025-07-01 18:00:00',
          'competition_location': 'Testville',
        }),
      );

      expect(res.statusCode, 200);
      final decoded = json.decode(res.body) as Map<String, dynamic>;
      final body = decoded['body'] as Map<String, dynamic>;
      expect(body['message'], isNotNull);
    });


  });
}
