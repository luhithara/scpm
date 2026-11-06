import '../config/api_config.dart';
import '../models/jadwalmodel.dart';
import '../models/presensimodel.dart';
import '../models/siswamodel.dart';
import '../utils/format.dart';
import 'api_services.dart';
import 'auth_service.dart';
import 'jadwal_service.dart';
import 'mock_store.dart';

class PresensiService {
  PresensiService._();
  static final PresensiService instance = PresensiService._();

  MockStore get _m => MockStore.instance;
  ApiServices get _api => ApiServices.instance;

  Future<List<SiswaModel>> siswaKelas(String kelas) => JadwalService.instance.daftarSiswa(kelas: kelas);

  Future<List<PresensiModel>> sesi(String jadwalId, DateTime tgl) async {
    if (ApiConfig.useMock) return _m.presensiSesi(jadwalId, tgl);
    return _api.list('/presensi', PresensiModel.fromJson, query: {'jadwalId': jadwalId, 'tanggal': Fmt.iso(tgl)});
  }

  Future<void> simpanSesi(JadwalModel j, DateTime tgl, List<PresensiModel> data) async {
    if (ApiConfig.useMock) {
      _m.simpanPresensi(j, tgl, data, AuthService.instance.current!);
      return;
    }
    await _api.post('/presensi/sesi', body: {
      'jadwalId': j.id,
      'tanggal': Fmt.iso(tgl),
      'data': data
          .map((p) => {'siswaId': p.siswaId, 'status': p.status.name, 'keterangan': p.keterangan})
          .toList(),
    });
  }

  Future<List<PresensiModel>> rekap(
      {DateTime? dari, DateTime? sampai, String? kelas, String? mapel, String? siswaId, String? guruId}) async {
    if (ApiConfig.useMock) {
      return _m.filterPresensi(dari: dari, sampai: sampai, kelas: kelas, mapel: mapel, siswaId: siswaId, guruId: guruId);
    }
    return _api.list('/presensi', PresensiModel.fromJson, query: {
      'dari': dari == null ? null : Fmt.iso(dari),
      'sampai': sampai == null ? null : Fmt.iso(sampai),
      'kelas': kelas,
      'mapel': mapel,
      'siswaId': siswaId,
      'guruId': guruId,
    });
  }
}
