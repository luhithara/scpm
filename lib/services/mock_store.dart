import 'dart:math';
import '../config/api_config.dart';
import '../models/gurumodel.dart';
import '../models/izinmodel.dart';
import '../models/jadwalmodel.dart';
import '../models/jurnalmodel.dart';
import '../models/logmodel.dart';
import '../models/notifmodel.dart';
import '../models/presensimodel.dart';
import '../models/siswamodel.dart';
import '../models/statmodel.dart';
import '../models/usermodel.dart';
import '../utils/blokputaran.dart';
import '../utils/format.dart';
import 'api_services.dart' show AppException;

class DemoAkun {
  final String label;
  final String username;
  final String password;
  const DemoAkun(this.label, this.username, this.password);
}

class _Akun {
  final UserModel user;
  String password;
  _Akun(this.user, this.password);
}

/// Data demo di memori. Dipakai saat ApiConfig.useMock = true.
class MockStore {
  MockStore._() {
    _seed();
  }
  static final MockStore instance = MockStore._();

  final List<String> daftarKelas = ['XI RPL 1', 'XI RPL 2', 'XI TKJ 1', 'XI TKJ 2'];
  final List<SiswaModel> siswa = [];
  final List<GuruModel> guru = [];
  final List<JadwalModel> jadwal = [];
  final List<PresensiModel> presensi = [];
  final List<IzinModel> izin = [];
  final List<JurnalModel> jurnal = [];
  final List<NotifModel> notif = [];
  final List<LogModel> log = [];
  final List<DemoAkun> demoAkun = [];
  final Map<String, _Akun> _akun = {};
  final Set<String> _diingatkan = {};
  bool jadwalTerkunci = false;
  int _seq = 1000;

  String nextId(String p) => '$p${_seq++}';

  void _tambahAkun(UserModel u, String pass) => _akun[u.username.toLowerCase()] = _Akun(u, pass);

