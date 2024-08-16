import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class Adverts {
  static String? getBannerAdUnitId() {
    if (Platform.isIOS) {
      return 'ca-app-pub-3940256099942544/2934735716';
    } else if (Platform.isAndroid) {
      return 'ca-app-pub-3940256099942544/6300978111';
    }
    return null;
  }

  static String? getInterstitialAdUnitId() {
    if (Platform.isIOS) {
      return 'ca-app-pub-3940256099942544/4411468910';
    } else if (Platform.isAndroid) {
      return 'ca-app-pub-3940256099942544/1033173712';
    }
    return null;
  }

  static String getAdmobNativeAds() {
    if (Platform.isIOS) {
      return 'ca-app-pub-3940256099942544/2247696110';
    } else {
      return 'ca-app-pub-3940256099942544/2247696110';
    }
  }
}

class AdmobNativeAds extends StatefulWidget {
  const AdmobNativeAds();

  @override
  State createState() => _NativeInlineAdState();
}

class _NativeInlineAdState extends State<AdmobNativeAds>
    with AutomaticKeepAliveClientMixin {
  // COMPLETE: Add NativeAd instance
  late NativeAd _ad;

  // COMPLETE: Add _isAdLoaded
  bool _isAdLoaded = false;

  @override
  void initState() {
    super.initState();

    // COMPLETE: Create a NativeAd instance
    _ad = NativeAd(
      adUnitId: Adverts.getAdmobNativeAds(),
      factoryId: 'adFactoryExample',
      request: const AdRequest(),
      listener: NativeAdListener(
        onAdLoaded: (_) {
          setState(() {
            _isAdLoaded = true;
          });
        },
        onAdFailedToLoad: (ad, error) {
          // Releases an ad resource when it fails to load
          ad.dispose();

          throw 'Ad load failed (code=${error.code} message=${error.message})';
        },
      ),
    );

    // COMPLETE: Load an ad
    _ad.load();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    if (_isAdLoaded) {
      return Container(
        child: SizedBox(height: 270, child: AdWidget(ad: _ad)),
        height: 270,
        padding: const EdgeInsets.all(8),
        
        alignment: Alignment.center,
      );
    }
    return const SizedBox(
      height: 72.0,
      child: Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(
            Colors.grey,
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _ad.dispose();
    super.dispose();
  }

  @override
  bool get wantKeepAlive => true;
}

/*class AdmobNativeAds extends StatefulWidget {
  AdmobNativeAds({Key key}) : super(key: key);

  @override
  _AdmobNativeAdsState createState() => _AdmobNativeAdsState();
}

class _AdmobNativeAdsState extends State<AdmobNativeAds>
    with AutomaticKeepAliveClientMixin {
  final NativeAd myNative = NativeAd(
    adUnitId: Adverts.getAdmobNativeAds(),
    factoryId: 'adFactoryExample',
    request: AdRequest(),
    //nativeAdOptions: NativeAdOptions(),
    listener: NativeAdListener(
      // Called when an ad is successfully received.
      onAdLoaded: (Ad ad) {
        print("Ad loaded = " + ad.adUnitId);
        //reloadView();
      },
      // Called when an ad request failed.
      onAdFailedToLoad: (Ad ad, LoadAdError error) {
        // Dispose the ad here to free resources.
        ad.dispose();
        print('Ad failed to load: $error');
        // Gets the domain from which the error came.
        String domain = error.domain;

        // Gets the error code. See
        // https://developers.google.com/android/reference/com/google/android/gms/ads/AdRequest
        // and https://developers.google.com/admob/ios/api/reference/Enums/GADErrorCode
        // for a list of possible codes.
        int code = error.code;
        print(code);

        // A log friendly string summarizing the error.
        String message = error.message;
        print(message);
      },
      // Called when an ad opens an overlay that covers the screen.
      onAdOpened: (Ad ad) => print('Ad opened.'),
      // Called when an ad removes an overlay that covers the screen.
      onAdClosed: (Ad ad) => print('Ad closed.'),
      // Called when an impression occurs on the ad.
      onAdImpression: (Ad ad) => print('Ad impression.'),
      // Called when a click is recorded for a NativeAd.
      onNativeAdClicked: (NativeAd ad) => print('Ad clicked.'),
    ),
  );
  AdWidget adWidget;

  void reloadView() {
    setState(() {});
  }

  @override
  void initState() {
    adWidget = AdWidget(ad: myNative);
    myNative.load();
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Container(
      alignment: Alignment.center,
      child: adWidget,
      width: 500,
      height: 500,
    );
  }
}*/
