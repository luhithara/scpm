import '../config/api_config.dart';
import 'api_services.dart';

class ImportService {
  ImportService._();
  static final instance = ImportService._();

  Future<int> upload(String jenis, String path) async {
    if (ApiConfig.useMock) return 0;
    final response = await ApiServices.instance.postMultipart('/import/$jenis', {}, files: {'file': path});
    return int.tryParse(ApiServices.instance.asMap(response)['imported']?.toString() ?? '') ?? 0;
  }
}
