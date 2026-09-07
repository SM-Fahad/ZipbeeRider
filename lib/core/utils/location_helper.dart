import 'dart:io' show Platform;
import 'package:geolocator/geolocator.dart';

/// Returns platform-specific location settings.
/// Enforces forceLocationManager on Android to ensure emulator mock locations are captured.
LocationSettings getLocationSettings({
  LocationAccuracy accuracy = LocationAccuracy.high,
  int distanceFilter = 10,
  Duration intervalDuration = const Duration(seconds: 5),
}) {
  if (Platform.isAndroid) {
    return AndroidSettings(
      accuracy: accuracy,
      distanceFilter: distanceFilter,
      forceLocationManager: true, // Critical for emulator GPS updates
      intervalDuration: intervalDuration,
    );
  } else if (Platform.isIOS) {
    return AppleSettings(
      accuracy: accuracy,
      distanceFilter: distanceFilter,
      activityType: ActivityType.otherNavigation,
    );
  } else {
    return LocationSettings(
      accuracy: accuracy,
      distanceFilter: distanceFilter,
    );
  }
}
