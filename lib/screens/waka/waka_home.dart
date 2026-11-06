import 'package:flutter/material.dart';
import '../../models/statmodel.dart';
import '../../services/api_services.dart';
import '../../services/auth_service.dart';
import '../../services/dashboard_service.dart';
import '../../services/notif_service.dart';
import '../../theme/app_theme.dart';
import '../../utils/format.dart';
import '../../widgets/scp_widgets.dart';

class WakaHome extends StatefulWidget {
  const WakaHome({super.key});

  @override
  State<WakaHome> createState() => _WakaHomeState();
}

class _WakaHomeState extends State<WakaHome> {
  late Future<WakaStat> _future;

  @override
  void initState() {
    super.initState();
    _future = DashboardService.instance.waka();
  }

  void _reload() => setState(() => _future = DashboardService.instance.waka());

  Future<void> _peringatan(BelumIsi b) async {
    final j = b.jadwal;
    final kurang = [if (!b.presensiOk) 'presensi', if (!b.jurnalOk) 'jurnal'].join(' dan ');
    try {
      await NotifService.instance.kirimPeringatan(
        j.guruId,
        'Mohon segera mengisi $kurang untuk ${j.kelas} · ${j.mapel} (${j.jam}).',
      );
      if (!mounted) return;
      showMsg(context, 'Peringatan dikirim ke ${j.guruNama}');
    } catch (e) {
      if (!mounted) return;
      showMsg(context, pesanError(e), error: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final u = AuthService.instance.current!;
    return FutureView<WakaStat>(
      future: _future,
      onRetry: _reload,
      builder: (c, s) => RefreshIndicator(
        onRefresh: () async => _reload(),
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text('Halo, ${u.nama}', style: const TextStyle(fontSize: 21, fontWeight: FontWeight.bold, color: AppTheme.navy)),
            Text(Fmt.tglPanjang(DateTime.now()), style: const TextStyle(color: AppTheme.grey)),
            const SizedBox(height: 14),
            const PutaranBanner(),
            StatGrid(items: [
              StatCard(title: 'Total Siswa', value: '${s.totalSiswa}', icon: Icons.people_alt_outlined, color: AppTheme.blue),
              StatCard(title: 'Total Guru', value: '${s.totalGuru}', icon: Icons.school_outlined, color: AppTheme.teal),
              StatCard(title: 'Kehadiran hari ini', value: '${s.persenHadir}%', icon: Icons.fact_check_outlined, color: AppTheme.purple),
              StatCard(title: 'Izin menunggu', value: '${s.izinMenunggu}', icon: Icons.mail_outline, color: AppTheme.orange),
            ]),
            SCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Kelengkapan hari ini', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  _progress('Presensi terisi', s.sesiPresensi, s.totalSesi),
                  const SizedBox(height: 10),
                  _progress('Jurnal terisi', s.sesiJurnal, s.totalSesi),
                ],
              ),
            ),
            SectionTitle('Belum mengisi (${s.belumIsi.length})'),
            if (s.belumIsi.isEmpty) const EmptyState('Semua sesi yang sudah berjalan telah terisi', icon: Icons.check_circle_outline),
            for (final b in s.belumIsi)
              SCard(
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(b.jadwal.guruNama, style: const TextStyle(fontWeight: FontWeight.bold)),
                          Text('${b.jadwal.kelas} · ${b.jadwal.mapel} · ${b.jadwal.jam}', style: const TextStyle(fontSize: 12, color: AppTheme.grey)),
                          const SizedBox(height: 6),
                          Wrap(spacing: 6, children: [
                            if (!b.presensiOk) const StatusChip('Presensi', AppTheme.orange),
                            if (!b.jurnalOk) const StatusChip('Jurnal', AppTheme.orange),
                          ]),
                        ],
                      ),
                    ),
                    IconButton(
                      tooltip: 'Kirim peringatan',
                      onPressed: () => _peringatan(b),
                      icon: const Icon(Icons.notification_important_outlined, color: AppTheme.red),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _progress(String label, int v, int total) {
    final f = total == 0 ? 0.0 : v / total;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(children: [Expanded(child: Text(label)), Text('$v / $total', style: const TextStyle(fontWeight: FontWeight.w600))]),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: LinearProgressIndicator(value: f, minHeight: 8, backgroundColor: AppTheme.bg, color: AppTheme.teal),
        ),
      ],
    );
  }
}
