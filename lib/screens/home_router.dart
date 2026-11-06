import 'package:flutter/material.dart';
import '../models/usermodel.dart';
import '../services/auth_service.dart';
import 'auth/login_screen.dart';
import 'bk/bk_home.dart';
import 'bk/izin_review_screen.dart';
import 'guru/guru_home.dart';
import 'guru/guru_izin_screen.dart';
import 'guru/guru_jadwal_screen.dart';
import 'guru/guru_jurnal_screen.dart';
import 'shared/presensi_monitor.dart';
import 'shared/profile_screen.dart';
import 'shared/rekap_screen.dart';
import 'shared/role_shell.dart';
import 'siswa/siswa_home.dart';
import 'siswa/siswa_izin_screen.dart';
import 'siswa/siswa_presensi_screen.dart';
import 'waka/waka_home.dart';
import 'waka/waka_jadwal_screen.dart';
import 'wali_kelas/wali_home.dart';

class HomeRouter extends StatelessWidget {
  const HomeRouter({super.key});

  @override
  Widget build(BuildContext context) {
    final u = AuthService.instance.current;
    if (u == null) return const LoginScreen();

    final profil = ShellTab('Profil', Icons.person_outline, Icons.person, (_) => const ProfileScreen());

    switch (u.role) {
      case UserRole.waka:
        return RoleShell(tabs: [
          ShellTab('Beranda', Icons.dashboard_outlined, Icons.dashboard, (_) => const WakaHome()),
          ShellTab('Jadwal', Icons.calendar_month_outlined, Icons.calendar_month, (_) => const WakaJadwalScreen()),
          ShellTab('Monitor', Icons.fact_check_outlined, Icons.fact_check, (_) => const PresensiMonitor()),
          ShellTab('Rekap', Icons.bar_chart_outlined, Icons.bar_chart, (_) => const RekapScreen()),
          profil,
        ]);
      case UserRole.guru:
        return RoleShell(tabs: [
          ShellTab('Beranda', Icons.home_outlined, Icons.home, (_) => const GuruHome()),
          ShellTab('Jurnal', Icons.menu_book_outlined, Icons.menu_book, (_) => const GuruJurnalScreen()),
          ShellTab('Jadwal', Icons.calendar_month_outlined, Icons.calendar_month, (_) => const GuruJadwalScreen()),
          ShellTab('Izin', Icons.mail_outline, Icons.mail, (_) => const GuruIzinScreen()),
          profil,
        ]);
      case UserRole.siswa:
        return RoleShell(tabs: [
          ShellTab('Beranda', Icons.home_outlined, Icons.home, (_) => const SiswaHome()),
          ShellTab('Presensi', Icons.fact_check_outlined, Icons.fact_check, (_) => const SiswaPresensiScreen()),
          ShellTab('Izin', Icons.mail_outline, Icons.mail, (_) => const SiswaIzinScreen()),
          profil,
        ]);
      case UserRole.ortu:
        return RoleShell(tabs: [
          ShellTab('Beranda', Icons.home_outlined, Icons.home, (_) => const SiswaHome()),
          ShellTab('Presensi', Icons.fact_check_outlined, Icons.fact_check, (_) => const SiswaPresensiScreen()),
          ShellTab('Izin', Icons.mail_outline, Icons.mail, (_) => const SiswaIzinScreen()),
          profil,
        ]);
      case UserRole.bk:
        return RoleShell(tabs: [
          ShellTab('Beranda', Icons.home_outlined, Icons.home, (_) => const BkHome()),
          ShellTab('Izin', Icons.mark_email_read_outlined, Icons.mark_email_read, (_) => const IzinReviewScreen()),
          ShellTab('Rekap', Icons.bar_chart_outlined, Icons.bar_chart, (_) => const RekapScreen()),
          profil,
        ]);
      case UserRole.walikelas:
        final k = u.kelas;
        return RoleShell(tabs: [
          ShellTab('Beranda', Icons.home_outlined, Icons.home, (_) => const WaliHome()),
          ShellTab('Izin', Icons.mark_email_read_outlined, Icons.mark_email_read, (_) => IzinReviewScreen(kelasTetap: k)),
          ShellTab('Presensi', Icons.fact_check_outlined, Icons.fact_check, (_) => PresensiMonitor(kelasTetap: k)),
          ShellTab('Rekap', Icons.bar_chart_outlined, Icons.bar_chart, (_) => RekapScreen(kelasTetap: k)),
          profil,
        ]);
    }
  }
}
