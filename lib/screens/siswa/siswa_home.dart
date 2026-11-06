import 'package:flutter/material.dart';
import '../../models/izinmodel.dart';
import '../../models/jadwalmodel.dart';
import '../../models/presensimodel.dart';
import '../../services/auth_service.dart';
import '../../services/izin_service.dart';
import '../../services/jadwal_service.dart';
import '../../services/presensi_service.dart';
import '../../theme/app_theme.dart';
import '../../utils/format.dart';
import '../../widgets/scp_widgets.dart';

class _SiswaData {
  final List<JadwalModel> sesi;
  final List<PresensiModel> presensi;
  final List<IzinModel> izin;
  _SiswaData(this.sesi, this.presensi, this.izin);
}

class SiswaHome extends StatefulWidget {
  const SiswaHome({super.key});

  @override
  State<SiswaHome> createState() => _SiswaHomeState();
}

class _SiswaHomeState extends State<SiswaHome> {
  final DateTime _tgl = Fmt.hariIni();
  late Future<_SiswaData> _future;

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  Future<_SiswaData> _load() async {
    final u = AuthService.instance.current!;
    final sesi = await JadwalService.instance.sesiHariIni(kelas: u.kelas, tgl: _tgl);
    final p = await PresensiService.instance.rekap(dari: _tgl.subtract(const Duration(days: 30)), sampai: _tgl, siswaId: u.id);
    final i = await IzinService.instance.list(siswaId: u.id);
    return _SiswaData(sesi, p, i);
  }

  void _reload() => setState(() => _future = _load());

  @override
  Widget build(BuildContext context) {
    final u = AuthService.instance.current!;
    return FutureView<_SiswaData>(
      future: _future,
      onRetry: _reload,
      builder: (c, d) {
        int n(StatusHadir s) => d.presensi.where((p) => p.status == s).length;
        final menunggu = d.izin.where((i) => i.status == StatusIzin.menunggu).length;
        return RefreshIndicator(
          onRefresh: () async => _reload(),
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text('Halo, ${u.nama}', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppTheme.navy)),
              Text(u.kelas ?? '', style: const TextStyle(color: AppTheme.grey)),
              const SizedBox(height: 14),
              PutaranBanner(kelas: u.kelas),
              if (menunggu > 0) InfoBanner('$menunggu pengajuan izin menunggu persetujuan', icon: Icons.hourglass_top, color: AppTheme.orange),
              const SectionTitle('Kehadiran 30 hari terakhir'),
              StatGrid(items: [
                StatCard(title: 'Hadir', value: '${n(StatusHadir.hadir)}', icon: Icons.check_circle_outline, color: AppTheme.teal),
                StatCard(title: 'Izin', value: '${n(StatusHadir.izin)}', icon: Icons.mail_outline, color: AppTheme.blue),
                StatCard(title: 'Sakit', value: '${n(StatusHadir.sakit)}', icon: Icons.healing_outlined, color: AppTheme.orange),
                StatCard(title: 'Alpa', value: '${n(StatusHadir.alpa)}', icon: Icons.cancel_outlined, color: AppTheme.red),
              ]),
              const SectionTitle('Grafik kehadiran'),
              _KehadiranChart(
                hadir: n(StatusHadir.hadir),
                izin: n(StatusHadir.izin),
                sakit: n(StatusHadir.sakit),
                alpa: n(StatusHadir.alpa),
              ),
              SectionTitle('Jadwal hari ini · ${Fmt.tglPanjang(_tgl)}'),
              if (d.sesi.isEmpty) const EmptyState('Tidak ada pelajaran hari ini', icon: Icons.free_breakfast_outlined),
              for (final j in d.sesi)
                SCard(
                  child: Row(
                    children: [
                      Container(
                        width: 78,
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        decoration: BoxDecoration(color: AppTheme.bg, borderRadius: BorderRadius.circular(12)),
                        child: Column(children: [
                          Text(j.jamMulai, style: const TextStyle(fontWeight: FontWeight.bold)),
                          Text(j.jamSelesai, style: const TextStyle(fontSize: 12, color: AppTheme.grey)),
                        ]),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(j.mapel, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                            Text(j.guruNama, style: const TextStyle(color: AppTheme.grey, fontSize: 13)),
                            Text(j.ruangan ?? 'Ruangan belum diatur', style: const TextStyle(color: AppTheme.grey, fontSize: 12)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

class _KehadiranChart extends StatelessWidget {
  final int hadir;
  final int izin;
  final int sakit;
  final int alpa;
  const _KehadiranChart({required this.hadir, required this.izin, required this.sakit, required this.alpa});

  @override
  Widget build(BuildContext context) {
    final total = hadir + izin + sakit + alpa;
    final rows = [
      ('Hadir', hadir, AppTheme.teal),
      ('Izin', izin, AppTheme.blue),
      ('Sakit', sakit, AppTheme.orange),
      ('Alpa', alpa, AppTheme.red),
    ];
    return SCard(
      child: Column(
        children: [
          for (final row in rows)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 5),
              child: Row(
                children: [
                  SizedBox(width: 48, child: Text(row.$1, style: const TextStyle(fontSize: 12))),
                  Expanded(
                    child: LinearProgressIndicator(
                      value: total == 0 ? 0 : row.$2 / total,
                      minHeight: 8,
                      borderRadius: BorderRadius.circular(8),
                      color: row.$3,
                      backgroundColor: row.$3.withValues(alpha: 0.12),
                    ),
                  ),
                  SizedBox(width: 32, child: Text('${row.$2}', textAlign: TextAlign.end)),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
