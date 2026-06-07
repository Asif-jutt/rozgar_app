import 'package:flutter/foundation.dart';

/// External service IDs and URLs — replace placeholders before production release.
class ExternalServicesConfig {
  ExternalServicesConfig._();

  // ─── Google AdMob (Monetization) ───────────────────────────────────────────
  // Create app at https://admob.google.com and replace these IDs.
  static const String adMobAppIdAndroid =
      'ca-app-pub-3940256099942544~3347511713'; // TEST — replace for production
  static const String adMobAppIdIos =
      'ca-app-pub-3940256099942544~1458002511'; // TEST — replace for production

  static String get bannerAdUnitId => kDebugMode
      ? 'ca-app-pub-3940256099942544/6300978111'
      : 'ca-app-pub-XXXXXXXXXXXXXXXX/YYYYYYYYYY'; // YOUR production banner ID

  // ─── Firebase (Authentication & Firestore) ─────────────────────────────────
  // Configured via firebase_options.dart + google-services.json (Android)
  // + GoogleService-Info.plist (iOS). Project: rozgar-25d03

  // ─── External REST APIs ────────────────────────────────────────────────────
  static const String remotiveJobsApi = 'https://remotive.com/api/remote-jobs';
  static const String restCountriesApi =
      'https://restcountries.com/v3.1/all?fields=name,capital';

  // ─── Encryption plugin ─────────────────────────────────────────────────────
  // Uses `encrypt` + `flutter_secure_storage` — keys stored on-device automatically.
}
