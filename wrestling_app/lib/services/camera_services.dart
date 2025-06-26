import 'package:flutter/material.dart';
import 'package:qr_code_scanner_plus/qr_code_scanner_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../views/shared/widgets/toast_helper.dart';

class QRScannerScreen extends StatefulWidget {
  @override
  _QRScannerScreenState createState() => _QRScannerScreenState();
}

class _QRScannerScreenState extends State<QRScannerScreen> {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');

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
     ToastHelper.eroare("Nu s-a putut deschide link-ul");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Scanează codul QR"),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      body: Column(
        children: [
          // QR Scanner View

          Expanded(
            flex: 5,
            child: QRView(
              key: qrKey,
              onQRViewCreated: _onQRViewCreated,
            ),
          ),

          // Ensure scrollability for buttons after scanning
          Expanded(
            flex: 2, // Increased flex to allow space for buttons
            child: SingleChildScrollView(
              child: Center(
                child: scannedData != null
                    ? Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("Informație scanată:", style: TextStyle(fontSize: 14)),
                    const SizedBox(height: 5),
                    Text(
                      scannedData!,
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.blue),
                      textAlign: TextAlign.center, // Prevent text overflow
                    ),
                    const SizedBox(height: 10),

                    // Open Link Button
                    ElevatedButton(
                      onPressed: () => _launchURL(scannedData!),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFFB4182D),  // Custom button color
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      ),
                      child: const Text("Deschide link",  style: TextStyle(color: Colors.white)),
                    ),

                    const SizedBox(height: 10),

                    // Scan Again Button
                    ElevatedButton(
                      onPressed: () => controller?.resumeCamera(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFFB4182D), // Custom button color
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      ),
                      child: const Text("Scanează din nou", style: TextStyle(color: Colors.white),),
                    ),
                  ],
                )
                    : const Text("Scanează codul QR"),
              ),
            ),
          ),
        ],
      ),
    );
  }

  QRViewController? controller;

  void _onQRViewCreated(QRViewController controller) {
    this.controller = controller;
    controller.scannedDataStream.listen((scanData) {
      setState(() {
        scannedData = scanData.code;
      });
      controller.pauseCamera();
    });
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }
}
