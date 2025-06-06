import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:wrestling_app/views/shared/widgets/toast_helper.dart';

/// Ce tip de document afișăm?
enum DocType { medical, sportive }

class QRCodeScreen extends StatelessWidget {
  final String url;
  final DocType docType;

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

  /// Mesajul care se afișează sub codul QR
  String get _scanMessage {
    switch (docType) {
      case DocType.medical:
        return 'Scanează aici pentru documentul medical';
      case DocType.sportive:
        return 'Scanează aici pentru documentul sportiv';
    }
  }

  /// Încearcă să deschidă URL-ul în browser/external app
  Future<void> _launchDocument(BuildContext context) async {
    final uri = Uri.tryParse(url);
    if (uri == null) {
      ToastHelper.eroare("URL invalid !");
      return;
    }
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      ToastHelper.eroare("Documentul nu poste fi deschis !");
    }
  }

  @override
  Widget build(BuildContext context) {
    // Culoarea roșie folosită peste tot în aplicație
    const primaryRed = Color(0xFFB4182D);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      backgroundColor: Colors.white,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Codul QR centrat
          Center(child: generateQRCode(url, size: 220)),
          const SizedBox(height: 20),
          // Mesajul de instrucțiuni
          Text(
            _scanMessage,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 30),
          // Buton mai lung
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 80.0),
            child: ElevatedButton.icon(
              onPressed: () => _launchDocument(context),
              icon: const Icon(Icons.open_in_new, color: Colors.white),
              label: const Text(
                'Deschide documentul',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryRed,
                // forțăm lățimea butonului să ocupe tot spațiul disponibil
                minimumSize: const Size.fromHeight(50), // înălțimea
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(50), // colțuri rotunjite
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}