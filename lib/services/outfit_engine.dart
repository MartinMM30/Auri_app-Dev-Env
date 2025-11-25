// lib/services/outfit_engine.dart

import 'package:auri_app/models/weather_model.dart';

class OutfitAccessory {
  final String emoji;
  final String reason;

  OutfitAccessory(this.emoji, this.reason);
}

class OutfitEngine {
  /// --- ACCESORIOS AURI ---
  static OutfitAccessory? pickAccessory(WeatherModel w) {
    final c = w.condition.toLowerCase();

    if (c.contains("rain")) return OutfitAccessory("☔", "lluvia");
    if (c.contains("snow")) return OutfitAccessory("🧣", "nieve");
    if (w.temperature >= 30) return OutfitAccessory("🧢", "sol fuerte");
    if (w.temperature <= 10) return OutfitAccessory("🧤", "frío");
    return null;
  }

  /// --- TITULO ---
  static String title(WeatherModel w) {
    final t = w.temperature;
    final c = w.condition.toLowerCase();

    if (c.contains("rain")) return "Listo para la lluvia";
    if (c.contains("snow")) return "Abrigo extremo";
    if (t >= 28) return "Verano intenso";
    if (t >= 20) return "Look ligero";
    if (t >= 14) return "Capas suaves";
    return "Ropa abrigada";
  }

  /// --- DESCRIPCIÓN ---
  static String description(WeatherModel w) {
    final t = w.temperature;
    final c = w.condition.toLowerCase();

    if (c.contains("rain")) return "Chamarra impermeable y ropa oscura.";
    if (c.contains("snow")) return "Abrigo, bufanda y guantes esenciales.";
    if (t >= 28) return "Ropa ligera, evita calor excesivo.";
    if (t >= 20) return "Look fresco y cómodo.";
    if (t >= 14) return "Chaqueta ligera funciona perfecto.";
    return "Abrígate bien, hace frío.";
  }
}
