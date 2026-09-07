import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:logger/logger.dart';
import 'package:http/http.dart' as http;
import 'package:ZipBee_Driver/core/utils/location_helper.dart';
import 'package:ZipBee_Driver/core/shared_prefs_service/shared_preference_helper.dart';
import 'package:ZipBee_Driver/core/api_end_point/api_end_point.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';

import 'package:ZipBee_Driver/core/utils/custom_map_marker_helper.dart';

class DistanceRadiusController extends GetxController {
  var isOffline = false.obs;
  var isAutoPopup = false.obs;
  RxDouble radiusKm = 5.0.obs;
  final markerIcon = Rxn<BitmapDescriptor>();
  
  // Location related
  var currentLocation = Rx<LatLng?>(null);
  var isLoadingLocation = false.obs;
  GoogleMapController? mapController;
  final logger = Logger();
  
  // Circles for map
  var circles = <Circle>[].obs;

  final TextEditingController radiusTextController = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    radiusTextController.text = radiusKm.value.toInt().toString();
    ever(radiusKm, (double val) {
      final str = val.toInt().toString();
      if (radiusTextController.text != str) {
        radiusTextController.text = str;
      }
    });
    _loadMarkerIcon();
    _initializeUserLocation();
  }

  void setRadiusFromText(double value) {
    if (value > 0) {
      radiusKm.value = value;
      _updateCircle();
    }
  }

  Future<void> _loadMarkerIcon() async {
    markerIcon.value = await CustomMapMarkerHelper.getRiderMarker();
  }

  void zoomIn() {
    mapController?.animateCamera(CameraUpdate.zoomIn());
  }

  void zoomOut() {
    mapController?.animateCamera(CameraUpdate.zoomOut());
  }

  Future<void> updateRadius() async {
    try {
      EasyLoading.show(status: 'Updating...');
      final token = await SharedPreferencesHelper.getToken();
      if (token == null || token.isEmpty) {
        EasyLoading.showError('Authentication token not found.');
        return;
      }

      final url = Uri.parse('${ApiEndPoint.baseUrl}/raider-profile/settings/radius-update');
      final response = await http.patch(
        url,
        headers: {
          'accept': '*/*',
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'radius': radiusKm.value.toInt(),
        }),
      );

      final Map<String, dynamic> responseData = jsonDecode(response.body);

      if (response.statusCode == 200 || (responseData['success'] == true)) {
        EasyLoading.showSuccess(responseData['message'] ?? 'Rider radius updated successfully');
        Get.back(); // Go back to previous screen
      } else {
        final errorMsg = _extractErrorMessage(responseData);
        EasyLoading.showError(errorMsg);
      }
    } catch (e) {
      logger.e('Error updating radius: $e');
      EasyLoading.showError('Something went wrong: $e');
    }
  }

  String _extractErrorMessage(Map<String, dynamic> responseData) {
    final message = responseData['message'];
    if (message is List) {
      return message.join('\n');
    } else if (message is String) {
      return message;
    }
    return responseData['error'] ?? 'Failed to update radius';
  }

  /// Get actual user location using geolocator plugin
  Future<void> _initializeUserLocation() async {
    try {
      isLoadingLocation.value = true;

      // Check if location services are enabled
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        logger.w('Location services are disabled.');
        return;
      }

      // Check permissions
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied ||
            permission == LocationPermission.deniedForever) {
          logger.w('Location permissions are denied.');
          return;
        }
      }

      final locationSettings = getLocationSettings();

      // Get current position
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        forceAndroidLocationManager: true,
        timeLimit: const Duration(seconds: 10),
      );

      currentLocation.value = LatLng(position.latitude, position.longitude);
      _updateCircle();

      // Listen to location changes
      Geolocator.getPositionStream(
        locationSettings: locationSettings,
      ).listen((Position position) {
        currentLocation.value = LatLng(position.latitude, position.longitude);
        _updateCircle();
      });
    } catch (e) {
      logger.e('Error getting location: $e');
    } finally {
      isLoadingLocation.value = false;
    }
  }

  /// Update circle on map when radius changes
  void _updateCircle() {
    if (currentLocation.value != null) {
      circles.value = [
        Circle(
          circleId: CircleId('radius_circle'),
          center: currentLocation.value!,
          radius: radiusKm.value * 1000, // Convert km to meters
          fillColor: Colors.blue.withValues(alpha: 0.2),
          strokeColor: Colors.blue,
          strokeWidth: 2,
        ),
      ];
      logger.i('Circle updated: radius=${radiusKm.value} km');
    }
  }

  void increaseRadius() {
    if (radiusKm.value < 50) {
      radiusKm.value += 1;
      _updateCircle();
    }
  }

  void toggleOffline(bool value) {
    isOffline.value = value;
  }

  void decreaseRadius() {
    if (radiusKm.value > 1) {
      radiusKm.value -= 1;
      _updateCircle();
    }
  }

  void onMapCreated(GoogleMapController controller) {
    mapController = controller;
    if (currentLocation.value != null) {
      _animateToLocation();
    }
  }

  void _animateToLocation() {
    if (mapController != null && currentLocation.value != null) {
      mapController!.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
            target: currentLocation.value!,
            zoom: 15,
          ),
        ),
      );
    }
  }

  @override
  void onClose() {
    radiusTextController.dispose();
    mapController?.dispose();
    super.onClose();
  }
}

