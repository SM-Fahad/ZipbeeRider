// ignore_for_file: deprecated_member_use

import 'dart:io';
import 'dart:convert';
import 'dart:async';

import 'package:ZipBee_Driver/core/api_end_point/api_end_point.dart';
import 'package:ZipBee_Driver/features/order_details/service/order_details_service.dart';
import 'package:ZipBee_Driver/core/services/file_upload_service.dart';
import 'package:ZipBee_Driver/core/services/order_completion_service.dart';
import 'package:ZipBee_Driver/core/shared_prefs_service/shared_preference_helper.dart';
import 'package:ZipBee_Driver/features/delivery_success/screen/screen.dart';
import 'package:ZipBee_Driver/features/home/model/order_model.dart';
import 'package:ZipBee_Driver/features/home/model/order_stop_model.dart';
import 'package:ZipBee_Driver/features/order_progress/service/order_stop_progress_service.dart';
import 'package:ZipBee_Driver/features/order_progress/screen/navigation_guideline_screen.dart';
import 'package:flutter/material.dart';
import 'package:ZipBee_Driver/core/utils/custom_map_marker_helper.dart';
import 'package:ZipBee_Driver/core/utils/location_helper.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:ZipBee_Driver/core/services/osrm_route_service.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_navigation_flutter/google_navigation_flutter.dart' as gnav;
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:logger/logger.dart';

class OrderProcessController extends GetxController {
  final orderDetail = Rxn<OrderModel>();
  final selectedStop = Rxn<OrderStopModel>();
  final selectedStopData = Rxn<Map<String, dynamic>>();
  final stopList = <OrderStopModel>[].obs;
  final markers = <Marker>[].obs;
  final polylines = <Polyline>{}.obs;
  final routePoints = <LatLng>[].obs;
  final currentLocation = Rxn<LatLng>();
  final dragX = 0.0.obs;
  final notesController = TextEditingController();
  final cashCollectedController = TextEditingController();
  final selectedImages = <String>[].obs;
  final uploadedProofUrls = <String>[].obs;
  final isUpdatingStep = false.obs;
  final isUploading = false.obs;
  final isCompleting = false.obs;
  final isConfirmingOrder = false.obs;
  final isReorderingRoute = false.obs;
  final errorMessage = ''.obs;
  final initialCameraPosition = const CameraPosition(
    target: LatLng(23.777176, 90.399452),
    zoom: 12,
  ).obs;

  final ImagePicker picker = ImagePicker();
  final fileUploadService = FileUploadService();
  final orderCompletionService = OrderCompletionService();
  final orderStopProgressService = OrderStopProgressService();
  final logger = Logger();

  GoogleMapController? mapController;
  gnav.GoogleNavigationViewController? navigationViewController;
  final navigationSessionInitialized = false.obs;
  final currentNavInfo = Rxn<gnav.NavInfo>();
  StreamSubscription<gnav.NavInfoEvent>? navInfoSubscription;
  final isNavigating = false.obs;
  final _orderDetailsService = OrderDetailsService();
  final isBottomPanelExpanded = false.obs;
  final isInstructionsVisible = false.obs;
  final isNightMode = false.obs;
  StreamSubscription<Position>? _orderPosStreamSub;

  Future<void> toggleMapStyle() async {
    isNightMode.value = !isNightMode.value;
    if (mapController != null) {
      if (isNightMode.value) {
        await mapController?.setMapStyle(_nightMapStyleJson);
      } else {
        await mapController?.setMapStyle(null);
      }
    }
  }

  static const String _nightMapStyleJson = '''
[
  {
    "elementType": "geometry",
    "stylers": [
      {
        "color": "#242f3e"
      }
    ]
  },
  {
    "elementType": "labels.text.fill",
    "stylers": [
      {
        "color": "#746855"
      }
    ]
  },
  {
    "elementType": "labels.text.stroke",
    "stylers": [
      {
        "color": "#242f3e"
      }
    ]
  },
  {
    "featureType": "administrative.locality",
    "elementType": "labels.text.fill",
    "stylers": [
      {
        "color": "#d59563"
      }
    ]
  },
  {
    "featureType": "poi",
    "elementType": "labels.text.fill",
    "stylers": [
      {
        "color": "#d59563"
      }
    ]
  },
  {
    "featureType": "poi.park",
    "elementType": "geometry",
    "stylers": [
      {
        "color": "#263c3f"
      }
    ]
  },
  {
    "featureType": "poi.park",
    "elementType": "labels.text.fill",
    "stylers": [
      {
        "color": "#6b9a76"
      }
    ]
  },
  {
    "featureType": "road",
    "elementType": "geometry",
    "stylers": [
      {
        "color": "#38414e"
      }
    ]
  },
  {
    "featureType": "road",
    "elementType": "geometry.stroke",
    "stylers": [
      {
        "color": "#212a37"
      }
    ]
  },
  {
    "featureType": "road",
    "elementType": "labels.text.fill",
    "stylers": [
      {
        "color": "#9ca5b3"
      }
    ]
  },
  {
    "featureType": "road.highway",
    "elementType": "geometry",
    "stylers": [
      {
        "color": "#746855"
      }
    ]
  },
  {
    "featureType": "road.highway",
    "elementType": "geometry.stroke",
    "stylers": [
      {
        "color": "#1f2835"
      }
    ]
  },
  {
    "featureType": "road.highway",
    "elementType": "labels.text.fill",
    "stylers": [
      {
        "color": "#f3d19c"
      }
    ]
  },
  {
    "featureType": "transit",
    "elementType": "geometry",
    "stylers": [
      {
        "color": "#2f3948"
      }
    ]
  },
  {
    "featureType": "transit.station",
    "elementType": "labels.text.fill",
    "stylers": [
      {
        "color": "#d59563"
      }
    ]
  },
  {
    "featureType": "water",
    "elementType": "geometry",
    "stylers": [
      {
        "color": "#17263c"
      }
    ]
  },
  {
    "featureType": "water",
    "elementType": "labels.text.fill",
    "stylers": [
      {
        "color": "#515c6d"
      }
    ]
  },
  {
    "featureType": "water",
    "elementType": "labels.text.stroke",
    "stylers": [
      {
        "color": "#17263c"
      }
    ]
  }
]
''';

