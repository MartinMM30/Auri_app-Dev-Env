class CurrentWeatherV2 {
  final String condition;
  final String description;
  final double temp;
  final double feelsLike;
  final int humidity;
  final double wind;
  final String icon;

  CurrentWeatherV2({
    required this.condition,
    required this.description,
    required this.temp,
    required this.feelsLike,
    required this.humidity,
    required this.wind,
    required this.icon,
  });

  factory CurrentWeatherV2.fromJson(Map<String, dynamic> json) {
    return CurrentWeatherV2(
      condition: json["weather"][0]["main"] ?? "Unknown",
      description: json["weather"][0]["description"] ?? '',
      temp: (json["main"]["temp"] as num).toDouble(),
      feelsLike: (json["main"]["feels_like"] as num).toDouble(),
      humidity: json["main"]["humidity"],
      wind: (json["wind"]["speed"] as num).toDouble(),
      icon: json["weather"][0]["icon"],
    );
  }
}

class ForecastEntryV2 {
  final DateTime time;
  final double temp;
  final String condition;
  final int humidity;
  final double wind;
  final double rainProb;

  ForecastEntryV2({
    required this.time,
    required this.temp,
    required this.condition,
    required this.humidity,
    required this.wind,
    required this.rainProb,
  });
}

class ForecastV2 {
  final String cityName;
  final List<ForecastEntryV2> entries;

  ForecastV2({required this.cityName, required this.entries});
}

class AdvancedWeatherV2 {
  final CurrentWeatherV2 current;
  final ForecastV2 forecast;

  final List<ForecastEntryV2> rainHours;
  final List<ForecastEntryV2> hotHours;
  final List<ForecastEntryV2> coldHours;

  AdvancedWeatherV2({
    required this.current,
    required this.forecast,
    required this.rainHours,
    required this.hotHours,
    required this.coldHours,
  });
}
