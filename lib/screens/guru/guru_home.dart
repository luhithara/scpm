import 'package:flutter/material.dart';
import '../../models/jadwalmodel.dart';
import '../../services/auth_service.dart';
import '../../services/jadwal_service.dart';
import '../../services/jurnal_service.dart';
import '../../services/notif_service.dart';
import '../../services/presensi_service.dart';
import '../../theme/app_theme.dart';
import '../../utils/format.dart';
import '../../widgets/scp_widgets.dart';
import 'guru_jurnal_screen.dart';
import 'guru_presensi_screen.dart';

class _GuruData {
  final List<JadwalModel> sesi;
  final Map<String, bool> presensiOk;
  final Map<String, bool> jurnalOk;
  final List<JadwalModel> belumJurnal;
  _GuruData(this.sesi, this.presensiOk, this.jurnalOk, this.belumJurnal);
}

class GuruHome extends StatefulWidget {
  const GuruHome({super.key});

  @override
  State<GuruHome> createState() => _GuruHomeState();
}

class _GuruHomeState extends State<GuruHome> {
  final DateTime _tgl = Fmt.hariIni();
  late Future<_GuruData> _future;

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  Future<_GuruData> _load() async {
    final u = AuthService.instance.current!;
    final sesi = await JadwalService.instance.sesiHariIni(guruId: u.id, tgl: _tgl);
    final p = <String, bool>{};
    final j = <String, bool>{};
    for (final s in sesi) {
      p[s.id] = (await PresensiService.instance.sesi(s.id, _tgl)).isNotEmpty;
      j[s.id] = await JurnalService.instance.sesi(s.id, _tgl) != null;
    }
    final belum = await NotifService.instance.jurnalBelumDiisi();
    return _GuruData(sesi, p, j, belum);
  }

  void _reload() => setState(() => _future = _load());

  Future<void> _buka(Widget w) async {
    await Navigator.push(context, MaterialPageRoute(builder: (_) => w));
    if (mounted) _reload();
  }

  @override
  Widget build(BuildContext context) {
    final u = AuthService.instance.current!;
    return FutureView<_GuruData>(
      future: _future,
      onRetry: _reload,
      builder: (c, d) => RefreshIndicator(
        onRefresh: () async => _reload(),
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text('Halo, ${u.nama}', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppTheme.navy)),
            const SizedBox(height: 4),
            Text(u.mapel ?? '', style: const TextStyle(color: AppTheme.grey)),
            const SizedBox(height: 14),
            const PutaranBanner(),
            if (d.belumJurnal.isNotEmpty)
              InfoBanner(
                'Jurnal belum diisi: ${d.belumJurnal.map((j) => '${j.kelas} (${j.jam})').join(', ')}',
                icon: Icons.warning_amber_rounded,
                color: AppTheme.orange,
              ),
            SectionTitle('Jadwal hari ini · ${Fmt.tglPanjang(_tgl)}'),
            if (d.sesi.isEmpty)
              EmptyState(_tgl.weekday > 5 ? 'Akhir pekan, tidak ada jadwal mengajar' : 'Tidak ada jadwal mengajar hari ini', icon: Icons.free_breakfast_outlined),
            for (final j in d.sesi)
              SCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.schedule, size: 18, color: AppTheme.grey),
                        const SizedBox(width: 6),
                        Text(j.jam, style: const TextStyle(fontWeight: FontWeight.w600)),
                        const Spacer(),
                        Text(j.ruangan ?? 'Ruangan belum diatur', style: TextStyle(color: j.ruangan == null ? AppTheme.orange : AppTheme.grey, fontSize: 12)),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text('${j.kelas} · ${j.mapel}', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.navy)),
                    const SizedBox(height: 8),
                    Wrap(spacing: 8, children: [
                      StatusChip(d.presensiOk[j.id] == true ? 'Presensi ✓' : 'Presensi belum', d.presensiOk[j.id] == true ? AppTheme.teal : AppTheme.orange),
                      StatusChip(d.jurnalOk[j.id] == true ? 'Jurnal ✓' : 'Jurnal belum', d.jurnalOk[j.id] == true ? AppTheme.teal : AppTheme.orange),
                    ]),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () => _buka(GuruPresensiScreen(jadwal: j, tanggal: _tgl)),
                            icon: const Icon(Icons.fact_check_outlined),
                            label: const Text('Presensi'),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: FilledButton.icon(
                            onPressed: () => _buka(GuruJurnalForm(jadwal: j, tanggal: _tgl)),
                            icon: const Icon(Icons.edit_note),
                            label: const Text('Jurnal'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
