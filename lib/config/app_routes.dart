import 'package:flutter/material.dart';
import '../screens/auth/forgot_password_screen.dart';
import '../screens/auth/login_screen.dart';
import '../screens/auth/register_screen.dart';
import '../screens/home_router.dart';

class AppRoutes {
  AppRoutes._();

  static const String login = '/login';
  static const String lupa = '/lupa-password';
  static const String home = '/home';
  static const String register = '/register';

  static Map<String, WidgetBuilder> get routes => {
        login: (_) => const LoginScreen(),
        lupa: (_) => const ForgotPasswordScreen(),
        home: (_) => const HomeRouter(),
        register: (_) => const RegisterScreen(),
      };
}
