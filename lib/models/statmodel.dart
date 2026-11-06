import '../utils/jsonx.dart';
import 'jadwalmodel.dart';

class BelumIsi {
  final JadwalModel jadwal;
  final bool presensiOk;
  final bool jurnalOk;
  const BelumIsi(this.jadwal, this.presensiOk, this.jurnalOk);
}

class WakaStat {
  final int totalSiswa;
  final int totalGuru;
  final int totalSesi;
  final int sesiPresensi;
  final int sesiJurnal;
  final int persenHadir;
  final int izinMenunggu;
  final List<BelumIsi> belumIsi;

  const WakaStat({
    required this.totalSiswa,
    required this.totalGuru,
    required this.totalSesi,
    required this.sesiPresensi,
    required this.sesiJurnal,
    required this.persenHadir,
    required this.izinMenunggu,
    required this.belumIsi,
  });

  factory WakaStat.fromJson(Map<String, dynamic> j) => WakaStat(
        totalSiswa: Jx.integer(j['totalSiswa']),
        totalGuru: Jx.integer(j['totalGuru']),
        totalSesi: Jx.integer(j['totalSesi']),
        sesiPresensi: Jx.integer(j['sesiPresensi']),
        sesiJurnal: Jx.integer(j['sesiJurnal']),
        persenHadir: Jx.integer(j['persenHadir']),
        izinMenunggu: Jx.integer(j['izinMenunggu']),
        belumIsi: ((j['belumIsi'] as List?) ?? [])
            .map((e) => BelumIsi(
                  JadwalModel.fromJson(Map<String, dynamic>.from((e as Map)['jadwal'] as Map)),
                  Jx.boolean(e['presensiOk']),
                  Jx.boolean(e['jurnalOk']),
                ))
            .toList(),
      );
}
