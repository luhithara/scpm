import '../utils/format.dart';
import '../utils/jsonx.dart';

class JadwalModel {
  final String id;
  final String kelas;
  final int hari; // 1 = Senin ... 5 = Jumat
  final String jamMulai;
  final String jamSelesai;
  final String mapel;
  final String guruId;
  final String guruNama;
  final String? ruangan;
  final int? putaranBlok;
  final int? blok;
  final DateTime? tanggalMulaiBlok;
  final DateTime? tanggalSelesaiBlok;

  const JadwalModel({
    required this.id,
    required this.kelas,
    required this.hari,
    required this.jamMulai,
    required this.jamSelesai,
    required this.mapel,
    required this.guruId,
    required this.guruNama,
    this.ruangan,
    this.putaranBlok,
    this.blok,
    this.tanggalMulaiBlok,
    this.tanggalSelesaiBlok,
  });

  String get jam => '$jamMulai - $jamSelesai';
  String get namaHari => Fmt.namaHari[hari];

  bool bentrokWaktu(JadwalModel o) =>
      hari == o.hari &&
      Fmt.menit(jamMulai) < Fmt.menit(o.jamSelesai) &&
      Fmt.menit(o.jamMulai) < Fmt.menit(jamSelesai);

  JadwalModel copyWith({
    String? id,
    String? kelas,
    int? hari,
    String? jamMulai,
    String? jamSelesai,
    String? mapel,
    String? guruId,
    String? guruNama,
    String? ruangan,
    int? putaranBlok,
    int? blok,
    DateTime? tanggalMulaiBlok,
    DateTime? tanggalSelesaiBlok,
  }) =>
      JadwalModel(
        id: id ?? this.id,
        kelas: kelas ?? this.kelas,
        hari: hari ?? this.hari,
        jamMulai: jamMulai ?? this.jamMulai,
        jamSelesai: jamSelesai ?? this.jamSelesai,
        mapel: mapel ?? this.mapel,
        guruId: guruId ?? this.guruId,
        guruNama: guruNama ?? this.guruNama,
        ruangan: ruangan ?? this.ruangan,
        putaranBlok: putaranBlok ?? this.putaranBlok,
        blok: blok ?? this.blok,
        tanggalMulaiBlok: tanggalMulaiBlok ?? this.tanggalMulaiBlok,
        tanggalSelesaiBlok: tanggalSelesaiBlok ?? this.tanggalSelesaiBlok,
      );

  factory JadwalModel.fromJson(Map<String, dynamic> j) => JadwalModel(
        id: Jx.str(j['id']),
        kelas: Jx.str(j['kelas']),
        hari: Jx.integer(j['hari']),
        jamMulai: Jx.jam(j['jamMulai']),
        jamSelesai: Jx.jam(j['jamSelesai']),
        mapel: Jx.str(j['mapel']),
        guruId: Jx.str(j['guruId']),
        guruNama: Jx.str(j['guruNama']),
        ruangan: Jx.strOrNull(j['ruangan']),
        putaranBlok: Jx.integerOrNull(j['putaranBlok'] ?? j['putaranblok']),
        blok: Jx.integerOrNull(j['blok']),
        tanggalMulaiBlok: Jx.dateOrNull(j['tanggalMulaiBlok'] ?? j['tanggalMulai']),
        tanggalSelesaiBlok: Jx.dateOrNull(j['tanggalSelesaiBlok'] ?? j['tanggalSelesai']),
      );

  Map<String, dynamic> toJson() => {
        'kelas': kelas,
        'hari': hari,
        'jamMulai': jamMulai,
        'jamSelesai': jamSelesai,
        'mapel': mapel,
        'guruId': guruId,
      };
}
