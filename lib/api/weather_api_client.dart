import 'dart:convert';
import '../models/weather.dart';
import 'package:meta/meta.dart';
import 'package:http/http.dart' as http;

/// Wrapper around the open weather map api
/// https://openweathermap.org/current
class WeatherApiClient {
  static const baseUrl = 'http://api.openweathermap.org';
  final apiKey;
  final http.Client httpClient;

  WeatherApiClient({required this.httpClient, required this.apiKey})
      : assert(httpClient != null),
        assert(apiKey != null);

  Future<String?> getCityNameFromLocation(
      {double? latitude, double? longitude}) async {
    final url =
        '$baseUrl/data/2.5/weather?lat=$latitude&lon=$longitude&appid=$apiKey';
    print('fetching $url');
    final res = await this.httpClient.get(Uri.parse(url));
    if (res.statusCode != 200) {
      return null;
    }
    final weatherJson = json.decode(res.body);
    return weatherJson['name'];
  }

  Future<Weather?> getWeatherData(String? cityName) async {
    final url = '$baseUrl/data/2.5/weather?q=$cityName&appid=$apiKey';
    print('fetching $url');
    final res = await this.httpClient.get(Uri.parse(url));
    if (res.statusCode != 200) {
      print("error weather= failed");
      return null;
    }
    final weatherJson = json.decode(res.body);
    return Weather.fromJson(weatherJson);
  }

  Future<List<dynamic>?> getForecast(String? cityName) async {
    final url = '$baseUrl/data/2.5/forecast?q=$cityName&appid=$apiKey';
    print('fetching $url');
    final res = await this.httpClient.get(Uri.parse(url));
    if (res.statusCode != 200) {
      print("error weather= failed2");
      return null;
    }
    final forecastJson = json.decode(res.body);
    List<dynamic> weathers = Weather.fromForecastJson(forecastJson);
    return weathers;
  }
}
