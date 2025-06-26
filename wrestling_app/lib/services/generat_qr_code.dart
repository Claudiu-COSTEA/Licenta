

import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

Widget generateQRCode(String url, {double size = 200.0}) {
  return QrImageView(
    data: url,
    version: QrVersions.auto,
    size: size,
  );
}