  // ---------------------------------------------------------------- seed
  void _seed() {
    const guruData = [
      ['Budi Santoso', 'Pemrograman Web'],
      ['Siti Rahmawati', 'Basis Data'],
      ['Agus Prasetyo', 'Pemrograman Dasar'],
      ['Dewi Lestari', 'Bahasa Indonesia'],
      ['Rudi Hartono', 'Matematika'],
      ['Nina Marlina', 'Jaringan Dasar'],
      ['Eko Prabowo', 'Administrasi Sistem Jaringan'],
    ];
    for (var i = 0; i < guruData.length; i++) {
      final g = GuruModel(id: 'g${i + 1}', nama: guruData[i][0], username: 'guru${i + 1}', mapel: guruData[i][1]);
      guru.add(g);
      _tambahAkun(UserModel(id: g.id, nama: g.nama, username: g.username, role: UserRole.guru, mapel: g.mapel), '123456');
    }

    const namaSiswa = [
      'Ahmad Fauzi', 'Aisyah Putri', 'Bagas Pratama', 'Citra Dewi', 'Dimas Saputra', 'Eka Wulandari',
      'Farhan Maulana', 'Gita Permata', 'Hafidz Ramadhan', 'Indah Sari', 'Joko Susilo', 'Kirana Anjani',
      'Lutfi Hakim', 'Maya Safitri', 'Naufal Rizky', 'Olivia Putri', 'Putra Mahendra', 'Qonita Azzahra',
      'Rizal Firmansyah', 'Salsabila Nur', 'Tegar Wibowo', 'Umi Kalsum', 'Vino Aditya', 'Wulan Ayu',
    ];
    for (var i = 0; i < namaSiswa.length; i++) {
      final k = daftarKelas[i ~/ 6];
      final jur = k.contains('RPL') ? 'Rekayasa Perangkat Lunak' : 'Teknik Komputer dan Jaringan';
      final s = SiswaModel(id: 's${i + 1}', nisn: '0051000${101 + i}', nama: namaSiswa[i], kelas: k, jurusan: jur);
      siswa.add(s);
      _tambahAkun(UserModel(id: s.id, nama: s.nama, username: s.nisn, role: UserRole.siswa, kelas: k), '123456');
      _tambahAkun(
          UserModel(id: s.id, nama: 'Orang tua ${s.nama}', username: 'ortu${s.nisn}', role: UserRole.ortu, kelas: k),
          '123456');
    }

    _tambahAkun(const UserModel(id: 'w1', nama: 'Hendra Wijaya, M.Pd.', username: 'waka', role: UserRole.waka), '123456');
    _tambahAkun(const UserModel(id: 'b1', nama: 'Ratna Kusuma, S.Psi.', username: 'bk', role: UserRole.bk), '123456');
    for (var i = 0; i < daftarKelas.length; i++) {
      _tambahAkun(
          UserModel(id: 'wk${i + 1}', nama: 'Wali ${daftarKelas[i]}', username: 'wali${i + 1}', role: UserRole.walikelas, kelas: daftarKelas[i]),
          '123456');
    }

    demoAkun.addAll([
      const DemoAkun('Waka Kurikulum', 'waka', '123456'),
      const DemoAkun('Guru (Pemrograman Web)', 'guru1', '123456'),
      DemoAkun('Siswa (${siswa[0].kelas}, kelas aktif)', siswa[0].nisn, '123456'),
      DemoAkun('Siswa (${siswa[6].kelas}, di luar blok)', siswa[6].nisn, '123456'),
      DemoAkun('Orang Tua (${siswa[0].nama})', 'ortu${siswa[0].nisn}', '123456'),
      const DemoAkun('BK', 'bk', '123456'),
      const DemoAkun('Wali Kelas XI RPL 1', 'wali1', '123456'),
    ]);

    // Jadwal
    const slot = {
      'S1': ['07:00', '08:30'],
      'S2': ['08:30', '10:00'],
      'S3': ['10:15', '11:45'],
      'S4': ['12:30', '14:00'],
    };
    const tplRpl = {
      1: ['S1-g1', 'S2-g2', 'S3-g5'],
      2: ['S1-g3', 'S2-g1', 'S3-g4'],
      3: ['S1-g2', 'S2-g3', 'S3-g1'],
      4: ['S1-g5', 'S2-g4', 'S3-g3'],
      5: ['S1-g1', 'S2-g2'],
    };
    const tplTkj = {
      1: ['S1-g6', 'S2-g7', 'S4-g4'],
      2: ['S1-g7', 'S2-g6', 'S4-g5'],
      3: ['S1-g6', 'S2-g7'],
      4: ['S1-g7', 'S2-g6', 'S4-g4'],
      5: ['S1-g6', 'S2-g7'],
    };
    for (var ki = 0; ki < daftarKelas.length; ki++) {
      final k = daftarKelas[ki];
      final tpl = k.contains('RPL') ? tplRpl : tplTkj;
      final lab = 'Lab ${k.substring(3)}';
      tpl.forEach((hari, items) {
        for (final it in items) {
          final p = it.split('-');
          final g = guru.firstWhere((x) => x.id == p[1]);
          final umum = g.mapel == 'Matematika' || g.mapel == 'Bahasa Indonesia';
          String? ruang = umum ? 'R. ${10 + ki}' : lab;
          if (ki == 0 && hari == 5 && p[0] == 'S2') ruang = null; // contoh: belum diatur Waka
          jadwal.add(JadwalModel(
            id: nextId('j'),
            kelas: k,
            hari: hari,
            jamMulai: slot[p[0]]![0],
            jamSelesai: slot[p[0]]![1],
            mapel: g.mapel,
            guruId: g.id,
            guruNama: g.nama,
            ruangan: ruang,
          ));
        }
      });
    }

    // Riwayat presensi & jurnal 14 hari terakhir
    final rnd = Random(7);
    const materi = [
      'Pengenalan konsep dasar',
      'Praktik di laboratorium',
      'Latihan soal dan diskusi',
      'Evaluasi harian',
      'Proyek kelompok',
      'Review materi sebelumnya',
    ];
    final today = Fmt.hariIni();
    for (var off = 14; off >= 1; off--) {
      final d = today.subtract(Duration(days: off));
      if (d.weekday > 5) continue;
      for (final j in jadwal.where((x) => x.hari == d.weekday && BlokPutaran.kelasAktif(x.kelas, d))) {
        for (final s in siswa.where((x) => x.kelas == j.kelas)) {
          final r = rnd.nextInt(100);
          final st = r < 88
              ? StatusHadir.hadir
              : r < 92
                  ? StatusHadir.sakit
                  : r < 96
                      ? StatusHadir.izin
                      : StatusHadir.alpa;
          presensi.add(PresensiModel(
            id: nextId('p'),
            jadwalId: j.id,
            tanggal: d,
            kelas: j.kelas,
            mapel: j.mapel,
            siswaId: s.id,
            siswaNama: s.nama,
            status: st,
            keterangan: st == StatusHadir.izin ? 'Izin disetujui (surat)' : '',
          ));
        }
        if (rnd.nextInt(100) < 85) {
          jurnal.add(JurnalModel(
            id: nextId('r'),
            jadwalId: j.id,
            tanggal: d,
            kelas: j.kelas,
            mapel: j.mapel,
            guruId: j.guruId,
            guruNama: j.guruNama,
            materi: materi[rnd.nextInt(materi.length)],
            waktuSimpan: DateTime(d.year, d.month, d.day, int.parse(j.jamMulai.substring(0, 2)), 30),
          ));
        }
      }
    }

    // Izin
    IzinModel iz(String sid, int offHari, String jenis, String alasan, String oleh, StatusIzin st,
        {String? proses, String? catatan}) {
      final s = siswa.firstWhere((x) => x.id == sid);
      return IzinModel(
        id: nextId('iz'),
        siswaId: s.id,
        siswaNama: s.nama,
        kelas: s.kelas,
        tanggal: today.add(Duration(days: offHari)),
        jenis: jenis,
        alasan: alasan,
        buktiNama: 'surat.jpg',
        diajukanOleh: oleh,
        waktuAjuan: DateTime.now().subtract(const Duration(hours: 5)),
        status: st,
        diprosesOleh: proses,
        waktuProses: proses == null ? null : DateTime.now().subtract(const Duration(hours: 2)),
        catatan: catatan,
      );
    }

    izin.addAll([
      iz('s1', 0, 'Izin', 'Mengikuti lomba LKS tingkat kota', 'Siswa', StatusIzin.menunggu),
      iz('s2', -3, 'Izin', 'Acara keluarga', 'Orang Tua', StatusIzin.disetujui, proses: 'BK - Ratna Kusuma, S.Psi.'),
      iz('s3', 0, 'Sakit', 'Demam, istirahat di rumah', 'Orang Tua', StatusIzin.menunggu),
      iz('s7', -2, 'Sakit', 'Sakit perut', 'Siswa', StatusIzin.ditolak,
          proses: 'Wali Kelas - Wali XI RPL 2', catatan: 'Surat dokter belum dilampirkan'),
      iz('s13', 1, 'Izin', 'Mengurus dokumen keluarga', 'Siswa', StatusIzin.menunggu),
    ]);

    final now = DateTime.now();
    notif.addAll([
      NotifModel(
          id: nextId('n'),
          judul: 'Pengajuan izin baru',
          isi: 'Ahmad Fauzi (XI RPL 1) mengajukan Izin untuk hari ini',
          waktu: now.subtract(const Duration(hours: 5)),
          untukRole: UserRole.bk.name),
      NotifModel(
          id: nextId('n'),
          judul: 'Jadwal terbuka',
          isi: 'Silakan input jadwal mengajar sesuai SK penugasan',
          waktu: now.subtract(const Duration(days: 1)),
          untukRole: UserRole.guru.name),
    ]);

    log.addAll([
      LogModel(
          id: nextId('l'),
          modul: 'Izin',
          aksi: 'Menyetujui izin',
          oleh: 'Ratna Kusuma, S.Psi.',
          waktu: now.subtract(const Duration(hours: 2)),
          sesudah: 'Aisyah Putri · Izin · Disetujui'),
      LogModel(
          id: nextId('l'),
          modul: 'Jadwal',
          aksi: 'Mengatur ruangan',
          oleh: 'Hendra Wijaya, M.Pd.',
          waktu: now.subtract(const Duration(days: 1)),
          sebelum: 'XI RPL 2 · Senin 07:00 - 08:30 · -',
          sesudah: 'XI RPL 2 · Senin 07:00 - 08:30 · Lab RPL 2'),
    ]);
  }

