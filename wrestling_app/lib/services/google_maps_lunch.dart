import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

/// Deschide Google Maps la coordonatele extrase dintr-un șir de forma
/// "44.4055975, 26.1421272" (sau fără spațiu după virgulă: "44.4055975,26.1421272").
Future<void> openGoogleMaps(BuildContext context, String locationString) async {
  // Regex care găsește două numere zecimale separate de virgulă,
  // indiferent dacă există sau nu spațiu după virgulă.
  final regex = RegExp(r'(-?\d+\.\d+)\s*,\s*(-?\d+\.\d+)');
  final match = regex.firstMatch(locationString.trim());

  if (match != null) {
    final latitude = match.group(1)!;
    final longitude = match.group(2)!;

    // Construim URL-ul pentru Google Maps
    final googleMapsUrl = Uri.parse(
      "https://www.google.com/maps/search/?api=1&query=$latitude,$longitude",
    );

    if (await canLaunchUrl(googleMapsUrl)) {
      await launchUrl(googleMapsUrl, mode: LaunchMode.externalApplication);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Nu pot deschide Google Maps")),
      );
    }
  } else {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          "Format locație invalid.\nSe așteaptă: 'latitudine, longitudine'\nEx: 44.4055975, 26.1421272",
        ),
      ),
    );
  }
}
