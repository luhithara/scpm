import '../utils/jsonx.dart';

class JurnalModel {
  final String id;
  final String jadwalId;
  final DateTime tanggal;
  final String kelas;
  final String mapel;
  final String guruId;
  final String guruNama;
  final String materi;
  final String catatan;
  final String fotoPath;
  final DateTime waktuSimpan;

  const JurnalModel({
    required this.id,
    required this.jadwalId,
    required this.tanggal,
    required this.kelas,
    required this.mapel,
    required this.guruId,
    required this.guruNama,
    required this.materi,
    this.catatan = '',
    this.fotoPath = '',
    required this.waktuSimpan,
  });

  factory JurnalModel.fromJson(Map<String, dynamic> j) => JurnalModel(
        id: Jx.str(j['id']),
        jadwalId: Jx.str(j['jadwalId']),
        tanggal: Jx.date(j['tanggal']),
        kelas: Jx.str(j['kelas']),
        mapel: Jx.str(j['mapel']),
        guruId: Jx.str(j['guruId']),
        guruNama: Jx.str(j['guruNama']),
        materi: Jx.str(j['materi']),
        catatan: Jx.str(j['catatan']),
        fotoPath: Jx.str(j['fotoUrl']),
        waktuSimpan: Jx.date(j['waktuSimpan']),
      );
}
