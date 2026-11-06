import 'package:intl/intl.dart';

class Fmt {
  Fmt._();

  static const List<String> namaHari = ['', 'Senin', 'Selasa', 'Rabu', 'Kamis', 'Jumat', 'Sabtu', 'Minggu'];

  static DateTime tanggalSaja(DateTime d) => DateTime(d.year, d.month, d.day);
  static DateTime hariIni() => tanggalSaja(DateTime.now());
  static bool sama(DateTime a, DateTime b) => a.year == b.year && a.month == b.month && a.day == b.day;

  /// 'HH:mm' -> menit sejak 00:00
  static int menit(String hhmm) {
    final p = hhmm.split(':');
    if (p.length < 2) return 0;
    return (int.tryParse(p[0]) ?? 0) * 60 + (int.tryParse(p[1]) ?? 0);
  }

  static int menitSekarang() {
    final n = DateTime.now();
    return n.hour * 60 + n.minute;
  }

  static String dua(int n) => n.toString().padLeft(2, '0');

  static String tgl(DateTime d) => DateFormat('d MMM yyyy', 'id_ID').format(d);
  static String tglPanjang(DateTime d) => DateFormat('EEEE, d MMMM yyyy', 'id_ID').format(d);
  static String jamMenit(DateTime d) => '${dua(d.hour)}:${dua(d.minute)}';
  static String tglJam(DateTime d) => '${tgl(d)}, ${jamMenit(d)}';
  static String iso(DateTime d) => '${d.year}-${dua(d.month)}-${dua(d.day)}';

  static String inisial(String nama) {
    final p = nama.trim().split(RegExp(r'\s+')).where((e) => e.isNotEmpty).toList();
    if (p.isEmpty) return '?';
    if (p.length == 1) return p[0][0].toUpperCase();
    return (p[0][0] + p[1][0]).toUpperCase();
  }
}
