import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:newsextra/utils/Adverts.dart';

class InterstitialAdsModel {
  static void loadInterstitialAds() {
    InterstitialAd.load(
        adUnitId: Adverts.getInterstitialAdUnitId()!,
        request: AdRequest(),
        adLoadCallback: InterstitialAdLoadCallback(
          onAdLoaded: (InterstitialAd ad) {
            // Keep a reference to the ad so you can show it later.
            ad.show();
          },
          onAdFailedToLoad: (LoadAdError error) {
            //loadInterstitialAds();
          },
        ));
  }
}
