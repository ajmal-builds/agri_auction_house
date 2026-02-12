import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapViewPage extends StatelessWidget {
  final double lat;
  final double lng;

  const MapViewPage({
    super.key,
    required this.lat,
    required this.lng,
  });

  @override
  Widget build(BuildContext context) {
    final LatLng position = LatLng(lat, lng);

    return Scaffold(
      appBar: AppBar(title: const Text("Seller Location")),
      body: GoogleMap(
        initialCameraPosition: CameraPosition(
          target: position,
          zoom: 14,
        ),
        markers: {
          Marker(
            markerId: const MarkerId("seller"),
            position: position,
          ),
        },
      ),
    );
  }
}
