import '../config/api_config.dart';
import '../models/logmodel.dart';
import 'api_services.dart';
import 'mock_store.dart';

class LogService {
  LogService._();
  static final LogService instance = LogService._();

  Future<List<LogModel>> list({String? modul, String? q, String? oleh}) async {
    if (ApiConfig.useMock) return MockStore.instance.getLog(modul: modul, q: q, oleh: oleh);
    return ApiServices.instance.list('/riwayat', LogModel.fromJson, query: {'modul': modul, 'q': q});
  }
}
