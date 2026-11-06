import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'config/app_routes.dart';
import 'services/auth_service.dart';
import 'theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('id_ID');
  await AuthService.instance.restore();
  runApp(const SCPApp());
}

class SCPApp extends StatelessWidget {
  const SCPApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'SCP - School Class Progress',
      theme: AppTheme.light,
      routes: AppRoutes.routes,
      initialRoute: AuthService.instance.current != null ? AppRoutes.home : AppRoutes.login,
    );
  }
}
