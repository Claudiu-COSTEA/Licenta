import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

class QRCodeScreen extends StatelessWidget {
  final String url = "https://pub.dev/packages/url_launcher/install";

  const QRCodeScreen({super.key}); // Replace with your URL

  Widget generateQRCode(String url, {double size = 200.0}) {
    return QrImageView(
      data: url,
      version: QrVersions.auto,
      size: size,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("QR Code Generator")),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Center(child: generateQRCode(url)), // Calling the function
          SizedBox(height: 20),
          Text(
            "Scan this QR Code",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
