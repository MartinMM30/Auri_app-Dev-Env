import 'package:flutter/material.dart';

class WeatherModel {
  final String cityName;
  final double temperature;
  final double feelsLike;
  final String description;
  final String condition;
  final String iconCode;
  final double windSpeed;
  final int humidity;

  WeatherModel({
    required this.cityName,
    required this.temperature,
    required this.feelsLike,
    required this.description,
    required this.condition,
    required this.iconCode,
    required this.windSpeed,
    required this.humidity,
  });

  factory WeatherModel.fromJson(Map<String, dynamic> json) {
    return WeatherModel(
      cityName: json['name'] ?? '-',
      temperature: (json['main']['temp'] as num).toDouble(),
      feelsLike: (json['main']['feels_like'] as num).toDouble(),
      description: json['weather'][0]['description'] ?? 'N/A',
      condition: json['weather'][0]['main'] ?? 'Unknown',
      iconCode: json['weather'][0]['icon'] ?? '01d',
      windSpeed: (json['wind']?['speed'] as num?)?.toDouble() ?? 0.0,
      humidity: json['main']?['humidity'] ?? 0,
    );
  }

  String get iconUrl => "https://openweathermap.org/img/wn/$iconCode@4x.png";

  String get emoji {
    switch (condition) {
      case 'Clear':
        return '☀️';
      case 'Clouds':
        return '☁️';
      case 'Rain':
        return '🌧️';
      case 'Thunderstorm':
        return '⛈️';
      case 'Snow':
        return '❄️';
      case 'Drizzle':
        return '🌦️';
      case 'Mist':
        return '🌫️';
      default:
        return '🌡️';
    }
  }

  Color get moodColor {
    switch (condition) {
      case 'Clear':
        return Colors.amber.shade400;
      case 'Clouds':
        return Colors.blueGrey.shade400;
      case 'Rain':
        return Colors.indigo.shade400;
      case 'Thunderstorm':
        return Colors.deepPurple.shade700;
      case 'Snow':
        return Colors.lightBlue.shade200;
      case 'Drizzle':
        return Colors.blue.shade300;
      case 'Mist':
        return Colors.grey.shade500;
      default:
        return Colors.blueGrey.shade200;
    }
  }

  String get outfitCategory {
    if (temperature >= 28) return "hot";
    if (temperature >= 20) return "warm";
    if (temperature >= 14) return "cool";
    if (temperature >= 7) return "cold";
    return "freezing";
  }

  String get outfitSuggestion {
    switch (outfitCategory) {
      case "hot":
        return "Ropa ligera, hidratación y protector solar.";
      case "warm":
        return "Ropa cómoda, quizá una camisa ligera.";
      case "cool":
        return "Una sudadera o chaqueta ligera será útil.";
      case "cold":
        return "Abrigo recomendado.";
      default:
        return "Abrígate bien, hace bastante frío.";
    }
  }

  String get rainIntensity {
    if (condition != "Rain" && condition != "Drizzle") return "none";

    if (description.contains("light")) return "light";
    if (description.contains("heavy")) return "heavy";
    return "medium";
  }
}
