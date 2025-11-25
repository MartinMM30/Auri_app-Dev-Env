// lib/pages/settings/settings_screen.dart
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:hive/hive.dart';

import 'package:auri_app/routes/app_routes.dart';
import 'package:auri_app/services/auth_service.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  Future<void> _reset(BuildContext context) async {
    // 1. Borrar SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();

    // 2. Borrar recordatorios (Hive)
    if (Hive.isBoxOpen('reminders')) {
      await Hive.box('reminders').clear(); // borra solo contenidos
    }

    // Si quieres borrar todos los boxes existentes:
    // for (var box in Hive.boxes.values) {
    //   await box.clear();
    // }

    // 3. Redirigir al inicio
    if (context.mounted) {
      Navigator.pushNamedAndRemoveUntil(
        context,
        AppRoutes.welcome,
        (_) => false,
      );
    }
  }

  void _confirmReset(BuildContext context) {
    showDialog(
      context: context,
      builder: (c) => AlertDialog(
        title: const Text("¿Reiniciar configuración?"),
        content: const Text("Esto borrará tus datos y volverás al inicio."),
        actions: [
          TextButton(
            child: const Text("Cancelar"),
            onPressed: () => Navigator.pop(c),
          ),
          TextButton(
            child: const Text("Reiniciar"),
            onPressed: () {
              Navigator.pop(c);
              _reset(context);
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Configuración")),
      body: ListView(
        children: [
          ListTile(
            leading: const Icon(Icons.person),
            title: const Text("Editar mi información"),
            onTap: () => Navigator.pushNamed(context, AppRoutes.survey),
          ),
          ListTile(
            leading: const Icon(Icons.refresh),
            title: const Text("Reiniciar configuración inicial"),
            subtitle: const Text("Borrar todos tus datos"),
            onTap: () => _confirmReset(context),
          ),
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text("Cerrar sesión"),
            onTap: () async {
              await AuthService.instance.signOut();
              // AuthGate detecta user == null y vuelve al login.
            },
          ),
        ],
      ),
    );
  }
}
