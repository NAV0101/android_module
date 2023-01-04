import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

Future<bool?> showExitNativeAd(BuildContext context) =>
    showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (BuildContext context) => const ExitNativeAdWidget());

class ExitNativeAdWidget extends StatefulWidget {
  final double nativeAdHeight;
  final double horizontalPadding;
  final String adId;

  const ExitNativeAdWidget({
    super.key,
    this.nativeAdHeight = 300,
    this.horizontalPadding = 20,
    this.adId = '/6499/example/native',
  });

  @override
  State<ExitNativeAdWidget> createState() => _ExitNativeAdWidgetState();
}

class _ExitNativeAdWidgetState extends State<ExitNativeAdWidget> {
  bool _adFailed = false;
  NativeAd? _nativeAd;

  @override
  void initState() {
    super.initState();
    _loadNativeAd();
  }

  @override
  void dispose() {
    super.dispose();
    _nativeAd?.dispose();
  }

  _loadNativeAd({int retryCount = 0}) async {
    _nativeAd?.dispose();
    _nativeAd = null;
    if (mounted) setState(() {});
    NativeAd(
      adUnitId: widget.adId,
      request: const AdRequest(),
      factoryId: 'nativeAdView',
      listener: NativeAdListener(
        onAdLoaded: (Ad ad) {
          if (mounted) setState(() => _nativeAd = ad as NativeAd);
        },
        onAdFailedToLoad: (Ad ad, LoadAdError error) {
          ad.dispose();
          if (retryCount < 2) {
            _loadNativeAd(retryCount: retryCount + 1);
          } else {
            if (mounted) setState(() => _adFailed = true);
          }
        },
      ),
    ).load();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Container(
        decoration: const BoxDecoration(
          borderRadius: BorderRadius.only(
            topRight: Radius.circular(40),
            topLeft: Radius.circular(40),
          ),
          color: Colors.grey,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              margin: const EdgeInsets.only(bottom: 16.0, top: 16.0),
              child: const SizedBox(
                height: 4.0,
                width: 26.0,
              ),
            ),
            Stack(
              children: [
                Column(
                  children: [
                    if (!_adFailed)
                      SizedBox(
                        height: widget.nativeAdHeight + 15,
                      ),
                    const SizedBox(
                      height: 10.0,
                    ),
                  ],
                ),
                if (!_adFailed)
                  SizedBox(
                    height: widget.nativeAdHeight,
                    child: Container(
                      padding: const EdgeInsets.all(5),
                      margin: EdgeInsets.symmetric(
                          horizontal: widget.horizontalPadding),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        color: Colors.black54,
                      ),
                      width: MediaQuery.of(context).size.width,
                      height: widget.nativeAdHeight,
                      child: _nativeAd != null
                          ? AdWidget(ad: _nativeAd!)
                          : const CircularProgressIndicator(),
                    ),
                  ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
