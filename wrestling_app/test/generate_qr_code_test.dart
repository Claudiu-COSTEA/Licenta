import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qr_flutter/qr_flutter.dart';

void main() {
  testWidgets('QR code is generated and rendered properly', (WidgetTester tester) async {
    // Define the test URL
    const String testUrl = 'https://example.com';
    const double testSize = 250.0;

    // Create the widget using MaterialApp (for testing)
    Widget qrWidget = MaterialApp(
      home: Scaffold(
        body: generateQRCode(testUrl, size: testSize),
      ),
    );

    // Pump the widget into the widget tree
    await tester.pumpWidget(qrWidget);

    // Verify if QrImageView is present
    expect(find.byType(QrImageView), findsOneWidget);

    // Find the QrImageView widget by key
    final qrImage = tester.widget<QrImageView>(find.byType(QrImageView));

    // Verify the widget size
    expect(qrImage.size, testSize);
  });
}

// The function to generate the QR code widget
Widget generateQRCode(String url, {double size = 200.0}) {
  return QrImageView(
    key: Key('qr_image_view'), // Assign a key for identification
    data: url,
    version: QrVersions.auto,
    size: size,
  );
}
