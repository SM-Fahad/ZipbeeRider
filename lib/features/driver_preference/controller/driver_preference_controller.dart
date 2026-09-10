import 'package:ZipBee_Driver/features/account/controller/account_controller.dart';
import 'package:ZipBee_Driver/features/bottom_navbar/controller/bottom_navbar_controller.dart';
import 'package:ZipBee_Driver/features/home/controller/home_controller.dart';
import 'package:ZipBee_Driver/routes/app_routes.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:logger/logger.dart';
import 'package:ZipBee_Driver/core/utils/location_helper.dart';

import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter/material.dart';

class DriverPreferenceController extends GetxController {
  var distanceRadius = 5.0.obs;

  late final HomeController _homeController;
  late final AccountController _accountController;
  final TextEditingController feedRefreshRateController = TextEditingController();
  var isModified = false.obs;

  // Location related
  var currentLocation = Rx<LatLng?>(null);
  var isLoadingLocation = false.obs;
  GoogleMapController? mapController;
  final logger = Logger();

  @override
  void onInit() {
    super.onInit();
    _homeController = Get.isRegistered<HomeController>()
        ? Get.find<HomeController>()
        : Get.put(HomeController(), permanent: true);
    _accountController = Get.isRegistered<AccountController>()
        ? Get.find<AccountController>()
        : Get.put(AccountController());

    feedRefreshRateController.text =
        _accountController.orderFeedRefreshRateSeconds.value.toString();
    feedRefreshRateController.addListener(_checkIfModified);

    ever(_accountController.orderFeedRefreshRateSeconds, (val) {
      if (feedRefreshRateController.text != val.toString()) {
        feedRefreshRateController.text = val.toString();
      }
      _checkIfModified();
    });

    _initializeUserLocation();
  }

  void _checkIfModified() {
    final currentInput = feedRefreshRateController.text.trim();
    final savedValue =
        _accountController.orderFeedRefreshRateSeconds.value.toString();
    isModified.value = currentInput.isNotEmpty && currentInput != savedValue;
  }

  RxBool get isOnline => _homeController.isOnline;
  RxBool get isAutoPopup => _accountController.isAutoPopupEnabled;
  RxBool get isAutoPopupUpdating => _accountController.isAutoPopupUpdating;
  RxBool get isFeedRefreshRateUpdating =>
      _accountController.isFeedRefreshRateUpdating;
  RxInt get orderFeedRefreshRateSeconds =>
      _accountController.orderFeedRefreshRateSeconds;
  bool get canShowAutoPopupPermission =>
      _accountController.canShowAutoPopupPermission;

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

      // Listen to location changes
      Geolocator.getPositionStream(
        locationSettings: locationSettings,
      ).listen((Position position) {
        currentLocation.value = LatLng(position.latitude, position.longitude);
      });
    } catch (e) {
      logger.e('Error getting location: $e');
    } finally {
      isLoadingLocation.value = false;
    }
  }

  Future<void> toggleOffline(bool value) async {
    await _homeController.handleOnlineSwitchChange(value);
  }

  Future<void> toggleAutoPopup(bool value) async {
    await _accountController.updateAutoPopupPermission(value);
  }

  Future<void> saveFeedRefreshRate() async {
    final input = feedRefreshRateController.text.trim();
    final seconds = int.tryParse(input);
    if (seconds == null || seconds <= 0) {
      EasyLoading.showError('Please enter a valid refresh rate in seconds');
      return;
    }
    if (seconds.toString() ==
        _accountController.orderFeedRefreshRateSeconds.value.toString()) {
      isModified.value = false;
      return;
    }
    EasyLoading.show(status: 'Updating...');
    final success = await _accountController.updateFeedRefreshRate(seconds);
    EasyLoading.dismiss();
    if (success) {
      isModified.value = false;
      EasyLoading.showSuccess('Feed refresh rate updated successfully');
      if (_homeController.orders.isNotEmpty) {
        _homeController.orders.assignAll(_homeController.sortOrdersList(_homeController.orders));
        _homeController.orders.refresh();
      }
    }
  }

  Future<void> resetOrderFeed() async {
    await _homeController.resetOrderFeed();
  }

  void onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  void markAsDone() {}

  void cancelOrder() {
    if (Get.isRegistered<BottomNavbarController>()) {
      Get.find<BottomNavbarController>().changeTab(0);
    }

    Get.offAllNamed(AppRoutes.getBottomNavbarScreen());
  }

  @override
  void onClose() {
    feedRefreshRateController.removeListener(_checkIfModified);
    feedRefreshRateController.dispose();
    mapController?.dispose();
    super.onClose();
  }
}
