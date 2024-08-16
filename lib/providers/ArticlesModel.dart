import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:newsextra/providers/InterstitialAdsModel.dart';
import '../screens/ArticleViewerScreen.dart';
import '../utils/TimUtil.dart';
import '../utils/ApiUrl.dart';
import '../models/Articles.dart';
import '../utils/SQLiteDbProvider.dart';
import '../models/ScreenArguements.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_sim_country_code/flutter_sim_country_code.dart';

class ArticlesModel with ChangeNotifier {
  List<Articles>? _items = [];
  RefreshController refreshController =
      RefreshController(initialRefresh: false);
  ScrollController scrollController = new ScrollController();
  bool isError = false;
  String? location = 'wo';
  String? sortDate = '';
  String? currentCategory = "All Stories";
  List<String> selectedcats = [];
  List<int>? unfollowedFeedSources = [];
  bool isWidgetInit = false;
  bool _isDisposed = false;

  ArticlesModel() {
    print("init articles mode;= ");
    getDatabaseArticles();
    getUserLocation();
  }

  setWidgetsInit(bool status) {
    isWidgetInit = status;
  }

  setCategories(List<String> selectedcats) {
    this.selectedcats = selectedcats;
  }

  refreshPageOnCategorySelected(String val) {
    print("currentCategory = " + currentCategory!);
    print("val = " + val);
    if (val != currentCategory && isWidgetInit) {
      currentCategory = val;
      refreshController.requestRefresh();
      if (!_isDisposed) {
        notifyListeners();
      }
    }
  }

  loadArticleViewer(BuildContext context, int position) async {
    var count = await Navigator.pushNamed(
      context,
      ArticleViewerScreen.routeName,
      arguments: ScreenArguements(position: position, items: _items),
    );

    if (count == 0) {
      InterstitialAdsModel.loadInterstitialAds();
    }
  }

  Future<void> setLastRefreshTime() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setInt("article_last_refresh_time", TimUtil.currentTimeInSeconds());
  }

  fetchOnFirstLoad(String? currentCategory) async {
    int? lastRefresh = 0;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (prefs.getInt("article_last_refresh_time") != null) {
      lastRefresh = prefs.getInt("article_last_refresh_time");
      print("lastRefresh = " + lastRefresh.toString());
    }
    print("COmpare categories = " +
        (this.currentCategory != currentCategory).toString());
    print("items length = " + _items!.length.toString());
    print("verify if should load = " +
        TimUtil.verifyIfScreenShouldReloadData(lastRefresh!).toString());
    if (this.currentCategory != currentCategory ||
        _items!.length == 0 ||
        lastRefresh == 0 ||
        TimUtil.verifyIfScreenShouldReloadData(lastRefresh)) {
      print("Load data now");
      this.currentCategory = currentCategory;
      refreshController.requestRefresh();
      fetchArticles();
    }
  }

  getUserLocation() async {
    try {
      location = await FlutterSimCountryCode.simCountryCode;
      print("location= " + location!);
    } catch (e) {
      location = 'wo';
      print("location= " + location!);
    }
  }

  getDatabaseArticles() async {
    /* List<Articles> itms = await SQLiteDbProvider.db.getAllArticles();
    if (itms.length > 0) {
      _items = itms;
    }
    notifyListeners();*/
  }

  List<Articles>? get items {
    return _items;
  }

  void setArticles(List<Articles>? item) {
    _items!.clear();
    _items = item;
    // SQLiteDbProvider.db.deleteAllArticles();
    // SQLiteDbProvider.db.insertBatchArticles(item);
    refreshController.refreshCompleted();
    isError = false;
    setLastRefreshTime();
    if (!_isDisposed) {
      notifyListeners();
    }
  }

  void setMoreArticles(List<Articles> item) {
    _items!.addAll(item);
    refreshController.loadComplete();
    if (!_isDisposed) {
      notifyListeners();
    }
  }

  /// Removes all items from the cart.
  void removeAll() {
    _items!.clear();
    //notifyListeners();
  }

  Future<void> getUnfollowedSources() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (prefs.getString("unfollowedfeedsources") != null) {
      unfollowedFeedSources =
          json.decode(prefs.getString("unfollowedfeedsources")!).cast<int>();
    }
  }

  Future<void> fetchArticles() async {
    await getUnfollowedSources();
    print("cats size = " + selectedcats.length.toString());
    try {
      var data = {
        "interests":
            currentCategory == "All Stories" ? selectedcats : [currentCategory],
        "location": location!.toLowerCase(),
      };
      if (unfollowedFeedSources!.length > 0) {
        data = {
          "interests": currentCategory == "All Stories"
              ? selectedcats
              : [currentCategory],
          "location": location!.toLowerCase(),
          "sources": unfollowedFeedSources!,
        };
      }
      print(data);
      final response = await http.post(Uri.parse(ApiUrl.ARTICLES),
          body: jsonEncode({"data": data}));
      if (response.statusCode == 200) {
        // If the server did return a 200 OK response,
        // then parse the JSON.
        print(response.body);
        final res = jsonDecode(response.body);
        sortDate = res["date"];
        final parsed = res["feeds"].cast<Map<String, dynamic>>();
        List<Articles>? articles =
            parsed.map<Articles>((json) => Articles.fromJson(json)).toList();
        setArticles(articles);
      } else {
        // If the server did not return a 200 OK response,
        // then throw an exception.
        setArticleFetchError();
      }
    } catch (exception) {
      // I get no exception here
      print(exception);
      setArticleFetchError();
    }
  }

  setArticleFetchError() {
    if (currentCategory != "All Stories") {
      _items = [];
      SQLiteDbProvider.db.deleteAllArticles();
    }
    refreshController.refreshFailed();
    isError = true;
    if (!_isDisposed) {
      notifyListeners();
    }
  }

  Future<void> fetchMoreArticles() async {
    await getUnfollowedSources();
    try {
      var data = {
        "interests":
            currentCategory == "All Stories" ? selectedcats : [currentCategory],
        "location": location!.toLowerCase(),
        "date": sortDate,
        "offset": items!.length + 1
      };
      if (unfollowedFeedSources!.length > 0) {
        data = {
          "interests": currentCategory == "All Stories"
              ? selectedcats
              : [currentCategory],
          "sources": unfollowedFeedSources,
          "location": location!.toLowerCase(),
          "date": sortDate,
          "offset": items!.length + 1
        };
      }
      final response = await http.post(Uri.parse(ApiUrl.ARTICLES),
          body: jsonEncode({"data": data}));
      if (response.statusCode == 200) {
        // If the server did return a 200 OK response,
        // then parse the JSON.
        final res = jsonDecode(response.body);
        final parsed = res["feeds"].cast<Map<String, dynamic>>();
        List<Articles> articles =
            parsed.map<Articles>((json) => Articles.fromJson(json)).toList();
        setMoreArticles(articles);
      } else {
        // If the server did not return a 200 OK response,
        // then throw an exception.
        refreshController.loadFailed();
        if (!_isDisposed) {
          notifyListeners();
        }
      }
    } catch (exception) {
      // I get no exception here
      print(exception);
      refreshController.loadFailed();
      if (!_isDisposed) {
        notifyListeners();
      }
    }
  }

  @override
  void dispose() {
    super.dispose();
    _isDisposed = true;
  }
}
