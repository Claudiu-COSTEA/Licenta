import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

class QRCodeScreen extends StatelessWidget {
  final String? url;

  const QRCodeScreen({super.key, required this.url}); // Replace with your URL

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
      appBar: AppBar(),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Center(child: generateQRCode(url!)), // Calling the function
          SizedBox(height: 20),
          Text(
            "Scaneaza aici pentru documentele medicale",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
