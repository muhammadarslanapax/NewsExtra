import 'package:flutter/foundation.dart';
import '../models/Userdata.dart';
import '../models/Categories.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/SQLiteDbProvider.dart';
import '../utils/langs.dart';
import '../i18n/strings.g.dart';

class AppStateNotifier with ChangeNotifier {
  bool? isDarkModeOn = false;
  bool? loadArticlesImages = true;
  bool? loadSmallImages = true;
  bool? isLoadingTheme = true;
  bool? isRtlEnabled = false;
  bool? isUserSeenOnboardingPage = false;
  bool? isReceievePushNotifications = true;
  Userdata? userdata;
  String currentCategory = "All Stories";
  List<String> selectedcats = [];
  List<Categories> dbcategories = [];
  int preferredLanguage = 0;
  final _langPreference = "language_preference";

  AppStateNotifier() {
    loadAppTheme();
    getPreferedLanguage();
    getDatabaseCategories();
    getLoadArticlesImages();
    getLoadSmallImages();
    getRtlEnabled();
    getRecieveNotifications();
    getUserData();
  }

  getUserSeenOnboarding() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (prefs.getBool("user_seen_onboarding_page") != null) {
      isUserSeenOnboardingPage = prefs.getBool("user_seen_onboarding_page");
    }
  }

  setUserSeenOnboardingPage(bool seen) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool("user_seen_onboarding_page", seen);
  }

  getDatabaseCategories() async {
    selectedcats = [];
    dbcategories = await SQLiteDbProvider.db.getAllCategories();
    for (var itm in dbcategories) {
      selectedcats.add(itm.title!);
    }

    selectedcats.sort((a, b) {
      return a.toLowerCase().compareTo(b.toLowerCase());
    });
    if (!selectedcats.contains(currentCategory)) {
      selectedcats.insert(0, currentCategory);
    }

    //notifyListeners();
  }

  chooseCategory(String? val) {
    if (val != currentCategory) {
      currentCategory = val!;
      notifyListeners();
    }
  }

  getPreferedLanguage() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    try {
      //load app language
      preferredLanguage = prefs.getInt(_langPreference) ?? 0;
    } catch (e) {
      // quietly pass
    }

    switch (appLanguageData[AppLanguage.values[preferredLanguage]]!['value']) {
      case "en":
        LocaleSettings.setLocale(AppLocale.en);
        break;
      case "fr":
        LocaleSettings.setLocale(AppLocale.fr);
        break;
      case "es":
        LocaleSettings.setLocale(AppLocale.es);
        break;
      case "pt":
        LocaleSettings.setLocale(AppLocale.pt);
        break;

      case "de":
        LocaleSettings.setLocale(AppLocale.en);
        break;
      case "it":
        LocaleSettings.setLocale(AppLocale.en);
        break;
      case "ar":
        LocaleSettings.setLocale(AppLocale.en);
        break;
    }
  }

  //app language setting
  setAppLanguage(int index) async {
    //AppLanguage _preferredLanguage = AppLanguage.values[index];
    preferredLanguage = index;
    switch (appLanguageData[AppLanguage.values[preferredLanguage]]!['value']) {
      case "en":
        LocaleSettings.setLocale(AppLocale.en);
        break;
      case "fr":
        LocaleSettings.setLocale(AppLocale.fr);
        break;
      case "es":
        LocaleSettings.setLocale(AppLocale.es);
        break;
      case "pt":
        LocaleSettings.setLocale(AppLocale.pt);
        break;

      case "de":
        LocaleSettings.setLocale(AppLocale.en);
        break;
      case "it":
        LocaleSettings.setLocale(AppLocale.en);
        break;
      case "ar":
        LocaleSettings.setLocale(AppLocale.en);
        break;
    }
    // Here we notify listeners that theme changed
    // so UI have to be rebuild
    notifyListeners();
    // Save selected theme into SharedPreferences
    var prefs = await SharedPreferences.getInstance();
    prefs.setInt(_langPreference, preferredLanguage);
  }

  getUserData() async {
    userdata = await SQLiteDbProvider.db.getUserData();
    print("userdata " + userdata.toString());
    notifyListeners();
  }

  setUserData(Userdata _userdata) async {
    await SQLiteDbProvider.db.deleteUserData();
    await SQLiteDbProvider.db.insertUser(_userdata);
    this.userdata = _userdata;
    notifyListeners();
  }

  unsetUserData() async {
    await SQLiteDbProvider.db.deleteUserData();
    this.userdata = null;
    notifyListeners();
  }

  loadAppTheme() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (prefs.getBool("app_theme") != null) {
      isDarkModeOn = prefs.getBool("app_theme");
    }
    isLoadingTheme = false;
    notifyListeners();
  }

  getAppTheme() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (prefs.getBool("app_theme") != null) {
      isDarkModeOn = prefs.getBool("app_theme");
    }
    return isDarkModeOn;
  }

  setAppTheme(bool theme) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    isDarkModeOn = theme;
    prefs.setBool("app_theme", theme);
    notifyListeners();
  }

  getLoadArticlesImages() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (prefs.getBool("load_article_images") != null) {
      loadArticlesImages = prefs.getBool("load_article_images");
    }
    return loadArticlesImages;
  }

  setLoadArticlesImages(bool value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    loadArticlesImages = value;
    prefs.setBool("load_article_images", value);
    notifyListeners();
  }

  getLoadSmallImages() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (prefs.getBool("load_small_article_images") != null) {
      loadSmallImages = prefs.getBool("load_small_article_images");
    }
    return loadArticlesImages;
  }

  setLoadSmallImages(bool value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    loadSmallImages = value;
    prefs.setBool("load_small_article_images", value);
    notifyListeners();
  }

  getRtlEnabled() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (prefs.getBool("rtl_enabled") != null) {
      isRtlEnabled = prefs.getBool("rtl_enabled");
    }
    return isRtlEnabled;
  }

  setRtlEnabled(bool value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    isRtlEnabled = value;
    prefs.setBool("rtl_enabled", value);
    notifyListeners();
  }

  getRecieveNotifications() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (prefs.getBool("receieve_notifications") != null) {
      isReceievePushNotifications = prefs.getBool("receieve_notifications");
    }
    return isReceievePushNotifications;
  }

  setRecieveNotifications(bool value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    isReceievePushNotifications = value;
    prefs.setBool("receieve_notifications", value);
    notifyListeners();
  }
}
