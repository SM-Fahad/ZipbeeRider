// ignore_for_file: deprecated_member_use

import 'dart:async';

import 'package:ZipBee_Driver/core/services/osrm_route_service.dart';
import 'package:ZipBee_Driver/core/utils/custom_map_marker_helper.dart';
import 'package:ZipBee_Driver/core/utils/location_helper.dart';
import 'package:ZipBee_Driver/features/google_map/service/one_map_service.dart';
import 'package:ZipBee_Driver/features/google_map/service/service_zone_service.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart' as geo;
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';

enum GoogleMapWidgetMode { display, addressPicker }

class OneMapRouteStop {
  final double latitude;
  final double longitude;
  final String address;
  final String stopType;
  final int sequence;

  const OneMapRouteStop({
    required this.latitude,
    required this.longitude,
    required this.address,
    required this.stopType,
    required this.sequence,
  });
}

class MapData {
  final LatLng initialFocus;
  final LatLng? currentPosition;
  final Location location;

  const MapData({
    required this.initialFocus,
    this.currentPosition,
    required this.location,
  });
}

class GoogleMapWidget extends StatefulWidget {
  const GoogleMapWidget({
    super.key,
    this.mode = GoogleMapWidgetMode.display,
    this.initialQuery,
    this.initialFocus,
    this.routeStops = const [],
    this.onLocationConfirmed,
    this.onDisplayTap,
    this.showZoomButtons = true,
  });

  final GoogleMapWidgetMode mode;
  final String? initialQuery;
  final LatLng? initialFocus;
  final List<OneMapRouteStop> routeStops;
  final ValueChanged<OneMapResolvedAddress>? onLocationConfirmed;
  final ValueChanged<LatLng>? onDisplayTap;
  final bool showZoomButtons;

  @override
  State<GoogleMapWidget> createState() => _GoogleMapWidgetState();

  static Future<void> warmUp({
    LatLng? initialFocus,
    List<OneMapRouteStop> routeStops = const [],
  }) async {
    await initializeMap(initialFocus: initialFocus, routeStops: routeStops);
  }

  static Future<MapData> initializeMap({
    LatLng? initialFocus,
    List<OneMapRouteStop> routeStops = const [],
  }) async {
    final location = Location();

    LatLng focus;
    if (initialFocus != null) {
      focus = initialFocus;
    } else if (routeStops.isNotEmpty) {
      focus = LatLng(routeStops.first.latitude, routeStops.first.longitude);
    } else {
      final zoneCenter = await ServiceZoneService.getFirstZoneCenter().timeout(
        const Duration(milliseconds: 500),
        onTimeout: () => null,
      );
      focus = zoneCenter ?? const LatLng(1.3521, 103.8198);
    }

    LatLng? currentPosition;
    try {
      final serviceEnabled = await location.serviceEnabled();
      final permission = await location.hasPermission();
      if (serviceEnabled && permission != PermissionStatus.denied) {
        final locData = await location.getLocation().timeout(
          const Duration(milliseconds: 800),
        );
        if (locData.latitude != null && locData.longitude != null) {
          currentPosition = LatLng(locData.latitude!, locData.longitude!);
        }
      }
    } catch (_) {}

    return MapData(
      initialFocus: focus,
      currentPosition: currentPosition,
      location: location,
    );
  }
}

class _GoogleMapWidgetState extends State<GoogleMapWidget> {
  late Future<MapData> _mapDataFuture;

  @override
  void initState() {
    super.initState();
    _mapDataFuture = GoogleMapWidget.initializeMap(
      initialFocus: widget.initialFocus,
      routeStops: widget.routeStops,
    );
  }

