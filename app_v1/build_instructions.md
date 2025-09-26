# Build Instructions for AyurTrack Collector App

## Prerequisites

Before building the app, ensure you have the following installed:

- Flutter SDK 3.9.2 or higher
- Dart SDK (comes with Flutter)
- Android Studio or VS Code with Flutter extensions
- Git

## Step-by-Step Build Process

### 1. Generate Hive Adapters

The app uses Hive for local storage, which requires generated adapters for custom classes.

```bash
# Navigate to the app directory
cd app_v1

# Install dependencies
flutter pub get

# Generate Hive adapters
flutter packages pub run build_runner build

# If you encounter conflicts, use:
flutter packages pub run build_runner build --delete-conflicting-outputs
```

### 2. Configure Backend URL

Edit the configuration file to point to your backend:

```dart
// lib/config/app_config.dart
static const String baseUrl = 'https://your-backend-url.com/api';
static const String smsGatewayNumber = '+1234567890'; // Your SMS gateway
```

### 3. Build for Development

```bash
# Run in debug mode
flutter run

# Run on specific device
flutter run -d <device-id>

# Hot reload is available in debug mode
```

### 4. Build for Production

#### Android APK
```bash
# Build release APK
flutter build apk --release

# Build APK for specific architecture
flutter build apk --target-platform android-arm64 --release
```

#### Android App Bundle (Recommended for Play Store)
```bash
# Build App Bundle
flutter build appbundle --release
```

#### iOS (if targeting iOS)
```bash
# Build for iOS
flutter build ios --release
```

### 5. Testing

```bash
# Run unit tests
flutter test

# Run integration tests (if available)
flutter test integration_test/

# Run tests with coverage
flutter test --coverage
```

## Configuration Checklist

Before building for production, verify:

- [ ] Backend URL is correctly configured
- [ ] SMS gateway number is set (if using SMS fallback)
- [ ] App permissions are properly configured in AndroidManifest.xml
- [ ] Hive adapters are generated successfully
- [ ] All dependencies are up to date

## Android Permissions

Ensure these permissions are in `android/app/src/main/AndroidManifest.xml`:

```xml
<uses-permission android:name="android.permission.INTERNET" />
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
<uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION" />
<uses-permission android:name="android.permission.SEND_SMS" />
<uses-permission android:name="android.permission.READ_SMS" />
<uses-permission android:name="android.permission.RECEIVE_SMS" />
<uses-permission android:name="android.permission.ACCESS_NETWORK_STATE" />
```

## Troubleshooting

### Common Issues

1. **Hive Adapter Generation Fails**
   ```bash
   flutter clean
   flutter pub get
   flutter packages pub run build_runner clean
   flutter packages pub run build_runner build --delete-conflicting-outputs
   ```

2. **Build Fails Due to Dependencies**
   ```bash
   flutter clean
   flutter pub get
   flutter pub upgrade
   ```

3. **Location Permission Issues**
   - Ensure location permissions are added to AndroidManifest.xml
   - Test location services on physical device (not emulator)

4. **SMS Permission Issues**
   - SMS permissions require runtime permission handling
   - Test on physical device with SIM card

### Performance Optimization

For production builds:

```bash
# Build with optimization flags
flutter build apk --release --shrink --obfuscate --split-debug-info=build/debug-info/

# For App Bundle
flutter build appbundle --release --shrink --obfuscate --split-debug-info=build/debug-info/
```

## Deployment

### Google Play Store
1. Build App Bundle: `flutter build appbundle --release`
2. Upload to Google Play Console
3. Configure store listing and screenshots
4. Submit for review

### Direct APK Distribution
1. Build APK: `flutter build apk --release`
2. Sign APK if needed
3. Distribute through your preferred method

## Environment Variables

For different environments (dev, staging, prod), consider using:

```dart
// lib/config/environment.dart
class Environment {
  static const String current = String.fromEnvironment('ENV', defaultValue: 'dev');
  
  static String get baseUrl {
    switch (current) {
      case 'prod':
        return 'https://api.ayurtrack.com';
      case 'staging':
        return 'https://staging-api.ayurtrack.com';
      default:
        return 'http://localhost:3000/api';
    }
  }
}
```

Build with environment:
```bash
flutter build apk --release --dart-define=ENV=prod
```

## Final Verification

Before releasing:

1. Test offline functionality
2. Test SMS fallback (if enabled)
3. Verify GPS accuracy
4. Test sync functionality
5. Check app performance on low-end devices
6. Verify all forms and validations work
7. Test with poor network conditions

## Support

If you encounter issues during the build process:
1. Check Flutter doctor: `flutter doctor`
2. Verify all dependencies are compatible
3. Check the Flutter documentation
4. Review error logs carefully
