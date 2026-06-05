import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:rozgar/shared/constants/firebase_constants.dart';

class AdService {
  static final AdService instance = AdService._();
  AdService._();

  InterstitialAd? _interstitial;

  String get bannerAdUnitId =>
      dotenv.env['BANNER_AD_UNIT_ID'] ??
      'ca-app-pub-3940256099942544/6300978111';
  String get interstitialAdUnitId =>
      dotenv.env['INTERSTITIAL_AD_UNIT_ID'] ??
      'ca-app-pub-3940256099942544/1033173712';
  String get nativeAdUnitId =>
      dotenv.env['NATIVE_AD_UNIT_ID'] ??
      'ca-app-pub-3940256099942544/2247696110';

  Future<void> init() async {
    await MobileAds.instance.initialize();
    _loadInterstitial();
  }

  void _loadInterstitial() {
    InterstitialAd.load(
      adUnitId: interstitialAdUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) => _interstitial = ad,
        onAdFailedToLoad: (_) => _interstitial = null,
      ),
    );
  }

  void showInterstitialAd() {
    if (_interstitial != null) {
      _interstitial!.show();
      _interstitial = null;
      _loadInterstitial();
    }
  }

  BannerAd? createBannerAd() {
    return BannerAd(
      adUnitId: bannerAdUnitId,
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdFailedToLoad: (ad, _) {
          ad.dispose();
          AppLogger.w('Banner ad failed to load');
        },
      ),
    )..load();
  }

  NativeAd? createNativeAd() {
    return NativeAd(
      adUnitId: nativeAdUnitId,
      factoryId: 'listTile',
      request: const AdRequest(),
      listener: NativeAdListener(
        onAdFailedToLoad: (ad, _) {
          ad.dispose();
          AppLogger.w('Native ad failed to load');
        },
      ),
    )..load();
  }
}