  // ---------------------------------------------------------------- log & notif
  void tulisLog(String modul, String aksi, String oleh, {String sebelum = '', String sesudah = ''}) {
    log.add(LogModel(
        id: nextId('l'), modul: modul, aksi: aksi, oleh: oleh, waktu: DateTime.now(), sebelum: sebelum, sesudah: sesudah));
  }

  void _kirim(String judul, String isi, {String? user, UserRole? role, String? kelas}) {
    notif.add(NotifModel(
        id: nextId('n'),
        judul: judul,
        isi: isi,
        waktu: DateTime.now(),
        untukUser: user,
        untukRole: role?.name,
        untukKelas: kelas));
  }

  bool _untuk(NotifModel n, UserModel u) {
    if (n.untukUser != null) return n.untukUser == u.id;
    if (n.untukRole != null) {
      if (n.untukRole != u.role.name) return false;
      return n.untukKelas == null || n.untukKelas == u.kelas;
    }
    return false;
  }

  List<NotifModel> notifUser(UserModel u) {
    final r = notif.where((n) => _untuk(n, u)).toList();
    r.sort((a, b) => b.waktu.compareTo(a.waktu));
    return r;
  }

  void tandaiBaca(String id) {
    final i = notif.indexWhere((n) => n.id == id);
    if (i >= 0) notif[i] = notif[i].sudahDibaca();
  }

