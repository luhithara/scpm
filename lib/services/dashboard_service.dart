import '../config/api_config.dart';
import '../models/statmodel.dart';
import 'api_services.dart';
import 'mock_store.dart';

class DashboardService {
  DashboardService._();
  static final DashboardService instance = DashboardService._();

  Future<WakaStat> waka() async {
    if (ApiConfig.useMock) return MockStore.instance.statistikWaka();
    return WakaStat.fromJson(ApiServices.instance.asMap(await ApiServices.instance.get('/dashboard/waka')));
  }
}
