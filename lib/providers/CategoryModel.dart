import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'dart:async';
import 'package:http/http.dart' as http;
import '../utils/ApiUrl.dart';
import '../utils/Parsers.dart';
import '../models/Categories.dart';
import '../utils/SQLiteDbProvider.dart';

class CategoryModel with ChangeNotifier {
  List<Categories> _items = [];
  List<String?> selectedcats = [];
  List<Categories> dbcategories = [];
  bool isLoading = true;
  bool? isFirstimeLoad = false;

  CategoryModel(bool? isFirstimeLoad) {
    this.isFirstimeLoad = isFirstimeLoad;
    getDatabaseCategories();
    fetchCategories();
  }

  getDatabaseCategories() async {
    dbcategories = await SQLiteDbProvider.db.getAllCategories();
    for (var itm in dbcategories) {
      selectedcats.add(itm.title);
    }
  }

  /// An unmodifiable view of the items.
  List<Categories> get items {
    return _items;
  }

  void setCategories(List<Categories> item) {
    _items.addAll(item);
    for (var itm in item) {
      if (isFirstimeLoad! && !isContain(itm.title)) {
        selectedcats.add(itm.title);
        dbcategories.add(itm);
        SQLiteDbProvider.db.insertCategory(itm);
        print("insert to db: " + itm.title!);
      }
    }
    _items.sort((a, b) {
      return a.title!.toLowerCase().compareTo(b.title!.toLowerCase());
    });
    isLoading = false;
    notifyListeners();
  }

  /// Removes all items from the cart.
  void removeAll() {
    _items.clear();
    //notifyListeners();
  }

  void setLoading() {
    isLoading = true;
    //notifyListeners();
  }

  void fetchData() {
    isLoading = true;
    notifyListeners();
    fetchCategories();
  }

  bool isContain(String? title) {
    return selectedcats.contains(title);
  }

  void selectUnselectCategory(Categories categories) {
    if (!isContain(categories.title)) {
      selectedcats.add(categories.title);
      dbcategories.add(categories);
      SQLiteDbProvider.db.insertCategory(categories);
      notifyListeners();
    } else {
      dbcategories.remove(categories);
      selectedcats.remove(categories.title);
      SQLiteDbProvider.db.deleteCategory(categories.id);
      notifyListeners();
    }
  }

  Future<void> fetchCategories() async {
    try {
      final response = await http.get(Uri.parse(ApiUrl.CATEGORIES));
      if (response.statusCode == 200) {
        // If the server did return a 200 OK response,
        // then parse the JSON.
        List<Categories> cats = await compute(parseCategories, response.body);
        setCategories(cats);
      } else {
        // If the server did not return a 200 OK response,
        // then throw an exception.
        isLoading = false;
        notifyListeners();
      }
    } catch (exception) {
      // I get no exception here
      print(exception);
      isLoading = false;
      notifyListeners();
    }
  }

  static List<Categories> parseCategories(String responseBody) {
    final parsed =
        jsonDecode(responseBody)["interests"].cast<Map<String, dynamic>>();
    return parsed.map<Categories>((json) => Categories.fromJson(json)).toList();
  }
}
