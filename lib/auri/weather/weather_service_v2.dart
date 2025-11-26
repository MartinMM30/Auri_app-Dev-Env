import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'weather_models_v2.dart';
import 'forecast_parser.dart';

class WeatherServiceV2 {
  static final WeatherServiceV2 instance = WeatherServiceV2._internal();
  WeatherServiceV2._internal();

  final String apiKey = dotenv.env['API_KEY'] ?? '';

  // ============================================================
  // 1) CLIMA ACTUAL
  // ============================================================
  Future<CurrentWeatherV2> getCurrent(String city) async {
    final uri = Uri.parse(
      "https://api.openweathermap.org/data/2.5/weather"
      "?q=$city&appid=$apiKey&units=metric&lang=es",
    );

    final res = await http.get(uri);
    if (res.statusCode != 200) {
      throw Exception("Error al obtener clima actual: ${res.statusCode}");
    }

    final json = jsonDecode(res.body);
    return CurrentWeatherV2.fromJson(json);
  }

  // ============================================================
  // 2) PRONÓSTICO 5 DÍAS (3 h)
  // ============================================================
  Future<ForecastV2> getForecast(String city) async {
    final uri = Uri.parse(
      "https://api.openweathermap.org/data/2.5/forecast"
      "?q=$city&appid=$apiKey&units=metric&lang=es",
    );

    final res = await http.get(uri);
    if (res.statusCode != 200) {
      throw Exception("Error al obtener forecast: ${res.statusCode}");
    }

    final json = jsonDecode(res.body);

    final list = ForecastParser.parseList(json);
    return ForecastV2(cityName: json["city"]["name"], entries: list);
  }

  // ============================================================
  // 3) CLIMA AVANZADO (fusionado)
  // ============================================================
  Future<AdvancedWeatherV2> getAdvanced(String city) async {
    final current = await getCurrent(city);
    final forecast = await getForecast(city);

    return AdvancedWeatherV2(
      current: current,
      forecast: forecast,
      rainHours: ForecastParser.extractRainHours(forecast),
      hotHours: ForecastParser.extractHotHours(forecast),
      coldHours: ForecastParser.extractColdHours(forecast),
    );
  }
}
