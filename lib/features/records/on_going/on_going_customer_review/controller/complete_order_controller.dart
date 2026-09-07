// ignore_for_file: deprecated_member_use

import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:logger/logger.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:ZipBee_Driver/core/services/osrm_route_service.dart';
import 'package:ZipBee_Driver/core/services/file_upload_service.dart';
import 'package:ZipBee_Driver/core/services/order_completion_service.dart';
import 'package:ZipBee_Driver/core/network_sevice/http_network_client.dart';
import 'package:ZipBee_Driver/core/api_end_point/api_end_point.dart';
import 'package:ZipBee_Driver/features/home/model/order_model.dart';
import 'package:ZipBee_Driver/features/home/model/user_model.dart';
import 'package:ZipBee_Driver/features/home/model/order_stop_model.dart';
import 'package:ZipBee_Driver/core/utils/custom_map_marker_helper.dart';

class CompleteOrderController extends GetxController {
  // Order data
  var orderDetail = Rxn<OrderModel>();
  var currentStopId = 0.obs;
  var currentStopAddress = ''.obs;
  var currentStopType = ''.obs; // PICKUP or DROP
  var completedStops = <int>[].obs;
  var remainingStops = <int>[].obs;

  // User data
  var customerInfo = Rxn<UserModel>();
  var isLoadingCustomer = false.obs;

  // Form fields
  var notesController = TextEditingController();
  var codAmount = 0.0.obs;
  var selectedImages = <String>[].obs;

  // State
  var isLoading = false.obs;
  var isUploading = false.obs;
  var isCompleting = false.obs;
  var uploadProgress = 0.0.obs;
  var errorMessage = ''.obs;

  // Slider state
  var dragX = 0.0.obs;

  // Map related
  GoogleMapController? mapController;
  var markers = <Marker>{}.obs;
  var polylines = <Polyline>{}.obs;
  var pickupLocation = Rx<LatLng?>(null);
  var dropoffLocation = Rx<LatLng?>(null);
  var routePoints = <LatLng>[].obs;

  final ImagePicker picker = ImagePicker();
  final fileUploadService = FileUploadService();
  final orderCompletionService = OrderCompletionService();
  final httpNetworkClient = HttpNetworkClient();
  final logger = Logger();

  @override
  void onInit() {
    super.onInit();
    // Get order data from arguments
    final order = Get.arguments as OrderModel?;
    if (order != null) {
      orderDetail.value = order;

      // Fetch customer information
      _fetchCustomerInfo(order.userId);

      // Separate stops: PICKUP first, then DROP
      final pickupStops = order.orderStops
          .where((stop) => stop.type == 'PICKUP')
          .map((stop) => stop.id)
          .toList();

      final dropStops = order.orderStops
          .where((stop) => stop.type == 'DROP')
          .map((stop) => stop.id)
          .toList();

      // Order: PICKUP stops first, then DROP stops
      remainingStops.value = [...pickupStops, ...dropStops];

      // Set COD amount if applicable
      if (order.payType == 'COD') {
        codAmount.value = double.tryParse(order.totalCost) ?? 0.0;
      }

      // Load first stop
      _loadNextStop();
      _initializeMapData();

      logger.i(
        'Initialized with order: ${order.id}, total stops: ${remainingStops.length}',
      );
    }
  }

  /// Fetch customer information by user ID
  Future<void> _fetchCustomerInfo(int userId) async {
    try {
      isLoadingCustomer.value = true;
      final url = '${ApiEndPoint.getUserById}/$userId';

      final response = await httpNetworkClient.getRequest(url: url);

      if (response.isSuccess && response.responseData != null) {
        final userData = response.responseData?['data'];
        if (userData != null) {
          customerInfo.value = UserModel.fromJson(userData);
          logger.i('Customer info fetched: ${customerInfo.value?.username}');
        }
      } else {
        logger.e('Failed to fetch customer info: ${response.errorMessage}');
      }
    } catch (e) {
      logger.e('Error fetching customer info: $e');
    } finally {
      isLoadingCustomer.value = false;
    }
  }

  /// Initialize map with markers and polyline
  void _initializeMapData() {
    final order = orderDetail.value;
    if (order == null) return;

    final orderedStops = _getOrderedStops(order);
    if (orderedStops.isEmpty) return;

    final pickupStop = orderedStops.first;
    final dropStop = orderedStops.last;

    // Parse locations
    try {
      final pickupLat = pickupStop.latitude;
      final pickupLng = pickupStop.longitude;
      final dropLat = dropStop.latitude;
      final dropLng = dropStop.longitude;

      pickupLocation.value = LatLng(pickupLat, pickupLng);
      dropoffLocation.value = LatLng(dropLat, dropLng);

      // Create markers
      _createMarkers(orderedStops);

      // Create route polyline that follows roads
      _createRoutePolyline(orderedStops);
    } catch (e) {
      logger.e('Error initializing map data: $e');
    }
  }

