import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_places_flutter/google_places_flutter.dart';

class MapPickerScreen extends StatefulWidget {
  const MapPickerScreen({super.key});

  @override
  _MapPickerScreenState createState() => _MapPickerScreenState();
}

class _MapPickerScreenState extends State<MapPickerScreen> {
  LatLng? _selectedLocation;
  final TextEditingController _searchController = TextEditingController();
  late GoogleMapController _mapController;

  void _onMapTapped(LatLng position) {
    setState(() {
      _selectedLocation = position;
    });
  }

  void _confirmLocation() {
    if (_selectedLocation != null) {
      Navigator.pop(context, _selectedLocation);
    }
  }

  void _moveCameraToLocation(LatLng location) {
    _mapController.animateCamera(CameraUpdate.newLatLng(location));
    setState(() {
      _selectedLocation = location;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: const CameraPosition(
              target: LatLng(44.4268, 26.1025), // Default to Bucharest
              zoom: 14,
            ),
            onMapCreated: (controller) => _mapController = controller,
            onTap: _onMapTapped,
            markers: _selectedLocation != null
                ? {
              Marker(
                  markerId: const MarkerId("selected"),
                  position: _selectedLocation!)
            }
                : {},
          ),

          // Search Bar
          Positioned(
            top: 50,
            left: 20,
            right: 20,
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 5,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: GooglePlaceAutoCompleteTextField(
                textEditingController: _searchController,
                googleAPIKey: "AIzaSyBbbpq-P9vhkUpzvreBoGC4bONPf561gr4",
                inputDecoration: const InputDecoration(
                  hintText: "Search for a location",
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.all(10),
                ),
                debounceTime: 800,
                countries: ["ro"], // Optional: Restrict to Romania
                getPlaceDetailWithLatLng: (placeDetail) {
                  //final String? latString = placeDetail.lat;
                  //final String? lngString = placeDetail.lng;

                  // if (latString != null && lngString != null) {
                  //   final double? lat = double.tryParse(latString);
                  //   final double? lng = double.tryParse(lngString);
                  //
                  //   if (lat != null && lng != null) {
                  //     _moveCameraToLocation(LatLng(lat, lng));
                  //   } else {
                  //     ScaffoldMessenger.of(context).showSnackBar(
                  //       const SnackBar(content: Text("Invalid coordinates received.")),
                  //     );
                  //   }
                  // } else {
                  //   ScaffoldMessenger.of(context).showSnackBar(
                  //     const SnackBar(content: Text("Failed to fetch location coordinates.")),
                  //   );
                  // }
                },

              ),
            ),
          ),
        ],
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: _confirmLocation,
        backgroundColor: Colors.red,
        child: const Icon(Icons.check, color: Colors.white),
      ),

      // bottom-left, floating above content
      floatingActionButtonLocation: FloatingActionButtonLocation.startFloat,

    );
  }
}