  void tandaiSemua(UserModel u) {
    for (var i = 0; i < notif.length; i++) {
      if (_untuk(notif[i], u)) notif[i] = notif[i].sudahDibaca();
    }
  }

  void kirimPeringatan(String guruId, String pesan, UserModel oleh) {
    _kirim('Peringatan dari Waka Kurikulum', pesan, user: guruId);
    tulisLog('Presensi', 'Mengirim peringatan ke guru', oleh.nama, sesudah: pesan);
  }

  List<LogModel> getLog({String? modul, String? q, String? oleh}) {
    final kata = (q ?? '').trim().toLowerCase();
    final r = log
        .where((l) =>
            (modul == null || l.modul == modul) &&
            (oleh == null || l.oleh == oleh) &&
            (kata.isEmpty || '${l.aksi} ${l.oleh} ${l.sebelum} ${l.sesudah}'.toLowerCase().contains(kata)))
        .toList();
    r.sort((a, b) => b.waktu.compareTo(a.waktu));
    return r;
  }

  // ---------------------------------------------------------------- akun
  UserModel login(String username, String password) {
    final a = _akun[username.trim().toLowerCase()];
    if (a == null || a.password != password) throw const AppException('Username/NISN atau password salah');
    return a.user.withToken('mock-${a.user.username}');
  }

  UserModel register(String identitas, String nama, String password, String jenisAkun) {
    final s = siswa.firstWhere(
      (item) => item.nisn == identitas.trim(),
      orElse: () => throw const AppException('NISN tidak ditemukan'),
    );
    final username = jenisAkun == 'orangtua' ? 'ortu${s.nisn}' : s.nisn;
    if (_akun.containsKey(username.toLowerCase())) {
      throw const AppException('Akun untuk jenis ini sudah terdaftar');
    }
    final user = UserModel(
      id: s.id,
      nama: nama.trim(),
      username: username,
      role: jenisAkun == 'orangtua' ? UserRole.ortu : UserRole.siswa,
      kelas: s.kelas,
    );
    _tambahAkun(user, password);
    return user.withToken('mock-$username');
  }

  void gantiPassword(String username, String lama, String baru) {
    final a = _akun[username.toLowerCase()];
    if (a == null || a.password != lama) throw const AppException('Password lama salah');
    a.password = baru;
    tulisLog('Akun', 'Mengganti password', a.user.nama);
  }

  String lupaPassword(String username) {
    final a = _akun[username.trim().toLowerCase()];
    if (a == null) throw const AppException('Akun tidak ditemukan');
    return 'Permintaan reset password dikirim. Hubungi admin sekolah untuk password sementara (mode demo).';
  }

  // ---------------------------------------------------------------- jadwal
  String ringkas(JadwalModel j) => '${j.kelas} · ${j.namaHari} ${j.jam} · ${j.mapel} · ${j.ruangan ?? '-'}';

