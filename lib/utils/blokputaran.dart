import '../config/api_config.dart';

/// Sistem blok: kelas ganjil = Putaran 1, kelas genap = Putaran 2.
/// Putaran bergantian setiap 2 minggu.
class BlokPutaran {
  BlokPutaran._();

  static int _minggu(DateTime tgl) {
    final a = DateTime(ApiConfig.blokAnchor.year, ApiConfig.blokAnchor.month, ApiConfig.blokAnchor.day);
    final d = DateTime(tgl.year, tgl.month, tgl.day);
    return (d.difference(a).inDays / 7).floor();
  }

  static int putaranAktif(DateTime tgl) {
    final siklus = (_minggu(tgl) / 2).floor();
    return siklus % 2 == 0 ? 1 : 2;
  }

  /// Minggu ke-1 atau ke-2 dalam putaran yang sedang berjalan.
  static int mingguKe(DateTime tgl) => (_minggu(tgl) % 2) + 1;

  static int putaranKelas(String kelas) {
    final m = RegExp(r'(\d+)\s*$').firstMatch(kelas.trim());
    if (m == null) return 1;
    return int.parse(m.group(1)!).isOdd ? 1 : 2;
  }

  static bool kelasAktif(String kelas, DateTime tgl) => putaranKelas(kelas) == putaranAktif(tgl);

  static String info(DateTime tgl) => 'Putaran ${putaranAktif(tgl)} aktif · minggu ke-${mingguKe(tgl)} dari 2';
}
