import '../utils/jsonx.dart';

class GuruModel {
  final String id;
  final String nama;
  final String username;
  final String mapel;
  final String? namaSk;

  const GuruModel({
    required this.id,
    required this.nama,
    required this.username,
    required this.mapel,
    this.namaSk,
  });

  factory GuruModel.fromJson(Map<String, dynamic> j) => GuruModel(
        id: Jx.str(j['id']),
        nama: Jx.str(j['nama']),
        username: Jx.str(j['username']),
        mapel: Jx.str(j['mapel']),
        namaSk: Jx.strOrNull(j['namaSk']),
      );

  GuruModel withSk(String nama) =>
      GuruModel(id: id, nama: this.nama, username: username, mapel: mapel, namaSk: nama);
}
