class Jx {
  Jx._();

  static String str(dynamic v, [String def = '']) => v == null ? def : v.toString();

  static String? strOrNull(dynamic v) {
    if (v == null) return null;
    final s = v.toString();
    return s.isEmpty ? null : s;
  }

  static int integer(dynamic v, [int def = 0]) {
    if (v is int) return v;
    if (v is num) return v.toInt();
    return int.tryParse(v?.toString() ?? '') ?? def;
  }

  static int? integerOrNull(dynamic v) {
    if (v == null || v.toString().isEmpty) return null;
    return integer(v);
  }

  static bool boolean(dynamic v) {
    if (v is bool) return v;
    final s = v?.toString().toLowerCase();
    return s == '1' || s == 'true';
  }

  static DateTime date(dynamic v) => DateTime.tryParse(v?.toString() ?? '') ?? DateTime.now();

  static DateTime? dateOrNull(dynamic v) => v == null ? null : DateTime.tryParse(v.toString());

  /// '07:00:00' -> '07:00'
  static String jam(dynamic v) {
    final s = str(v);
    return s.length >= 5 ? s.substring(0, 5) : s;
  }
}
