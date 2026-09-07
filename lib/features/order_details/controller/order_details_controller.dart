import 'dart:math' as math;

import 'package:ZipBee_Driver/features/home/model/order_model.dart';
import 'package:ZipBee_Driver/features/home/model/order_stop_model.dart';
import 'package:ZipBee_Driver/features/order_details/service/order_details_service.dart';
import 'package:ZipBee_Driver/core/utils/app_route_observer.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:logger/logger.dart';

class OrderDetailsController extends GetxController with WidgetsBindingObserver, RouteAware {
  int? _orderId;
  bool openedFromTakeNow = false;
  bool openedFromOngoing = false;

  final orderDetail = Rxn<OrderModel>();
  final isLoadingOrder = false.obs;
  final errorMessage = ''.obs;

  final userLatitude = 0.0.obs;
  final userLongitude = 0.0.obs;
  final distanceToPickup = 0.0.obs;
  final distanceToDelivery = 0.0.obs;
  final timeToPickup = 0.obs;
  final timeToDelivery = 0.obs;
  final isLoadingLocation = false.obs;

  final sheetHeight = 260.0.obs;
  final double minHeight = 220;
  final double maxHeight = 420;

  final logger = Logger();
  final orderDetailsService = OrderDetailsService();

  bool _isRouteObserverSubscribed = false;

  void subscribeRoute(BuildContext context) {
    if (!_isRouteObserverSubscribed) {
      final route = ModalRoute.of(context);
      if (route != null) {
        appRouteObserver.subscribe(this, route);
        _isRouteObserverSubscribed = true;
      }
    }
  }

