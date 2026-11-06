import '../utils/jsonx.dart';

enum StatusHadir { hadir, izin, sakit, alpa }

extension StatusHadirX on StatusHadir {
  String get label => switch (this) {
        StatusHadir.hadir => 'Hadir',
        StatusHadir.izin => 'Izin',
        StatusHadir.sakit => 'Sakit',
        StatusHadir.alpa => 'Alpa',
      };

  static StatusHadir parse(String s) {
    final v = s.toLowerCase();
    for (final r in StatusHadir.values) {
      if (r.name == v) return r;
    }
    return StatusHadir.hadir;
  }
}

class PresensiModel {
  final String id;
  final String jadwalId;
  final DateTime tanggal;
  final String kelas;
  final String mapel;
  final String siswaId;
  final String siswaNama;
  final StatusHadir status;
  final String keterangan;

  const PresensiModel({
    required this.id,
    required this.jadwalId,
    required this.tanggal,
    required this.kelas,
    required this.mapel,
    required this.siswaId,
    required this.siswaNama,
    required this.status,
    this.keterangan = '',
  });

  PresensiModel copyWith({
    String? id,
    String? jadwalId,
    DateTime? tanggal,
    String? kelas,
    String? mapel,
    StatusHadir? status,
    String? keterangan,
  }) =>
      PresensiModel(
        id: id ?? this.id,
        jadwalId: jadwalId ?? this.jadwalId,
        tanggal: tanggal ?? this.tanggal,
        kelas: kelas ?? this.kelas,
        mapel: mapel ?? this.mapel,
        siswaId: siswaId,
        siswaNama: siswaNama,
        status: status ?? this.status,
        keterangan: keterangan ?? this.keterangan,
      );

  factory PresensiModel.fromJson(Map<String, dynamic> j) => PresensiModel(
        id: Jx.str(j['id']),
        jadwalId: Jx.str(j['jadwalId']),
        tanggal: Jx.date(j['tanggal']),
        kelas: Jx.str(j['kelas']),
        mapel: Jx.str(j['mapel']),
        siswaId: Jx.str(j['siswaId']),
        siswaNama: Jx.str(j['siswaNama']),
        status: StatusHadirX.parse(Jx.str(j['status'])),
        keterangan: Jx.str(j['keterangan']),
      );
}