  @override
  void onClose() {
    notesController.dispose();
    cashCollectedController.dispose();
    mapController?.dispose();
    stopInAppNavigation();
    EasyLoading.dismiss();
    _orderPosStreamSub?.cancel();
    super.onClose();
  }

  /// Starts turn-by-turn navigation by initializing the session,
  /// accepting terms and conditions if required, setting waypoints,
  /// and navigating to the Navigation Guideline Screen.
  Future<void> startInAppNavigation() async {
    try {
      errorMessage.value = '';

      // 1. Check/request location permissions and GPS service
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        EasyLoading.showError('GPS is turned off. Please turn on location services.');
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.deniedForever ||
          permission == LocationPermission.denied) {
        EasyLoading.showError('Location permission is required for navigation');
        return;
      }

      // 2. Validate stops
      final stops = remainingStops.isNotEmpty ? remainingStops : sortedStops;
      if (stops.isEmpty) {
        EasyLoading.showError('No stops available for navigation');
        return;
      }

      EasyLoading.show(
        status: 'Checking GPS location...',
        maskType: EasyLoadingMaskType.black,
      );

      // Force a high-accuracy GPS fix so location engine has recent position
      try {
        final pos = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high,
          timeLimit: const Duration(seconds: 4),
        );
        currentLocation.value = LatLng(pos.latitude, pos.longitude);
      } catch (e) {
        logger.w('Position check prior to navigation: $e');
      }

      // 3. Accept Google Maps Navigation Terms & Conditions
      EasyLoading.show(
        status: 'Checking navigation terms...',
        maskType: EasyLoadingMaskType.black,
      );
      final bool termsAccepted = await gnav.GoogleMapsNavigator.areTermsAccepted();
      if (!termsAccepted) {
        final bool accepted = await gnav.GoogleMapsNavigator.showTermsAndConditionsDialog(
          'ZipBee Driver Navigation',
          'ZipBee',
        );
        if (!accepted) {
          EasyLoading.dismiss();
          EasyLoading.showError('Terms and conditions must be accepted to use navigation');
          return;
        }
      }

      // 4. Initialize Navigation Session
      EasyLoading.show(
        status: 'Initializing navigation session...',
        maskType: EasyLoadingMaskType.black,
      );
      final isSessionInitialized = await gnav.GoogleMapsNavigator.isInitialized();
      if (!isSessionInitialized) {
        await gnav.GoogleMapsNavigator.initializeNavigationSession();
      }
      navigationSessionInitialized.value = true;

      // 5. Setup waypoints and destinations
      EasyLoading.show(
        status: 'Calculating route...',
        maskType: EasyLoadingMaskType.black,
      );

      final List<gnav.NavigationWaypoint> waypoints = [];
      for (var stop in stops) {
        waypoints.add(
          gnav.NavigationWaypoint(
            title: stop.isPickup ? 'Pickup ${stop.sequence}' : 'Drop ${stop.sequence}',
            target: gnav.LatLng(latitude: stop.latitude, longitude: stop.longitude),
          ),
        );
      }

      final destinations = gnav.Destinations(
        waypoints: waypoints,
        displayOptions: gnav.NavigationDisplayOptions(
          showDestinationMarkers: true,
          showStopSigns: true,
          showTrafficLights: true,
        ),
        routingOptions: gnav.RoutingOptions(
          travelMode: gnav.NavigationTravelMode.driving,
        ),
      );

      final status = await gnav.GoogleMapsNavigator.setDestinations(destinations);
      EasyLoading.dismiss();

