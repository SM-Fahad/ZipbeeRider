import 'dart:async';
import 'dart:math' as math;
import 'package:ZipBee_Driver/core/services/socket_service.dart';
import 'package:ZipBee_Driver/features/order_details/screen/order_details_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:geolocator/geolocator.dart';
import 'package:logger/logger.dart';
import 'package:ZipBee_Driver/features/home/model/order_model.dart';
import 'package:ZipBee_Driver/features/take_now/service/order_detail_service.dart';

class TakeNowController extends GetxController {
  // Order Detail State
  var orderDetail = Rxn<OrderModel>();
  var isLoadingOrder = false.obs;
  var errorMessage = ''.obs;

  // Location State
  var userLatitude = 0.0.obs;
  var userLongitude = 0.0.obs;
  var distanceToPickup = 0.0.obs;
  var distanceToDelivery = 0.0.obs;
  var timeToPickup = 0.obs; // in minutes
  var timeToDelivery = 0.obs; // in minutes
  var isLoadingLocation = false.obs;

  // Draggable Map Sheet
  var dragX = 0.0.obs;
  // RxDouble sheetHeight = 120.0.obs;
  // final double minHeight = 120;
  // final double maxHeight = 420;
  late final double minHeight = Get.height * 0.25;
  late final double maxHeight = Get.height * 0.8;
  late RxDouble sheetHeight = minHeight.obs;
  RxBool isSheetVisible = true.obs;

  final orderDetailService = OrderDetailService();
  final logger = Logger();
  final SocketService _socketService = SocketService();

  // Competition State
  final competitorCount = 0.obs;
  final timeRemaining = 0.obs;
  final progressValue = 0.0.obs;
  var isWin = false.obs;
  var isLoss = false.obs;
  Timer? _progressTimer;

  @override
  void onInit() {
    super.onInit();
    // Get order ID from arguments
    final orderId = Get.arguments as int?;
    if (orderId != null) {
      fetchOrderDetail(orderId);
      _initializeUserLocation();
    } else {
      errorMessage.value = 'Order ID not provided';
    }
  }

  @override
  void onClose() {
    _stopProgressTimer();
    super.onClose();
  }

  // ========== Location Methods ==========
  /// Get actual user location using geolocator plugin
  Future<void> _initializeUserLocation() async {
    try {
      isLoadingLocation.value = true;

      // Check if location services are enabled
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        logger.w('Location services are disabled.');
        _useDefaultLocation();
        return;
      }

      // Check and request location permission
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          logger.w('Location permissions are denied');
          _useDefaultLocation();
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        logger.w('Location permissions are permanently denied');
        _useDefaultLocation();
        return;
      }

