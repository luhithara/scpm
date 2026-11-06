import '../utils/jsonx.dart';

class NotifModel {
  final String id;
  final String judul;
  final String isi;
  final DateTime waktu;
  final bool dibaca;
  final String? untukUser;
  final String? untukRole;
  final String? untukKelas;

  const NotifModel({
    required this.id,
    required this.judul,
    required this.isi,
    required this.waktu,
    this.dibaca = false,
    this.untukUser,
    this.untukRole,
    this.untukKelas,
  });

  NotifModel sudahDibaca() => NotifModel(
        id: id,
        judul: judul,
        isi: isi,
        waktu: waktu,
        dibaca: true,
        untukUser: untukUser,
        untukRole: untukRole,
        untukKelas: untukKelas,
      );

  factory NotifModel.fromJson(Map<String, dynamic> j) => NotifModel(
        id: Jx.str(j['id']),
        judul: Jx.str(j['judul']),
        isi: Jx.str(j['isi']),
        waktu: Jx.date(j['waktu']),
        dibaca: Jx.boolean(j['dibaca']),
      );
}
