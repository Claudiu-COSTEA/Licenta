import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

/// What kind of document are we showing?
enum DocType { medical, sportive }

class QRCodeScreen extends StatelessWidget {
  final String url;
  final DocType docType;                         // 🆕  parameter

  const QRCodeScreen({
    super.key,
    required this.url,
    required this.docType,
  });

  Widget generateQRCode(String data, {double size = 200}) {
    return QrImageView(
      data: data,
      version: QrVersions.auto,
      size: size,
    );
  }

  /// Pick a message based on the document type
  String get _scanMessage {
    switch (docType) {
      case DocType.medical:
        return 'Scanează aici pentru documentul medical';
      case DocType.sportive:
        return 'Scanează aici pentru documentul sportiv';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Center(child: generateQRCode(url)),
          const SizedBox(height: 20),
          Text(
            _scanMessage,                            // dynamic message
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
      backgroundColor: Colors.white,
    );
  }
}
