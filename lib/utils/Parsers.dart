import 'dart:convert';
import '../models/Categories.dart';
import '../models/Radios.dart';
import '../models/Sources.dart';

class Parsers {
  static List<Categories> parseCategories(String responseBody) {
    final parsed =
        jsonDecode(responseBody)["interests"].cast<Map<String, dynamic>>();
    return parsed.map<Categories>((json) => Categories.fromJson(json)).toList();
  }

  static List<Radios> parseRadios(String responseBody) {
    final parsed =
        jsonDecode(responseBody)["radios"].cast<Map<String, dynamic>>();
    return parsed.map<Radios>((json) => Radios.fromJson(json)).toList();
  }

  static List<Sources> parseSources(String responseBody) {
    final parsed =
        jsonDecode(responseBody)["sources"].cast<Map<String, dynamic>>();
    return parsed.map<Sources>((json) => Sources.fromJson(json)).toList();
  }
}
