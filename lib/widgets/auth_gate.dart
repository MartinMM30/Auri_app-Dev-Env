// lib/widgets/auth_gate.dart
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:auri_app/services/auth_service.dart';
import 'package:auri_app/routes/app_routes.dart';
import 'package:auri_app/pages/auth/login_page.dart';
import 'package:auri_app/pages/auth/register_page.dart';

class AuthGate extends StatelessWidget {
  final bool isSurveyCompleted;

  const AuthGate({super.key, required this.isSurveyCompleted});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: AuthService.instance.authStateChanges,
      builder: (context, snapshot) {
        // Cargando estado de Firebase
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final user = snapshot.data;

        // Si NO hay usuario → mostrar pantalla de login
        if (user == null) {
          return const _LoginEntry();
        }

        // Si hay usuario logueado → decidir si va al Welcome (encuesta)
        // o directo al Home.
        final initialRoute = isSurveyCompleted
            ? AppRoutes.home
            : AppRoutes.welcome;

        // Usamos Navigator para ir a la ruta que ya tienes definida
        // evitando pantallas duplicadas.
        WidgetsBinding.instance.addPostFrameCallback((_) {
          Navigator.of(
            context,
          ).pushNamedAndRemoveUntil(initialRoute, (_) => false);
        });

        // Pantalla intermedia breve
        return const Scaffold(
          body: Center(child: Text("Preparando tu espacio...")),
        );
      },
    );
  }
}

/// Pequeño wrapper para que el Login use Navigator.pushNamed correctamente
class _LoginEntry extends StatelessWidget {
  const _LoginEntry();

  @override
  Widget build(BuildContext context) {
    return Navigator(
      onGenerateRoute: (settings) {
        return MaterialPageRoute(builder: (_) => const _AuthLandingScreen());
      },
    );
  }
}

/// Pantalla con Tabs: Iniciar sesión / Registrarse (simple)
class _AuthLandingScreen extends StatefulWidget {
  const _AuthLandingScreen();

  @override
  State<_AuthLandingScreen> createState() => _AuthLandingScreenState();
}

class _AuthLandingScreenState extends State<_AuthLandingScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tab;

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tab.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Auri · Inicia sesión"),
        bottom: TabBar(
          controller: _tab,
          tabs: const [
            Tab(text: "Iniciar sesión"),
            Tab(text: "Crear cuenta"),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tab,
        children: const [
          // los creamos abajo
          LoginPage(),
          RegisterPage(),
        ],
      ),
    );
  }
}