  @override
  void didUpdateWidget(covariant GoogleMapWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialFocus != oldWidget.initialFocus ||
        widget.routeStops.length != oldWidget.routeStops.length) {
      _mapDataFuture = GoogleMapWidget.initializeMap(
        initialFocus: widget.initialFocus,
        routeStops: widget.routeStops,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<MapData>(
      future: _mapDataFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done &&
            !snapshot.hasData) {
          return const Center(
            child: CircularProgressIndicator(color: Colors.amber),
          );
        }

        final fallbackFocus = widget.initialFocus ??
            (widget.routeStops.isNotEmpty
                ? LatLng(
                    widget.routeStops.first.latitude,
                    widget.routeStops.first.longitude,
                  )
                : const LatLng(1.3521, 103.8198));

        final mapData = snapshot.data ??
            MapData(
              initialFocus: fallbackFocus,
              location: Location(),
            );

        return GoogleMapContent(
          key: widget.key ??
              ValueKey(
                'map_content_${widget.mode.name}_${widget.routeStops.length}_${widget.initialFocus?.latitude ?? 0}',
              ),
          data: mapData,
          mode: widget.mode,
          routeStops: widget.routeStops,
          initialQuery: widget.initialQuery,
          onLocationConfirmed: widget.onLocationConfirmed,
          onDisplayTap: widget.onDisplayTap,
          showZoomButtons: widget.showZoomButtons,
        );
      },
    );
  }
}

class GoogleMapContentController extends GetxController {
  final MapData data;
  final GoogleMapWidgetMode mode;
  final String? initialQuery;
  List<OneMapRouteStop> routeStops;

  GoogleMapContentController({
    required this.data,
    required this.mode,
    this.initialQuery,
    this.routeStops = const [],
  });

  String? lastInitialQuery;

  final Completer<GoogleMapController> mapController = Completer();
  late final TextEditingController searchController;

  final RxList<OneMapAddressSuggestion> suggestions =
      <OneMapAddressSuggestion>[].obs;

  StreamSubscription<LocationData>? locSub;
  StreamSubscription<geo.Position>? geoLocSub;
  Timer? debounce;

  final RxList<LatLng> driverToPickupPolylinePoints = <LatLng>[].obs;
  int driverPolylineRequestId = 0;
  DateTime? _lastDriverPolylineFetchTime;
  LatLng? _lastDriverPolylineLoc;

  late final Rx<LatLng> currentPosition;
  final RxList<LatLng> routePolylinePoints = <LatLng>[].obs;
  final Rxn<Marker> selectedMarker = Rxn<Marker>();
  final RxSet<Marker> displayMarkers = <Marker>{}.obs;
  final Rxn<OneMapResolvedAddress> pendingSelection =
      Rxn<OneMapResolvedAddress>();

  final RxBool hasDeviceLocation = false.obs;
  final RxBool isSearching = false.obs;
  final RxBool showSuggestions = false.obs;
  final RxBool didRunInitialQuery = false.obs;
  final RxnString helperMessage = RxnString();

  bool isMutatingSearchField = false;
  bool hasUserMovedMap = false;
  bool isProgrammaticCameraMove = false;
  int routeRequestId = 0;
  String? _loadedRouteSignature;
  bool _hasFittedCameraToRoute = false;

  @override
  void onInit() {
    super.onInit();
    lastInitialQuery = initialQuery;
    searchController = TextEditingController(text: initialQuery ?? '');
    currentPosition = (data.currentPosition ?? data.initialFocus).obs;
    hasDeviceLocation.value = data.currentPosition != null;

    _updateMarkers();

    listenLocation();

    ever(currentPosition, (_) => _updateMarkers());
    ever(hasDeviceLocation, (_) => _updateMarkers());
    ever(selectedMarker, (_) => _updateMarkers());

    if (mode == GoogleMapWidgetMode.display && routeStops.isNotEmpty) {
      final sig = _getRouteSignature(routeStops);
      _refreshRoutePolyline(routeStops, sig);
    }
  }

  void updateInitialQuery(String newQuery) {
    lastInitialQuery = newQuery;
    if (newQuery.isNotEmpty && searchController.text.trim().isEmpty) {
      _setSearchField(newQuery);
    }
  }

  void updateRouteStops(List<OneMapRouteStop> newStops) {
    if (_areStopsEqual(routeStops, newStops)) return;
    routeStops = newStops;
    _loadedRouteSignature = null;
    _updateMarkers();
    if (mode == GoogleMapWidgetMode.display && newStops.isNotEmpty) {
      final sig = _getRouteSignature(newStops);
      _refreshRoutePolyline(newStops, sig);
      if (!_hasFittedCameraToRoute && !hasUserMovedMap) {
        _hasFittedCameraToRoute = true;
        _fitCameraToRoute(newStops);
      }
    }
  }

