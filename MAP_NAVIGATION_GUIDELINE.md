# Google Maps Navigation Guideline 🗺️

This document provides a comprehensive guide to configuring, initializing, and using the **Google Maps Navigation SDK** in your Flutter application for **Step-by-Step Road-wise Navigation (Turn-by-Turn Guidance)** and **Visual Map UI**.

---

## Table of Contents
1. [Prerequisites & Requirements](#1-prerequisites--requirements)
2. [Platform-specific Configurations](#2-platform-specific-configurations)
3. [Initialization Flow in Code](#3-initialization-flow-in-code)
4. [Visual Map View Component](#4-visual-map-view-component)
5. [Road-wise Instructions Stream](#5-road-wise-instructions-stream)
6. [Stopping & Resource Cleanup](#6-stopping--resource-cleanup)
7. [Troubleshooting](#7-troubleshooting)

---

## 1. Prerequisites & Requirements

To run Google Maps Navigation (In-App Turn-by-Turn GPS) successfully, the following prerequisites are required:

### A. Google Cloud Navigation SDK Authorization (Critical ⚠️)
* A standard Google Maps SDK API Key **will not work** for in-app turn-by-turn navigation.
* You must enable the **Navigation SDK for Android** and **Navigation SDK for iOS** APIs in your Google Cloud Console.
* **Important:** The Navigation SDK is a premium product. Using it requires active billing account verification and special approval or white-listing of your app's bundle/package ID (`sg.com.zipbee.driver`) by Google. Otherwise, the SDK will fail with `apiKeyNotAuthorized` or `notAuthorized` status errors.

### B. Flutter Dependencies
Ensure the following packages are correctly installed in your `pubspec.yaml` (already configured in the project):
```yaml
dependencies:
  geolocator: ^10.1.0            # For location permission checks and GPS status
  google_maps_navigation: ^0.3.0  # Main Google Maps Navigation SDK wrapper
  get: ^4.7.2                    # State management (Controllers)
```

---

## 2. Platform-specific Configurations

### A. Android Configuration
1. **AndroidManifest.xml** (`android/app/src/main/AndroidManifest.xml`):
   Ensure that the location permissions are declared inside the `<manifest>` tag:
   ```xml
   <uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
   <uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION" />
   <!-- If background navigation is required, declare the following: -->
   <uses-permission android:name="android.permission.ACCESS_BACKGROUND_LOCATION" />
   ```
2. **Google Maps API Key**:
   Provide your API Key inside the `<application>` tag of your manifest:
   ```xml
   <meta-data
       android:name="com.google.android.geo.API_KEY"
       android:value="YOUR_GOOGLE_MAPS_API_KEY_HERE" />
   ```

### B. iOS Configuration
1. **Info.plist** (`ios/Runner/Info.plist`):
   Add the following keys to prompt users for location access:
   ```xml
   <key>NSLocationWhenInUseUsageDescription</key>
   <string>This app needs access to location when open for turn-by-turn navigation.</string>
   <key>NSLocationAlwaysAndWhenInUseUsageDescription</key>
   <string>This app needs access to location in the background to provide continuous voice and visual guidance.</string>
   ```

---

## 3. Initialization Flow in Code

To start turn-by-turn navigation, perform these steps in sequence. This matches the flow handled in the project's [OrderProcessController](file:///Users/nuhan/Shahriar_Shanto/nicholaslim/Latest%20Update/nicholaslim80Rider/lib/features/order_progress/controller/order_process_controller.dart):

### Step 1: Location Permission Verification
First, verify and request location permission from the device:
```dart
LocationPermission permission = await Geolocator.checkPermission();
if (permission == LocationPermission.denied) {
  permission = await Geolocator.requestPermission();
}
if (permission == LocationPermission.deniedForever || permission == LocationPermission.denied) {
  EasyLoading.showError('Location permission is required for navigation');
  return;
}
```

### Step 2: Accept Google Maps Navigation Terms & Conditions
Google requires users to accept the Navigation T&C dialogue before initiating active guidance:
```dart
final bool termsAccepted = await GoogleMapsNavigator.areTermsAccepted();
if (!termsAccepted) {
  final bool accepted = await GoogleMapsNavigator.showTermsAndConditionsDialog(
    'ZipBee Driver Navigation',
    'ZipBee',
  );
  if (!accepted) {
    EasyLoading.showError('Terms and conditions must be accepted to use navigation');
    return;
  }
}
```

### Step 3: Initialize the Navigation Session
Initialize the navigation session once terms are accepted:
```dart
final isSessionInitialized = await GoogleMapsNavigator.isInitialized();
if (!isSessionInitialized) {
  await GoogleMapsNavigator.initializeNavigationSession();
}
```

### Step 4: Setup Waypoints and Destinations
Define stops/destinations as list of `NavigationWaypoint` and request routing information:
```dart
// Map stops into waypoints
final List<NavigationWaypoint> waypoints = [];
for (var stop in stops) {
  waypoints.add(
    NavigationWaypoint(
      title: stop.isPickup ? 'Pickup ${stop.sequence}' : 'Drop ${stop.sequence}',
      target: LatLng(latitude: stop.latitude, longitude: stop.longitude),
    ),
  );
}

// Wrap inside Destinations object
final destinations = Destinations(
  waypoints: waypoints,
  displayOptions: NavigationDisplayOptions(
    showDestinationMarkers: true,
    showStopSigns: true,
    showTrafficLights: true,
  ),
  routingOptions: RoutingOptions(
    travelMode: NavigationTravelMode.driving,
  ),
);

// Call setDestinations to fetch and calculate route
final status = await GoogleMapsNavigator.setDestinations(destinations);
if (status == NavigationRouteStatus.statusOk) {
  // Routing succeeded! Prepare to open visual map screen
} else {
  // Routing failed (e.g., if status is apiKeyNotAuthorized, review your API setup)
}
```

---

## 4. Visual Map View Component

Once destinations are set, display the `GoogleMapsNavigationView` widget to render the visual navigation interface on screen.

As implemented in [NavigationGuidelineScreen](file:///Users/nuhan/Shahriar_Shanto/nicholaslim/Latest%20Update/nicholaslim80Rider/lib/features/order_progress/screen/navigation_guideline_screen.dart):

```dart
GoogleMapsNavigationView(
  onViewCreated: (GoogleNavigationViewController controller) {
    // Keep reference to controller
    navigationViewController = controller;
    
    // Enable visual live location indicator
    controller.setMyLocationEnabled(true);
    
    // Trigger turn-by-turn voice and directional guidance
    GoogleMapsNavigator.startGuidance();
    
    // Setup listener to capture road-wise turn instructions
    startListeningToNavInfo();
  },
  initialNavigationUIEnabledPreference: NavigationUIEnabledPreference.automatic,
)
```

---

## 5. Road-wise Instructions Stream

While driving, the SDK provides real-time route changes, next maneuver, and distance metadata through a stream listener.

### Setup Stream Listener (NavInfo):
```dart
StreamSubscription<NavInfoEvent>? navInfoSubscription;

void startListeningToNavInfo() {
  navInfoSubscription?.cancel();
  navInfoSubscription = GoogleMapsNavigator.setNavInfoListener((event) {
    // Event contains the NavInfo object containing current instructions
    currentNavInfo.value = event.navInfo;
  });
}
```

### UI Rendering of Directions:
You can render turn-by-turn guidance dynamically using variables in `event.navInfo`:

1. **Next Turn/Maneuver Icon**:
   * Inspect `navInfo.currentStep?.maneuver` (returns enum values like `turnLeft`, `turnRight`, `straight`, `roundabout`).
   * Map this enum to appropriate UI Icons:
     ```dart
     IconData getManeuverIcon(Maneuver? maneuver) {
       switch (maneuver) {
         case Maneuver.turnLeft: return Icons.turn_left;
         case Maneuver.turnRight: return Icons.turn_right;
         case Maneuver.straight: return Icons.straight;
         default: return Icons.directions;
       }
     }
     ```
2. **Road Guideline Text**:
   * Retrieve instructions using `navInfo.currentStep?.fullInstructions` (e.g., *"Turn left onto Panthapath Ave"*).
3. **Distance to Next Turn**:
   * Inspect `navInfo.distanceToCurrentStepMeters` or `step.distanceFromPrevStepMeters` (e.g., *"In 200 meters"*).
4. **ETA & Final Target Distance**:
   * Distance: `navInfo.distanceToNextDestinationMeters` or `navInfo.distanceToFinalDestinationMeters`.
   * Time remaining (seconds): `navInfo.timeToNextDestinationSeconds` or `navInfo.timeToFinalDestinationSeconds`.
   * Calculate remaining minutes: `(seconds / 60).round()`.

---

## 6. Stopping & Resource Cleanup

Always clean up navigation resources and stop GPS tracking when navigating away or after completing a trip to prevent high battery consumption and memory leaks:

```dart
Future<void> stopInAppNavigation() async {
  try {
    if (navigationSessionInitialized.value) {
      await GoogleMapsNavigator.stopGuidance();
      await GoogleMapsNavigator.clearDestinations();
      await GoogleMapsNavigator.cleanup(); // Clean up navigation session
    }
    // Cancel the listener subscription
    navInfoSubscription?.cancel();
    navInfoSubscription = null;
    currentNavInfo.value = null;
    isNavigating.value = false;
  } catch (e) {
    debugPrint('Failed to stop navigation: $e');
  }
}
```

---

## 7. Troubleshooting

### 1. The SDK throws `apiKeyNotAuthorized` or session fails
* **Cause:** The Google Maps API Key does not have the **Navigation SDK** enabled, or your application bundle ID (`sg.com.zipbee.driver`) is not whitelisted by Google's server database.
* **Solution:** Navigate to the Google Cloud Console, ensure "Navigation SDK for Android/iOS" are enabled. Since this is a premium feature, you might need to contact Google Maps Support / Enterprise Sales to register and authorize your bundle ID.

### 2. Map loads but routes or turn-by-turn guidance details do not show up
* **Solution:**
  1. Ensure the device's location service/GPS is turned on and location permissions are fully granted.
  2. Double-check that destination coordinates (`latitude` and `longitude`) are valid, positive/negative values and situated in map-accessible regions.
  3. Check console logs to ensure `setDestinations` returned `NavigationRouteStatus.statusOk`.
