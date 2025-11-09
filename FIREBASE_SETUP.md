# Firebase Configuration Setup

## ⚠️ Important Security Notice

The Firebase configuration files (`google-services.json`, `GoogleService-Info.plist`) are **NOT** included in this repository for security reasons. Each developer must add their own Firebase project configuration files.

## Setup Instructions

### For Android

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Select your project (or create a new one)
3. Go to **Project Settings** → **Your apps**
4. Click on the Android app icon
5. Download `google-services.json`
6. Place it in: `android/app/google-services.json`

### For iOS

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Select your project
3. Go to **Project Settings** → **Your apps**
4. Click on the iOS app icon
5. Download `GoogleService-Info.plist`
6. Place it in: `ios/Runner/GoogleService-Info.plist`

### For macOS

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Select your project
3. Go to **Project Settings** → **Your apps**
4. Click on the macOS app icon (or add macOS app if not exists)
5. Download `GoogleService-Info.plist`
6. Place it in: `macos/Runner/GoogleService-Info.plist`

## Required Firebase Services

Make sure the following services are enabled in your Firebase project:

- **Authentication** (Email/Password provider)
- **Cloud Firestore** (Database)
- **Firebase Storage** (File storage)
- **Firebase App Check** (Security)

## Firebase App Check Configuration

Update `lib/main.dart` with appropriate App Check providers:

- **Android (Production)**: `AndroidPlayIntegrityProvider()`
- **Android (Debug)**: `AndroidProvider.debug`
- **iOS (Production)**: `AppleAppAttestProvider()`
- **iOS (Debug)**: `AppleDebugProvider()`
- **Web**: `ReCaptchaV3Provider('your-recaptcha-site-key')`

## Verification

After adding the configuration files, verify the setup:

```bash
# Check if files exist
ls android/app/google-services.json
ls ios/Runner/GoogleService-Info.plist
ls macos/Runner/GoogleService-Info.plist

# Run the app
flutter run
```

## Troubleshooting

If you encounter build errors:

1. Ensure the configuration files are in the correct locations
2. Verify the package name/bundle ID matches your Firebase project
3. Run `flutter clean` and `flutter pub get`
4. For iOS: Run `cd ios && pod install && cd ..`

