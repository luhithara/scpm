import '../utils/jsonx.dart';

enum UserRole { waka, guru, siswa, ortu, bk, walikelas }

extension UserRoleX on UserRole {
  String get label => switch (this) {
        UserRole.waka => 'Waka Kurikulum',
        UserRole.guru => 'Guru',
        UserRole.siswa => 'Siswa',
        UserRole.ortu => 'Orang Tua',
        UserRole.bk => 'BK',
        UserRole.walikelas => 'Wali Kelas',
      };

  static UserRole parse(String s) {
    final v = s.toLowerCase().replaceAll(RegExp(r'[^a-z]'), '');
    if (v == 'orangtua') return UserRole.ortu;
    for (final r in UserRole.values) {
      if (r.name == v) return r;
    }
    return UserRole.siswa;
  }
}

class UserModel {
  final String id;
  final String nama;
  final String username;
  final UserRole role;
  final String? kelas;
  final String? mapel;
  final String? token;

  const UserModel({
    required this.id,
    required this.nama,
    required this.username,
    required this.role,
    this.kelas,
    this.mapel,
    this.token,
  });

  factory UserModel.fromJson(Map<String, dynamic> j, {String? token}) => UserModel(
        id: Jx.str(j['id']),
        nama: Jx.str(j['nama'] ?? j['name']),
        username: Jx.str(j['username'] ?? j['nisn'] ?? j['kodepegawai'] ?? j['kodekelas']),
        role: UserRoleX.parse(Jx.str(j['role'])),
        kelas: Jx.strOrNull(j['kelas'] ?? j['namaKelas'] ?? j['kodekelas']),
        mapel: Jx.strOrNull(j['mapel']),
        token: token ?? Jx.strOrNull(j['token']),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'nama': nama,
        'username': username,
        'role': role.name,
        'kelas': kelas,
        'mapel': mapel,
        'token': token,
      };

  UserModel withToken(String t) => UserModel(
        id: id,
        nama: nama,
        username: username,
        role: role,
        kelas: kelas,
        mapel: mapel,
        token: t,
      );
}
