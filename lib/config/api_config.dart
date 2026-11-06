class ApiConfig {
  ApiConfig._();

  /// true  = data lokal (demo), tanpa server.
  /// false = pakai API Laravel (lihat API.md untuk daftar endpoint).
  static const bool useMock = true;

  /// Emulator Android: 10.0.2.2 | HP fisik: IP laptop, mis. http://192.168.1.5:8000/api
  static const String baseUrl = 'http://10.0.2.2:8000/api';
  static const Duration timeout = Duration(seconds: 20);

  /// Senin pertama dari Putaran 1 (kelas ganjil). Sesuaikan dengan kalender sekolah.
  static final DateTime blokAnchor = DateTime(2026, 10, 26);

  /// Demo: jurnal boleh diisi kapan saja pada hari jadwal.
  /// Produksi: set false agar jurnal hanya bisa diisi saat jam pelajaran berlangsung.
  static const bool longgarJam = true;

  /// Pengingat jurnal muncul sekian menit sebelum jam pelajaran selesai.
  static const int menitPengingat = 30;
}
