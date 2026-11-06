import '../config/api_config.dart';
import '../models/izinmodel.dart';
import '../utils/format.dart';
import 'api_services.dart';
import 'auth_service.dart';
import 'mock_store.dart';

class IzinService {
  IzinService._();
  static final IzinService instance = IzinService._();

  MockStore get _m => MockStore.instance;
  ApiServices get _api => ApiServices.instance;

  Future<List<IzinModel>> list(
      {String? siswaId, String? kelas, StatusIzin? status, DateTime? tanggal, DateTime? dari, DateTime? sampai}) async {
    if (ApiConfig.useMock) {
      return _m.getIzin(siswaId: siswaId, kelas: kelas, status: status, tanggal: tanggal, dari: dari, sampai: sampai);
    }
    return _api.list('/izin', IzinModel.fromJson, query: {
      'siswaId': siswaId,
      'kelas': kelas,
      'status': status?.name,
      'tanggal': tanggal == null ? null : Fmt.iso(tanggal),
      'dari': dari == null ? null : Fmt.iso(dari),
      'sampai': sampai == null ? null : Fmt.iso(sampai),
    });
  }

  Future<IzinModel> ajukan({
    required DateTime tanggal,
    required String jenis,
    required String alasan,
    String? buktiPath,
    String? buktiNama,
  }) async {
    final u = AuthService.instance.current!;
    if (ApiConfig.useMock) {
      return _m.ajukanIzin(
          oleh: u, tanggal: tanggal, jenis: jenis, alasan: alasan, buktiNama: buktiNama, buktiPath: buktiPath);
    }
    final res = await _api.postMultipart(
      '/izin',
      {'tanggal': Fmt.iso(tanggal), 'jenis': jenis, 'alasan': alasan},
      files: buktiPath == null ? {} : {'bukti': buktiPath},
    );
    return IzinModel.fromJson(_api.asMap(res));
  }

  Future<IzinModel> proses(String id, {required bool setuju, String? catatan}) async {
    if (ApiConfig.useMock) {
      return _m.prosesIzin(id, setuju, AuthService.instance.current!, catatan: catatan);
    }
    final res = await _api.put('/izin/$id/proses', body: {'setuju': setuju, 'catatan': catatan});
    return IzinModel.fromJson(_api.asMap(res));
  }

  Future<Set<String>> siswaIzinDisetujui(String kelas, DateTime tgl) async {
    if (ApiConfig.useMock) return _m.siswaIzinDisetujui(kelas, tgl);
    final r = await list(kelas: kelas, status: StatusIzin.disetujui, tanggal: tgl);
    return r.map((e) => e.siswaId).toSet();
  }

  /// Izin siswa pada tanggal tertentu untuk kelas yang diajar guru (informasi saja).
  Future<List<IzinModel>> infoGuru(DateTime tgl) async {
    if (ApiConfig.useMock) return _m.infoGuru(AuthService.instance.current!.id, tgl);
    return _api.list('/izin/info-guru', IzinModel.fromJson, query: {'tanggal': Fmt.iso(tgl)});
  }
}
