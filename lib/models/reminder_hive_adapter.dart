// lib/models/reminder_hive_adapter.dart
import 'package:hive/hive.dart';
import 'reminder_hive.dart';

class ReminderAdapter extends TypeAdapter<ReminderHive> {
  @override
  final int typeId = 1; // No lo cambies una vez en producción

  @override
  ReminderHive read(BinaryReader reader) {
    final id = reader.readString();
    final title = reader.readString();
    final dateIso = reader.readString();
    final repeats = reader.readString();
    final tag = reader.readString();
    final isAuto = reader.readBool();
    final jsonPayload = reader.readString();

    return ReminderHive(
      id: id,
      title: title,
      dateIso: dateIso,
      repeats: repeats,
      tag: tag,
      isAuto: isAuto,
      jsonPayload: jsonPayload,
    );
  }

  @override
  void write(BinaryWriter writer, ReminderHive obj) {
    writer.writeString(obj.id);
    writer.writeString(obj.title);
    writer.writeString(obj.dateIso);
    writer.writeString(obj.repeats);
    writer.writeString(obj.tag);
    writer.writeBool(obj.isAuto);
    writer.writeString(obj.jsonPayload);
  }
}
