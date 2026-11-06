import 'package:flutter/material.dart';
import '../../models/izinmodel.dart';
import '../../models/jurnalmodel.dart';
import '../../models/presensimodel.dart';
import '../../services/izin_service.dart';
import '../../services/jadwal_service.dart';
import '../../services/jurnal_service.dart';
import '../../services/presensi_service.dart';
import '../../theme/app_theme.dart';
import '../../utils/format.dart';
import '../../widgets/scp_widgets.dart';

class _RekapData {
  final List<PresensiModel> presensi;
  final List<IzinModel> izin;
  final List<JurnalModel> jurnal;
  _RekapData(this.presensi, this.izin, this.jurnal);
}

class _Agg {
  final String nama;
  final String kelas;
  int hadir = 0;
  int izin = 0;
  int sakit = 0;
  int alpa = 0;
  _Agg(this.nama, this.kelas);
  int get total => hadir + izin + sakit + alpa;
}

/// Rekap presensi, izin, dan jurnal dengan filter periode, kelas, dan pencarian.
class RekapScreen extends StatefulWidget {
  final String? kelasTetap;
  const RekapScreen({super.key, this.kelasTetap});

  @override
  State<RekapScreen> createState() => _RekapScreenState();
}

class _RekapScreenState extends State<RekapScreen> {
  int _hari = 7; // 1 = hari ini, 7 = 7 hari, 30 = 30 hari
  String? _kelas;
  String _q = '';
  List<String> _daftarKelas = [];
  late Future<_RekapData> _future;

  @override
  void initState() {
    super.initState();
    _kelas = widget.kelasTetap;
    _future = _load();
    if (widget.kelasTetap == null) {
      JadwalService.instance.daftarKelas().then((v) {
        if (mounted) setState(() => _daftarKelas = v);
      });
    }
  }

  Future<_RekapData> _load() async {
    final sampai = Fmt.hariIni();
    final dari = sampai.subtract(Duration(days: _hari - 1));
    final p = await PresensiService.instance.rekap(dari: dari, sampai: sampai, kelas: _kelas);
    final i = await IzinService.instance.list(kelas: _kelas, dari: dari, sampai: sampai);
    final j = await JurnalService.instance.list(kelas: _kelas, dari: dari, sampai: sampai);
    return _RekapData(p, i, j);
  }

  void _reload() => setState(() => _future = _load());

  bool _cocok(String teks) => _q.trim().isEmpty || teks.toLowerCase().contains(_q.trim().toLowerCase());

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: Row(
              children: [
                for (final p in const [[1, 'Hari ini'], [7, '7 hari'], [30, '30 hari']])
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text(p[1] as String),
                      selected: _hari == p[0],
                      onSelected: (_) {
                        _hari = p[0] as int;
                        _reload();
                      },
                    ),
                  ),
                if (widget.kelasTetap == null)
                  Expanded(
                    child: DropBox<String>(
                      value: _kelas,
                      hint: 'Semua kelas',
                      items: [
                        const DropdownMenuItem<String>(value: null, child: Text('Semua kelas')),
                        for (final k in _daftarKelas) DropdownMenuItem<String>(value: k, child: Text(k)),
                      ],
                      onChanged: (v) {
                        _kelas = v;
                        _reload();
                      },
                    ),
                  ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
            child: TextField(
              decoration: inputDeco('Cari siswa / mapel / guru...', icon: Icons.search),
              onChanged: (v) => setState(() => _q = v),
            ),
          ),
          const TabBar(
            labelColor: AppTheme.navy,
            indicatorColor: AppTheme.navy,
            tabs: [Tab(text: 'Presensi'), Tab(text: 'Izin'), Tab(text: 'Jurnal')],
          ),
          Expanded(
            child: FutureView<_RekapData>(
              future: _future,
              onRetry: _reload,
              builder: (c, d) => TabBarView(children: [_tabPresensi(d), _tabIzin(d), _tabJurnal(d)]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _tabPresensi(_RekapData d) {
    final map = <String, _Agg>{};
    for (final p in d.presensi) {
      if (!_cocok('${p.siswaNama} ${p.mapel}')) continue;
      final a = map.putIfAbsent(p.siswaId, () => _Agg(p.siswaNama, p.kelas));
      switch (p.status) {
        case StatusHadir.hadir:
          a.hadir++;
        case StatusHadir.izin:
          a.izin++;
        case StatusHadir.sakit:
          a.sakit++;
        case StatusHadir.alpa:
          a.alpa++;
      }
    }
    final rows = map.values.toList()..sort((a, b) => a.nama.compareTo(b.nama));
    if (rows.isEmpty) return const EmptyState('Tidak ada data presensi pada periode ini');
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: rows.length,
      itemBuilder: (c, i) {
        final a = rows[i];
        final persen = a.total == 0 ? 0 : (a.hadir * 100 / a.total).round();
        return SCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(child: Text(a.nama, style: const TextStyle(fontWeight: FontWeight.bold))),
                  Text('$persen%', style: TextStyle(fontWeight: FontWeight.bold, color: persen >= 80 ? AppTheme.teal : AppTheme.red)),
                ],
              ),
              Text(a.kelas, style: const TextStyle(color: AppTheme.grey, fontSize: 12)),
              const SizedBox(height: 8),
              Wrap(spacing: 8, children: [
                StatusChip('Hadir ${a.hadir}', AppTheme.teal),
                StatusChip('Izin ${a.izin}', AppTheme.blue),
                StatusChip('Sakit ${a.sakit}', AppTheme.orange),
                StatusChip('Alpa ${a.alpa}', AppTheme.red),
              ]),
            ],
          ),
        );
      },
    );
  }

  Widget _tabIzin(_RekapData d) {
    final rows = d.izin.where((i) => _cocok('${i.siswaNama} ${i.alasan}')).toList();
    if (rows.isEmpty) return const EmptyState('Tidak ada data izin pada periode ini');
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: rows.length,
      itemBuilder: (c, i) {
        final z = rows[i];
        return SCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(child: Text(z.siswaNama, style: const TextStyle(fontWeight: FontWeight.bold))),
                  StatusChip(z.status.label, warnaIzin(z.status)),
                ],
              ),
              Text('${z.kelas} · ${z.jenis} · ${Fmt.tgl(z.tanggal)}', style: const TextStyle(color: AppTheme.grey, fontSize: 12)),
              const SizedBox(height: 6),
              Text(z.alasan),
              if (z.diprosesOleh != null) ...[
                const SizedBox(height: 6),
                Text('Diproses: ${z.diprosesOleh}', style: const TextStyle(fontSize: 12, color: AppTheme.grey)),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _tabJurnal(_RekapData d) {
    final rows = d.jurnal.where((j) => _cocok('${j.mapel} ${j.guruNama} ${j.materi}')).toList();
    if (rows.isEmpty) return const EmptyState('Tidak ada jurnal pada periode ini');
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: rows.length,
      itemBuilder: (c, i) {
        final j = rows[i];
        return SCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('${j.mapel} · ${j.kelas}', style: const TextStyle(fontWeight: FontWeight.bold)),
              Text('${j.guruNama} · ${Fmt.tgl(j.tanggal)}', style: const TextStyle(color: AppTheme.grey, fontSize: 12)),
              const SizedBox(height: 6),
              Text(j.materi),
            ],
          ),
        );
      },
    );
  }
}
