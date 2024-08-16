import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:newsextra/service/AudioPlayerModel.dart';
import 'package:newsextra/utils/my_colors.dart';
import './screens/OnboardingPage.dart';
import 'MyApp.dart';
import './providers/AppStateNotifier.dart';
import './screens/HomePage.dart';
import './screens/CategoriesScreen.dart';
import './providers/BookmarksModel.dart';
import './models/Categories.dart';
import 'package:provider/provider.dart';
import './utils/SQLiteDbProvider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import './providers/ArticlesModel.dart';
import './providers/VideosModel.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  MobileAds.instance.initialize();
  SystemChrome.setSystemUIOverlayStyle(
    SystemUiOverlayStyle(
      statusBarColor: MyColors.primary,
    ),
  );
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  Future<Widget> getFirstScreen() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<Categories> _itms = await SQLiteDbProvider.db.getAllCategories();
    if (prefs.getBool("user_seen_onboarding_page") == null ||
        prefs.getBool("user_seen_onboarding_page") == false) {
      return new OnboardingPage();
    } else if (_itms == null || _itms.length == 0) {
      return new CategoriesScreen(
        isFirstLoad: true,
      );
    } else {
      return HomePage();
    }
  }

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AppStateNotifier()),
        ChangeNotifierProvider(create: (_) => BookmarksModel()),
        ChangeNotifierProvider(create: (_) => ArticlesModel()),
        ChangeNotifierProvider(create: (_) => AudioPlayerModel()),
        ChangeNotifierProvider(create: (_) => VideosModel()),
      ],
      child: FutureBuilder<Widget>(
          future: getFirstScreen(), //returns bool
          builder: (BuildContext context, AsyncSnapshot<Widget> snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              return MyApp(defaultHome: snapshot.data);
            } else {
              return Center(child: CupertinoActivityIndicator());
            }
          }),
    ),
  );
}
