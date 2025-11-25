import 'package:flutter/material.dart';

class WeatherModel {
  final String cityName;
  final double temperature;
  final String description;
  final String condition; // Clear, Rain, Clouds, etc.
  final String iconCode; // API icon
  final double windSpeed;
  final int humidity;

  WeatherModel({
    required this.cityName,
    required this.temperature,
    required this.description,
    required this.condition,
    required this.iconCode,
    required this.windSpeed,
    required this.humidity,
  });

  /// Parse desde OpenWeatherMap
  factory WeatherModel.fromJson(Map<String, dynamic> json) {
    return WeatherModel(
      cityName: json['name'] ?? '-',
      temperature: (json['main']['temp'] as num).toDouble(),
      description: json['weather'][0]['description'] ?? 'N/A',
      condition: json['weather'][0]['main'] ?? 'Unknown',
      iconCode: json['weather'][0]['icon'] ?? '01d',
      windSpeed: (json['wind']?['speed'] as num?)?.toDouble() ?? 0.0,
      humidity: json['main']?['humidity'] ?? 0,
    );
  }

  /// Icono oficial de OWM
  String get iconUrl => "https://openweathermap.org/img/wn/$iconCode@4x.png";

  /// Emoji para UI simple
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

  /// Color para tarjetas según condición
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

  /// Categoría para el outfit del usuario
  String get outfitCategory {
    if (temperature >= 28) return "hot";
    if (temperature >= 20) return "warm";
    if (temperature >= 14) return "cool";
    if (temperature >= 7) return "cold";
    return "freezing";
  }

  /// Recomendación básica incluida
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

  /// Intensidad de la lluvia → útil para animación del slime Auri
  String get rainIntensity {
    if (condition != "Rain" && condition != "Drizzle") return "none";

    if (description.contains("light")) return "light";
    if (description.contains("heavy")) return "heavy";
    return "medium";
  }
}
