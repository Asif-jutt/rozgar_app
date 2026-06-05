import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:rozgar/shared/providers/ad_service.dart';
import 'package:rozgar/user/providers/auth_provider.dart';

class AdBannerWidget extends StatefulWidget {
  const AdBannerWidget({super.key});

  @override
  State<AdBannerWidget> createState() => _AdBannerWidgetState();
}

class _AdBannerWidgetState extends State<AdBannerWidget> {
  BannerAd? _banner;
  bool _loaded = false;

  @override
  void initState() {
    super.initState();
    _loadAd();
  }

  void _loadAd() {
    final user = AuthProvider.to.currentUser.value;
    if (user?.isPremium == true) return;
    final ad = BannerAd(
      adUnitId: AdService.instance.bannerAdUnitId,
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (ad) => setState(() {
          _banner = ad as BannerAd;
          _loaded = true;
        }),
        onAdFailedToLoad: (ad, _) {
          ad.dispose();
          setState(() => _loaded = false);
        },
      ),
    );
    ad.load();
    _banner = ad;
  }

  @override
  void dispose() {
    _banner?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (AuthProvider.to.currentUser.value?.isPremium == true) {
        return const SizedBox.shrink();
      }
      if (!_loaded || _banner == null) return const SizedBox.shrink();
      return SizedBox(
        height: _banner!.size.height.toDouble(),
        child: AdWidget(ad: _banner!),
      );
    });
  }
}
