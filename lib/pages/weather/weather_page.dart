import 'package:flutter/material.dart';
import '../../models/weather_model.dart';
import '../../services/weather_service.dart';

class WeatherPage extends StatefulWidget {
  const WeatherPage({super.key});

  @override
  State<WeatherPage> createState() => _WeatherPageState();
}

class _WeatherPageState extends State<WeatherPage> {
  final _weatherService = WeatherService();
  WeatherModel? _weather;
  String _errorMessage = '';

  void fetchWeather(String city) async {
    setState(() {
      _weather = null;
      _errorMessage = '';
    });

    try {
      final weatherData = await _weatherService.getWeather(city);
      setState(() => _weather = weatherData);
    } catch (e) {
      setState(() => _errorMessage = e.toString());
    }
  }

  @override
  void initState() {
    super.initState();
    fetchWeather("Mexico City");
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Clima - Auri'),
        actions: [
          IconButton(
            onPressed: () => fetchWeather("Mexico City"),
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (_errorMessage.isNotEmpty)
              Text(_errorMessage, style: const TextStyle(color: Colors.red)),

            if (_weather == null && _errorMessage.isEmpty)
              const CircularProgressIndicator(),

            if (_weather != null) ...[
              Text(
                _weather!.cityName,
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 10),

              Text(_weather!.emoji, style: const TextStyle(fontSize: 64)),

              const SizedBox(height: 10),

              Text(
                _weather!.description,
                style: TextStyle(
                  fontSize: 18,
                  color: cs.onSurface.withOpacity(0.7),
                ),
              ),

              const SizedBox(height: 10),

              Text(
                "${_weather!.temperature.round()}°C",
                style: const TextStyle(fontSize: 48),
              ),

              const SizedBox(height: 20),

              Text(
                "Viento: ${_weather!.windSpeed} m/s",
                style: TextStyle(color: cs.onSurface.withOpacity(0.6)),
              ),

              Text(
                "Humedad: ${_weather!.humidity}%",
                style: TextStyle(color: cs.onSurface.withOpacity(0.6)),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