      if (status == gnav.NavigationRouteStatus.statusOk) {
        isNavigating.value = true;
        Get.to(() => const NavigationGuidelineScreen());
      } else {
        logger.e('Failed to set destinations. Status: $status');
        if (status == gnav.NavigationRouteStatus.apiKeyNotAuthorized) {
          EasyLoading.showError('Navigation API Key not authorized by Google Cloud.');
        } else {
          EasyLoading.showError('Could not calculate route: ${status.name}');
        }
      }
    } catch (e) {
      EasyLoading.dismiss();
      logger.e('Failed to start navigation: $e');
      EasyLoading.showError('Failed to start navigation: $e');
    }
  }

  /// Sets up listener to capture real-time road-wise turn instructions stream
  void startListeningToNavInfo() {
    navInfoSubscription?.cancel();
    navInfoSubscription = gnav.GoogleMapsNavigator.setNavInfoListener((event) {
      currentNavInfo.value = event.navInfo;
    });
  }

  /// Stops in-app navigation guidance and frees up resources
  Future<void> stopInAppNavigation() async {
    try {
      if (navigationSessionInitialized.value) {
        await gnav.GoogleMapsNavigator.stopGuidance();
        await gnav.GoogleMapsNavigator.clearDestinations();
        await gnav.GoogleMapsNavigator.cleanup();
        navigationSessionInitialized.value = false;
      }
      navInfoSubscription?.cancel();
      navInfoSubscription = null;
      currentNavInfo.value = null;
      isNavigating.value = false;
      navigationViewController = null;
    } catch (e) {
      logger.w('Failed to stop navigation cleanly: $e');
      isNavigating.value = false;
    }
  }

  @override
  void onInit() {
    super.onInit();
    _loadArguments();
    _setupMapData();
  }

  Future<void> checkCustomerConfirmation() async {
    final order = orderDetail.value;
    if (order == null) return;

    if (order.userConfirmationAt == null && !order.isAutoConfirmation) {
      if (order.raiderConfirmation) {
        try {
          EasyLoading.show(
            status: 'Waiting for Customer Confirmation...',
            maskType: EasyLoadingMaskType.black,
          );
          await refreshOrderDetails();

          final updatedOrder = orderDetail.value;
          if (updatedOrder != null && updatedOrder.userConfirmationAt != null) {
            EasyLoading.showSuccess('Order Confirmed!');
          } else {
            EasyLoading.showInfo('Still waiting for Customer Confirmation.');
          }
        } catch (e) {
          EasyLoading.dismiss();
        }
      } else {
        EasyLoading.showInfo(
          'Please Call or Message $customerName to confirm the order',
        );
      }
    }
  }

  Future<void> refreshOrderDetails() async {
    final order = orderDetail.value;
    if (order == null) return;

    try {
      final updatedOrder = await _orderDetailsService.fetchOrderDetail(order.id);
      orderDetail.value = updatedOrder;
      stopList.assignAll(_sortStops(updatedOrder.orderStops));

      final currentStopId = selectedStop.value?.id;
      if (currentStopId != null) {
        final updatedStop = stopList.firstWhereOrNull((stop) => stop.id == currentStopId);
        if (updatedStop != null) {
          selectedStop.value = updatedStop;
          selectedStopData.value = updatedStop.toJson();
        }
      }
      _refreshMapData();
    } catch (e) {
      logger.e('Failed to refresh order details: $e');
    }
  }

  void _loadArguments() {
    final argument = Get.arguments;

    if (argument is Map) {
      final order = argument['order'];
      final stop = argument['stop'];
      final stopData = argument['stopData'];

      if (order is OrderModel) {
        orderDetail.value = order;
        stopList.assignAll(_sortStops(order.orderStops));
      }
      if (stop is OrderStopModel) {
        selectedStop.value = stop;
      }
      if (stopData is Map) {
        selectedStopData.value = Map<String, dynamic>.from(stopData);
      }
    } else if (argument is OrderModel) {
      orderDetail.value = argument;
    }

    selectedStop.value ??= pendingStops.firstOrNull ?? sortedStops.firstOrNull;
    selectedStopData.value ??= selectedStop.value?.toJson();
    _clearStopForm(resetNotes: false);
  }

  void _setupMapData() {
    if (sortedStops.isEmpty) {
      return;
    }

    final focusStop = selectedStop.value ?? sortedStops.first;
    initialCameraPosition.value = CameraPosition(
      target: LatLng(focusStop.latitude, focusStop.longitude),
      zoom: 14,
    );

    _refreshMapData();
    _initializeCurrentLocation();
  }

  List<OrderStopModel> get sortedStops {
    return _sortStops(stopList);
  }

  List<OrderStopModel> get pendingStops {
    return sortedStops.where((stop) => !stop.isCompleted).toList();
  }

  List<OrderStopModel> get completedStops {
    return sortedStops.where((stop) => stop.isCompleted).toList();
  }

  List<OrderStopModel> get remainingStops {
    return sortedStops.where((stop) => !stop.isCompleted).toList();
  }

  void onMapCreated(GoogleMapController controller) {
    mapController = controller;
    _animateToFitRoute();
  }

  String get currentStopType {
    final stop = selectedStop.value;
    if (stop == null) {
      return 'STOP';
    }
    return stop.isPickup ? 'PICKUP' : 'DROP';
  }

  String get currentStopAddress {
    return selectedStop.value?.address ?? 'No location found';
  }

  double get codAmount {
    final stopPayment = selectedStop.value?.payment;
    if (stopPayment == null) {
      return 0;
    }
    return double.tryParse(stopPayment.amount) ?? 0;
  }

  int get currentStopNumber {
    final stop = selectedStop.value;
    if (stop == null) {
      return 0;
    }
    return sortedStops.indexWhere((item) => item.id == stop.id) + 1;
  }

  String get customerName {
    return orderDetail.value?.user.username ?? '';
  }

  String get customerPhone {
    return orderDetail.value?.user.phone ?? '';
  }

  String? get customerImage {
    return orderDetail.value?.user.image;
  }

  bool get isBusy {
    return isUpdatingStep.value ||
        isUploading.value ||
        isCompleting.value ||
        isConfirmingOrder.value ||
        isReorderingRoute.value;
  }

  bool get isOrderConfirmed {
    final order = orderDetail.value;
    if (order == null) {
      return false;
    }

    return order.userConfirmationAt != null || order.isAutoConfirmation;
  }

  bool get needsManualOrderConfirmation {
    final order = orderDetail.value;
    if (order == null) {
      return false;
    }

    return !order.isAutoConfirmation && !order.raiderConfirmation;
  }

  String get orderConfirmationStatusText {
    final order = orderDetail.value;
    if (order == null) {
      return 'Pending Confirmation';
    }
    if (order.userConfirmationAt != null) {
      return 'Order Confirmed';
    }
    if (order.isAutoConfirmation) {
      return 'Order Auto Confirmed';
    }
    return 'Pending Confirmation';
  }

  Color get orderConfirmationStatusColor {
    final order = orderDetail.value;
    if (order == null) {
      return const Color(0xFFF5A623);
    }
    if (order.userConfirmationAt != null || order.isAutoConfirmation) {
      return const Color(0xFF1FA34A);
    }
    return const Color(0xFFF5A623);
  }

  bool get canChangeRoute {
    final order = orderDetail.value;
    if (order == null || order.isFixed) {
      return false;
    }

    return sortedStops.where((stop) => stop.isDrop).length > 1;
  }

  String get appBarTitle {
    switch (slideButtonText) {
      case 'Proceed To Pickup':
        return 'Pickup at $estimatedPickupTimeText';
      case 'Proceed To Drop':
        return 'Delivery at $estimatedCurrentDeliveryTimeText';
      case 'Arrived':
        return selectedStop.value?.isPickup == true
            ? 'Proceed To Pickup'
            : 'Proceed To Drop';
      case 'Take Photo':
        return 'Arrived';
      case 'Proceed To Load':
      case 'Proceed To Unload':
        return 'Take Photo';
      case 'Complete Stop':
        return 'Complete';
      default:
        return 'Order Process';
    }
  }

  String get estimatedPickupTimeText {
    final pickupAt = estimatedPickupAt;
    if (pickupAt == null) {
      return 'N/A';
    }

    return DateFormat('hh:mm a').format(pickupAt.toLocal());
  }

  String get estimatedCurrentDeliveryTimeText {
    final deliveryAt = estimatedCurrentDeliveryAt;
    if (deliveryAt == null) {
      return 'N/A';
    }

    return DateFormat('hh:mm a').format(deliveryAt.toLocal());
  }

  DateTime? get estimatedPickupAt {
    final order = orderDetail.value;
    final assignedAt = order?.assignAt;
    if (order == null || assignedAt == null) {
      return null;
    }

    return assignedAt.add(
      Duration(minutes: order.effectiveCollectionTimeMinutes),
    );
  }

  DateTime? get estimatedCurrentDeliveryAt {
    final pickupAt = estimatedPickupAt;
    final currentStop = selectedStop.value;
    if (pickupAt == null || currentStop == null) {
      return null;
    }

    var deliveryAt = pickupAt;
    for (final stop in sortedStops) {
      if (!stop.isDrop) {
        continue;
      }

      deliveryAt = deliveryAt.add(Duration(minutes: stop.calculatedTime ?? 0));
      if (stop.id == currentStop.id) {
        return deliveryAt;
      }
    }

    return deliveryAt;
  }

  bool get canSkipCurrentStop {
    final order = orderDetail.value;
    final stop = selectedStop.value;
    if (order == null || stop == null || order.isFixed || isBusy) {
      return false;
    }

    final status = stop.status.toUpperCase();
    return status != 'COMPLETE' &&
        status != 'COMPLETED' &&
        status != 'FAILED' &&
        !stop.isSkiped;
  }

  bool get canFailCurrentStop {
    final stop = selectedStop.value;
    if (stop == null || isBusy) {
      return false;
    }

    final status = stop.status.toUpperCase();
    return status != 'COMPLETE' &&
        status != 'COMPLETED' &&
        status != 'FAILED' &&
        !stop.isSkiped;
  }

  bool get hasUploadedProof {
    return uploadedProofUrls.isNotEmpty;
  }

  bool get isCurrentStopUnpaid {
    final status = _readNestedString(selectedStopData.value, [
      ['payment', 'status'],
    ]);
    return status.toUpperCase() == 'UNPAID';
  }

  String get slideButtonText {
    final stop = selectedStop.value;
    final data = selectedStopData.value;
    if (stop == null || data == null) {
      return 'No Stop';
    }

    final rawStatus = _readString(data, ['status']).toUpperCase();
    if (rawStatus == 'FAILED' || _readBool(data, ['is_skiped'])) {
      return 'Try Again';
    }
    if (!_readBool(data, ['proceed_to_pickup'])) {
      return stop.isPickup ? 'Proceed To Pickup' : 'Proceed To Drop';
    }
    if (!_readBool(data, ['is_arrived'])) {
      return 'Arrived';
    }
    if (!hasUploadedProof) {
      return 'Take Photo';
    }
    if (stop.isPickup && !_readBool(data, ['is_load'])) {
      return 'Proceed To Load';
    }
    if (stop.isDrop && !_readBool(data, ['is_unload'])) {
      return 'Proceed To Unload';
    }
    return 'Complete Stop';
  }

  String? get progressStepValue {
    switch (slideButtonText) {
      case 'Try Again':
      case 'Proceed To Pickup':
      case 'Proceed To Drop':
        return 'PROCEED';
      case 'Arrived':
        return 'ARRIVED';
      case 'Proceed To Load':
        return 'LOADED';
      case 'Proceed To Unload':
        return 'UNLOADED';
      default:
        return null;
    }
  }

  String? get latestActionLabel {
    final action = latestActionInfo;
    if (action == null) {
      return null;
    }
    return '${action.$1} at';
  }

  String? get latestActionValue {
    final action = latestActionInfo;
    if (action == null) {
      return null;
    }
    return action.$2;
  }

  (String, String)? get latestActionInfo {
    final data = selectedStopData.value;
    if (data == null) {
      return null;
    }

    final actionFields = <(String, String)>[
      ('Unloaded', _readString(data, ['unloadedAt'])),
      ('Loaded', _readString(data, ['loadedAt'])),
      ('Arrived', _readString(data, ['arrivedStepAt'])),
      ('Proceed', _readString(data, ['proceedAt'])),
    ];

    for (final action in actionFields) {
      if (action.$2.isNotEmpty) {
        return (action.$1, _formatDateTime(action.$2));
      }
    }

    return null;
  }

  String stopTitle(OrderStopModel stop) {
    final contactName = stop.destinationContactName.trim();
    if (contactName.isNotEmpty) {
      return contactName;
    }
    return stop.isPickup ? 'Pickup ${stop.sequence}' : 'Drop ${stop.sequence}';
  }

  String statusText(OrderStopModel stop) {
    final rawStatus = stop.status.toUpperCase();

    if (rawStatus == 'COMPLETE' || rawStatus == 'COMPLETED') {
      return 'COMPLETE';
    } else if (rawStatus == 'FAILED') {
      return 'FAILED';
    } else if (stop.isSkiped) {
      return 'SKIPED';
    } else if (stop.isPickup && stop.isLoad) {
      return 'LOADED';
    } else if (stop.isDrop && stop.isUnload) {
      return 'UNLOADED';
    } else if (stop.isArrived) {
      return 'ARRIVED';
    } else if (stop.proceedToPickup) {
      return 'PROCEED';
    } else {
      return 'PENDING';
    }
  }

  Color statusColor(OrderStopModel stop) {
    switch (statusText(stop)) {
      case 'COMPLETE':
        return const Color(0xFF2E7D32);
      case 'FAILED':
        return const Color(0xFFC62828);
      case 'SKIPED':
        return const Color(0xFFEF6C00);
      case 'UNLOADED':
        return const Color(0xFF1565C0);
      case 'LOADED':
        return const Color(0xFF6A1B9A);
      case 'ARRIVED':
        return const Color(0xFF00838F);
      case 'PROCEED':
        return const Color(0xFFF9A825);
      case 'PENDING':
        return const Color(0xFF6B7280);
      default:
        return const Color(0xFF00695C);
    }
  }

  Color statusBackgroundColor(OrderStopModel stop) {
    switch (statusText(stop)) {
      case 'COMPLETE':
        return const Color(0xFFE8F5E9);
      case 'FAILED':
        return const Color(0xFFFFEBEE);
      case 'SKIPED':
        return const Color(0xFFFFF3E0);
      case 'UNLOADED':
        return const Color(0xFFE3F2FD);
      case 'LOADED':
        return const Color(0xFFEDE7F6);
      case 'ARRIVED':
        return const Color(0xFFE0F7FA);
      case 'PROCEED':
        return const Color(0xFFFFF8E1);
      case 'PENDING':
        return const Color(0xFFF3F4F6);
      default:
        return const Color(0xFFE0F2F1);
    }
  }

  String amountText() {
    final order = orderDetail.value;
    if (order == null) {
      return '\$0.00';
    }

    final total = double.tryParse(order.totalCost) ?? 0;
    return '\$${total.toStringAsFixed(2)}';
  }

  String orderTypeText() {
    final order = orderDetail.value;
    if (order == null) {
      return 'N/A';
    }

    return '${_formatValue(order.deliveryType)} / ${_formatValue(order.routeType)}';
  }

  String paymentTypeText() {
    final order = orderDetail.value;
    if (order == null) {
      return 'N/A';
    }

    if (order.payType.toUpperCase() == 'COD') {
      return 'Cash on Delivery';
    }

    return _formatValue(order.payType);
  }

  String _formatValue(String value) {
    return value.replaceAll('_', ' ');
  }

  void resetSlider() {
    dragX.value = 0;
  }

  Future<void> handleSlideAction() async {
    if (isBusy) {
      return;
    }

    final action = slideButtonText;
    if (action == 'Try Again') {
      await retryCurrentStop();
      return;
    }

    if (action == 'Take Photo') {
      await showPhotoSourcePicker();
      return;
    }

    if (action == 'Complete Stop') {
      await completeCurrentStop();
      return;
    }

    await updateCurrentStopProgress();
  }

  Future<void> skipCurrentStop() async {
    final stop = selectedStop.value;
    if (stop == null) {
      return;
    }

    try {
      isUpdatingStep.value = true;
      errorMessage.value = '';

      final response = await orderStopProgressService.skipStop(stopId: stop.id);
      final mergedStop = _extractMergedStopPayload(
        response,
        fallback: {...stop.toJson(), 'is_skiped': true},
      );
      _replaceStopData(mergedStop);

      final nextStop = remainingStops.firstWhereOrNull(
        (item) => item.id != stop.id,
      );
      if (nextStop != null) {
        _loadSelectedStop(nextStop, clearForms: true);
      }

      EasyLoading.showSuccess(
        _extractResponseMessage(response) ?? 'Stop skipped successfully',
      );
    } catch (e) {
      errorMessage.value = _cleanError(e);
      EasyLoading.showError(errorMessage.value);
    } finally {
      isUpdatingStep.value = false;
    }
  }

  Future<void> failCurrentStop(String reason) async {
    final stop = selectedStop.value;
    if (stop == null) {
      return;
    }

    final trimmedReason = reason.trim();
    if (trimmedReason.isEmpty) {
      errorMessage.value = 'Please enter failure reason';
      EasyLoading.showError(errorMessage.value);
      return;
    }

    try {
      isUpdatingStep.value = true;
      errorMessage.value = '';

      final response = await orderStopProgressService.failStop(
        stopId: stop.id,
        reason: trimmedReason,
      );
      final mergedStop = _extractMergedStopPayload(
        response,
        fallback: {
          ...stop.toJson(),
          'status': 'FAILED',
          'failureReason': trimmedReason,
          'failedAt': DateTime.now().toUtc().toIso8601String(),
        },
      );
      _replaceStopData(mergedStop);

      EasyLoading.showSuccess(
        _extractResponseMessage(response) ?? 'Stop failed successfully',
      );
    } catch (e) {
      errorMessage.value = _cleanError(e);
      EasyLoading.showError(errorMessage.value);
    } finally {
      isUpdatingStep.value = false;
    }
  }

  Future<void> retryCurrentStop() async {
    final stop = selectedStop.value;
    if (stop == null) {
      return;
    }

    try {
      isUpdatingStep.value = true;
      errorMessage.value = '';

      final response = await orderStopProgressService.retryStop(
        stopId: stop.id,
      );
      final mergedStop = _extractMergedStopPayload(
        response,
        fallback: {
          ...stop.toJson(),
          'status': 'PENDING',
          'is_skiped': false,
          'failureReason': null,
          'failedAt': null,
        },
      );
      _replaceStopData(mergedStop);
      _clearStopForm();

      EasyLoading.showSuccess(
        _extractResponseMessage(response) ?? 'Retry started successfully',
      );
    } catch (e) {
      errorMessage.value = _cleanError(e);
      EasyLoading.showError(errorMessage.value);
    } finally {
      isUpdatingStep.value = false;
    }
  }

  Future<void> updateCurrentStopProgress() async {
    final stop = selectedStop.value;
    final step = progressStepValue;
    if (stop == null || step == null) {
      return;
    }

    try {
      isUpdatingStep.value = true;
      errorMessage.value = '';

      final response = await orderStopProgressService.updateStopProgress(
        stopId: stop.id,
        step: step,
      );

      final responseStop = response['data'] is Map<String, dynamic>
          ? response['data']['stop'] as Map<String, dynamic>?
          : null;
      if (responseStop == null) {
        throw Exception('Stop data not found in response');
      }

      final mergedStop = _mergeStopPayload(
        selectedStopData.value,
        Map<String, dynamic>.from(responseStop),
      );
      _replaceStopData(mergedStop);

      EasyLoading.showSuccess(
        response['data']?['message']?.toString() ?? 'Progress updated',
      );
    } catch (e) {
      errorMessage.value = _cleanError(e);
      EasyLoading.showError(errorMessage.value);
    } finally {
      isUpdatingStep.value = false;
    }
  }

  Future<void> showPhotoSourcePicker() async {
    final choice = await Get.bottomSheet<String>(
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt_outlined),
              title: const Text('Use Camera'),
              onTap: () => Get.back(result: 'camera'),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library_outlined),
              title: const Text('Choose From Gallery'),
              onTap: () => Get.back(result: 'gallery'),
            ),
          ],
        ),
      ),
    );

    if (choice == 'camera') {
      await openCamera();
    } else if (choice == 'gallery') {
      await openGallery();
    }
  }

  Future<void> openCamera() async {
    try {
      final XFile? image = await picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 70,
      );
      if (image != null) {
        await _uploadSelectedImages([image.path]);
      }
    } catch (e) {
      errorMessage.value = 'Failed to capture photo';
      EasyLoading.showError(errorMessage.value);
    }
  }

  Future<void> openGallery() async {
    try {
      final List<XFile> images = await picker.pickMultiImage(imageQuality: 70);
      if (images.isNotEmpty) {
        await _uploadSelectedImages(images.map((e) => e.path).toList());
      }
    } catch (e) {
      errorMessage.value = 'Failed to select photos';
      EasyLoading.showError(errorMessage.value);
    }
  }

  Future<void> _uploadSelectedImages(List<String> imagePaths) async {
    final uniquePaths = imagePaths
        .where((path) => path.isNotEmpty)
        .toSet()
        .toList();
    if (uniquePaths.isEmpty) {
      return;
    }

    for (final path in uniquePaths) {
      if (!await File(path).exists()) {
        throw Exception('Image file not found');
      }
    }

    try {
      isUploading.value = true;
      errorMessage.value = '';
      selectedImages.addAll(
        uniquePaths.where((path) => !selectedImages.contains(path)),
      );

      final urls = await fileUploadService.uploadFiles(uniquePaths);
      uploadedProofUrls.addAll(
        urls.where((url) => !uploadedProofUrls.contains(url)),
      );
      EasyLoading.showSuccess('${urls.length} photo uploaded');
    } catch (e) {
      selectedImages.removeWhere((path) => uniquePaths.contains(path));
      errorMessage.value = _cleanError(e);
      EasyLoading.showError(errorMessage.value);
    } finally {
      isUploading.value = false;
    }
  }

  void removeImage(int index) {
    if (index < 0 || index >= selectedImages.length) {
      return;
    }

    selectedImages.removeAt(index);
    if (index < uploadedProofUrls.length) {
      uploadedProofUrls.removeAt(index);
    }
  }

  Future<void> completeCurrentStop() async {
    final stop = selectedStop.value;
    if (stop == null) {
      return;
    }

    if (uploadedProofUrls.isEmpty) {
      errorMessage.value = 'Please upload at least one proof photo';
      EasyLoading.showError(errorMessage.value);
      return;
    }

    try {
      isCompleting.value = true;
      errorMessage.value = '';

      final codCollected = double.tryParse(cashCollectedController.text.trim());
      final response = await orderCompletionService.completeOrderStop(
        stopId: stop.id,
        proofUrls: uploadedProofUrls.toList(),
        notes: notesController.text.trim().isEmpty
            ? null
            : notesController.text.trim(),
        codCollected: cashCollectedController.text.trim().isEmpty
            ? null
            : codCollected,
      );

      final completedStop = _mergeStopPayload(selectedStopData.value, {
        'status': 'COMPLETED',
        'completedAt': DateTime.now().toUtc().toIso8601String(),
        'proofs': uploadedProofUrls.toList(),
        'notes': notesController.text.trim().isEmpty
            ? null
            : notesController.text.trim(),
      });
      _replaceStopData(completedStop);

      final data = response['data'] as Map<String, dynamic>?;
      final orderCompleted = data?['orderCompleted'] == true;

      if (orderCompleted || pendingStops.isEmpty) {
        EasyLoading.showSuccess('Stop completed successfully');
        Get.offAll(
          () => DeliverySuccessScreen(),
          arguments: {'userName': customerName},
        );
        return;
      }

      final nextStop = pendingStops.firstWhereOrNull(
        (item) => item.id != stop.id,
      );
      if (nextStop != null) {
        _loadSelectedStop(nextStop, clearForms: true);
        EasyLoading.showSuccess('Stop completed. Loading next stop...');
      }
    } catch (e) {
      errorMessage.value = _cleanError(e);
      EasyLoading.showError(errorMessage.value);
    } finally {
      isCompleting.value = false;
    }
  }

  Future<bool> confirmOrderIfNeeded() async {
    if (!needsManualOrderConfirmation) {
      return true;
    }

    final order = orderDetail.value;
    if (order == null || isConfirmingOrder.value) {
      return false;
    }

    try {
      isConfirmingOrder.value = true;
      errorMessage.value = '';

      final token = await SharedPreferencesHelper.getAccessToken();
      if (token == null || token.isEmpty) {
        throw Exception('Access token not found');
      }

      final response = await http.patch(
        Uri.parse(ApiEndPoint.orderRaiderConfirmation(order.id)),
        headers: {'accept': '*/*', 'Authorization': 'Bearer $token'},
      );

      final isSuccessful =
          response.statusCode >= 200 && response.statusCode < 300;
      if (!isSuccessful) {
        final message = response.body.isNotEmpty
            ? _extractHttpErrorMessage(response.body)
            : 'Failed to confirm order';
        throw Exception(message);
      }

      _updateOrderConfirmationState(raiderConfirmation: true);
      return true;
    } catch (e) {
      errorMessage.value = _cleanError(e);
      EasyLoading.showError(errorMessage.value);
      return false;
    } finally {
      isConfirmingOrder.value = false;
    }
  }

  Future<bool> reorderDropStops(List<OrderStopModel> dropStops) async {
    final order = orderDetail.value;
    if (order == null || dropStops.length < 2 || isReorderingRoute.value) {
      return false;
    }

    try {
      isReorderingRoute.value = true;
      errorMessage.value = '';

      final token = await SharedPreferencesHelper.getAccessToken();
      if (token == null || token.isEmpty) {
        throw Exception('Access token not found');
      }

      final response = await http.patch(
        Uri.parse(ApiEndPoint.reorderOrderStops(order.id)),
        headers: {
          'accept': '*/*',
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'stops': dropStops.asMap().entries.map((entry) {
            return {'orderStopId': entry.value.id, 'sequence': entry.key + 1};
          }).toList(),
        }),
      );

      final isSuccessful =
          response.statusCode >= 200 && response.statusCode < 300;
      if (!isSuccessful) {
        final message = response.body.isNotEmpty
            ? _extractHttpErrorMessage(response.body)
            : 'Failed to change route';
        throw Exception(message);
      }

      if (Get.isDialogOpen ?? false) {
        Get.back();
      }

      EasyLoading.showSuccess('Route changed successfully');
      Get.back();
      return true;
    } catch (e) {
      errorMessage.value = _cleanError(e);
      EasyLoading.showError(errorMessage.value);
      return false;
    } finally {
      isReorderingRoute.value = false;
    }
  }

  void _updateOrderConfirmationState({bool? raiderConfirmation}) {
    final order = orderDetail.value;
    if (order == null) {
      return;
    }

    final updatedOrderJson = Map<String, dynamic>.from(
      order.toJson(),
    )..['raider_confirmation'] = raiderConfirmation ?? order.raiderConfirmation;
    orderDetail.value = OrderModel.fromJson(updatedOrderJson);
  }

  void _loadSelectedStop(OrderStopModel stop, {bool clearForms = false}) {
    selectedStop.value = stop;
    selectedStopData.value = stop.toJson();
    if (clearForms) {
      _clearStopForm();
    }
    _refreshMapData();
  }

  void _replaceStopData(Map<String, dynamic> stopData) {
    final updatedStop = OrderStopModel.fromJson(stopData);
    final index = stopList.indexWhere((item) => item.id == updatedStop.id);
    if (index != -1) {
      stopList[index] = updatedStop;
      stopList.refresh();
    }
    selectedStop.value = updatedStop;
    selectedStopData.value = stopData;
    _refreshMapData();
  }

  Map<String, dynamic> _extractMergedStopPayload(
    Map<String, dynamic> response, {
    Map<String, dynamic>? fallback,
  }) {
    final data = response['data'];
    Map<String, dynamic>? responseStop;

    if (data is Map<String, dynamic>) {
      final nestedStop = data['stop'];
      if (nestedStop is Map<String, dynamic>) {
        responseStop = Map<String, dynamic>.from(nestedStop);
      } else if (nestedStop is Map) {
        responseStop = Map<String, dynamic>.from(nestedStop);
      } else if (data['data'] is Map<String, dynamic>) {
        responseStop = Map<String, dynamic>.from(data['data']);
      } else if (data['data'] is Map) {
        responseStop = Map<String, dynamic>.from(data['data']);
      } else if (data['orderStop'] is Map<String, dynamic>) {
        responseStop = Map<String, dynamic>.from(data['orderStop']);
      } else if (data['orderStop'] is Map) {
        responseStop = Map<String, dynamic>.from(data['orderStop']);
      } else {
        responseStop = Map<String, dynamic>.from(data);
      }
    } else if (response['stop'] is Map<String, dynamic>) {
      responseStop = Map<String, dynamic>.from(response['stop']);
    } else if (response['stop'] is Map) {
      responseStop = Map<String, dynamic>.from(response['stop']);
    }

    if (!_isValidStopPayload(responseStop)) {
      if (fallback == null || fallback.isEmpty) {
        throw Exception('Stop data not found in response');
      }
      responseStop = Map<String, dynamic>.from(fallback);
    }

    return _mergeStopPayload(selectedStopData.value, responseStop!);
  }

  bool _isValidStopPayload(Map<String, dynamic>? payload) {
    if (payload == null || payload.isEmpty) {
      return false;
    }

    final hasStopIdentity =
        payload.containsKey('id') &&
        (payload.containsKey('status') ||
            payload.containsKey('type') ||
            payload.containsKey('sequence'));

    final hasStopFlags =
        payload.containsKey('proceed_to_pickup') ||
        payload.containsKey('is_arrived') ||
        payload.containsKey('is_load') ||
        payload.containsKey('is_unload') ||
        payload.containsKey('is_skiped');

    return hasStopIdentity || hasStopFlags;
  }

  String? _extractResponseMessage(Map<String, dynamic> response) {
    final data = response['data'];
    if (data is Map && data['message'] != null) {
      return data['message'].toString();
    }
    if (response['message'] != null) {
      return response['message'].toString();
    }
    return null;
  }

  String _extractHttpErrorMessage(String body) {
    try {
      final decoded = jsonDecode(body);
      if (decoded is Map<String, dynamic>) {
        if (decoded['message'] != null) {
          return decoded['message'].toString();
        }
        if (decoded['error'] != null) {
          return decoded['error'].toString();
        }
      }
    } catch (_) {}

    return 'Failed to confirm order';
  }

  Map<String, dynamic> _mergeStopPayload(
    Map<String, dynamic>? existing,
    Map<String, dynamic> next,
  ) {
    final merged = <String, dynamic>{...?existing, ...next};
    if (merged['destination'] == null && existing?['destination'] != null) {
      merged['destination'] = existing!['destination'];
    }
    if (merged['payment'] == null && existing?['payment'] != null) {
      merged['payment'] = existing!['payment'];
    }
    return merged;
  }

  void _clearStopForm({bool resetNotes = true}) {
    if (resetNotes) {
      notesController.clear();
    }
    cashCollectedController.text = codAmount % 1 == 0
        ? codAmount.toInt().toString()
        : codAmount.toStringAsFixed(2);
    selectedImages.clear();
    uploadedProofUrls.clear();
    errorMessage.value = '';
  }

  Future<void> _initializeCurrentLocation() async {
    try {
      final isServiceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!isServiceEnabled) {
        logger.w('Location services are disabled for order progress map');
        _refreshMapData();
        return;
      }

      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        logger.w('Location permission unavailable for order progress map');
        _refreshMapData();
        return;
      }

      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        forceAndroidLocationManager: true,
        timeLimit: const Duration(seconds: 10),
      );

      currentLocation.value = LatLng(position.latitude, position.longitude);
      _refreshMapData();

      // Continuously update driver location and marker as rider moves
      _orderPosStreamSub?.cancel();
      _orderPosStreamSub = Geolocator.getPositionStream(
        locationSettings: getLocationSettings(
          accuracy: LocationAccuracy.high,
          distanceFilter: 0,
          intervalDuration: const Duration(seconds: 1),
        ),
      ).listen((pos) {
        currentLocation.value = LatLng(pos.latitude, pos.longitude);
        _refreshMapData();
      });
    } catch (e) {
      logger.e('Failed to load current location for order progress map: $e');
      _refreshMapData();
    }
  }

  void _refreshMapData() {
    final routeStops = _orderedRouteStops();
    _createMarkers(routeStops);
    _createRoutePolyline(routeStops);
  }

  List<OrderStopModel> _orderedRouteStops() {
    final pickups = sortedStops.where((stop) => stop.isPickup).toList()
      ..sort((a, b) => a.sequence.compareTo(b.sequence));
    final drops = sortedStops.where((stop) => stop.isDrop).toList()
      ..sort((a, b) => a.sequence.compareTo(b.sequence));
    return [...pickups, ...drops];
  }

  Future<void> _createMarkers(List<OrderStopModel> orderedStops) async {
    try {
      final nextMarkers = <Marker>[];

      final driverLocation = currentLocation.value;
      if (driverLocation != null) {
        final driverIcon = await CustomMapMarkerHelper.getRiderMarker();
        nextMarkers.add(
          Marker(
            markerId: const MarkerId('driver_current_location'),
            position: driverLocation,
            anchor: CustomMapMarkerHelper.defaultAnchor,
            infoWindow: const InfoWindow(title: 'Driver Current Location'),
            icon: driverIcon,
          ),
        );
      }

      final totalDrops = orderedStops.where((stop) => stop.isDrop).length;
      final showNumbers = totalDrops > 1;

      int dropCount = 0;

      for (var i = 0; i < orderedStops.length; i++) {
        final stop = orderedStops[i];
        final isPickup = stop.isPickup;

        String title;
        BitmapDescriptor icon;

        if (isPickup) {
          title = 'Pickup';
          icon = await CustomMapMarkerHelper.getPickupMarker();
        } else {
          dropCount++;
          title = 'Drop Number $dropCount';
          if (showNumbers) {
            icon = await CustomMapMarkerHelper.getNumberedDropMarker(
              number: dropCount,
            );
          } else {
            icon = await CustomMapMarkerHelper.getDropMarker();
          }
        }

        nextMarkers.add(
          Marker(
            markerId: MarkerId('stop_${stop.id}_${stop.sequence}'),
            position: LatLng(stop.latitude, stop.longitude),
            anchor: CustomMapMarkerHelper.defaultAnchor,
            infoWindow: InfoWindow(title: title, snippet: stop.address),
            icon: icon,
          ),
        );
      }

      markers.assignAll(nextMarkers);
      markers.refresh();
    } catch (e, stack) {
      logger.e('Error inside _createMarkers: $e\n$stack');
    }
  }

  int get pickupsCount => sortedStops.where((stop) => stop.isPickup).length;

  Future<void> _createRoutePolyline(List<OrderStopModel> orderedStops) async {
    polylines.assignAll(<Polyline>{});

    if (orderedStops.isEmpty) {
      routePoints.clear();
      return;
    }

    final driverLoc = currentLocation.value;
    final pickupLoc = LatLng(orderedStops.first.latitude, orderedStops.first.longitude);
    final restStops = orderedStops.skip(1).map((stop) => LatLng(stop.latitude, stop.longitude)).toList();

    List<LatLng> driverToPickupPoints = [];
    List<LatLng> pickupOnwardPoints = [];

    // 1. Fetch driver to pickup path (yellow line)
    if (driverLoc != null) {
      driverToPickupPoints = await OsrmRouteService.getRoutePoints([driverLoc, pickupLoc]);
    }

    // 2. Fetch pickup onward path (blue line)
    final onwardSequence = [pickupLoc, ...restStops];
    if (onwardSequence.length >= 2) {
      pickupOnwardPoints = await OsrmRouteService.getRoutePoints(onwardSequence);
    }

    final nextPolylines = <Polyline>{};
    if (driverToPickupPoints.length >= 2) {
      nextPolylines.add(
        Polyline(
          polylineId: const PolylineId('driver_to_pickup_route'),
          points: driverToPickupPoints,
          color: const Color(0xFFFFCC00), // ZipBee primary color yellow
          width: 5,
          geodesic: true,
        ),
      );
    }

    if (pickupOnwardPoints.length >= 2) {
      nextPolylines.add(
        Polyline(
          polylineId: const PolylineId('pickup_onward_route'),
          points: pickupOnwardPoints,
          color: const Color(0xFF1565C0), // Blue
          width: 5,
          geodesic: true,
        ),
      );
    }

    polylines.assignAll(nextPolylines);

    routePoints.assignAll([
      ...driverToPickupPoints,
      ...pickupOnwardPoints,
    ]);

    _animateToFitRoute();
  }

  void _animateToFitRoute() {
    if (mapController == null) {
      return;
    }

    final boundsPoints = routePoints.isNotEmpty
        ? routePoints.toList()
        : [
            if (currentLocation.value != null) currentLocation.value!,
            ...sortedStops.map((stop) => LatLng(stop.latitude, stop.longitude)),
          ];

    if (boundsPoints.isEmpty) {
      return;
    }

    if (boundsPoints.length == 1) {
      mapController!.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(target: boundsPoints.first, zoom: 14),
        ),
      );
      return;
    }

    double minLat = boundsPoints.first.latitude;
    double maxLat = boundsPoints.first.latitude;
    double minLng = boundsPoints.first.longitude;
    double maxLng = boundsPoints.first.longitude;

    for (final point in boundsPoints.skip(1)) {
      if (point.latitude < minLat) minLat = point.latitude;
      if (point.latitude > maxLat) maxLat = point.latitude;
      if (point.longitude < minLng) minLng = point.longitude;
      if (point.longitude > maxLng) maxLng = point.longitude;
    }

    mapController!.animateCamera(
      CameraUpdate.newLatLngBounds(
        LatLngBounds(
          southwest: LatLng(minLat, minLng),
          northeast: LatLng(maxLat, maxLng),
        ),
        70,
      ),
    );
  }

  List<OrderStopModel> _sortStops(List<OrderStopModel> stops) {
    final sorted = [...stops];
    sorted.sort((a, b) => a.sequence.compareTo(b.sequence));
    return sorted;
  }

  bool _readBool(Map<String, dynamic>? json, List<String> keys) {
    if (json == null) {
      return false;
    }
    for (final key in keys) {
      final value = json[key];
      if (value is bool) {
        return value;
      }
      if (value is String) {
        return value.toLowerCase() == 'true';
      }
      if (value is num) {
        return value != 0;
      }
    }
    return false;
  }

  String _readString(Map<String, dynamic>? json, List<String> keys) {
    if (json == null) {
      return '';
    }
    for (final key in keys) {
      final value = json[key];
      if (value is String) {
        return value;
      }
      if (value != null) {
        return value.toString();
      }
    }
    return '';
  }

  String _readNestedString(
    Map<String, dynamic>? json,
    List<List<String>> paths,
  ) {
    if (json == null) {
      return '';
    }
    for (final path in paths) {
      dynamic current = json;
      for (final segment in path) {
        if (current is Map && current.containsKey(segment)) {
          current = current[segment];
        } else {
          current = null;
          break;
        }
      }
      if (current is String) {
        return current;
      }
      if (current != null) {
        return current.toString();
      }
    }
    return '';
  }

  String _formatDateTime(String isoString) {
    final parsed = DateTime.tryParse(isoString);
    if (parsed == null) {
      return isoString;
    }
    final local = parsed.toLocal();
    final time = DateFormat('h:mm a').format(local);
    final date = DateFormat('d MMMM yyyy').format(local);
    return '$time, $date';
  }

  String _cleanError(Object error) {
    final text = error.toString();
    if (text.startsWith('Exception: ')) {
      return text.replaceFirst('Exception: ', '');
    }
    return text;
  }
}
