import 'package:flutter/foundation.dart';
import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../utils/ApiUrl.dart';
import '../utils/Parsers.dart';
import '../models/Radios.dart';
import '../utils/TimUtil.dart';
import '../utils/SQLiteDbProvider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RadioModel with ChangeNotifier {
  List<Radios> _items = [];
  bool isError = false;
  String location = 'wo';
  RefreshController refreshController =
      RefreshController(initialRefresh: false);

  RadioModel() {
    getDatabaseRadio();
    //fetchRadio();
  }

//fetch radio, display list
  Future<void> setLastRefreshTime() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setInt("radio_last_refresh_time", TimUtil.currentTimeInSeconds());
  }

  fetchOnFirstLoad() async {
    int? lastRefresh = 0;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (prefs.getInt("radio_last_refresh_time") != null) {
      lastRefresh = prefs.getInt("radio_last_refresh_time");
    }
    if (lastRefresh == 0 ||
        TimUtil.verifyIfScreenShouldReloadData(lastRefresh!)) {
      print("Load data now");
      refreshController.requestRefresh();
      fetchRadio();
    }
  }

  getDatabaseRadio() async {
    _items = await SQLiteDbProvider.db.getAllRadio();
    notifyListeners();
  }

  /// An unmodifiable view of the items.
  List<Radios> get items {
    return _items;
  }

  void setRadios(List<Radios> item) {
    _items = item;
    SQLiteDbProvider.db.deleteAllRadio();
    SQLiteDbProvider.db.insertBatchRadio(item);
    refreshController.refreshCompleted();
    isError = false;
    setLastRefreshTime();
    _items.sort((a, b) {
      return a.title!.toLowerCase().compareTo(b.title!.toLowerCase());
    });
    notifyListeners();
  }

  Future<void> fetchRadio() async {
    try {
      final response = await http.post(Uri.parse(ApiUrl.RADIO),
          body: jsonEncode({
            "data": {"location": location.toLowerCase()}
          }));
      if (response.statusCode == 200) {
        // If the server did return a 200 OK response,
        // then parse the JSON.
        List<Radios> cats = await compute(Parsers.parseRadios, response.body);
        print(cats.toString());
        setRadios(cats);
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
    if (_items.length == 0) {
      refreshController.refreshFailed();
      isError = true;
    }
    notifyListeners();
  }
}
