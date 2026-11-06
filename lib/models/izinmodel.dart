import '../utils/jsonx.dart';

enum StatusIzin { menunggu, disetujui, ditolak }

extension StatusIzinX on StatusIzin {
  String get label => switch (this) {
        StatusIzin.menunggu => 'Menunggu',
        StatusIzin.disetujui => 'Disetujui',
        StatusIzin.ditolak => 'Ditolak',
      };

  static StatusIzin parse(String s) {
    final v = s.toLowerCase();
    for (final r in StatusIzin.values) {
      if (r.name == v) return r;
    }
    return StatusIzin.menunggu;
  }
}

class IzinModel {
  final String id;
  final String siswaId;
  final String siswaNama;
  final String kelas;
  final DateTime tanggal;
  final String jenis; // Izin / Sakit
  final String alasan;
  final String? buktiNama;
  final String? buktiPath;
  final String diajukanOleh;
  final DateTime waktuAjuan;
  final StatusIzin status;
  final String? diprosesOleh;
  final DateTime? waktuProses;
  final String? catatan;

  const IzinModel({
    required this.id,
    required this.siswaId,
    required this.siswaNama,
    required this.kelas,
    required this.tanggal,
    required this.jenis,
    required this.alasan,
    this.buktiNama,
    this.buktiPath,
    required this.diajukanOleh,
    required this.waktuAjuan,
    this.status = StatusIzin.menunggu,
    this.diprosesOleh,
    this.waktuProses,
    this.catatan,
  });

  IzinModel copyWith({
    StatusIzin? status,
    String? diprosesOleh,
    DateTime? waktuProses,
    String? catatan,
  }) =>
      IzinModel(
        id: id,
        siswaId: siswaId,
        siswaNama: siswaNama,
        kelas: kelas,
        tanggal: tanggal,
        jenis: jenis,
        alasan: alasan,
        buktiNama: buktiNama,
        buktiPath: buktiPath,
        diajukanOleh: diajukanOleh,
        waktuAjuan: waktuAjuan,
        status: status ?? this.status,
        diprosesOleh: diprosesOleh ?? this.diprosesOleh,
        waktuProses: waktuProses ?? this.waktuProses,
        catatan: catatan ?? this.catatan,
      );

  factory IzinModel.fromJson(Map<String, dynamic> j) => IzinModel(
        id: Jx.str(j['id']),
        siswaId: Jx.str(j['siswaId']),
        siswaNama: Jx.str(j['siswaNama']),
        kelas: Jx.str(j['kelas']),
        tanggal: Jx.date(j['tanggal']),
        jenis: Jx.str(j['jenis'], 'Izin'),
        alasan: Jx.str(j['alasan']),
        buktiNama: Jx.strOrNull(j['buktiNama']),
        buktiPath: Jx.strOrNull(j['buktiUrl']),
        diajukanOleh: Jx.str(j['diajukanOleh']),
        waktuAjuan: Jx.date(j['waktuAjuan']),
        status: StatusIzinX.parse(Jx.str(j['status'])),
        diprosesOleh: Jx.strOrNull(j['diprosesOleh']),
        waktuProses: Jx.dateOrNull(j['waktuProses']),
        catatan: Jx.strOrNull(j['catatan']),
      );
}
