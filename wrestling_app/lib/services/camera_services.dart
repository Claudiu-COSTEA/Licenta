import 'package:flutter/material.dart';
import 'package:qr_code_scanner_plus/qr_code_scanner_plus.dart';
import 'package:url_launcher/url_launcher.dart';

class QRScannerScreen extends StatefulWidget {
  @override
  _QRScannerScreenState createState() => _QRScannerScreenState();
}

class _QRScannerScreenState extends State<QRScannerScreen> {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  QRViewController? controller;
  String? scannedData; // Store scanned QR result

  @override
  void reassemble() {
    super.reassemble();
    if (controller != null) {
      controller!.pauseCamera();
      controller!.resumeCamera();
    }
  }

  Future<void> _launchURL(String url) async {
    final Uri uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Could not open the link: $url")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Scan QR Code")),
      body: Column(
        children: [
          Expanded(
            flex: 5,
            child: QRView(
              key: qrKey,
              onQRViewCreated: _onQRViewCreated,
            ),
          ),
          Expanded(
            flex: 1,
            child: Center(
              child: scannedData != null
                  ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("Scanned Data:", style: TextStyle(fontSize: 16)),
                  SizedBox(height: 5),
                  Text(scannedData!,
                      style: TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blue)),
                  SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: () => _launchURL(scannedData!),
                    child: Text("Open Link"),
                  ),
                  ElevatedButton(
                    onPressed: () => controller?.resumeCamera(),
                    child: Text("Scan Again"),
                  ),
                ],
              )
                  : Text("Scan a QR code"),
            ),
          ),
        ],
      ),
    );
  }

  void _onQRViewCreated(QRViewController controller) {
    this.controller = controller;
    controller.scannedDataStream.listen((scanData) {
      setState(() {
        scannedData = scanData.code; // Save scanned data
      });
      controller.pauseCamera(); // Pause after scanning
    });
  }

  @override
  void dispose() {
    controller?.disposed;
    super.dispose();
  }
}
