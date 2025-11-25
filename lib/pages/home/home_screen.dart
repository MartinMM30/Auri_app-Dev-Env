import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:auri_app/models/reminder_hive.dart';
import 'package:auri_app/widgets/auri_visual.dart';
import 'package:auri_app/widgets/weather_display.dart';
import 'package:auri_app/widgets/outfit_recommendation.dart';
import 'package:auri_app/services/weather_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:auri_app/routes/app_routes.dart';
import 'package:auri_app/models/weather_model.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _userName = '';
  String _userCity = '';

  final WeatherService _weatherService = WeatherService();
  WeatherModel? _weather;

  bool _weatherLoading = true;
  String _weatherError = '';

  List<ReminderHive> _upcoming = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => loadData());
  }

  Future<void> loadData() async {
    final prefs = await SharedPreferences.getInstance();
    _userName = prefs.getString('userName') ?? "Usuario";
    _userCity = prefs.getString('userCity') ?? "";

    if (!mounted) return;
    setState(() {});

    await _loadWeather();
    await _loadReminders();
  }

  Future<void> _loadWeather() async {
    if (_userCity.isEmpty) {
      _weatherError = "Configura tu ciudad en ajustes.";
      _weatherLoading = false;
      if (!mounted) return;
      setState(() {});
      return;
    }

    try {
      final w = await _weatherService.getWeather(_userCity);
      _weather = w;
      _weatherError = '';
    } catch (_) {
      _weatherError = "Error cargando clima";
    }

    _weatherLoading = false;
    if (!mounted) return;
    setState(() {});
  }

  Future<void> _loadReminders() async {
    final box = Hive.box('reminders');

    final all = box.values.cast<ReminderHive>().toList();

    final now = DateTime.now();

    final upcoming =
        all.where((r) {
          final dt = DateTime.tryParse(r.dateIso);
          return dt != null && dt.isAfter(now);
        }).toList()..sort((a, b) {
          final da = DateTime.parse(a.dateIso);
          final db = DateTime.parse(b.dateIso);
          return da.compareTo(db);
        });

    _upcoming = upcoming;

    if (!mounted) return;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Auri: Dashboard"),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () async {
              await Navigator.pushNamed(context, AppRoutes.settings);
              loadData();
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Hola, $_userName",
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: cs.primary,
              ),
            ),
            const SizedBox(height: 5),
            Text(
              "Tu asistente Auri tiene tu día bajo control.",
              style: TextStyle(
                fontSize: 16,
                color: cs.onSurface.withOpacity(0.7),
              ),
            ),

            const SizedBox(height: 25),

            if (_weatherLoading)
              const Center(child: CircularProgressIndicator())
            else if (_weatherError.isNotEmpty)
              _ErrorCard(message: _weatherError)
            else if (_weather != null)
              WeatherDisplay(cityName: _userCity),

            const SizedBox(height: 20),

            if (_weather != null)
              OutfitRecommendationWidget(
                temperature: _weather!.temperature,
                condition: _weather!.condition, // ← Nuevo modelo
                onTap: () {},
              ),

            const SizedBox(height: 25),

            Row(
              children: [
                Expanded(
                  child: Text(
                    'Próximos Recordatorios',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                TextButton.icon(
                  icon: const Icon(Icons.alarm),
                  label: const Text("Ver Todos"),
                  onPressed: () {
                    Navigator.pushNamed(context, AppRoutes.reminders);
                  },
                ),
              ],
            ),

            if (_upcoming.isEmpty)
              Padding(
                padding: const EdgeInsets.all(30),
                child: Center(
                  child: Text(
                    "¡No tienes recordatorios pendientes! ✨",
                    style: TextStyle(color: cs.onSurface.withOpacity(0.6)),
                  ),
                ),
              )
            else
              ..._upcoming.take(3).map((r) => _ReminderItem(r: r, cs: cs)),

            const SizedBox(height: 40),
            Center(
              child: Column(
                children: [
                  const SizedBox(width: 100, height: 100, child: AuriVisual()),
                  const SizedBox(height: 10),
                  Text(
                    "Auri está lista para ayudarte.",
                    style: TextStyle(color: cs.onSurface.withOpacity(0.8)),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ReminderItem extends StatelessWidget {
  final ReminderHive r;
  final ColorScheme cs;

  const _ReminderItem({required this.r, required this.cs});

  @override
  Widget build(BuildContext context) {
    final date = DateTime.tryParse(r.dateIso);
    final formatted = date != null
        ? "${date.day}/${date.month} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}"
        : "Fecha inválida";

    return Card(
      color: cs.surface.withOpacity(0.1),
      child: ListTile(
        leading: const Icon(Icons.alarm, color: Colors.purpleAccent),
        title: Text(r.title, overflow: TextOverflow.ellipsis),
        subtitle: Text("Vence: $formatted"),
      ),
    );
  }
}

class _ErrorCard extends StatelessWidget {
  final String message;
  const _ErrorCard({required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.red.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.red),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline, color: Colors.red),
          const SizedBox(width: 10),
          Expanded(child: Text(message)),
        ],
      ),
    );
  }
}
