// lib/auri/mind/nlp_tools.dart

import 'dart:convert';

/// Utilidades ligeras de NLP para español.
/// Sin paquetes externos, todo local.
class NLPTools {
  /// Normaliza texto:
  /// - trim
  /// - toLowerCase
  /// - sin acentos
  /// - colapsa espacios
  static String normalize(String input) {
    final noAccents = _removeDiacritics(input);
    return noAccents.toLowerCase().replaceAll(RegExp(r'\s+'), ' ').trim();
  }

  /// Tokenización muy simple por espacios.
  static List<String> tokenize(String input) {
    final norm = normalize(input);
    if (norm.isEmpty) return [];
    return norm.split(' ');
  }

  /// Intenta convertir un número en texto español a int.
  /// Soporta hasta 59 porque lo usamos sobre todo para minutos/horas.
  static int? parseSpanishNumber(String word) {
    final map = <String, int>{
      'cero': 0,
      'uno': 1,
      'una': 1,
      'un': 1,
      'dos': 2,
      'tres': 3,
      'cuatro': 4,
      'cinco': 5,
      'seis': 6,
      'siete': 7,
      'ocho': 8,
      'nueve': 9,
      'diez': 10,
      'once': 11,
      'doce': 12,
      'trece': 13,
      'catorce': 14,
      'quince': 15,
      'dieciseis': 16,
      'dieciséis': 16,
      'diecisiete': 17,
      'dieciocho': 18,
      'diecinueve': 19,
      'veinte': 20,
      'veintiuno': 21,
      'veintidos': 22,
      'veintidós': 22,
      'veintitres': 23,
      'veintitrés': 23,
      'treinta': 30,
      'cuarenta': 40,
      'cincuenta': 50,
    };

    final norm = normalize(word);
    if (map.containsKey(norm)) return map[norm];

    // Forma combinada: "treinta y cinco"
    if (norm.contains(' ')) {
      final parts = norm.split(' ');
      if (parts.length == 3 && parts[1] == 'y') {
        final tens = map[parts[0]] ?? 0;
        final unit = map[parts[2]] ?? 0;
        if (tens > 0) return tens + unit;
      }
    }

    // Intentar parseo numérico directo
    final direct = int.tryParse(norm);
    return direct;
  }

  /// Quita acentos y diacríticos (útil para regex sencillos).
  static String _removeDiacritics(String str) {
    const withDiacritics = 'áàäâãåÁÀÄÂÃÅéèëêÉÈËÊíìïîÍÌÏÎóòöôõÓÒÖÔÕúùüûÚÙÜÛçÇñÑ';
    const withoutDiacritics =
        'aaaaaaAAAAAAeeeeEEEEiiiiIIIIoooooOOOOOuuuuUUUUcCnN';

    final buffer = StringBuffer();
    for (int i = 0; i < str.length; i++) {
      final ch = str[i];
      final index = withDiacritics.indexOf(ch);
      if (index >= 0) {
        buffer.write(withoutDiacritics[index]);
      } else {
        buffer.write(ch);
      }
    }
    return buffer.toString();
  }

  /// Helper para debug rápido de entidades.
  static String prettyJson(Map<String, dynamic> map) {
    const encoder = JsonEncoder.withIndent('  ');
    return encoder.convert(map);
  }
}
