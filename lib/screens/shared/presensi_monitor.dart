import 'package:flutter/material.dart';
import '../../models/jadwalmodel.dart';
import '../../models/presensimodel.dart';
import '../../services/jadwal_service.dart';
import '../../services/presensi_service.dart';
import '../../theme/app_theme.dart';
import '../../utils/blokputaran.dart';
import '../../utils/format.dart';
import '../../widgets/scp_widgets.dart';

class _MonData {
  final List<JadwalModel> sesi;
  final List<PresensiModel> presensi;
  _MonData(this.sesi, this.presensi);
}

/// Monitoring presensi (hanya lihat). Dipakai Waka (semua kelas) dan Wali Kelas (kelas sendiri).
class PresensiMonitor extends StatefulWidget {
  final String? kelasTetap;
  const PresensiMonitor({super.key, this.kelasTetap});

  @override
  State<PresensiMonitor> createState() => _PresensiMonitorState();
}

class _PresensiMonitorState extends State<PresensiMonitor> {
  DateTime _tgl = Fmt.hariIni();
  String? _kelas;
  List<String> _daftarKelas = [];
  late Future<_MonData> _future;

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

  Future<_MonData> _load() async {
    final sesi = _tgl.weekday > 5
        ? <JadwalModel>[]
        : (await JadwalService.instance.list(kelas: _kelas, hari: _tgl.weekday))
            .where((j) => BlokPutaran.kelasAktif(j.kelas, _tgl))
            .toList();
    final p = await PresensiService.instance.rekap(dari: _tgl, sampai: _tgl, kelas: _kelas);
    return _MonData(sesi, p);
  }

  void _reload() => setState(() => _future = _load());

  Future<void> _pilihTanggal() async {
    final d = await showDatePicker(
      context: context,
      initialDate: _tgl,
      firstDate: DateTime(2025),
      lastDate: DateTime(2030),
    );
    if (d != null) {
      _tgl = Fmt.tanggalSaja(d);
      _reload();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _pilihTanggal,
                  icon: const Icon(Icons.event),
                  label: Text(Fmt.tglPanjang(_tgl), overflow: TextOverflow.ellipsis),
                ),
              ),
              if (widget.kelasTetap == null) ...[
                const SizedBox(width: 10),
                SizedBox(
                  width: 140,
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
            ],
          ),
        ),
        Expanded(
          child: FutureView<_MonData>(
            future: _future,
            onRetry: _reload,
            builder: (c, d) {
              if (d.sesi.isEmpty) {
                return EmptyState(
                  _tgl.weekday > 5 ? 'Akhir pekan, tidak ada pembelajaran' : 'Tidak ada sesi pada tanggal ini (${BlokPutaran.info(_tgl)})',
                  icon: Icons.event_busy,
                );
              }
              return RefreshIndicator(
                onRefresh: () async => _reload(),
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: d.sesi.length,
                  itemBuilder: (c, i) {
                    final j = d.sesi[i];
                    final rec = d.presensi.where((p) => p.jadwalId == j.id).toList()
                      ..sort((a, b) => a.siswaNama.compareTo(b.siswaNama));
                    int n(StatusHadir s) => rec.where((p) => p.status == s).length;
                    return SCard(
                      padding: EdgeInsets.zero,
                      child: ExpansionTile(
                        shape: const Border(),
                        collapsedShape: const Border(),
                        title: Text('${j.jam} · ${j.mapel}', style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text('${j.kelas} · ${j.guruNama}'),
                        trailing: rec.isEmpty
                            ? const StatusChip('Belum diisi', AppTheme.orange)
                            : Text('H${n(StatusHadir.hadir)} I${n(StatusHadir.izin)} S${n(StatusHadir.sakit)} A${n(StatusHadir.alpa)}',
                                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                        children: [
                          if (rec.isEmpty)
                            const Padding(padding: EdgeInsets.all(14), child: Text('Guru belum mengisi presensi sesi ini.')),
                          for (final p in rec)
                            ListTile(
                              dense: true,
                              title: Text(p.siswaNama),
                              subtitle: p.keterangan.isEmpty ? null : Text(p.keterangan),
                              trailing: StatusChip(p.status.label, warnaHadir(p.status)),
                            ),
                        ],
                      ),
                    );
                  },
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
