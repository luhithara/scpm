import '../utils/jsonx.dart';

class SiswaModel {
  final String id;
  final String nisn;
  final String nama;
  final String kelas;
  final String jurusan;

  const SiswaModel({
    required this.id,
    required this.nisn,
    required this.nama,
    required this.kelas,
    this.jurusan = '',
  });

  factory SiswaModel.fromJson(Map<String, dynamic> j) => SiswaModel(
        id: Jx.str(j['id']),
        nisn: Jx.str(j['nisn']),
        nama: Jx.str(j['nama']),
        kelas: Jx.str(j['kelas']),
        jurusan: Jx.str(j['jurusan']),
      );
}