  /// Create markers for pickup and drop locations
  Future<void> _createMarkers(List<OrderStopModel> orderedStops) async {
    try {
      final nextMarkers = <Marker>{};
      final totalDrops = orderedStops.where((stop) => stop.type == 'DROP').length;
      final showNumbers = totalDrops > 1;

      int dropCount = 0;

      for (var i = 0; i < orderedStops.length; i++) {
        final stop = orderedStops[i];
        final stopLatLng = LatLng(stop.latitude, stop.longitude);
        final isPickup = stop.type == 'PICKUP';

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
            markerId: MarkerId('stop_${stop.id}_$i'),
            position: stopLatLng,
            anchor: CustomMapMarkerHelper.defaultAnchor,
            infoWindow: InfoWindow(
              title: title,
              snippet: stop.address,
            ),
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

  Future<void> _createRoutePolyline(List<OrderStopModel> orderedStops) async {
    polylines.assignAll(<Polyline>{});
    polylines.refresh();

    if (orderedStops.length < 2) {
      routePoints.assignAll(
        orderedStops
            .map((stop) => LatLng(stop.latitude, stop.longitude))
            .toList(),
      );
      _updatePolyline(routePoints);
      return;
    }

    final waypoints = orderedStops
        .map((stop) => LatLng(stop.latitude, stop.longitude))
        .toList();

    final points = await OsrmRouteService.getRoutePoints(waypoints);

    routePoints.assignAll(points);
    _updatePolyline(routePoints);
    _animateToFitRoute();
  }

  void _updatePolyline(List<LatLng> points) {
    if (points.length < 2) {
      polylines.assignAll(<Polyline>{});
      polylines.refresh();
      return;
    }

    polylines.assignAll({
      Polyline(
        polylineId: const PolylineId('route'),
        points: points,
        color: const Color(0xFF1565C0), // Blue path
        width: 6,
        geodesic: true,
      ),
    });
    polylines.refresh();
    logger.i('Polyline updated with ${points.length} points');
  }

  /// Handle map creation
  void onMapCreated(GoogleMapController controller) {
    mapController = controller;
    _animateToFitRoute();
  }

  /// Load the next stop to complete
  void _loadNextStop() {
    if (remainingStops.isEmpty) {
      logger.i('All stops completed!');
      return;
    }

    final nextStopId = remainingStops.first;
    final order = orderDetail.value;

    if (order != null) {
      final stop = order.orderStops.firstWhere(
        (s) => s.id == nextStopId,
        orElse: () => order.orderStops.first,
      );

      currentStopId.value = stop.id;
      currentStopAddress.value = stop.address;
      currentStopType.value = stop.type;
      selectedImages.clear();
      notesController.clear();
      errorMessage.value = '';

      logger.i('Loaded ${stop.type} stop: ${stop.address}');
    }
  }

  List<OrderStopModel> _getOrderedStops(OrderModel order) {
    final pickupStops = order.orderStops.where((stop) => stop.type == 'PICKUP');
    final dropStops = order.orderStops.where((stop) => stop.type == 'DROP');

    final orderedStops = [...pickupStops, ...dropStops].toList()
      ..sort((a, b) => a.sequence.compareTo(b.sequence));

    if (orderedStops.isNotEmpty) {
      return orderedStops;
    }

    return order.orderStops.toList();
  }

  /// Animate camera to show full route
  void _animateToFitRoute() {
    if (mapController == null) {
      return;
    }

    final points = routePoints.isNotEmpty
        ? routePoints.toList()
        : [
            if (pickupLocation.value != null) pickupLocation.value!,
            if (dropoffLocation.value != null) dropoffLocation.value!,
          ];

    if (points.isEmpty) {
      return;
    }

    if (points.length == 1) {
      mapController!.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(target: points.first, zoom: 15),
        ),
      );
      return;
    }

    double minLat = points.first.latitude;
    double maxLat = points.first.latitude;
    double minLng = points.first.longitude;
    double maxLng = points.first.longitude;

    for (final point in points.skip(1)) {
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
        60,
      ),
    );
  }

  @override
  void onClose() {
    mapController?.dispose();
    notesController.dispose();
    super.onClose();
  }

