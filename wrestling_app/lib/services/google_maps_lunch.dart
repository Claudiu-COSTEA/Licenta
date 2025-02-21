import 'package:url_launcher/url_launcher.dart';

void openGoogleMaps(String locationString) {
  // Extract latitude and longitude using RegExp
  final RegExp regex = RegExp(r'Lat:\s*(-?\d+\.\d+)\s+Lon:\s*(-?\d+\.\d+)');
  final match = regex.firstMatch(locationString);

  if (match != null) {
    final String latitude = match.group(1)!;
    final String longitude = match.group(2)!;

    // Construct the Google Maps URL
    final Uri googleMapsUrl = Uri.parse("https://www.google.com/maps/search/?api=1&query=$latitude,$longitude");

    // Open Google Maps
    launchUrl(googleMapsUrl, mode: LaunchMode.externalApplication);
  } else {
    print("Invalid location format.");
  }
}
