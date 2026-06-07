import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:rozgar/core/config/external_services_config.dart';
import 'package:rozgar/core/logger/app_logger.dart';

/// Google Mobile Ads integration for banner monetization.
class AdService {
  AdService._();
  static final AdService instance = AdService._();

  bool _initialized = false;

  static String get bannerAdUnitId => ExternalServicesConfig.bannerAdUnitId;

  Future<void> initialize() async {
    if (kIsWeb) return;
    try {
      await MobileAds.instance.initialize();
      _initialized = true;
      AppLogger.info('AdService initialized');
    } catch (e, st) {
      AppLogger.error('AdService init failed', e, st);
    }
  }

  bool get isReady => _initialized && !kIsWeb;

  BannerAd? createBannerAd({VoidCallback? onLoaded}) {
    if (!isReady) return null;

    final banner = BannerAd(
      adUnitId: bannerAdUnitId,
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (_) {
          AppLogger.debug('Banner ad loaded');
          onLoaded?.call();
        },
        onAdFailedToLoad: (ad, error) {
          AppLogger.warning('Banner ad failed: ${error.message}');
          ad.dispose();
        },
      ),
    );
    banner.load();
    return banner;
  }
}
