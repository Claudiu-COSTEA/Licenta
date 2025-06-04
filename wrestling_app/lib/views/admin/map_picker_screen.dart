import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;

const kGoogleApiKey = 'AIzaSyBbbpq-P9vhkUpzvreBoGC4bONPf561gr4';
const kPrimaryRed   = Color(0xFFB4182D);

class MapPickerScreen extends StatefulWidget {
  const MapPickerScreen({super.key});
  @override State<MapPickerScreen> createState() => _MapPickerScreenState();
}

class _MapPickerScreenState extends State<MapPickerScreen> {
  final _searchCtrl = TextEditingController();
  GoogleMapController? _mapCtrl;
  LatLng? _picked;
  List<_PlaceSuggestion> _suggestions = [];

  // ======== GOOGLE PLACES AUTOCOMPLETE =============
  Future<void> _search(String input) async {
    if (input.length < 3) {                      // nu spama API-ul
      setState(() => _suggestions = []);
      return;
    }
    final url = Uri.https(
      'maps.googleapis.com',
      '/maps/api/place/autocomplete/json',
      {
        'input'        : input,
        'key'          : kGoogleApiKey,
        'components'   : 'country:ro',           // doar România
        'language'     : 'ro'
      },
    );

    final resp = await http.get(url);
    if (resp.statusCode != 200) return;

    final data = jsonDecode(resp.body);
    if (data['status'] != 'OK') return;

    setState(() {
      _suggestions = (data['predictions'] as List)
          .map((p) => _PlaceSuggestion(
        desc   : p['description'],
        placeId: p['place_id'],
      ))
          .toList();
    });
  }

  // ======== PLACE DETAILS (lat/lng) =============
  Future<void> _selectSuggestion(_PlaceSuggestion s) async {
    setState(() => _suggestions = []);
    final url = Uri.https(
      'maps.googleapis.com',
      '/maps/api/place/details/json',
      {
        'place_id': s.placeId,
        'key'     : kGoogleApiKey,
        'fields'  : 'geometry'
      },
    );
    final resp = await http.get(url);
    if (resp.statusCode != 200) return;

    final data = jsonDecode(resp.body);
    if (data['status'] != 'OK') return;
    final loc = data['result']['geometry']['location'];
    final latLng = LatLng(
      (loc['lat'] as num).toDouble(),
      (loc['lng'] as num).toDouble(),
    );

    _mapCtrl?.animateCamera(CameraUpdate.newLatLng(latLng));
    setState(() => _picked = latLng);
  }

  // =================================================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _buildRedAppBar(context),
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: const CameraPosition(
              target: LatLng(44.4268, 26.1025),
              zoom  : 14,
            ),
            onMapCreated: (c) => _mapCtrl = c,
            onTap: (pos) => setState(() => _picked = pos),
            markers: _picked == null
                ? {}
                : {Marker(markerId: const MarkerId('sel'), position: _picked!)},
          ),
          if (_suggestions.isNotEmpty) _buildOverlaySuggestions(),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed:
        _picked == null ? null : () => Navigator.pop(context, _picked),
        backgroundColor: kPrimaryRed,
        child: const Icon(Icons.check, color: Colors.white),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.startFloat,
    );
  }

  PreferredSizeWidget _buildRedAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: kPrimaryRed,
      automaticallyImplyLeading: false,
      titleSpacing: 0,
      title: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.pop(context),
            splashRadius: 24,
          ),
          Expanded(
            child: TextField(
              controller: _searchCtrl,
              onChanged: _search,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Caută o locație',
                hintStyle: const TextStyle(color: Colors.white70),
                border: InputBorder.none,
                contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                suffixIcon:
                _searchCtrl.text.isEmpty
                    ? null
                    : IconButton(
                  icon: const Icon(Icons.clear, color: Colors.white),
                  onPressed: () {
                    _searchCtrl.clear();
                    setState(() => _suggestions = []);
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOverlaySuggestions() {
    // înălţimea barei de stare (notch) + AppBar
    final double topOffset =
        MediaQuery.of(context).padding.top + kToolbarHeight + 4;

    final maxH = MediaQuery.of(context).size.height * .45;

    return Positioned(// ⇦ mai sus decât înainte
      left: 16,
      right: 16,
      child: Material(
        elevation: 6,
        borderRadius: BorderRadius.circular(8),
        child: ConstrainedBox(
          constraints: BoxConstraints(maxHeight: maxH),
          child: ListView.separated(
            padding: EdgeInsets.zero,
            shrinkWrap: true,
            itemCount: _suggestions.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (_, i) {
              final s = _suggestions[i];
              return ListTile(
                dense: true,
                title: Text(
                  s.desc,
                  style: const TextStyle(fontSize: 14),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                onTap: () => _selectSuggestion(s),
              );
            },
          ),
        ),
      ),
    );
  }
}

// ======== helper small class =========
class _PlaceSuggestion {
  final String desc;
  final String placeId;
  _PlaceSuggestion({required this.desc, required this.placeId});
}
