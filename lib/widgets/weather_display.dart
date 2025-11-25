import 'package:flutter/material.dart';
import '../models/weather_model.dart';
import '../services/weather_service.dart';

class WeatherDisplay extends StatefulWidget {
  final String cityName;

  const WeatherDisplay({super.key, required this.cityName});

  @override
  State<WeatherDisplay> createState() => _WeatherDisplayState();
}

class _WeatherDisplayState extends State<WeatherDisplay> {
  final _weatherService = WeatherService();
  WeatherModel? _weather;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    fetchWeather(widget.cityName);
  }

  @override
  void didUpdateWidget(covariant WeatherDisplay oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.cityName != widget.cityName) {
      fetchWeather(widget.cityName);
    }
  }

  void fetchWeather(String city) async {
    if (city.trim().isEmpty) {
      setState(() {
        _errorMessage = 'Configura tu ciudad en Ajustes.';
        _weather = null;
      });
      return;
    }

    setState(() {
      _weather = null;
      _errorMessage = '';
    });

    try {
      final w = await _weatherService.getWeather(city);
      setState(() => _weather = w);
    } catch (e) {
      setState(() {
        _errorMessage = "No se pudo obtener el clima para $city.";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_errorMessage.isNotEmpty) {
      return Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.red.withOpacity(0.2),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.red),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '⚠️ Error al cargar clima',
              style: TextStyle(
                color: Colors.redAccent,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 5),
            Text(_errorMessage),
          ],
        ),
      );
    }

    if (_weather == null) {
      return const Center(child: CircularProgressIndicator());
    }

    final w = _weather!;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: w.moodColor.withOpacity(0.2),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: w.moodColor.withOpacity(0.4)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // LEFT SIDE (Expanded → evita overflow)
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                FittedBox(
                  alignment: Alignment.centerLeft,
                  fit: BoxFit.scaleDown,
                  child: Text(
                    w.cityName,
                    style: const TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  w.description,
                  style: const TextStyle(fontSize: 16, color: Colors.white70),
                ),
                const SizedBox(height: 8),
                GestureDetector(
                  onTap: () => fetchWeather(widget.cityName),
                  child: const Text(
                    "Actualizar",
                    style: TextStyle(
                      color: Colors.tealAccent,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // RIGHT SIDE (emoji + temp)
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(w.emoji, style: const TextStyle(fontSize: 48)),
              const SizedBox(width: 12),
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  '${w.temperature.round()}°C',
                  style: const TextStyle(
                    fontSize: 40,
                    fontWeight: FontWeight.w300,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