  List<JadwalModel> getJadwal({String? kelas, String? guruId, int? hari}) {
    final r = jadwal
        .where((j) =>
            (kelas == null || j.kelas == kelas) &&
            (guruId == null || j.guruId == guruId) &&
            (hari == null || j.hari == hari))
        .toList();
    r.sort((a, b) {
      final c = a.hari.compareTo(b.hari);
      return c != 0 ? c : Fmt.menit(a.jamMulai).compareTo(Fmt.menit(b.jamMulai));
    });
    return r;
  }

  /// Bentrok hanya dihitung untuk kelas yang satu putaran (kelas beda putaran tidak pernah masuk bersamaan).
  String? cekBentrok(JadwalModel j, {String? kecualiId}) {
    if (Fmt.menit(j.jamMulai) >= Fmt.menit(j.jamSelesai)) return 'Jam selesai harus setelah jam mulai';
    final p = BlokPutaran.putaranKelas(j.kelas);
    for (final o in jadwal) {
      if (o.id == kecualiId || o.id == j.id) continue;
      if (!j.bentrokWaktu(o)) continue;
      if (o.kelas == j.kelas) return 'Bentrok: ${j.kelas} sudah punya jadwal ${o.mapel} (${o.jam})';
      if (BlokPutaran.putaranKelas(o.kelas) != p) continue;
      if (o.guruId == j.guruId) return 'Bentrok: ${j.guruNama} sudah mengajar ${o.kelas} pada jam tersebut';
      if (j.ruangan != null && j.ruangan == o.ruangan) {
        return 'Bentrok: ruangan ${j.ruangan} dipakai ${o.kelas} (${o.mapel})';
      }
    }
    return null;
  }

  void _cekKunci() {
    if (jadwalTerkunci) throw const AppException('Jadwal sedang dikunci oleh Waka Kurikulum');
  }

  JadwalModel tambahJadwal(JadwalModel j, UserModel oleh) {
    _cekKunci();
    final msg = cekBentrok(j);
    if (msg != null) throw AppException(msg);
    final baru = j.copyWith(id: nextId('j'));
    jadwal.add(baru);
    tulisLog('Jadwal', 'Menambah jadwal', oleh.nama, sesudah: ringkas(baru));
    return baru;
  }

  JadwalModel ubahJadwal(JadwalModel j, UserModel oleh) {
    _cekKunci();
    final i = jadwal.indexWhere((x) => x.id == j.id);
    if (i < 0) throw const AppException('Jadwal tidak ditemukan');
    final msg = cekBentrok(j, kecualiId: j.id);
    if (msg != null) throw AppException(msg);
    final lama = jadwal[i];
    final baru = j.copyWith(ruangan: lama.ruangan);
    jadwal[i] = baru;
    tulisLog('Jadwal', 'Mengubah jadwal', oleh.nama, sebelum: ringkas(lama), sesudah: ringkas(baru));
    return baru;
  }

  void hapusJadwal(String id, UserModel oleh) {
    _cekKunci();
    final i = jadwal.indexWhere((x) => x.id == id);
    if (i < 0) return;
    final lama = jadwal.removeAt(i);
    tulisLog('Jadwal', 'Menghapus jadwal', oleh.nama, sebelum: ringkas(lama));
  }

  JadwalModel setRuangan(String id, String ruangan, UserModel oleh) {
    final i = jadwal.indexWhere((x) => x.id == id);
    if (i < 0) throw const AppException('Jadwal tidak ditemukan');
    final lama = jadwal[i];
    final baru = lama.copyWith(ruangan: ruangan.trim());
    final msg = cekBentrok(baru, kecualiId: id);
    if (msg != null) throw AppException(msg);
    jadwal[i] = baru;
    _kirim('Ruangan ditentukan', '${baru.kelas} · ${baru.mapel} (${baru.namaHari} ${baru.jam}) di ${baru.ruangan}',
        user: baru.guruId);
    tulisLog('Jadwal', 'Mengatur ruangan', oleh.nama, sebelum: ringkas(lama), sesudah: ringkas(baru));
    return baru;
  }

  void setKunci(bool v, UserModel oleh) {
    jadwalTerkunci = v;
    _kirim(v ? 'Jadwal dikunci' : 'Jadwal dibuka',
        v ? 'Waka Kurikulum mengunci jadwal. Perubahan tidak dapat dilakukan.' : 'Jadwal dibuka, Anda dapat mengubah jadwal.',
        role: UserRole.guru);
    tulisLog('Jadwal', v ? 'Mengunci jadwal' : 'Membuka kunci jadwal', oleh.nama);
  }

