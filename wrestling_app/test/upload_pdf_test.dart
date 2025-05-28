// test/upload_pdf_test.dart
import 'dart:convert';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/testing.dart';
import 'package:http/http.dart' as http;

import 'package:wrestling_app/services/admin_apis_services.dart';
import 'package:wrestling_app/services/notifications_services.dart';

/// ───────────────── Stub Notifications (fără Firebase) ─────────────────
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

/// PDF dummy utilitar
PlatformFile _fakePdf(String name) => PlatformFile(
  name: name,
  size: 4,
  path: '/tmp/$name',
);

/// Client care răspunde la PUT (S3) urmat de POST (DB)
MockClient _twoStepClient({required int putStatus, required int postStatus}) {
  var call = 0;
  return MockClient((req) async {
    if (call == 0) {
      expect(req.method, 'PUT');
      call++;
      return http.Response.bytes([], putStatus);
    } else {
      expect(req.method, 'POST');
      return http.Response('{}', postStatus);
    }
  });
}

void main() {
  group('AdminServices._pickAndUploadPdf', () {
    test('caz fericit → uploaded', () async {
      final admin = AdminServices(
        client: _twoStepClient(putStatus: 200, postStatus: 200),
        pickPdf: () async => _fakePdf('11_Alex.pdf'),
        readBytes: (_) async => [0x25, 0x50, 0x44, 0x46], // “%PDF”
        notifications: _StubNotifications(),
      );

      final res = await admin.pickAndUploadLicensePdf();
      expect(res.success, isTrue);
      expect(res.message, 'uploaded');
    });

    test('user cancel → cancelled', () async {
      final admin = AdminServices(
        client: MockClient((_) async => throw 'should not be called'),
        pickPdf: () async => null,
        readBytes: (_) async => [],
        notifications: _StubNotifications(),
      );

      final res = await admin.pickAndUploadMedicalPdf();
      expect(res.success, isFalse);
      expect(res.message, 'cancelled');
    });

    test('invalid filename → mesaj eroare', () async {
      final admin = AdminServices(
        client: MockClient((_) async => throw 'should not be called'),
        pickPdf: () async => _fakePdf('Alex.pdf'), // fără UUID numeric
        readBytes: (_) async => [],
        notifications: _StubNotifications(),
      );

      final res = await admin.pickAndUploadLicensePdf();
      expect(res.success, isFalse);
      expect(res.message, 'Invalid UUID prefix');
    });

    test('upload S3 500 → S3 HTTP 500', () async {
      final admin = AdminServices(
        client: _twoStepClient(putStatus: 500, postStatus: 200),
        pickPdf: () async => _fakePdf('11_Alex.pdf'),
        readBytes: (_) async => [1, 2, 3],
        notifications: _StubNotifications(),
      );

      final res = await admin.pickAndUploadLicensePdf();
      expect(res.success, isFalse);
      expect(res.message, 'S3 HTTP 500');
    });

    test('DB update 500 → db-error', () async {
      final admin = AdminServices(
        client: _twoStepClient(putStatus: 200, postStatus: 500),
        pickPdf: () async => _fakePdf('11_Alex.pdf'),
        readBytes: (_) async => [1],
        notifications: _StubNotifications(),
      );

      final res = await admin.pickAndUploadMedicalPdf();
      expect(res.success, isFalse);
      expect(res.message, 'db-error');
    });
  });
}
