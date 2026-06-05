# Rozgar App — Setup Guide

## 1. Flutter SDK Installation

### Windows
1. Download from https://docs.flutter.dev/get-started/install/windows
2. Extract to `C:\src\flutter`, add `bin` to PATH
3. Run `flutter doctor`

### macOS
```bash
brew install --cask flutter
flutter doctor
```

### Linux
```bash
sudo snap install flutter --classic
flutter doctor
```

Required: Flutter 3.x, Dart 3.x (null-safe).

## 2. Install Dependencies

```bash
cd rozgar_app
flutter pub get
```

## 3. Firebase Setup

1. Create a Firebase project at https://console.firebase.google.com
2. Enable **Authentication** (Email/Password + Google)
3. Create **Firestore** database
4. Enable **Cloud Messaging**, **Crashlytics**, **Performance**

### Android
- Download `google-services.json` → place in `android/app/`

### iOS
- Download `GoogleService-Info.plist` → add to `ios/Runner/` in Xcode
- Minimum iOS 12

## 4. Cloudinary Setup

1. Create account at https://cloudinary.com
2. Create unsigned upload preset named `rozgar_unsigned`
3. Allow formats: jpg, png, webp, pdf

## 5. Environment Variables

Copy and fill `.env` in project root:

```
CLOUDINARY_CLOUD_NAME=your_cloud_name
CLOUDINARY_UPLOAD_PRESET=rozgar_unsigned
JSEARCH_API_KEY=your_rapidapi_key
EXCHANGE_API_KEY=your_exchangerate_key
BANNER_AD_UNIT_ID=ca-app-pub-3940256099942544/6300978111
INTERSTITIAL_AD_UNIT_ID=ca-app-pub-3940256099942544/1033173712
NATIVE_AD_UNIT_ID=ca-app-pub-3940256099942544/2247696110
ADMIN_EMAIL_DOMAIN=@rozgar.admin
```

## 6. Run

```bash
flutter pub get
flutter run
```

## Project Structure

```
lib/
├── main.dart
├── app.dart
├── user/       # Job Seeker
├── company/    # Employer
├── admin/      # Admin
└── shared/     # Cross-role utilities
```

## Known Issues

| Issue | Fix |
|-------|-----|
| Firebase init failed | Ensure `google-services.json` is present |
| `.env` not loaded | Create `.env` from template above |
| Cloudinary upload fails | Verify unsigned preset name |
| Google Sign-In fails | Add SHA-1 to Firebase console |
| Permission denied (Firestore) | Deploy `firestore.rules` |