  @override
  void didPopNext() {
    refreshOrderDetail();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      refreshOrderDetail();
    }
  }

  @override
  void onInit() {
    super.onInit();
    WidgetsBinding.instance.addObserver(this);
    final argument = Get.arguments;
    int? orderId;

    if (argument is Map) {
      openedFromTakeNow = argument['fromTakeNow'] == true;
      openedFromOngoing = argument['fromOngoing'] == true;
      final order = argument['order'];
      final orderIdArg = argument['orderId'];

      if (order is OrderModel) {
        orderId = order.id;
        orderDetail.value = order;
      } else if (orderIdArg is int) {
        orderId = orderIdArg;
      }
    } else if (argument is OrderModel) {
      orderId = argument.id;
      orderDetail.value = argument;
    } else if (argument is int) {
      orderId = argument;
    }

    if (orderId == null) {
      errorMessage.value = 'Order details not provided';
      return;
    }

    _orderId = orderId;
    fetchOrderDetail(orderId);
    _initializeUserLocation();
  }

  Future<void> refreshOrderDetail() async {
    final orderId = _orderId ?? orderDetail.value?.id;
    if (orderId == null) {
      errorMessage.value = 'Order details not provided';
      return;
    }

    await fetchOrderDetail(orderId);
  }

  List<OrderStopModel> sortedStops(OrderModel order) {
    final stops = [...order.orderStops];
    stops.sort((a, b) => a.sequence.compareTo(b.sequence));
    return stops;
  }

  List<OrderStopModel> pickupStops(OrderModel order) {
    return sortedStops(order).where((stop) => stop.isPickup).toList();
  }

  List<OrderStopModel> dropStops(OrderModel order) {
    return sortedStops(order).where((stop) => stop.isDrop).toList();
  }

  String titleForStop(OrderStopModel stop) {
    final contactName = stop.destinationContactName.trim();
    if (contactName.isNotEmpty) {
      return contactName;
    }
    return stop.address;
  }

  String subtitleForStop(OrderStopModel stop) {
    final addressFromApr = stop.destinationAddressFromApr.trim();
    if (addressFromApr.isNotEmpty) {
      return addressFromApr;
    }

    final floorUnit = stop.destinationFloorUnit.trim();
    if (floorUnit.isNotEmpty) {
      return floorUnit;
    }

    final additionalInfo = stop.additionalInfo?.trim() ?? '';
    if (additionalInfo.isNotEmpty) {
      return additionalInfo;
    }

    final notes = stop.notes?.trim() ?? '';
    if (notes.isNotEmpty) {
      return notes;
    }

    return stop.address;
  }

  String remarksForOrder(OrderModel order) {
    for (final stop in sortedStops(order)) {
      final noteToDriver = stop.destinationNoteToDriver?.trim() ?? '';
      if (noteToDriver.isNotEmpty) {
        return noteToDriver;
      }

      final note = stop.notes?.trim() ?? '';
      if (note.isNotEmpty) {
        return note;
      }

      final additionalInfo = stop.additionalInfo?.trim() ?? '';
      if (additionalInfo.isNotEmpty) {
        return additionalInfo;
      }
    }

    return 'No remarks';
  }

  Future<void> fetchOrderDetail(int orderId) async {
    try {
      isLoadingOrder.value = true;
      errorMessage.value = '';

      final response = await orderDetailsService.fetchOrderDetail(orderId);
      orderDetail.value = response;
      _calculateDistances();
      logger.i('Order loaded: Order #${response.id}');
    } catch (e) {
      errorMessage.value = e.toString();
      logger.e('Error fetching order details: $e');
    } finally {
      isLoadingOrder.value = false;
    }
  }

  String statusLabel(OrderStopModel stop) {
    final rawStatus = stop.status.toUpperCase();

    if (rawStatus == 'COMPLETE' || rawStatus == 'COMPLETED') {
      return 'COMPLETED';
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
    switch (statusLabel(stop)) {
      case 'COMPLETED':
        return const Color(0xFF22C55E);
      case 'FAILED':
        return const Color(0xFFEF4444);
      case 'SKIPED':
        return const Color(0xFFF59E0B);
      case 'UNLOADED':
      case 'LOADED':
      case 'ARRIVED':
      case 'PROCEED':
        return const Color(0xFF3B82F6);
      case 'PENDING':
        return const Color(0xFFF59E0B);
      default:
        return const Color(0xFF3B82F6);
    }
  }

  Color statusBackgroundColor(OrderStopModel stop) {
    switch (statusLabel(stop)) {
      case 'COMPLETED':
        return const Color(0xFFDCFCE7);
      case 'FAILED':
        return const Color(0xFFFEE2E2);
      case 'SKIPED':
        return const Color(0xFFFEF3C7);
      case 'UNLOADED':
      case 'LOADED':
      case 'ARRIVED':
      case 'PROCEED':
        return const Color(0xFFDBEAFE);
      case 'PENDING':
        return const Color(0xFFFEF3C7);
      default:
        return const Color(0xFFDBEAFE);
    }
  }

  Future<void> _initializeUserLocation() async {
    try {
      isLoadingLocation.value = true;

      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        _useDefaultLocation();
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          _useDefaultLocation();
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        _useDefaultLocation();
        return;
      }

      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        forceAndroidLocationManager: true,
        timeLimit: const Duration(seconds: 10),
      );

      userLatitude.value = position.latitude;
      userLongitude.value = position.longitude;
      _calculateDistances();
    } catch (e) {
      logger.e('Error getting location: $e');
      _useDefaultLocation();
    } finally {
      isLoadingLocation.value = false;
    }
  }

  void _useDefaultLocation() {
    userLatitude.value = 23.7777571;
    userLongitude.value = 90.4057408;
    _calculateDistances();
  }

  void _calculateDistances() {
    final order = orderDetail.value;
    if (order == null) {
      return;
    }

    final pickup = pickupStops(order).firstOrNull;
    final drop = dropStops(order).firstOrNull;

    if (pickup != null) {
      distanceToPickup.value = _calculateDistance(
        userLatitude.value,
        userLongitude.value,
        pickup.latitude,
        pickup.longitude,
      );
      timeToPickup.value = _calculateEstimatedTime(distanceToPickup.value);
    }

    if (drop != null) {
      distanceToDelivery.value = _calculateDistance(
        userLatitude.value,
        userLongitude.value,
        drop.latitude,
        drop.longitude,
      );
      timeToDelivery.value = _calculateEstimatedTime(distanceToDelivery.value);
    }
  }

  double _calculateDistance(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
    const earthRadiusKm = 6371.0;
    final dLat = _degreesToRadians(lat2 - lat1);
    final dLon = _degreesToRadians(lon2 - lon1);

    final a =
        math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(_degreesToRadians(lat1)) *
            math.cos(_degreesToRadians(lat2)) *
            math.sin(dLon / 2) *
            math.sin(dLon / 2);

    final c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
    return double.parse((earthRadiusKm * c).toStringAsFixed(2));
  }

  double _degreesToRadians(double degrees) {
    return degrees * math.pi / 180;
  }

  int _calculateEstimatedTime(double distanceKm) {
    const averageSpeedKmH = 40.0;
    final timeHours = distanceKm / averageSpeedKmH;
    return (timeHours * 60).ceil();
  }

  String getPickupDistanceAndTime() {
    return '${distanceToPickup.value.toStringAsFixed(2)} km | ${timeToPickup.value} min';
  }

  String getDeliveryDistanceAndTime() {
    return '${distanceToDelivery.value.toStringAsFixed(2)} km | ${timeToDelivery.value} min';
  }

  String getTotalDistanceText(OrderModel order) {
    final distance = order.effectiveDistanceKm;
    return '${distance.toStringAsFixed(2)} km';
  }

  String getPriceText(OrderModel order) {
    return '\$${order.riderEarningDouble.toStringAsFixed(2)}';
  }

  String formatValue(String value) {
    return value.replaceAll('_', ' ');
  }

  String collectTimeText(OrderModel order) {
    final collectAt = estimatedPickupAt(order);
    if (collectAt == null) {
      return formatValue(order.collectTime);
    }

    return DateFormat('hh:mm a').format(collectAt.toLocal());
  }

  DateTime? estimatedPickupAt(OrderModel order) {
    final assignedAt = order.assignAt;
    if (assignedAt == null) {
      return null;
    }

    return assignedAt.add(
      Duration(minutes: order.effectiveCollectionTimeMinutes),
    );
  }

  String orderStatusLabel(OrderModel order) {
    final rawStatus = order.orderStatus.toUpperCase();
    if (rawStatus == 'COMPLETE' || rawStatus == 'COMPLETED') {
      return 'COMPLETED';
    }
    return formatValue(rawStatus);
  }

  Color orderStatusColor(OrderModel order) {
    switch (orderStatusLabel(order)) {
      case 'COMPLETED':
        return const Color(0xFF22C55E);
      case 'CANCELLED':
      case 'CANCELED':
      case 'FAILED':
        return const Color(0xFFEF4444);
      case 'IN PROGRESS':
      case 'ONGOING':
      case 'ACCEPTED':
        return const Color(0xFF3B82F6);
      case 'PENDING':
        return const Color(0xFFF59E0B);
      default:
        return const Color(0xFF3B82F6);
    }
  }

  Color orderStatusBackgroundColor(OrderModel order) {
    switch (orderStatusLabel(order)) {
      case 'COMPLETED':
        return const Color(0xFFDCFCE7);
      case 'CANCELLED':
      case 'CANCELED':
      case 'FAILED':
        return const Color(0xFFFEE2E2);
      case 'IN PROGRESS':
      case 'ONGOING':
      case 'ACCEPTED':
        return const Color(0xFFDBEAFE);
      case 'PENDING':
        return const Color(0xFFFEF3C7);
      default:
        return const Color(0xFFDBEAFE);
    }
  }

  bool isStopCompleted(OrderStopModel stop) {
    final status = stop.status.toUpperCase();
    return status == 'COMPLETE' || status == 'COMPLETED';
  }

  String addressForStop(OrderStopModel stop) {
    final order = orderDetail.value;
    final isOrderCompleted =
        order != null &&
        (order.isCompleted || order.orderStatus.toUpperCase() == 'COMPLETED');
    final isStopCompletedStatus = isStopCompleted(stop);

    if (isOrderCompleted || isStopCompletedStatus) {
      return stop.displayName;
    }

    return stop.address;
  }

  String formatDateTime(DateTime value) {
    return DateFormat('dd MMM yyyy, hh:mm a').format(value.toLocal());
  }

  String formatPayType(String payType) {
    if (payType.toUpperCase() == 'COD') {
      return 'Cash';
    }
    return formatValue(payType);
  }

  String formatAmount(String amount) {
    final parsed = double.tryParse(amount) ?? 0.0;
    final absolute = parsed.abs().toStringAsFixed(2);
    if (parsed < 0) {
      return '-\$$absolute';
    }
    return '\$$absolute';
  }

  String? actionButtonText(OrderStopModel stop) {
    if (!shouldShowActionButton(stop)) {
      return null;
    }

    final status = stop.status.toUpperCase();
    if (status == 'COMPLETE' || status == 'COMPLETED') {
      return null;
    }

    if (status == 'FAILED') {
      return 'Try Again';
    }

    if (status == 'PENDING') {
      if (stop.isSkiped) {
        return 'Try again';
      } else if (!stop.proceedToPickup) {
        return stop.isPickup ? 'Proceed to Pick-up' : 'Proceed to Drop';
      } else if (!stop.isArrived) {
        return 'Arrived';
      } else if (!stop.isLoad || !stop.isUnload) {
        return stop.isPickup ? 'Load' : 'Unload';
      } else {
        return 'Take Photo';
      }
    }

    return null;
  }

  bool shouldShowActionButton(OrderStopModel stop) {
    final order = orderDetail.value;
    if (order == null) {
      return false;
    }

    if (isStopCompleted(stop)) {
      return false;
    }

    final stops = sortedStops(order);
    final currentIndex = stops.indexWhere((item) => item.id == stop.id);
    if (currentIndex == -1) {
      return false;
    }

    if (currentIndex == 0) {
      return true;
    }

    final previousStop = stops[currentIndex - 1];
    return isStopCompleted(previousStop);
  }

  void onDragUpdate(double delta) {
    sheetHeight.value += -delta;

    if (sheetHeight.value < minHeight) {
      sheetHeight.value = minHeight;
    }
    if (sheetHeight.value > maxHeight) {
      sheetHeight.value = maxHeight;
    }
  }

  void onDragEnd() {
    if (sheetHeight.value < minHeight + 50) {
      sheetHeight.value = minHeight;
    } else {
      sheetHeight.value = maxHeight;
    }
  }

  @override
  void onClose() {
    if (_isRouteObserverSubscribed) {
      appRouteObserver.unsubscribe(this);
    }
    WidgetsBinding.instance.removeObserver(this);
    super.onClose();
  }
}
