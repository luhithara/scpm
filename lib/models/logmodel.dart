import '../utils/jsonx.dart';

class LogModel {
  final String id;
  final String modul;
  final String aksi;
  final String oleh;
  final DateTime waktu;
  final String sebelum;
  final String sesudah;

  const LogModel({
    required this.id,
    required this.modul,
    required this.aksi,
    required this.oleh,
    required this.waktu,
    this.sebelum = '',
    this.sesudah = '',
  });

  factory LogModel.fromJson(Map<String, dynamic> j) => LogModel(
        id: Jx.str(j['id']),
        modul: Jx.str(j['modul']),
        aksi: Jx.str(j['aksi']),
        oleh: Jx.str(j['oleh']),
        waktu: Jx.date(j['waktu']),
        sebelum: Jx.str(j['sebelum']),
        sesudah: Jx.str(j['sesudah']),
      );
}
