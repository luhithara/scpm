import '../config/api_config.dart';
import '../models/jadwalmodel.dart';
import '../models/notifmodel.dart';
import 'api_services.dart';
import 'auth_service.dart';
import 'mock_store.dart';

class NotifService {
  NotifService._();
  static final NotifService instance = NotifService._();

  MockStore get _m => MockStore.instance;
  ApiServices get _api => ApiServices.instance;

  Future<List<NotifModel>> list() async {
    if (ApiConfig.useMock) return _m.notifUser(AuthService.instance.current!);
    return _api.list('/notifikasi', NotifModel.fromJson);
  }

  Future<int> unread() async {
    try {
      final l = await list();
      return l.where((n) => !n.dibaca).length;
    } catch (_) {
      return 0;
    }
  }

  Future<void> baca(String id) async {
    if (ApiConfig.useMock) {
      _m.tandaiBaca(id);
      return;
    }
    await _api.put('/notifikasi/$id/baca');
  }

  Future<void> bacaSemua() async {
    if (ApiConfig.useMock) {
      _m.tandaiSemua(AuthService.instance.current!);
      return;
    }
    await _api.put('/notifikasi/baca-semua');
  }

  Future<void> kirimPeringatan(String guruId, String pesan) async {
    if (ApiConfig.useMock) {
      _m.kirimPeringatan(guruId, pesan, AuthService.instance.current!);
      return;
    }
    await _api.post('/notifikasi/peringatan', body: {'guruId': guruId, 'pesan': pesan});
  }

  /// Sesi yang jurnalnya belum diisi dan sudah masuk jendela pengingat (30 menit sebelum selesai).
  /// Catatan: ini pengingat di dalam aplikasi. Push notification sungguhan butuh FCM + scheduler di server.
  Future<List<JadwalModel>> jurnalBelumDiisi() async {
    if (ApiConfig.useMock) return _m.jurnalBelumDiisi(AuthService.instance.current!);
    return _api.list('/jurnal/belum-diisi', JadwalModel.fromJson);
  }
}
