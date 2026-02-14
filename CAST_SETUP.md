# TV Casting Setup Instructions

This app uses the `flutter_chrome_cast` package for a high-quality integration with the Google Cast SDK.

## Android Setup

1. **Permissions**: The following permissions are added to `AndroidManifest.xml`:
   - `INTERNET`
   - `ACCESS_NETWORK_STATE`
   - `ACCESS_WIFI_STATE`
   - `CHANGE_WIFI_MULTICAST_STATE`

2. **Cast Options Provider**:
   The `AndroidManifest.xml` includes the `OPTIONS_PROVIDER_CLASS_NAME` meta-data pointing to `com.felnanuke.google_cast.GoogleCastOptionsProvider`.

3. **Dependencies**:
   `implementation("com.google.android.gms:play-services-cast-framework:21.4.0")` is added to `android/app/build.gradle.kts`.

4. **Activity Class**:
   `MainActivity` extends `FlutterFragmentActivity` to support the Cast SDK's UI requirements.

5. **Theme**:
   The app theme is set to `Theme.AppCompat.NoActionBar` as required by the Cast SDK.

## iOS Setup (Requirements)

To support casting on iOS, you must add the following to your `Info.plist`:

```xml
<key>NSBluetoothAlwaysUsageDescription</key>
<string>We use Bluetooth to discover nearby Cast devices.</string>
<key>NSBluetoothPeripheralUsageDescription</key>
<string>We use Bluetooth to discover nearby Cast devices.</string>
<key>NSLocalNetworkUsageDescription</key>
<string>We use the local network to discover and connect to Cast devices on your WiFi.</string>
<key>NSBonjourServices</key>
<array>
  <string>_googlecast._tcp</string>
  <string>_CC1AD845._googlecast._tcp</string>
</array>
```

## How Casting Works Internally

1. **Initialization**: `GoogleCastContext.instance.setSharedInstanceWithOptions` initializes the native SDK.
2. **Discovery**: `GoogleCastDiscoveryManager` starts searching for devices using mDNS and Bluetooth.
3. **Session**: `GoogleCastSessionManager` handles connecting to a device and maintaining the session.
4. **Media Control**: `GoogleCastRemoteMediaClient` sends commands like `loadMedia`, `play`, and `pause` to the connected TV.

## Troubleshooting

- Ensure both the phone and the TV are on the **exact same Wi-Fi network**.
- AP Isolation must be disabled on your router.
- For Android 12+, ensure "Nearby devices" permission is granted.