  /// Open camera to take photo
  Future<void> openCamera() async {
    try {
      final XFile? image = await picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 70,
      );

      if (image != null) {
        selectedImages.add(image.path);
        logger.i('Photo captured: ${image.path}');
      }
    } catch (e) {
      logger.e('Camera error: $e');
      errorMessage.value = 'Failed to capture photo';
    }
  }

  /// Open gallery to select photos
  Future<void> openGallery() async {
    try {
      final List<XFile>? images = await picker.pickMultiImage(imageQuality: 70);

      if (images != null && images.isNotEmpty) {
        selectedImages.addAll(images.map((e) => e.path).toList());
        logger.i('Selected ${images.length} photos from gallery');
      }
    } catch (e) {
      logger.e('Gallery error: $e');
      errorMessage.value = 'Failed to select photos';
    }
  }

  /// Remove a selected image
  void removeImage(int index) {
    if (index >= 0 && index < selectedImages.length) {
      selectedImages.removeAt(index);
      logger.i('Removed image at index $index');
    }
  }

  /// Complete the current stop by uploading images and calling completion API
  Future<void> completeCurrentStop() async {
    try {
      // Guard: Check if there are no remaining stops (all already completed)
      if (remainingStops.isEmpty) {
        EasyLoading.showInfo('All stops have already been completed!');
        return;
      }

      if (selectedImages.isEmpty) {
        errorMessage.value = 'Please capture at least one proof photo';
        return;
      }

      if (currentStopId.value == 0) {
        errorMessage.value = 'Stop ID not found';
        return;
      }

      isUploading.value = true;
      uploadProgress.value = 0.0;
      errorMessage.value = '';

      logger.i(
        'Starting completion for ${currentStopType.value} stop: ${currentStopId.value}',
      );

      // Step 1: Upload photos
      logger.i('Uploading ${selectedImages.length} photos...');
      final uploadedUrls = await fileUploadService.uploadFiles(
        selectedImages.toList(),
      );
      logger.i('Successfully uploaded ${uploadedUrls.length} photos');

      uploadProgress.value = 0.5;

      // Step 2: Complete the stop
      isCompleting.value = true;
      logger.i('Calling stop completion API...');

      final response = await orderCompletionService.completeOrderStop(
        stopId: currentStopId.value,
        proofUrls: uploadedUrls,
        notes: notesController.text.isNotEmpty ? notesController.text : null,
        codCollected: codAmount.value > 0 && currentStopType.value == 'DROP'
            ? codAmount.value
            : null,
      );

      logger.i('Stop completed successfully: $response');
      uploadProgress.value = 1.0;

      // Mark this stop as completed and remove from remaining
      completedStops.add(currentStopId.value);
      remainingStops.remove(currentStopId.value);

      // Check if all stops are completed
      if (remainingStops.isEmpty) {
        logger.i('All stops completed! Going back to previous screen...');

        EasyLoading.showSuccess('All stops completed successfully! 🎉');

        // Wait for snackbar to finish, close it, then go back
        await Future.delayed(const Duration(seconds: 3));
        Get.closeAllSnackbars();

        // Reset drag position before navigating back
        dragX.value = 0;

        // Use Future.microtask to ensure navigation happens after current frame
        Future.microtask(() {
          logger.i('Navigating back with result completed');
          Get.back(result: 'completed');
        });
      } else {
        // Show stop completed and load next
        EasyLoading.showSuccess(
          '${currentStopType.value} completed! Moving to next stop...',
        );

        Future.delayed(const Duration(milliseconds: 1500), () {
          _loadNextStop();
        });
      }
    } catch (e) {
      logger.e('Error completing stop: $e');

      // Extract user-friendly error message
      String userMessage = e.toString();
      if (userMessage.contains('Exception:')) {
        userMessage = userMessage.replaceAll('Exception: ', '');
      }

      // Make error messages more user-friendly
      if (userMessage.contains('Stop already completed')) {
        logger.i('Stop was already completed, moving to next stop...');
        // Mark this stop as completed even though API says it was already done
        completedStops.add(currentStopId.value);
        remainingStops.remove(currentStopId.value);

        // Load next stop
        if (remainingStops.isEmpty) {
          EasyLoading.showSuccess('All stops completed! 🎉');

          Future.delayed(const Duration(milliseconds: 1500), () {
            Get.back();
          });
        } else {
          _loadNextStop();
          _initializeMapData();

          EasyLoading.showInfo(
            'This stop was already completed. Loading next stop...',
          );
        }
        return;
      } else if (userMessage.contains('Stop not found')) {
        userMessage = 'Stop information not found. Please try again.';
      } else if (userMessage.contains('Unauthorized')) {
        userMessage = 'Your session has expired. Please login again.';
      } else if (userMessage.contains('timeout')) {
        userMessage =
            'Request timed out. Please check your connection and try again.';
      } else if (userMessage.contains('Upload')) {
        userMessage =
            'Failed to upload photos. Please check the image files and try again.';
      }

      errorMessage.value = userMessage;

      EasyLoading.showError(userMessage);
    } finally {
      isUploading.value = false;
      isCompleting.value = false;
    }
  }
}
