import 'package:flutter/material.dart';
import 'controllers/survey_controller.dart';
import 'widgets/survey_section.dart';
import 'widgets/survey_text_field.dart';
import 'widgets/survey_multi_text_field.dart';
import 'widgets/survey_switch.dart';
import 'package:auri_app/pages/survey/widgets/survey_time_picker.dart';

class SurveyScreen extends StatefulWidget {
  final bool isInitialSetup;

  const SurveyScreen({super.key, required this.isInitialSetup});

  @override
  State<SurveyScreen> createState() => _SurveyScreenState();
}

class _SurveyScreenState extends State<SurveyScreen> {
  final SurveyController controller = SurveyController();
  final PageController _pageController = PageController();
  int _page = 0;

  bool loading = true;

  final int totalPages = 5;

  // -------------------------------------------------------
  // PARSE TIME (para transformar "08:30" → TimeOfDay)
  // -------------------------------------------------------
  TimeOfDay _parseTime(String text) {
    try {
      final parts = text.split(":");
      return TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
    } catch (_) {
      return const TimeOfDay(hour: 8, minute: 0);
    }
  }

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    await controller.load();
    setState(() => loading = false);
  }

  void _next() {
    if (_page < totalPages - 1) {
      _pageController.animateToPage(
        _page + 1,
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOut,
      );
    } else {
      _save();
    }
  }

  void _back() {
    if (_page > 0) {
      _pageController.animateToPage(
        _page - 1,
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOut,
      );
    }
  }

  Future<void> _save() async {
    await controller.save();
    if (!mounted) return;

    if (widget.isInitialSetup) {
      Navigator.pushReplacementNamed(context, "/home");
    } else {
      Navigator.pop(context);
    }
  }

  @override
  void dispose() {
    controller.dispose();
    _pageController.dispose();
    super.dispose();
  }

  // -------------------------------------------------------
  // PROGRESS BAR
  // -------------------------------------------------------
  Widget _buildProgress(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final progress = (_page + 1) / totalPages;

    return Container(
      height: 8,
      margin: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
      decoration: BoxDecoration(
        color: cs.surface.withOpacity(0.2),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Align(
        alignment: Alignment.centerLeft,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeOutQuad,
          width: MediaQuery.of(context).size.width * progress,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                cs.primary.withOpacity(0.9),
                cs.primary.withOpacity(0.6),
              ],
            ),
            borderRadius: BorderRadius.circular(30),
          ),
        ),
      ),
    );
  }

  // -------------------------------------------------------
  // BUILD
  // -------------------------------------------------------
  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    if (loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      backgroundColor: cs.background,
      body: SafeArea(
        child: Column(
          children: [
            _buildProgress(context),

            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                onPageChanged: (i) => setState(() => _page = i),
                children: [
                  _pagePerfil(),
                  _pageRutina(),
                  _pagePagos(),
                  _pageCumples(),
                  _pagePreferencias(),
                ],
              ),
            ),
          ],
        ),
      ),

      bottomNavigationBar: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          color: cs.surface.withOpacity(0.1),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(22)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            if (_page > 0)
              TextButton(
                onPressed: _back,
                child: const Text("Atrás", style: TextStyle(fontSize: 18)),
              )
            else
              const SizedBox(width: 70),

            ElevatedButton(
              onPressed: _next,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 35,
                  vertical: 14,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
              ),
              child: Text(
                _page < totalPages - 1 ? "Siguiente" : "Finalizar",
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // -------------------------------------------------------------
  // PÁGINAS DEL SURVEY
  // -------------------------------------------------------------

  Widget _pagePerfil() {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        SurveySection(
          title: "Tu Perfil",
          children: [
            SurveyTextField(
              label: "¿Cómo te llamas?",
              controller: controller.name,
            ),
            SurveyTextField(
              label: "¿A qué te dedicas?",
              controller: controller.occupation,
            ),
            SurveyTextField(
              label: "¿En qué ciudad vives?",
              controller: controller.city,
            ),
          ],
        ),
      ],
    );
  }

  Widget _pageRutina() {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        SurveySection(
          title: "Rutina Diaria",
          children: [
            // WAKE UP TIME
            Text(
              "¿A qué hora te despiertas?",
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 8),
            AuriTimePicker(
              initialTime: _parseTime(controller.wakeUp.text),
              onChanged: (t) {
                controller.wakeUp.text =
                    "${t.hour}:${t.minute.toString().padLeft(2, '0')}";
              },
            ),
            const SizedBox(height: 20),

            // SLEEP TIME
            Text("¿A qué hora duermes?", style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 8),
            AuriTimePicker(
              initialTime: _parseTime(controller.sleep.text),
              onChanged: (t) {
                controller.sleep.text =
                    "${t.hour}:${t.minute.toString().padLeft(2, '0')}";
              },
            ),
            const SizedBox(height: 20),

            // CLASES
            SurveySwitch(
              text: "¿Tienes clases?",
              value: controller.hasClasses,
              onChanged: (v) => setState(() => controller.hasClasses = v),
            ),
            if (controller.hasClasses)
              SurveyMultiTextField(
                label: "Clases (una por línea)",
                controller: controller.classesInfo,
              ),

            // EXAMENES
            SurveySwitch(
              text: "¿Tienes exámenes?",
              value: controller.hasExams,
              onChanged: (v) => setState(() => controller.hasExams = v),
            ),
            if (controller.hasExams)
              SurveyMultiTextField(
                label: "Exámenes",
                controller: controller.examsInfo,
              ),
          ],
        ),
      ],
    );
  }

  Widget _pagePagos() {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        SurveySection(
          title: "Pagos Mensuales",
          children: [
            SurveySwitch(
              text: "¿Recordar pagos?",
              value: controller.wantsPaymentReminders,
              onChanged: (v) =>
                  setState(() => controller.wantsPaymentReminders = v),
            ),

            if (controller.wantsPaymentReminders) ...[
              SurveyTextField(
                label: "Pago del agua",
                controller: controller.waterPayment,
              ),
              SurveyTextField(
                label: "Pago de la luz",
                controller: controller.electricPayment,
              ),
              SurveyTextField(
                label: "Pago del internet",
                controller: controller.internetPayment,
              ),
              SurveyTextField(
                label: "Pago del teléfono",
                controller: controller.phonePayment,
              ),
              SurveyTextField(
                label: "Pago de la renta",
                controller: controller.rentPayment,
              ),
            ],
          ],
        ),
      ],
    );
  }

  Widget _pageCumples() {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        SurveySection(
          title: "Cumpleaños",
          children: [
            // NUEVO: cumpleaños del usuario
            SurveyTextField(
              label: "Tu cumpleaños",
              controller: controller.userBirthday,
              hint: "Ej. 27/10",
            ),

            const SizedBox(height: 12),

            SurveySwitch(
              text: "¿Tienes pareja?",
              value: controller.hasPartner,
              onChanged: (v) => setState(() => controller.hasPartner = v),
            ),

            if (controller.hasPartner)
              SurveyTextField(
                label: "Cumpleaños de tu pareja",
                controller: controller.partnerBirthday,
                hint: "Ej. 12/04",
              ),

            SurveyMultiTextField(
              label: "Familia (opcional)",
              controller: controller.familyBirthdays,
              hint: "Ej. Mamá - 15/08",
            ),

            SurveySwitch(
              text: "¿Recordar cumpleaños de amigos?",
              value: controller.wantsFriendBirthdays,
              onChanged: (v) =>
                  setState(() => controller.wantsFriendBirthdays = v),
            ),

            if (controller.wantsFriendBirthdays)
              SurveyMultiTextField(
                label: "Amigos importantes",
                controller: controller.friendBirthdays,
                hint: "Ej. Carlos - 02/11",
              ),
          ],
        ),
      ],
    );
  }

  Widget _pagePreferencias() {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        SurveySection(
          title: "Preferencias",
          children: [
            SurveyTextField(
              label: "¿Cuánta anticipación prefieres?",
              controller: controller.reminderAdvance,
              hint: "Ej. 1 día antes",
            ),

            SurveySwitch(
              text: "¿Agenda semanal automática?",
              value: controller.wantsWeeklyAgenda,
              onChanged: (v) =>
                  setState(() => controller.wantsWeeklyAgenda = v),
            ),
          ],
        ),
      ],
    );
  }
}
