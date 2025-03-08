import 'package:flutter/material.dart';
import 'package:wrestling_app/services/camera_services.dart';

class CameraOpen extends StatelessWidget {
  const CameraOpen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("QR Code Scanner")),
      body: Center(
        child: IconButton(
          icon: Icon(Icons.qr_code_scanner, size: 50, color: Colors.blue),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => QRScannerScreen()),
            );
          },
        ),
      ),
    );
  }
}
