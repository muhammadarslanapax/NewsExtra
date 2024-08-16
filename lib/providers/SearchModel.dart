import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'dart:async';
import 'package:http/http.dart' as http;
import '../screens/ArticleViewerScreen.dart';
import '../screens/VideoViewerScreen.dart';
import '../models/ScreenArguements.dart';
import '../utils/ApiUrl.dart';
import '../models/Search.dart';
import '../models/Articles.dart';
import '../models/Videos.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:flutter_sim_country_code/flutter_sim_country_code.dart';

class SearchModel with ChangeNotifier {
  List<Search> _items = [];
  RefreshController refreshController =
      RefreshController(initialRefresh: false);
  bool isError = false;
  bool isLoading = false;
  bool isIdle = true;
  static bool isFirstLoad = false;
  String? location = 'wo';
  static String? sortDate = '';
  String query = "";

  SearchModel() {
    getUserLocation();
    //fetchOnFirstLoad();
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

  List<Search> get items {
    return _items;
  }

  loadSearchViewer(BuildContext context, int position) {
    Search search = items[position];
    if (search.type!.toLowerCase() == "article") {
      Navigator.pushNamed(
        context,
        ArticleViewerScreen.routeName,
        arguments: getArticlesList(search.id),
      );
    } else {
      Navigator.pushNamed(
        context,
        VideoViewerScreen.routeName,
        arguments: getVideosList(search.id),
      );
    }
  }

  ScreenArguements getArticlesList(int? id) {
    List<Articles> itms = [];
    int position = 0;
    for (Search search in items) {
      if (search.type!.toLowerCase() == "article") {
        Articles articles = Articles.fromSearch(search);
        itms.add(articles);
        if (search.id == id) {
          position = itms.indexOf(articles);
        }
      }
    }
    return ScreenArguements(position: position, items: itms);
  }

  ScreenArguements getVideosList(int? id) {
    List<Videos> itms = [];
    int position = 0;
    for (Search search in items) {
      if (search.type!.toLowerCase() == "article") {
        Videos videos = Videos.fromSearch(search);
        itms.add(videos);
        if (search.id == id) {
          position = itms.indexOf(videos);
        }
      }
    }
    return ScreenArguements(position: position, items: itms);
  }

  void cancelSearch() {
    isError = false;
    isLoading = false;
    isIdle = true;
    notifyListeners();
  }

  void setSearchResult(List<Search> item) {
    _items = item;
    refreshController.refreshCompleted();
    isError = false;
    isLoading = false;
    notifyListeners();
  }

  void setMoreSearchResults(List<Search> item) {
    _items.addAll(item);
    refreshController.loadComplete();
    notifyListeners();
  }

  Future<void> searchArticles(String query) async {
    try {
      this.query = query;
      isIdle = false;
      isFirstLoad = true;
      isLoading = true;
      notifyListeners();
      final response = await http.post(Uri.parse(ApiUrl.SEARCH),
          body: jsonEncode({
            "data": {
              "offset": 0,
              "query": query,
              "location": location!.toLowerCase()
            }
          }));
      if (response.statusCode == 200) {
        // If the server did return a 200 OK response,
        // then parse the JSON.
        List<Search> articles = await compute(parseArticles, response.body);
        setSearchResult(articles);
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
    _items = [];
    refreshController.refreshFailed();
    isError = true;
    isLoading = false;
    notifyListeners();
  }

  Future<void> fetchMoreArticles() async {
    isFirstLoad = false;
    try {
      final response = await http.post(Uri.parse(ApiUrl.SEARCH),
          body: jsonEncode({
            "data": {
              "query": query,
              "location": location!.toLowerCase(),
              "date": sortDate,
              "offset": items.length + 1
            }
          }));
      if (response.statusCode == 200) {
        // If the server did return a 200 OK response,
        // then parse the JSON.
        List<Search> articles = await compute(parseArticles, response.body);
        setMoreSearchResults(articles);
      } else {
        // If the server did not return a 200 OK response,
        // then throw an exception.
        refreshController.refreshFailed();
        notifyListeners();
      }
    } catch (exception) {
      // I get no exception here
      print(exception);
      refreshController.loadFailed();
      notifyListeners();
    }
  }

  static List<Search> parseArticles(String responseBody) {
    final res = jsonDecode(responseBody);
    if (isFirstLoad) {
      sortDate = res["date"];
    }
    final parsed = res["search"].cast<Map<String, dynamic>>();
    return parsed.map<Search>((json) => Search.fromJson(json)).toList();
  }
}