      // Get current position
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        forceAndroidLocationManager: true,
        timeLimit: Duration(seconds: 10),
      );

      userLatitude.value = position.latitude;
      userLongitude.value = position.longitude;

      logger.i('User location: ${position.latitude}, ${position.longitude}');
      _calculateDistances();
    } catch (e) {
      logger.e('Error getting location: $e');
      _useDefaultLocation();
    } finally {
      isLoadingLocation.value = false;
    }
  }

  /// Use default location if geolocator fails
  void _useDefaultLocation() {
    logger.i('Using default location');
    userLatitude.value = 23.7777571;
    userLongitude.value = 90.4057408;
    _calculateDistances();
  }

  void _calculateDistances() {
    final sender = getSenderDestination();
    final receiver = getReceiverDestination();

    if (sender != null) {
      final senderLat = double.tryParse(sender['latitude']) ?? 0.0;
      final senderLng = double.tryParse(sender['longitude']) ?? 0.0;
      distanceToPickup.value = _calculateDistance(
        userLatitude.value,
        userLongitude.value,
        senderLat,
        senderLng,
      );
      timeToPickup.value = _calculateEstimatedTime(distanceToPickup.value);
    }

    if (receiver != null) {
      final receiverLat = double.tryParse(receiver['latitude']) ?? 0.0;
      final receiverLng = double.tryParse(receiver['longitude']) ?? 0.0;
      distanceToDelivery.value = _calculateDistance(
        userLatitude.value,
        userLongitude.value,
        receiverLat,
        receiverLng,
      );
      timeToDelivery.value = _calculateEstimatedTime(distanceToDelivery.value);
    }
  }

  /// Calculate distance between two coordinates using Haversine formula
  /// Returns distance in kilometers
  double _calculateDistance(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
    const double earthRadiusKm = 6371;

    final double dLat = _degreesToRadians(lat2 - lat1);
    final double dLon = _degreesToRadians(lon2 - lon1);

    final double a =
        math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(_degreesToRadians(lat1)) *
            math.cos(_degreesToRadians(lat2)) *
            math.sin(dLon / 2) *
            math.sin(dLon / 2);

    final double c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
    final double distance = earthRadiusKm * c;

    return double.parse(distance.toStringAsFixed(2));
  }

  /// Convert degrees to radians
  double _degreesToRadians(double degrees) {
    return degrees * math.pi / 180;
  }

  String getPickupDistance() {
    return '${distanceToPickup.value.toStringAsFixed(2)} km';
  }

  String getDeliveryDistance() {
    return '${distanceToDelivery.value.toStringAsFixed(2)} km';
  }

  /// Calculate estimated time based on distance and average speed
  /// Average speed: 40 km/h for city traffic
  int _calculateEstimatedTime(double distanceKm) {
    const double averageSpeedKmH = 40; // City average speed
    final double timeHours = distanceKm / averageSpeedKmH;
    final int timeMinutes = (timeHours * 60).ceil();
    return timeMinutes;
  }

  String getPickupTime() {
    if (timeToPickup.value == 0) return '0 min';
    return '${timeToPickup.value} min';
  }

  String getDeliveryTime() {
    if (timeToDelivery.value == 0) return '0 min';
    return '${timeToDelivery.value} min';
  }

  String getPickupDistanceAndTime() {
    return '${distanceToPickup.value.toStringAsFixed(2)} km | ${getPickupTime()}';
  }

  String getDeliveryDistanceAndTime() {
    return '${distanceToDelivery.value.toStringAsFixed(2)} km | ${getDeliveryTime()}';
  }

  // ========== Order Detail Methods ==========
  Future<void> fetchOrderDetail(int orderId) async {
    try {
      isLoadingOrder.value = true;
      errorMessage.value = '';

      final response = await orderDetailService.fetchOrderDetail(orderId);
      final foundOrder = OrderModel.fromJson(response.rawData);

      orderDetail.value = foundOrder;
      _calculateDistances(); // Calculate distances after loading order
      logger.i('Order loaded: Order #${foundOrder.id}');
    } catch (e) {
      errorMessage.value = e.toString();
      logger.e('Error fetching order: $e');
    } finally {
      isLoadingOrder.value = false;
    }
  }

  /// Get the sender/pickup destination from orderStops
  Map<String, dynamic>? getSenderDestination() {
    try {
      final pickup = orderDetail.value?.orderStops.firstWhere(
        (stop) => stop.type == 'PICKUP',
      );
      if (pickup != null) {
        return {
          'address': pickup.destinationAddressFromApr.isNotEmpty
              ? pickup.destinationAddressFromApr
              : pickup.address,
          'latitude': pickup.latitude.toString(),
          'longitude': pickup.longitude.toString(),
          'floorUnit': pickup.destinationFloorUnit.isNotEmpty
              ? pickup.destinationFloorUnit
              : (pickup.additionalInfo ?? pickup.address),
          'noteToDriver':
              pickup.destinationNoteToDriver ??
              pickup.notes ??
              'Pickup location',
        };
      }
    } catch (e) {
      logger.w('No sender destination found');
    }
    return null;
  }

  /// Get the first receiver/drop destination from orderStops
  Map<String, dynamic>? getReceiverDestination() {
    try {
      final drop = orderDetail.value?.orderStops.firstWhere(
        (stop) => stop.type == 'DROP',
      );
      if (drop != null) {
        return {
          'address': drop.destinationAddressFromApr.isNotEmpty
              ? drop.destinationAddressFromApr
              : drop.address,
          'latitude': drop.latitude.toString(),
          'longitude': drop.longitude.toString(),
          'floorUnit': drop.destinationFloorUnit.isNotEmpty
              ? drop.destinationFloorUnit
              : (drop.additionalInfo ?? drop.address),
          'noteToDriver':
              drop.destinationNoteToDriver ?? drop.notes ?? 'Drop location',
        };
      }
    } catch (e) {
      logger.w('No receiver destination found');
    }
    return null;
  }

  void acceptOrder() {
    logger.i('Order accepted: Order #${orderDetail.value?.id}');
    showTakeDialog();
  }

  /// Accept order via socket
  Future<void> _acceptOrderViaSocket() async {
    try {
      final orderId = orderDetail.value?.id;
      if (orderId == null) {
        errorMessage.value = 'Order ID not found';
        Get.back(); // Close dialog
        return;
      }

      if (_socketService.socket == null) {
        EasyLoading.showError('Go to online first');
        Get.back(); // Close dialog
        return;
      }

      logger.i('Accepting order via socket: Order #$orderId');
      _setupSocketListeners();
      _socketService.joinCompetition(orderId);
    } catch (e) {
      logger.e('Error accepting order: $e');
      Get.back(); // Close dialog
      EasyLoading.showError(e.toString());
    }
  }

  void _setupSocketListeners() {
    // Joined competition
    _socketService.on('rider:competition_joined', (data) {
      logger.i('Rider joined competition: $data');
      competitorCount.value = (data['competitorCount'] ?? 0) as int;
      final remaining = (data['timeRemaining'] ?? 0) as int;
      timeRemaining.value = remaining;
      _startProgressTimer(remaining);
    });

    // Join error
    _socketService.on('rider:competition_error', (data) {
      logger.e('Failed to join competition: $data');
      _stopProgressTimer();
      final msg = data['message']?.toString() ?? 'Failed to join competition';
      Get.back(); // Close dialog
      EasyLoading.showError(msg);
    });

    // Won
    _socketService.on('rider:competition_won', (data) {
      logger.i('Competition won: $data');
      _stopProgressTimer();
      isWin.value = true;
    });

    // Lost
    _socketService.on('rider:competition_lost', (data) {
      logger.i('Competition lost: $data');
      _stopProgressTimer();
      isLoss.value = true;
    });

    // Assigned
    _socketService.on('rider:order_assigned', (data) {
      logger.i('Order assigned: $data');
    });

    _socketService.on('rider:order_auto_confirmed', (data) {
      logger.i('Order auto confirmed: $data');
    });
  }

  void declineOrder() {
    logger.i('Order declined: Order #${orderDetail.value?.id}');
    // TODO: Call API to decline order
  }

  // ========== Draggable Sheet Methods ==========

  void onSlideComplete() {
    dragX.value = 0;
    showTakeDialog();
  }

  void resetSlide() {
    dragX.value = 0.0;
  }

  void onDragUpdate(double delta) {
    double newHeight = sheetHeight.value - delta;
    if (newHeight >= minHeight && newHeight <= maxHeight) {
      sheetHeight.value = newHeight;
    }
  }

  void onDragEnd() {
    if (sheetHeight.value > (maxHeight + minHeight) / 2) {
      sheetHeight.value = maxHeight;
    } else {
      sheetHeight.value = minHeight;
    }
  }

  /// —— DIALOG STEPS ——
  RxInt dialogStep = 0.obs;

  void showTakeDialog() {
    // Reset states for new competition
    competitorCount.value = 0;
    timeRemaining.value = 0;
    progressValue.value = 0.0;
    isWin.value = false;
    isLoss.value = false;

    Get.dialog(Obx(() => _buildDialog()), barrierDismissible: false);

    // Immediately call socket to accept order
    _acceptOrderViaSocket();
  }

  Widget _buildDialog() {
    // State 1: Waiting for competition to start
    if (competitorCount.value == 0 && !isWin.value && !isLoss.value) {
      return _loadingDialog();
    }

    // State 2: Competition active with competitor count
    if (competitorCount.value > 0 && !isWin.value && !isLoss.value) {
      return _activeCompetitionDialog();
    }

    // State 3: Won competition
    if (isWin.value) {
      return _successDialog();
    }

    // State 4: Lost competition
    if (isLoss.value) {
      return _lossDialog();
    }

    // Fallback
    return _loadingDialog();
  }

  Widget _dialogBase(Widget child) {
    return Center(
      child: Container(
        width: 300,
        padding: EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
        ),
        child: child,
      ),
    );
  }

  Widget _loadingDialog() {
    return _dialogBase(
      Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 14),
          SizedBox(
            width: 60,
            height: 60,
            child: CircularProgressIndicator(
              value: 0.1,
              strokeWidth: 5,
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.blue),
            ),
          ),
          const SizedBox(height: 14),
          const Text(
            "Accepting Order",
            style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 6),
          const Text("In progress..."),
        ],
      ),
    );
  }

  Widget _activeCompetitionDialog() {
    if (timeRemaining.value > 0 && _progressTimer == null) {
      _startProgressTimer(timeRemaining.value);
    }

    return _dialogBase(
      Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 14),
          Obx(
            () => SizedBox(
              width: 80,
              height: 80,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  CircularProgressIndicator(
                    value: progressValue.value,
                    strokeWidth: 6,
                    valueColor: const AlwaysStoppedAnimation<Color>(
                      Colors.blue,
                    ),
                  ),
                  Text(
                    "${(progressValue.value * 100).toStringAsFixed(0)}%",
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            "Accepting Order...",
            style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            "${competitorCount.value} Driver${competitorCount.value != 1 ? 's' : ''} Joined",
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 6),
          const Text("Please wait..."),
        ],
      ),
    );
  }

  void _startProgressTimer(int totalSeconds) {
    _stopProgressTimer();

    if (totalSeconds <= 0) return;

    progressValue.value = 0.0;
    int elapsedMilliseconds = 0;
    final totalMilliseconds = totalSeconds * 1000;
    const timerInterval = Duration(milliseconds: 100);

    _progressTimer = Timer.periodic(timerInterval, (timer) {
      elapsedMilliseconds += timerInterval.inMilliseconds;
      progressValue.value = (elapsedMilliseconds / totalMilliseconds).clamp(
        0.0,
        1.0,
      );

      if (progressValue.value >= 1.0) {
        _stopProgressTimer();
      }
    });
  }

  void _stopProgressTimer() {
    _progressTimer?.cancel();
    _progressTimer = null;
  }

  Widget _successDialog() {
    return _dialogBase(
      Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.check_circle, size: 55, color: Colors.green),
          const SizedBox(height: 12),
          const Text(
            "You got the Order!",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.amber),
            onPressed: () {
              Get.back(); // Close dialog
              final order = orderDetail.value;
              if (order != null) {
                // Get.to(() => CompleteOrderScreen(), arguments: order)?.then((
                //   result,
                // ) {
                //   if (result == 'completed') {
                //     logger.i('Order completed, refreshing orders list...');
                //   }
                // });
                Get.to(
                  () => OrderDetailsScreen(),
                  arguments: {'order': order, 'fromTakeNow': true},
                );
              }
            },
            child: const Text("Done", style: TextStyle(color: Colors.black)),
          ),
        ],
      ),
    );
  }

  Widget _lossDialog() {
    return _dialogBase(
      Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.close_rounded, size: 55, color: Colors.red),
          const SizedBox(height: 12),
          const Text(
            "Try again",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.amber),
            onPressed: () {
              Get.back(); // Close dialog
            },
            child: const Text("Done", style: TextStyle(color: Colors.black)),
          ),
        ],
      ),
    );
  }
}
