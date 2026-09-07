# Google Maps Setup for Android

## Issue
The app is throwing this error:
```
PlatformException(error, java.lang.IllegalStateException: Trying to create a platform view of unregistered type: plugins.flutter.dev/google_maps_android
```

This happens because the Google Maps API key is not properly configured in the Android native code.

## Solution

### Step 1: Get a Google Maps API Key

1. Go to [Google Cloud Console](https://console.cloud.google.com/)
2. Create a new project or select an existing one
3. Enable these APIs:
   - Maps SDK for Android
   - Maps SDK for iOS (if also building for iOS)
4. Go to Credentials → Create API Key
5. Restrict the key to Android apps and add your app's SHA-1 fingerprint

### Step 2: Get Your SHA-1 Fingerprint

Run this command to get your debug keystore SHA-1:
```bash
cd /Users/bdcalling/emtiaz/nicholaslim80rider
./gradlew signingReport
```

Look for the SHA-1 under `Variant: debugAndroidTest`.

### Step 3: Add API Key to AndroidManifest.xml

1. Open: `android/app/src/main/AndroidManifest.xml`
2. Find this line:
```xml
<meta-data
    android:name="com.google.android.geo.API_KEY"
    android:value="YOUR_GOOGLE_MAPS_API_KEY" />
```
3. Replace `YOUR_GOOGLE_MAPS_API_KEY` with your actual API key from Step 1

**The updated AndroidManifest.xml already has this placeholder added.**

### Step 4: Clean and Rebuild

```bash
cd /Users/bdcalling/emtiaz/nicholaslim80rider
flutter clean
flutter pub get
flutter run
```

## Verification

Once configured, you should be able to:
- See the interactive Google Map with markers
- Zoom, pan, and rotate the map
- See blue marker for pickup and red markers for delivery locations
- See polylines connecting destinations

## Troubleshooting

If you still see the error:

1. **Verify API Key is correct** - Check that you copied it exactly
2. **Check API is enabled** - Go to Google Cloud Console and verify Maps SDK for Android is enabled
3. **Verify app restriction** - Make sure the API key allows your app's package name (`sg.com.zipbee.driver`)
4. **Clear cache**:
   ```bash
   flutter clean
   rm -rf build/
   rm -rf android/.gradle
   rm -rf android/build
   flutter pub get
   ```
5. **Rebuild APK**: `flutter run --verbose` to see detailed error messages

## File Modified
- `android/app/src/main/AndroidManifest.xml` - Added Google Maps API key meta-data tag (placeholder)
