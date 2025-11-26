import 'weather_models_v2.dart';

class ForecastParser {
  static List<ForecastEntryV2> parseList(Map<String, dynamic> json) {
    final List list = json["list"];

    return list.map((item) {
      final time = DateTime.parse(item["dt_txt"]);

      // Probabilidad lluvia
      double rain = 0;
      if (item["pop"] != null) {
        rain = (item["pop"] as num).toDouble(); // 0.0 a 1.0
      }

      return ForecastEntryV2(
        time: time,
        temp: (item["main"]["temp"] as num).toDouble(),
        condition: item["weather"][0]["main"],
        humidity: item["main"]["humidity"],
        wind: (item["wind"]["speed"] as num).toDouble(),
        rainProb: rain,
      );
    }).toList();
  }

  // ======================================================================
  // ⛈️ HORAS DE LLUVIA
  // ======================================================================
  static List<ForecastEntryV2> extractRainHours(ForecastV2 f) {
    return f.entries.where((e) => e.rainProb >= 0.4).toList();
  }

  // ======================================================================
  // 🔥 HORAS CALUROSAS
  // ======================================================================
  static List<ForecastEntryV2> extractHotHours(ForecastV2 f) {
    return f.entries.where((e) => e.temp >= 30).toList();
  }

  // ======================================================================
  // 🧊 HORAS FRÍAS
  // ======================================================================
  static List<ForecastEntryV2> extractColdHours(ForecastV2 f) {
    return f.entries.where((e) => e.temp <= 12).toList();
  }
}