  bool _areStopsEqual(List<OneMapRouteStop> a, List<OneMapRouteStop> b) {
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i].latitude != b[i].latitude ||
          a[i].longitude != b[i].longitude ||
          a[i].stopType != b[i].stopType ||
          a[i].sequence != b[i].sequence) {
        return false;
      }
    }
    return true;
  }

  String _getRouteSignature(List<OneMapRouteStop> stops) {
    return stops
        .map((s) => '${s.stopType}_${s.latitude}_${s.longitude}_${s.sequence}')
        .join('|');
  }

  @override
  void onClose() {
    debounce?.cancel();
    locSub?.cancel();
    geoLocSub?.cancel();
    searchController.dispose();
    super.onClose();
  }

  bool _isPickup(String type) {
    final t = type.toUpperCase();
    return t == 'PICKUP' || t == 'SENDER';
  }

  bool _isDrop(String type) {
    final t = type.toUpperCase();
    return t == 'DROP' || t == 'RECEIVER';
  }

  Future<void> _updateMarkers() async {
    final nextMarkers = <Marker>{};

    final isDisplayWithStops =
        mode == GoogleMapWidgetMode.display && routeStops.isNotEmpty;

    // 1. Device Location Marker
    if (hasDeviceLocation.value && !isDisplayWithStops) {
      final deviceLocationIcon =
          await CustomMapMarkerHelper.getDeviceLocationMarker();
      nextMarkers.add(
        Marker(
          markerId: const MarkerId('current'),
          position: currentPosition.value,
          anchor: CustomMapMarkerHelper.defaultAnchor,
          icon: deviceLocationIcon,
        ),
      );
    }

    // 2. Rider/Driver Marker on display with stops
    if (hasDeviceLocation.value && isDisplayWithStops) {
      final riderIcon = await CustomMapMarkerHelper.getRiderMarker();
      nextMarkers.add(
        Marker(
          markerId: const MarkerId('rider_current'),
          position: currentPosition.value,
          anchor: CustomMapMarkerHelper.defaultAnchor,
          icon: riderIcon,
          infoWindow: const InfoWindow(title: 'Your Location'),
        ),
      );
    }

    // 3. User Selected / Tapped Marker
    if (selectedMarker.value != null) {
      nextMarkers.add(selectedMarker.value!);
    }

    // 4. Route Stops Markers (Pickup + Drops)
    if (mode == GoogleMapWidgetMode.display && routeStops.isNotEmpty) {
      final pickups =
          routeStops.where((s) => _isPickup(s.stopType)).toList()
            ..sort((a, b) => a.sequence.compareTo(b.sequence));
      final drops =
          routeStops.where((s) => _isDrop(s.stopType)).toList()
            ..sort((a, b) => a.sequence.compareTo(b.sequence));

      final showDropNumbers = drops.length > 1;

      // Pickups (Blue Pin)
      for (var i = 0; i < pickups.length; i++) {
        final stop = pickups[i];
        final icon = await CustomMapMarkerHelper.getPickupMarker();
        nextMarkers.add(
          Marker(
            markerId: MarkerId('pickup_${stop.sequence}_$i'),
            position: LatLng(stop.latitude, stop.longitude),
            anchor: CustomMapMarkerHelper.defaultAnchor,
            icon: icon,
            infoWindow: InfoWindow(
              title: 'Pickup Location',
              snippet: stop.address,
            ),
          ),
        );
      }

      // Drops (Red Pin / Numbered Red Pin)
      for (var i = 0; i < drops.length; i++) {
        final stop = drops[i];
        final dropNumber = i + 1;
        final icon = showDropNumbers
            ? await CustomMapMarkerHelper.getNumberedDropMarker(
                number: dropNumber,
              )
            : await CustomMapMarkerHelper.getDropMarker();

        nextMarkers.add(
          Marker(
            markerId: MarkerId('drop_${stop.sequence}_$dropNumber'),
            position: LatLng(stop.latitude, stop.longitude),
            anchor: CustomMapMarkerHelper.defaultAnchor,
            icon: icon,
            infoWindow: InfoWindow(
              title: showDropNumbers
                  ? 'Dropoff #$dropNumber'
                  : 'Dropoff Location',
              snippet: stop.address,
            ),
          ),
        );
      }
    }

    displayMarkers.assignAll(nextMarkers);
  }

  Future<void> listenLocation() async {
    try {
      bool serviceEnabled = await geo.Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) return;

      geo.LocationPermission permission =
          await geo.Geolocator.checkPermission();
      if (permission == geo.LocationPermission.denied) {
        permission = await geo.Geolocator.requestPermission();
      }

      if (permission == geo.LocationPermission.denied ||
          permission == geo.LocationPermission.deniedForever) {
        return;
      }

      geo.Position? pos;
      try {
        pos = await geo.Geolocator.getLastKnownPosition();
      } catch (_) {}

      pos ??= await geo.Geolocator.getCurrentPosition(
        desiredAccuracy: geo.LocationAccuracy.high,
        timeLimit: const Duration(seconds: 5),
      );

      final newPos = LatLng(pos.latitude, pos.longitude);
      hasDeviceLocation.value = true;
      currentPosition.value = newPos;

      if (mode == GoogleMapWidgetMode.display && routeStops.isNotEmpty) {
        final pickup = routeStops.firstWhere(
          (s) => _isPickup(s.stopType),
          orElse: () => routeStops.first,
        );
        await _throttledRefreshDriverToPickupPolyline(
          newPos,
          LatLng(pickup.latitude, pickup.longitude),
        );
      }

      geoLocSub?.cancel();
      geoLocSub = geo.Geolocator.getPositionStream(
        locationSettings: getLocationSettings(
          accuracy: geo.LocationAccuracy.high,
          distanceFilter: 5,
        ),
      ).listen((updatedPos) async {
        final newLocation = LatLng(updatedPos.latitude, updatedPos.longitude);
        hasDeviceLocation.value = true;
        currentPosition.value = newLocation;

        if (mode == GoogleMapWidgetMode.display && routeStops.isNotEmpty) {
          final pickup = routeStops.firstWhere(
            (s) => _isPickup(s.stopType),
            orElse: () => routeStops.first,
          );
          await _throttledRefreshDriverToPickupPolyline(
            newLocation,
            LatLng(pickup.latitude, pickup.longitude),
          );
        }
      });
    } catch (e) {
      debugPrint('⚠️ Error in listenLocation: $e');
    }
  }

  Future<void> _throttledRefreshDriverToPickupPolyline(
    LatLng driverLoc,
    LatLng pickupLoc,
  ) async {
    final now = DateTime.now();

    if (driverToPickupPolylinePoints.isNotEmpty &&
        _lastDriverPolylineFetchTime != null &&
        _lastDriverPolylineLoc != null) {
      final elapsedSeconds =
          now.difference(_lastDriverPolylineFetchTime!).inSeconds;
      final distanceMovedMeters = OsrmRouteService.calculateDistanceMeters(
        _lastDriverPolylineLoc!,
        driverLoc,
      );

      if (distanceMovedMeters < 25.0) return;
      if (elapsedSeconds < 15) return;
    }

    _lastDriverPolylineFetchTime = now;
    _lastDriverPolylineLoc = driverLoc;
    await _refreshDriverToPickupPolyline(driverLoc, pickupLoc);
  }

  Future<void> _refreshDriverToPickupPolyline(
    LatLng driverLoc,
    LatLng pickupLoc,
  ) async {
    final requestId = ++driverPolylineRequestId;
    try {
      final points = await OsrmRouteService.getRoutePoints([driverLoc, pickupLoc]);
      if (requestId != driverPolylineRequestId) return;
      driverToPickupPolylinePoints.assignAll(points);
    } catch (error) {
      debugPrint('❌ Failed to load driver to pickup route polyline: $error');
      if (requestId != driverPolylineRequestId) return;
      driverToPickupPolylinePoints.assignAll([driverLoc, pickupLoc]);
    }
  }

  Future<void> _refreshRoutePolyline(
    List<OneMapRouteStop> stops,
    String signature,
  ) async {
    if (stops.length < 2) {
      routePolylinePoints.clear();
      _loadedRouteSignature = null;
      return;
    }

    if (signature == _loadedRouteSignature && routePolylinePoints.isNotEmpty) {
      return;
    }

    final requestId = ++routeRequestId;

    try {
      final waypoints =
          stops.map((s) => LatLng(s.latitude, s.longitude)).toList();
      final points = await OsrmRouteService.getRoutePoints(waypoints);

      if (requestId != routeRequestId) return;

      _loadedRouteSignature = signature;
      routePolylinePoints.assignAll(points);
    } catch (error) {
      debugPrint('❌ Failed to load road route polyline: $error');
      if (requestId != routeRequestId) return;
      _loadedRouteSignature = signature;
      final fallbackPoints =
          stops.map((s) => LatLng(s.latitude, s.longitude)).toList();
      routePolylinePoints.assignAll(fallbackPoints);
    }
  }

  Future<void> _fitCameraToRoute(List<OneMapRouteStop> stops) async {
    if (stops.isEmpty) return;

    try {
      if (stops.length == 1) {
        await moveCamera(
          LatLng(stops.first.latitude, stops.first.longitude),
          zoom: 14,
        );
        return;
      }

      double minLat = stops.first.latitude;
      double maxLat = stops.first.latitude;
      double minLng = stops.first.longitude;
      double maxLng = stops.first.longitude;

      for (final stop in stops.skip(1)) {
        if (stop.latitude < minLat) minLat = stop.latitude;
        if (stop.latitude > maxLat) maxLat = stop.latitude;
        if (stop.longitude < minLng) minLng = stop.longitude;
        if (stop.longitude > maxLng) maxLng = stop.longitude;
      }

      final controller = await mapController.future;
      isProgrammaticCameraMove = true;
      await controller.animateCamera(
        CameraUpdate.newLatLngBounds(
          LatLngBounds(
            southwest: LatLng(minLat, minLng),
            northeast: LatLng(maxLat, maxLng),
          ),
          60,
        ),
      );
    } catch (e) {
      debugPrint('⚠️ _fitCameraToRoute error: $e');
    }
  }

  Future<void> moveCamera(LatLng position, {double zoom = 16}) async {
    try {
      final controller = await mapController.future;
      isProgrammaticCameraMove = true;
      await controller.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(target: position, zoom: zoom),
        ),
      );
    } catch (e) {
      debugPrint('⚠️ moveCamera error: $e');
    }
  }

  Future<void> changeZoom(double delta) async {
    try {
      final controller = await mapController.future;
      isProgrammaticCameraMove = true;
      await controller.animateCamera(CameraUpdate.zoomBy(delta));
    } catch (e) {
      debugPrint('⚠️ changeZoom error: $e');
    }
  }

  void dropPin(LatLng position) {
    selectedMarker.value = Marker(
      markerId: const MarkerId('selected'),
      position: position,
    );
  }

  Set<Marker> _buildDisplayMarkers() {
    return displayMarkers.toSet();
  }

  Set<Polyline> _buildDisplayPolylines() {
    final polylines = <Polyline>{};
    if (mode != GoogleMapWidgetMode.display) {
      return polylines;
    }

    if (routePolylinePoints.length >= 2) {
      polylines.add(
        Polyline(
          polylineId: const PolylineId('order_route'),
          color: const Color(0xFF1565C0), // Blue
          width: 5,
          geodesic: false,
          points: routePolylinePoints.toList(),
        ),
      );
    }

    if (driverToPickupPolylinePoints.length >= 2) {
      polylines.add(
        Polyline(
          polylineId: const PolylineId('driver_to_pickup'),
          color: const Color(0xFFFFCC00), // Yellow
          width: 5,
          geodesic: false,
          points: driverToPickupPolylinePoints.toList(),
        ),
      );
    }

    return polylines;
  }

  Future<void> handleMapTap(
    LatLng latLng,
    ValueChanged<LatLng>? onDisplayTap,
  ) async {
    dropPin(latLng);

    if (mode == GoogleMapWidgetMode.display) {
      onDisplayTap?.call(latLng);
      return;
    }

    await _resolveFromTap(latLng);
  }

  Future<void> _resolveFromTap(LatLng latLng) async {
    isSearching.value = true;
    helperMessage.value = null;
    showSuggestions.value = false;

    final resolved = await OneMapService.reverseGeocode(
      latLng.latitude,
      latLng.longitude,
    );

    isSearching.value = false;
    if (resolved == null) {
      pendingSelection.value = null;
      helperMessage.value = "Couldn't detect address here. Try clicking nearby.";
      return;
    }

    pendingSelection.value = resolved;
    helperMessage.value = null;
    _setSearchField(
      resolved.postalCode.isNotEmpty ? resolved.postalCode : resolved.address,
    );

    await moveCamera(latLng);
  }

  Future<void> runSearch(String query) async {
    final trimmed = query.trim();
    if (trimmed.length < 3) return;

    isSearching.value = true;
    helperMessage.value = null;
    showSuggestions.value = false;
    suggestions.clear();

    final currentQuery = trimmed;
    final results = await OneMapService.searchSuggestions(trimmed);

    if (searchController.text.trim() != currentQuery) {
      return;
    }

    if (results.isEmpty) {
      isSearching.value = false;
      pendingSelection.value = null;
      helperMessage.value =
          'No location found. Try a building name, road, or postal code.';
      return;
    }

    isSearching.value = false;
    helperMessage.value = null;
    suggestions.assignAll(results);
    showSuggestions.value = true;

    await selectSuggestion(results.first, updateSearchField: false);
  }

  Future<void> selectSuggestion(
    OneMapAddressSuggestion suggestion, {
    bool updateSearchField = true,
  }) async {
    final resolved = suggestion.toResolvedAddress();
    final target = LatLng(suggestion.lat, suggestion.lng);

    pendingSelection.value = resolved;
    helperMessage.value = null;
    if (updateSearchField) {
      _setSearchField(suggestion.postalCode);
    }
    selectedMarker.value = Marker(
      markerId: const MarkerId('selected'),
      position: target,
    );

    await moveCamera(target, zoom: 17);
  }

  void _setSearchField(String value) {
    isMutatingSearchField = true;
    searchController.text = value;
    searchController.selection = TextSelection.collapsed(offset: value.length);
    isMutatingSearchField = false;
  }

  void handleSearchInputChanged(String value) {
    if (isMutatingSearchField) return;

    debounce?.cancel();
    if (value.trim().length < 3) {
      showSuggestions.value = false;
      suggestions.clear();
      helperMessage.value = null;
      return;
    }

    debounce = Timer(
      const Duration(milliseconds: 700),
      () => runSearch(value),
    );
  }

  String displaySuggestionText(String value) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) return trimmed;

    final hasLetters = RegExp(r'[A-Za-z]').hasMatch(trimmed);
    final isAllUppercase = hasLetters && trimmed == trimmed.toUpperCase();
    if (!isAllUppercase) return trimmed;

    return trimmed
        .split(RegExp(r'(\s+)'))
        .map((part) {
          if (part.trim().isEmpty) return part;

          return part
              .split('-')
              .map((segment) {
                if (segment.isEmpty) return segment;
                final lower = segment.toLowerCase();
                return '${lower[0].toUpperCase()}${lower.substring(1)}';
              })
              .join('-');
        })
        .join(' ');
  }
}

