import '../config/api_config.dart';
import '../models/gurumodel.dart';
import '../models/jadwalmodel.dart';
import '../models/siswamodel.dart';
import '../utils/blokputaran.dart';
import '../utils/format.dart';
import 'api_services.dart';
import 'auth_service.dart';
import 'mock_store.dart';

class JadwalService {
  JadwalService._();
  static final JadwalService instance = JadwalService._();

  MockStore get _m => MockStore.instance;
  ApiServices get _api => ApiServices.instance;

  Future<List<JadwalModel>> list({String? kelas, String? guruId, int? hari}) async {
    if (ApiConfig.useMock) return _m.getJadwal(kelas: kelas, guruId: guruId, hari: hari);
    return _api.list('/jadwal', JadwalModel.fromJson, query: {'kelas': kelas, 'guruId': guruId, 'hari': hari});
  }

  /// Sesi pada tanggal tertentu, hanya untuk kelas yang sedang masuk blok.
  Future<List<JadwalModel>> sesiHariIni({String? kelas, String? guruId, DateTime? tgl}) async {
    final t = tgl ?? Fmt.hariIni();
    if (t.weekday > 5) return [];
    final all = await list(kelas: kelas, guruId: guruId, hari: t.weekday);
    return all.where((j) => BlokPutaran.kelasAktif(j.kelas, t)).toList();
  }

  Future<List<String>> daftarKelas() async {
    if (ApiConfig.useMock) return List<String>.from(_m.daftarKelas);
    final d = await _api.get('/kelas');
    final raw = d is List ? d : (d is Map && d['data'] is List ? d['data'] as List : <dynamic>[]);
    return raw.map((e) => e.toString()).toList();
  }

  Future<List<GuruModel>> daftarGuru() async {
    if (ApiConfig.useMock) return List<GuruModel>.from(_m.guru);
    return _api.list('/guru', GuruModel.fromJson);
  }

  Future<List<SiswaModel>> daftarSiswa({String? kelas}) async {
    if (ApiConfig.useMock) return kelas == null ? List<SiswaModel>.from(_m.siswa) : _m.siswaKelas(kelas);
    return _api.list('/siswa', SiswaModel.fromJson, query: {'kelas': kelas});
  }

  Future<JadwalModel> tambah(JadwalModel j) async {
    if (ApiConfig.useMock) return _m.tambahJadwal(j, AuthService.instance.current!);
    return JadwalModel.fromJson(_api.asMap(await _api.post('/jadwal', body: j.toJson())));
  }

  Future<JadwalModel> ubah(JadwalModel j) async {
    if (ApiConfig.useMock) return _m.ubahJadwal(j, AuthService.instance.current!);
    return JadwalModel.fromJson(_api.asMap(await _api.put('/jadwal/${j.id}', body: j.toJson())));
  }

  Future<void> hapus(String id) async {
    if (ApiConfig.useMock) {
      _m.hapusJadwal(id, AuthService.instance.current!);
      return;
    }
    await _api.delete('/jadwal/$id');
  }

  Future<void> setRuangan(String id, String ruangan) async {
    if (ApiConfig.useMock) {
      _m.setRuangan(id, ruangan, AuthService.instance.current!);
      return;
    }
    await _api.put('/jadwal/$id/ruangan', body: {'ruangan': ruangan});
  }

  Future<bool> terkunci() async {
    if (ApiConfig.useMock) return _m.jadwalTerkunci;
    final d = _api.asMap(await _api.get('/jadwal/kunci'));
    return d['terkunci'] == true || d['terkunci']?.toString() == '1';
  }

  Future<void> setKunci(bool v) async {
    if (ApiConfig.useMock) {
      _m.setKunci(v, AuthService.instance.current!);
      return;
    }
    await _api.put('/jadwal/kunci', body: {'terkunci': v});
  }

  Future<void> unggahSk(String guruId, String namaFile, String path) async {
    if (ApiConfig.useMock) {
      _m.unggahSk(guruId, namaFile, AuthService.instance.current!);
      return;
    }
    await _api.postMultipart('/guru/$guruId/sk', {}, files: {'file': path});
  }
}
