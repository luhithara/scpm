import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
import '../bk/bk_home.dart';

class WaliHome extends StatelessWidget {
  const WaliHome({super.key});

  @override
  Widget build(BuildContext context) {
    return BkHome(kelasTetap: AuthService.instance.current!.kelas);
  }
}