class GoogleMapContent extends StatefulWidget {
  const GoogleMapContent({
    super.key,
    required this.data,
    required this.mode,
    required this.routeStops,
    this.initialQuery,
    this.onLocationConfirmed,
    this.onDisplayTap,
    this.showZoomButtons = true,
  });

  final MapData data;
  final GoogleMapWidgetMode mode;
  final List<OneMapRouteStop> routeStops;
  final String? initialQuery;
  final ValueChanged<OneMapResolvedAddress>? onLocationConfirmed;
  final ValueChanged<LatLng>? onDisplayTap;
  final bool showZoomButtons;

  @override
  State<GoogleMapContent> createState() => _GoogleMapContentState();
}

class _GoogleMapContentState extends State<GoogleMapContent> {
  late final GoogleMapContentController controller;

  @override
  void initState() {
    super.initState();
    controller = GoogleMapContentController(
      data: widget.data,
      mode: widget.mode,
      initialQuery: widget.initialQuery,
      routeStops: widget.routeStops,
    );
    controller.onInit();

    if (widget.mode == GoogleMapWidgetMode.addressPicker &&
        (widget.initialQuery?.trim().length ?? 0) >= 3) {
      controller.didRunInitialQuery.value = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        controller.runSearch(widget.initialQuery!.trim());
      });
    }
  }

  @override
  void didUpdateWidget(covariant GoogleMapContent oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialQuery != null &&
        widget.initialQuery != controller.lastInitialQuery) {
      controller.updateInitialQuery(widget.initialQuery!);
    }
    controller.updateRouteStops(widget.routeStops);
  }

  @override
  void dispose() {
    controller.onClose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Obx(
          () => GoogleMap(
            mapType: MapType.normal,
            initialCameraPosition: CameraPosition(
              target: widget.data.currentPosition ?? widget.data.initialFocus,
              zoom: widget.mode == GoogleMapWidgetMode.addressPicker ? 13 : 11,
            ),
            onCameraMoveStarted: () {
              if (!controller.isProgrammaticCameraMove) {
                controller.hasUserMovedMap = true;
              }
            },
            onCameraIdle: () {
              controller.isProgrammaticCameraMove = false;
            },
            onMapCreated: (mapControllerInst) async {
              if (!controller.mapController.isCompleted) {
                controller.mapController.complete(mapControllerInst);
              }
              await controller.moveCamera(
                widget.data.currentPosition ?? widget.data.initialFocus,
                zoom: widget.mode == GoogleMapWidgetMode.addressPicker ? 13 : 11,
              );
              if (widget.mode == GoogleMapWidgetMode.display &&
                  controller.routeStops.isNotEmpty) {
                final sig = controller._getRouteSignature(controller.routeStops);
                await controller._refreshRoutePolyline(
                  controller.routeStops,
                  sig,
                );
                if (!controller._hasFittedCameraToRoute &&
                    !controller.hasUserMovedMap) {
                  controller._hasFittedCameraToRoute = true;
                  await controller._fitCameraToRoute(controller.routeStops);
                }
              }
            },
            myLocationEnabled: widget.mode == GoogleMapWidgetMode.addressPicker &&
                controller.hasDeviceLocation.value,
            myLocationButtonEnabled:
                widget.mode == GoogleMapWidgetMode.addressPicker,
            onTap: (latLng) =>
                controller.handleMapTap(latLng, widget.onDisplayTap),
            markers: controller._buildDisplayMarkers(),
            polylines: controller._buildDisplayPolylines(),
          ),
        ),
        if (widget.showZoomButtons)
          Positioned(
            right: 12,
            top: widget.mode == GoogleMapWidgetMode.addressPicker ? 84 : 24,
            child: Column(
              children: [
                _buildZoomButton(
                  icon: Icons.add,
                  onTap: () => controller.changeZoom(1),
                ),
                const SizedBox(height: 10),
                _buildZoomButton(
                  icon: Icons.remove,
                  onTap: () => controller.changeZoom(-1),
                ),
              ],
            ),
          ),
        if (widget.mode == GoogleMapWidgetMode.addressPicker) ...[
          _buildSearchOverlay(controller),
          Obx(
            () => controller.showSuggestions.value &&
                    controller.suggestions.isNotEmpty
                ? _buildSuggestionsOverlay(controller)
                : const SizedBox.shrink(),
          ),
          Obx(
            () => controller.isSearching.value
                ? _buildLoadingOverlay()
                : const SizedBox.shrink(),
          ),
          Obx(() => _buildBottomSelectionCard(controller)),
        ],
      ],
    );
  }

  Widget _buildZoomButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.white,
      elevation: 6,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: SizedBox(
          width: 42,
          height: 42,
          child: Icon(icon, color: Colors.black87),
        ),
      ),
    );
  }

  Widget _buildSearchOverlay(GoogleMapContentController controller) {
    return Positioned(
      top: 12,
      left: 12,
      right: 12,
      child: Column(
        children: [
          Material(
            elevation: 6,
            borderRadius: BorderRadius.circular(16),
            color: Colors.white,
            child: Obx(
              () => TextField(
                controller: controller.searchController,
                onChanged: controller.handleSearchInputChanged,
                onSubmitted: controller.runSearch,
                textInputAction: TextInputAction.search,
                decoration: InputDecoration(
                  hintText: 'Search postal code, building, or road',
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: controller.isSearching.value
                      ? const Padding(
                          padding: EdgeInsets.all(14),
                          child: SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                        )
                      : IconButton(
                          icon: const Icon(Icons.my_location_outlined),
                          onPressed: controller.hasDeviceLocation.value
                              ? () => controller.moveCamera(
                                    controller.currentPosition.value,
                                    zoom: 16,
                                  )
                              : null,
                        ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 14,
                  ),
                ),
              ),
            ),
          ),
          Obx(
            () => controller.helperMessage.value != null
                ? Container(
                    width: double.infinity,
                    margin: const EdgeInsets.only(top: 8),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.95),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      controller.helperMessage.value!,
                      style: TextStyle(
                        fontSize: 12,
                        color: controller.helperMessage.value!.startsWith('No') ||
                                controller.helperMessage.value!
                                    .startsWith("Couldn't")
                            ? Colors.red.shade600
                            : Colors.grey.shade700,
                      ),
                    ),
                  )
                : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }

  Widget _buildSuggestionsOverlay(GoogleMapContentController controller) {
    return Positioned(
      top: 74,
      left: 12,
      right: 12,
      child: Material(
        elevation: 8,
        borderRadius: BorderRadius.circular(16),
        color: Colors.white,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxHeight: 180),
          child: Obx(
            () => ListView.separated(
              padding: const EdgeInsets.symmetric(vertical: 8),
              shrinkWrap: true,
              itemCount: controller.suggestions.length,
              separatorBuilder: (_, __) =>
                  Divider(height: 1, color: Colors.grey.shade200),
              itemBuilder: (context, index) {
                final suggestion = controller.suggestions[index];
                final isSelected = controller
                            .pendingSelection.value?.postalCode ==
                        suggestion.postalCode &&
                    controller.pendingSelection.value?.address ==
                        suggestion.label;

                return ListTile(
                  dense: true,
                  leading: Icon(
                    Icons.location_on_outlined,
                    color: isSelected ? Colors.amber.shade700 : Colors.grey,
                  ),
                  title: Text(
                    controller.displaySuggestionText(
                      suggestion.building.isNotEmpty
                          ? suggestion.building
                          : suggestion.road,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  subtitle: Text(
                    controller.displaySuggestionText(suggestion.label),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 12),
                  ),
                  trailing: isSelected
                      ? Icon(
                          Icons.check_circle,
                          color: Colors.green.shade600,
                          size: 18,
                        )
                      : const Icon(Icons.chevron_right),
                  onTap: () async {
                    controller.showSuggestions.value = false;
                    await controller.selectSuggestion(suggestion);
                  },
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingOverlay() {
    return Positioned.fill(
      child: IgnorePointer(
        child: Center(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.96),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.amber,
                  ),
                ),
                SizedBox(width: 10),
                Text('Finding address...'),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBottomSelectionCard(GoogleMapContentController controller) {
    return Positioned(
      left: 12,
      right: 12,
      bottom: 12,
      child: Material(
        elevation: 8,
        borderRadius: BorderRadius.circular(18),
        color: Colors.white.withOpacity(0.97),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: controller.pendingSelection.value == null
              ? Row(
                  children: [
                    Icon(Icons.place_outlined, color: Colors.amber.shade700),
                    const SizedBox(width: 8),
                    const Expanded(
                      child: Text(
                        'Search or tap the map to select a location.',
                        style: TextStyle(fontSize: 12),
                      ),
                    ),
                  ],
                )
              : Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Selected Address',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: Colors.grey.shade600,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            controller.pendingSelection.value!.address,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Postal Code: ${controller.pendingSelection.value!.postalCode.isEmpty ? 'N/A' : controller.pendingSelection.value!.postalCode}',
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.grey.shade700,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 10),
                    FilledButton(
                      onPressed: widget.onLocationConfirmed == null
                          ? null
                          : () => widget.onLocationConfirmed!(
                                controller.pendingSelection.value!,
                              ),
                      style: FilledButton.styleFrom(
                        backgroundColor: Colors.amber,
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 12,
                        ),
                      ),
                      child: const Text(
                        'Use',
                        style: TextStyle(fontWeight: FontWeight.w700),
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}
