package apps.envisionapps.newsextra_flutter;


import io.flutter.embedding.android.FlutterActivity;
import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.plugins.googlemobileads.GoogleMobileAdsPlugin;
import io.flutter.plugins.googlemobileads.GoogleMobileAdsPlugin.NativeAdFactory;

public class MainActivity extends FlutterActivity {
 
    @Override
  public void configureFlutterEngine(FlutterEngine flutterEngine) {
    super.configureFlutterEngine(flutterEngine);
    final NativeAdFactory factory = new NativeAdFactoryExample(getLayoutInflater());
    GoogleMobileAdsPlugin.registerNativeAdFactory(flutterEngine, "adFactoryExample", factory);
  }

  @Override
  public void cleanUpFlutterEngine(FlutterEngine flutterEngine) {
    GoogleMobileAdsPlugin.unregisterNativeAdFactory(flutterEngine, "adFactoryExample");
  }
}