  void unggahSk(String guruId, String namaFile, UserModel oleh) {
    final i = guru.indexWhere((g) => g.id == guruId);
    if (i < 0) throw const AppException('Guru tidak ditemukan');
    guru[i] = guru[i].withSk(namaFile);
    _kirim('SK penugasan diunggah', 'SK penugasan Anda ($namaFile) sudah tersedia. Silakan input jadwal mengajar.',
        user: guruId);
    tulisLog('Jadwal', 'Mengunggah SK penugasan', oleh.nama, sesudah: '${guru[i].nama} · $namaFile');
  }

  // ---------------------------------------------------------------- presensi
  List<SiswaModel> siswaKelas(String kelas) => siswa.where((s) => s.kelas == kelas).toList();

  List<PresensiModel> presensiSesi(String jadwalId, DateTime tgl) =>
      presensi.where((p) => p.jadwalId == jadwalId && Fmt.sama(p.tanggal, tgl)).toList();

  String _hitung(List<PresensiModel> l) {
    int c(StatusHadir s) => l.where((p) => p.status == s).length;
    return 'H:${c(StatusHadir.hadir)} I:${c(StatusHadir.izin)} S:${c(StatusHadir.sakit)} A:${c(StatusHadir.alpa)}';
  }

  void simpanPresensi(JadwalModel j, DateTime tgl, List<PresensiModel> data, UserModel oleh) {
    final d = Fmt.tanggalSaja(tgl);
    final lama = presensiSesi(j.id, d);
    presensi.removeWhere((p) => p.jadwalId == j.id && Fmt.sama(p.tanggal, d));
    for (final p in data) {
      presensi.add(p.copyWith(id: nextId('p'), jadwalId: j.id, tanggal: d, kelas: j.kelas, mapel: j.mapel));
    }
    tulisLog('Presensi', lama.isEmpty ? 'Mengisi presensi' : 'Mengubah presensi', oleh.nama,
        sebelum: lama.isEmpty ? '' : _hitung(lama), sesudah: '${j.kelas} · ${j.mapel} · ${_hitung(data)}');
  }

  List<PresensiModel> filterPresensi(
      {DateTime? dari, DateTime? sampai, String? kelas, String? mapel, String? siswaId, String? guruId}) {
    final guruJadwal = guruId == null ? null : jadwal.where((j) => j.guruId == guruId).map((j) => j.id).toSet();
    return presensi
        .where((p) =>
            (dari == null || !p.tanggal.isBefore(dari)) &&
            (sampai == null || !p.tanggal.isAfter(sampai)) &&
            (kelas == null || p.kelas == kelas) &&
            (mapel == null || p.mapel == mapel) &&
            (siswaId == null || p.siswaId == siswaId) &&
            (guruJadwal == null || guruJadwal.contains(p.jadwalId)))
        .toList();
  }

  // ---------------------------------------------------------------- izin
  List<IzinModel> getIzin({String? siswaId, String? kelas, StatusIzin? status, DateTime? tanggal, DateTime? dari, DateTime? sampai}) {
    final r = izin
        .where((i) =>
            (siswaId == null || i.siswaId == siswaId) &&
            (kelas == null || i.kelas == kelas) &&
            (status == null || i.status == status) &&
            (tanggal == null || Fmt.sama(i.tanggal, tanggal)) &&
            (dari == null || !i.tanggal.isBefore(dari)) &&
            (sampai == null || !i.tanggal.isAfter(sampai)))
        .toList();
    r.sort((a, b) => b.waktuAjuan.compareTo(a.waktuAjuan));
    return r;
  }

