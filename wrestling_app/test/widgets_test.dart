// test/google_map_widget_test.dart

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';


class TestMapScreen extends StatefulWidget {
  const TestMapScreen({Key? key}) : super(key: key);

  @override
  State<TestMapScreen> createState() => _TestMapScreenState();
}

class _TestMapScreenState extends State<TestMapScreen> {
  late GoogleMapController _mapCtrl;
  LatLng? _picked;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: GoogleMap(
          initialCameraPosition: const CameraPosition(
            target: LatLng(44.4268, 26.1025),
            zoom: 14,
          ),
          onMapCreated: (c) => _mapCtrl = c,
          onTap: (pos) => setState(() => _picked = pos),
          markers: _picked == null
              ? {}
              : {Marker(markerId: const MarkerId('sel'), position: _picked!)},
        ),
      ),
    );
  }
}

void main() {
  testWidgets('GoogleMap is inserted into the tree', (WidgetTester tester) async {

    await tester.pumpWidget(const TestMapScreen());

    await tester.pumpAndSettle();

    expect(find.byType(GoogleMap), findsOneWidget);
  });
}
