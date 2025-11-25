// lib/pages/reminders/reminders_page.dart
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

import 'package:auri_app/models/reminder_hive.dart';

class RemindersPage extends StatefulWidget {
  const RemindersPage({super.key});

  @override
  State<RemindersPage> createState() => _RemindersPageState();
}

class _RemindersPageState extends State<RemindersPage> {
  late final Box<ReminderHive> _box;
  final Uuid _uuid = const Uuid();

  List<ReminderHive> _reminders = [];

  @override
  void initState() {
    super.initState();
    _box = Hive.box<ReminderHive>('reminders');
    _loadReminders();
  }

  void _loadReminders() {
    _reminders = _box.values.cast<ReminderHive>().toList();

    _reminders.sort((a, b) {
      final da = DateTime.tryParse(a.dateIso) ?? DateTime.now();
      final db = DateTime.tryParse(b.dateIso) ?? DateTime.now();
      return da.compareTo(db);
    });

    setState(() {});
  }

  // ---------------------------------------------------
  // ADD REMINDER (manual)
  // ---------------------------------------------------
  void _showAddReminderModal() {
    final titleCtrl = TextEditingController();
    DateTime selected = DateTime.now().add(const Duration(minutes: 5));

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).cardColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            top: 20,
            left: 20,
            right: 20,
            bottom: MediaQuery.of(context).viewInsets.bottom + 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                "Nuevo Recordatorio",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: titleCtrl,
                decoration: const InputDecoration(
                  labelText: "Título",
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20),
              StatefulBuilder(
                builder: (_, setModal) {
                  return Row(
                    children: [
                      Expanded(
                        child: Text(
                          "${selected.day.toString().padLeft(2, '0')}/"
                          "${selected.month.toString().padLeft(2, '0')} "
                          "${selected.hour.toString().padLeft(2, '0')}:"
                          "${selected.minute.toString().padLeft(2, '0')}",
                          style: const TextStyle(fontSize: 16),
                        ),
                      ),
                      ElevatedButton(
                        onPressed: () async {
                          final d = await showDatePicker(
                            context: context,
                            initialDate: selected,
                            firstDate: DateTime.now(),
                            lastDate: DateTime.now().add(
                              const Duration(days: 365),
                            ),
                          );

                          if (d != null) {
                            final t = await showTimePicker(
                              context: context,
                              initialTime: TimeOfDay.fromDateTime(selected),
                            );

                            if (t != null) {
                              setModal(() {
                                selected = DateTime(
                                  d.year,
                                  d.month,
                                  d.day,
                                  t.hour,
                                  t.minute,
                                );
                              });
                            }
                          }
                        },
                        child: const Text("Fecha"),
                      ),
                    ],
                  );
                },
              ),
              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  child: const Text("Guardar"),
                  onPressed: () {
                    if (titleCtrl.text.trim().isEmpty) return;

                    final r = ReminderHive(
                      id: _uuid.v4(),
                      title: titleCtrl.text.trim(),
                      dateIso: selected.toIso8601String(),
                      repeats: "once",
                      tag: "MANUAL",
                      isAuto: false,
                      jsonPayload: "",
                    );

                    _box.put(r.id, r);
                    Navigator.pop(context);
                    _loadReminders();
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // ---------------------------------------------------
  // Delete reminder
  // ---------------------------------------------------
  void _delete(ReminderHive r) async {
    await _box.delete(r.id);
    _loadReminders();
  }

  // ---------------------------------------------------
  // UI
  // ---------------------------------------------------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Recordatorios")),
      body: _reminders.isEmpty
          ? const Center(
              child: Text(
                "No tienes recordatorios todavía ✨",
                textAlign: TextAlign.center,
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(15),
              itemCount: _reminders.length,
              itemBuilder: (_, i) {
                final r = _reminders[i];
                final dt = DateTime.tryParse(r.dateIso);

                final formatted = dt != null
                    ? "${dt.day.toString().padLeft(2, '0')}/"
                          "${dt.month.toString().padLeft(2, '0')} "
                          "${dt.hour.toString().padLeft(2, '0')}:"
                          "${dt.minute.toString().padLeft(2, '0')}"
                    : "Fecha inválida";

                final isSoon = r.title.toLowerCase().contains('pronto');

                return Dismissible(
                  key: Key(r.id),
                  background: Container(
                    color: Colors.red,
                    padding: const EdgeInsets.only(right: 20),
                    alignment: Alignment.centerRight,
                    child: const Icon(Icons.delete, color: Colors.white),
                  ),
                  direction: DismissDirection.endToStart,
                  onDismissed: (_) => _delete(r),
                  child: Card(
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    child: ListTile(
                      leading: Icon(
                        r.isAuto ? Icons.auto_awesome : Icons.circle,
                        color: r.isAuto
                            ? Colors.purpleAccent
                            : Colors.blueAccent,
                      ),
                      title: Text(
                        r.title,
                        style: TextStyle(
                          fontWeight: isSoon
                              ? FontWeight.bold
                              : FontWeight.w500,
                        ),
                      ),
                      subtitle: Text("Vence: $formatted"),
                      trailing: r.isAuto
                          ? const Padding(
                              padding: EdgeInsets.only(left: 8.0),
                              child: Icon(
                                Icons.bolt,
                                size: 18,
                                color: Colors.amber,
                              ),
                            )
                          : null,
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddReminderModal,
        child: const Icon(Icons.add),
      ),
    );
  }
}