  IzinModel ajukanIzin({
    required UserModel oleh,
    required DateTime tanggal,
    required String jenis,
    required String alasan,
    String? buktiNama,
    String? buktiPath,
  }) {
    final s = siswa.firstWhere((x) => x.id == oleh.id, orElse: () => throw const AppException('Data siswa tidak ditemukan'));
    if (alasan.trim().isEmpty) throw const AppException('Alasan wajib diisi');
    if (buktiPath == null) throw const AppException('Bukti surat izin wajib dilampirkan');
    final d = Fmt.tanggalSaja(tanggal);
    final dup = izin.any((i) => i.siswaId == s.id && Fmt.sama(i.tanggal, d) && i.status != StatusIzin.ditolak);
    if (dup) throw const AppException('Pengajuan izin untuk tanggal tersebut sudah ada');
    final baru = IzinModel(
      id: nextId('iz'),
      siswaId: s.id,
      siswaNama: s.nama,
      kelas: s.kelas,
      tanggal: d,
      jenis: jenis,
      alasan: alasan.trim(),
      buktiNama: buktiNama,
      buktiPath: buktiPath,
      diajukanOleh: oleh.role.label,
      waktuAjuan: DateTime.now(),
    );
    izin.add(baru);
    final isi = '${s.nama} (${s.kelas}) mengajukan $jenis untuk ${Fmt.tgl(d)}';
    _kirim('Pengajuan izin baru', isi, role: UserRole.bk);
    _kirim('Pengajuan izin baru', isi, role: UserRole.walikelas, kelas: s.kelas);
    for (final gid in jadwal.where((j) => j.kelas == s.kelas && j.hari == d.weekday).map((j) => j.guruId).toSet()) {
      _kirim('Info izin siswa', isi, user: gid);
    }
    tulisLog('Izin', 'Mengajukan izin', oleh.nama, sesudah: '${s.nama} · $jenis · ${Fmt.tgl(d)}');
    return baru;
  }

  /// Siapa pun (BK atau wali kelas) yang memproses lebih dulu, hasilnya berlaku.
  IzinModel prosesIzin(String id, bool setuju, UserModel oleh, {String? catatan}) {
    final idx = izin.indexWhere((i) => i.id == id);
    if (idx < 0) throw const AppException('Data izin tidak ditemukan');
    final i = izin[idx];
    final boleh = oleh.role == UserRole.bk || (oleh.role == UserRole.walikelas && oleh.kelas == i.kelas);
    if (!boleh) throw const AppException('Anda tidak berwenang memproses izin ini');
    if (i.status != StatusIzin.menunggu) {
      throw AppException('Izin sudah ${i.status.label.toLowerCase()} oleh ${i.diprosesOleh ?? '-'}');
    }
    final st = setuju ? StatusIzin.disetujui : StatusIzin.ditolak;
    final baru = i.copyWith(
      status: st,
      diprosesOleh: '${oleh.role.label} - ${oleh.nama}',
      waktuProses: DateTime.now(),
      catatan: (catatan ?? '').trim().isEmpty ? null : catatan!.trim(),
    );
    izin[idx] = baru;
    _kirim('Izin ${st.label.toLowerCase()}', 'Izin ${i.jenis} tanggal ${Fmt.tgl(i.tanggal)} ${st.label.toLowerCase()} oleh ${oleh.nama}',
        user: i.siswaId);
    tulisLog('Izin', setuju ? 'Menyetujui izin' : 'Menolak izin', oleh.nama,
        sebelum: 'Menunggu', sesudah: '${i.siswaNama} · ${i.jenis} · ${st.label}');
    return baru;
  }

  Set<String> siswaIzinDisetujui(String kelas, DateTime tgl) => izin
      .where((i) => i.kelas == kelas && i.status == StatusIzin.disetujui && Fmt.sama(i.tanggal, tgl))
      .map((i) => i.siswaId)
      .toSet();

  List<IzinModel> infoGuru(String guruId, DateTime tgl) {
    final kelasDiajar = jadwal
        .where((j) => j.guruId == guruId && j.hari == tgl.weekday && BlokPutaran.kelasAktif(j.kelas, tgl))
        .map((j) => j.kelas)
        .toSet();
    return getIzin(tanggal: tgl).where((i) => kelasDiajar.contains(i.kelas)).toList();
  }

  // ---------------------------------------------------------------- jurnal
  JurnalModel? jurnalSesi(String jadwalId, DateTime tgl) {
    for (final j in jurnal) {
      if (j.jadwalId == jadwalId && Fmt.sama(j.tanggal, tgl)) return j;
    }
    return null;
  }

