import 'package:ZipBee_Driver/features/home/model/order_feed_response.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:ZipBee_Driver/core/utils/custom_map_marker_helper.dart';
import 'package:ZipBee_Driver/core/services/osrm_route_service.dart';
import 'package:get/get.dart';
import 'dart:ui' as ui;
import 'dart:typed_data';

class DestinationMapController extends GetxController {
  GoogleMapController? mapController;
  final markers = <Marker>{}.obs;
  final polylines = <Polyline>{}.obs;
  final stopIcons = <int, BitmapDescriptor>{}.obs;
  List<Destination>? _lastDestinations;

  @override
  void onClose() {
    mapController?.dispose();
    super.onClose();
  }

  void updateDestinations(List<Destination> destinations) {
    if (_lastDestinations != null && _areListsEqual(_lastDestinations!, destinations)) {
      return;
    }
    _lastDestinations = destinations;
    _generateStopIcons(destinations);
    _initializePolylines(destinations);
    _fitMapToMarkers();
  }

  bool _areListsEqual(List<Destination> a, List<Destination> b) {
    if (a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
      if (a[i].latitude != b[i].latitude ||
          a[i].longitude != b[i].longitude ||
          a[i].address != b[i].address) {
        return false;
      }
    }
    return true;
  }

  Future<void> _generateStopIcons(List<Destination> destinations) async {
    final totalDrops = destinations.length > 1 ? destinations.length - 1 : 0;
    final showNumbers = totalDrops > 1;
    final icons = <int, BitmapDescriptor>{};
    int dropCount = 0;

    for (var i = 0; i < destinations.length; i++) {
      final isPickup = i == 0;
      BitmapDescriptor icon;
      if (isPickup) {
        icon = await CustomMapMarkerHelper.getPickupMarker();
      } else {
        dropCount++;
        if (showNumbers) {
          icon = await CustomMapMarkerHelper.getNumberedDropMarker(number: dropCount);
        } else {
          icon = await CustomMapMarkerHelper.getDropMarker();
        }
      }
      icons[i] = icon;
    }
    stopIcons.assignAll(icons);
    _initializeMarkers(destinations);
  }

  void _initializeMarkers(List<Destination> destinations) {
    markers.clear();
    int dropCount = 0;
    for (int i = 0; i < destinations.length; i++) {
      final destination = destinations[i];
      try {
        final lat = double.parse(destination.latitude);
        final lng = double.parse(destination.longitude);

        if (stopIcons.containsKey(i)) {
          final isPickup = i == 0;
          final icon = stopIcons[i]!;

          String title;
          if (isPickup) {
            title = 'Pickup';
          } else {
            dropCount++;
            title = 'Drop Number $dropCount';
          }

          markers.add(
            Marker(
              markerId: MarkerId('destination_${i}_custom_${icon.hashCode}'),
              position: LatLng(lat, lng),
              anchor: CustomMapMarkerHelper.defaultAnchor,
              infoWindow: InfoWindow(
                title: title,
                snippet: destination.address,
              ),
              icon: icon,
            ),
          );
        }
      } catch (e) {
        debugPrint('Error parsing destination coordinates: $e');
      }
    }
  }

  Future<void> _initializePolylines(List<Destination> destinations) async {
    polylines.clear();
    if (destinations.length < 2) {
      return;
    }

    try {
      final waypoints = <LatLng>[];
      for (final destination in destinations) {
        final lat = double.parse(destination.latitude);
        final lng = double.parse(destination.longitude);
        waypoints.add(LatLng(lat, lng));
      }

      if (waypoints.length >= 2) {
        final points = await OsrmRouteService.getRoutePoints(waypoints);
        polylines.add(
          Polyline(
            polylineId: const PolylineId('route'),
            points: points,
            color: const Color(0xFF1565C0), // Blue path
            width: 5,
            geodesic: true,
          ),
        );
      }
    } catch (e) {
      debugPrint('Error creating polyline: $e');
    }
  }

  Future<void> _fitMapToMarkers() async {
    if (markers.isEmpty || mapController == null) return;

    try {
      double minLat = double.infinity;
      double maxLat = -double.infinity;
      double minLng = double.infinity;
      double maxLng = -double.infinity;

      for (final marker in markers) {
        minLat = minLat > marker.position.latitude ? marker.position.latitude : minLat;
        maxLat = maxLat < marker.position.latitude ? marker.position.latitude : maxLat;
        minLng = minLng > marker.position.longitude ? marker.position.longitude : minLng;
        maxLng = maxLng < marker.position.longitude ? marker.position.longitude : maxLng;
      }

      final bounds = LatLngBounds(
        southwest: LatLng(minLat, minLng),
        northeast: LatLng(maxLat, maxLng),
      );

      await mapController!.animateCamera(
        CameraUpdate.newLatLngBounds(bounds, 100),
      );
    } catch (e) {
      debugPrint('Error fitting map to markers: $e');
    }
  }

  void onMapCreated(GoogleMapController controller) {
    mapController = controller;
    _fitMapToMarkers();
  }
}

class DestinationMapWidget extends StatelessWidget {
  final List<Destination> destinations;
  final double height;

  const DestinationMapWidget({
    super.key,
    required this.destinations,
    this.height = 400,
  });

  LatLng _getCenterPosition() {
    if (destinations.isEmpty) {
      return LatLng(23.7777571, 90.3961643); // Default center
    }

    double avgLat = 0;
    double avgLng = 0;
    int validCount = 0;

    for (final destination in destinations) {
      try {
        final lat = double.parse(destination.latitude);
        final lng = double.parse(destination.longitude);
        avgLat += lat;
        avgLng += lng;
        validCount++;
      } catch (e) {
        debugPrint('Error parsing coordinates: $e');
      }
    }

    if (validCount > 0) {
      avgLat /= validCount;
      avgLng /= validCount;
    } else {
      return LatLng(23.7777571, 90.3961643);
    }

    return LatLng(avgLat, avgLng);
  }

  @override
  Widget build(BuildContext context) {
    if (destinations.isEmpty) {
      return Container(
        height: height,
        color: Colors.grey.shade200,
        child: Center(
          child: Text('No destination data available'),
        ),
      );
    }

    final uniqueTag = 'dest_map_${identityHashCode(this)}';

    return GetBuilder<DestinationMapController>(
      tag: uniqueTag,
      init: DestinationMapController(),
      builder: (controller) {
        controller.updateDestinations(destinations);

        return ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: SizedBox(
            height: height,
            child: Obx(() => GoogleMap(
                  mapType: MapType.normal,
                  onMapCreated: controller.onMapCreated,
                  initialCameraPosition: CameraPosition(
                    target: _getCenterPosition(),
                    zoom: 14,
                  ),
                  markers: controller.markers,
                  polylines: controller.polylines,
                  myLocationButtonEnabled: false,
                  zoomControlsEnabled: false,
                  scrollGesturesEnabled: true,
                  rotateGesturesEnabled: true,
                  tiltGesturesEnabled: true,
                  zoomGesturesEnabled: true,
                )),
          ),
        );
      },
    );
  }
}
