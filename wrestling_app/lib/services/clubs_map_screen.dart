import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import 'package:wrestling_app/models/wrestling_club_model.dart';

class ClubsMapScreen extends StatefulWidget {
  const ClubsMapScreen({Key? key}) : super(key: key);

  @override
  State<ClubsMapScreen> createState() => _ClubsMapScreenState();
}

class _ClubsMapScreenState extends State<ClubsMapScreen> {
  final Completer<GoogleMapController> _ctrl = Completer();
  final Set<Marker> _markers = {};
  WrestlingClub? _selectedClub;
  bool _loading = true;
  static const _romaniaCenter = LatLng(45.9432, 24.9668);

  @override
  void initState() {
    super.initState();
    _loadClubs();
  }

  // ... fetchClubs(), _loadClubs(), _createBounds() rămân neschimbate ...

  Future<void> _openInGoogleMaps(WrestlingClub club) async {
    final lat = club.latitude;
    final lng = club.longitude;
    final label = Uri.encodeComponent(club.city);
    final uri = Uri.parse('geo:$lat,$lng?q=$lat,$lng($label)');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Nu pot deschide Google Maps')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFB4182D),
        iconTheme: const IconThemeData(color: Colors.white),  // ← aici!
      ),

      body: Stack(
        children: [
          _loading
              ? const Center(child: CircularProgressIndicator())
              : GoogleMap(
            initialCameraPosition:
            const CameraPosition(target: _romaniaCenter, zoom: 6),
            markers: _markers,
            onMapCreated: (ctrl) => _ctrl.complete(ctrl),
          ),

          // Buton care apare doar după tap pe marker
          if (_selectedClub != null)
            Positioned(
              bottom: 20,
              left: 16,
              right: 16,
              child: ElevatedButton.icon(
                onPressed: () => _openInGoogleMaps(_selectedClub!),
                icon: const Icon(Icons.map, color: Colors.white,),
                label: const Text('Deschide în Google Maps', style: TextStyle(color: Colors.white),),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFB4182D),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),
        ],
      ),
    );
  }

  // În _loadClubs(), atunci când creezi marker-ele, adaugă onTap:
  Future<void> _loadClubs() async {
    final clubs = await fetchClubs();
    final markers = clubs.map((club) {
      return Marker(
        markerId: MarkerId(club.uuid.toString()),
        position: LatLng(club.latitude, club.longitude),
        infoWindow: InfoWindow(
            title: club.clubName,                                   // numele clubului
            snippet: 'Lat: ${club.latitude}, Lng: ${club.longitude}' // coordonatele
        ),
        onTap: () => setState(() => _selectedClub = club),
      );
    }).toSet();

    setState(() {
      _markers.addAll(markers);
      _loading = false;
    });
    // … restul codului de centrare a hărții …
  }

  Future<List<WrestlingClub>> fetchClubs() async {
    final res = await http.get(Uri.parse(
        'https://rhybb6zgsb.execute-api.us-east-1.amazonaws.com/wrestling/getWrestlingClubsLocations'
    ));

    if (res.statusCode != 200) {
      throw Exception('Failed to load clubs (${res.statusCode})');
    }

    // 1) Decode the raw body bytes as UTF-8:
    final decodedEnvelope = jsonDecode(utf8.decode(res.bodyBytes))
    as Map<String, dynamic>;

    // 2) Extract the inner `body`, which is itself a JSON-string:
    final bodyString = decodedEnvelope['body'] as String;

    // 3) Decode that string again as UTF-8 bytes (to preserve diacritics):
    final fixedBodyJson = utf8.decode(utf8.encode(bodyString));

    // 4) Parse into a Dart List:
    final List<dynamic> list = jsonDecode(fixedBodyJson) as List<dynamic>;

    // 5) Map into your model:
    return list
        .map((e) => WrestlingClub.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}