  JurnalModel simpanJurnal({
    required JadwalModel jd,
    required DateTime tgl,
    required String materi,
    required String catatan,
    required String fotoPath,
    required UserModel oleh,
  }) {
    if (jurnalSesi(jd.id, tgl) != null) throw const AppException('Jurnal sudah disimpan dan tidak dapat diubah');
    if (materi.trim().isEmpty) throw const AppException('Materi wajib diisi');
    if (fotoPath.isEmpty) throw const AppException('Foto kegiatan (ambil langsung dari kamera) wajib dilampirkan');
    if (!ApiConfig.longgarJam) {
      final m = Fmt.menitSekarang();
      if (!Fmt.sama(DateTime.now(), tgl) || m < Fmt.menit(jd.jamMulai) || m > Fmt.menit(jd.jamSelesai)) {
        throw const AppException('Jurnal hanya dapat diisi saat pembelajaran berlangsung');
      }
    }
    final baru = JurnalModel(
      id: nextId('r'),
      jadwalId: jd.id,
      tanggal: Fmt.tanggalSaja(tgl),
      kelas: jd.kelas,
      mapel: jd.mapel,
      guruId: jd.guruId,
      guruNama: jd.guruNama,
      materi: materi.trim(),
      catatan: catatan.trim(),
      fotoPath: fotoPath,
      waktuSimpan: DateTime.now(),
    );
    jurnal.add(baru);
    tulisLog('Jurnal', 'Mengisi jurnal mengajar', oleh.nama, sesudah: '${jd.kelas} · ${jd.mapel} · ${baru.materi}');
    return baru;
  }

  List<JurnalModel> getJurnal({String? guruId, String? kelas, DateTime? dari, DateTime? sampai}) {
    final r = jurnal
        .where((j) =>
            (guruId == null || j.guruId == guruId) &&
            (kelas == null || j.kelas == kelas) &&
            (dari == null || !j.tanggal.isBefore(dari)) &&
            (sampai == null || !j.tanggal.isAfter(sampai)))
        .toList();
    r.sort((a, b) => b.waktuSimpan.compareTo(a.waktuSimpan));
    return r;
  }

  /// Sesi hari ini yang sudah masuk jendela pengingat (selesai - 30 menit) tapi jurnal belum diisi.
  List<JadwalModel> jurnalBelumDiisi(UserModel guruUser) {
    final tgl = Fmt.hariIni();
    final m = Fmt.menitSekarang();
    final r = jadwal
        .where((j) =>
            j.guruId == guruUser.id &&
            j.hari == tgl.weekday &&
            BlokPutaran.kelasAktif(j.kelas, tgl) &&
            m >= Fmt.menit(j.jamSelesai) - ApiConfig.menitPengingat &&
            jurnalSesi(j.id, tgl) == null)
        .toList();
    for (final j in r) {
      final key = '${j.id}-${Fmt.iso(tgl)}';
      if (_diingatkan.add(key)) {
        _kirim('Jurnal belum diisi', 'Isi jurnal ${j.kelas} · ${j.mapel} (${j.jam}) sebelum pelajaran berakhir.',
            user: guruUser.id);
      }
    }
    return r;
  }

  // ---------------------------------------------------------------- dashboard
  WakaStat statistikWaka() {
    final tgl = Fmt.hariIni();
    final m = Fmt.menitSekarang();
    final sesi = jadwal.where((j) => j.hari == tgl.weekday && BlokPutaran.kelasAktif(j.kelas, tgl)).toList();
    final pHari = presensi.where((p) => Fmt.sama(p.tanggal, tgl)).toList();
    final hadir = pHari.where((p) => p.status == StatusHadir.hadir).length;
    final belum = <BelumIsi>[];
    var sp = 0;
    var sj = 0;
    for (final j in sesi) {
      final pOk = presensi.any((p) => p.jadwalId == j.id && Fmt.sama(p.tanggal, tgl));
      final jOk = jurnalSesi(j.id, tgl) != null;
      if (pOk) sp++;
      if (jOk) sj++;
      if (Fmt.menit(j.jamMulai) <= m && (!pOk || !jOk)) belum.add(BelumIsi(j, pOk, jOk));
    }
    return WakaStat(
      totalSiswa: siswa.length,
      totalGuru: guru.length,
      totalSesi: sesi.length,
      sesiPresensi: sp,
      sesiJurnal: sj,
      persenHadir: pHari.isEmpty ? 0 : (hadir * 100 / pHari.length).round(),
      izinMenunggu: izin.where((i) => i.status == StatusIzin.menunggu).length,
      belumIsi: belum,
    );
  }
}
