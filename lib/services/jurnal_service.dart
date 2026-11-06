import '../config/api_config.dart';
import '../models/jadwalmodel.dart';
import '../models/jurnalmodel.dart';
import '../utils/format.dart';
import 'api_services.dart';
import 'auth_service.dart';
import 'mock_store.dart';

class JurnalService {
  JurnalService._();
  static final JurnalService instance = JurnalService._();

  MockStore get _m => MockStore.instance;
  ApiServices get _api => ApiServices.instance;

  Future<JurnalModel?> sesi(String jadwalId, DateTime tgl) async {
    if (ApiConfig.useMock) return _m.jurnalSesi(jadwalId, tgl);
    final r = await _api.list('/jurnal', JurnalModel.fromJson, query: {'jadwalId': jadwalId, 'tanggal': Fmt.iso(tgl)});
    return r.isEmpty ? null : r.first;
  }

  Future<JurnalModel> simpan({
    required JadwalModel jadwal,
    required DateTime tanggal,
    required String materi,
    required String catatan,
    required String fotoPath,
  }) async {
    if (ApiConfig.useMock) {
      return _m.simpanJurnal(
          jd: jadwal,
          tgl: tanggal,
          materi: materi,
          catatan: catatan,
          fotoPath: fotoPath,
          oleh: AuthService.instance.current!);
    }
    final res = await _api.postMultipart(
      '/jurnal',
      {'jadwalId': jadwal.id, 'tanggal': Fmt.iso(tanggal), 'materi': materi, 'catatan': catatan},
      files: {'foto': fotoPath},
    );
    return JurnalModel.fromJson(_api.asMap(res));
  }

  Future<List<JurnalModel>> list({String? guruId, String? kelas, DateTime? dari, DateTime? sampai}) async {
    if (ApiConfig.useMock) return _m.getJurnal(guruId: guruId, kelas: kelas, dari: dari, sampai: sampai);
    return _api.list('/jurnal', JurnalModel.fromJson, query: {
      'guruId': guruId,
      'kelas': kelas,
      'dari': dari == null ? null : Fmt.iso(dari),
      'sampai': sampai == null ? null : Fmt.iso(sampai),
    });
  }
}
