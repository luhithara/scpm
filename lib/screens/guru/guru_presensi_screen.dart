import 'package:flutter/material.dart';
import '../../models/jadwalmodel.dart';
import '../../models/presensimodel.dart';
import '../../models/siswamodel.dart';
import '../../services/api_services.dart';
import '../../services/izin_service.dart';
import '../../services/presensi_service.dart';
import '../../theme/app_theme.dart';
import '../../utils/format.dart';
import '../../widgets/scp_widgets.dart';

class GuruPresensiScreen extends StatefulWidget {
  final JadwalModel jadwal;
  final DateTime tanggal;
  const GuruPresensiScreen({super.key, required this.jadwal, required this.tanggal});

  @override
  State<GuruPresensiScreen> createState() => _GuruPresensiScreenState();
}

class _GuruPresensiScreenState extends State<GuruPresensiScreen> {
  List<SiswaModel> _siswa = [];
  final Map<String, StatusHadir> _status = {};
  final Map<String, String> _ket = {};
  bool _loading = true;
  bool _saving = false;
  bool _sudahAda = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final siswa = await PresensiService.instance.siswaKelas(widget.jadwal.kelas);
      final ada = await PresensiService.instance.sesi(widget.jadwal.id, widget.tanggal);
      final izin = await IzinService.instance.siswaIzinDisetujui(widget.jadwal.kelas, widget.tanggal);
      siswa.sort((a, b) => a.nama.compareTo(b.nama));
      for (final s in siswa) {
        final rec = ada.where((p) => p.siswaId == s.id);
        if (rec.isNotEmpty) {
          _status[s.id] = rec.first.status;
          _ket[s.id] = rec.first.keterangan;
        } else if (izin.contains(s.id)) {
          _status[s.id] = StatusHadir.izin;
          _ket[s.id] = 'Izin disetujui (surat)';
        } else {
          _status[s.id] = StatusHadir.hadir;
          _ket[s.id] = '';
        }
      }
      if (!mounted) return;
      setState(() {
        _siswa = siswa;
        _sudahAda = ada.isNotEmpty;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = pesanError(e);
        _loading = false;
      });
    }
  }

  Future<void> _pilih(SiswaModel s, StatusHadir st) async {
    if (st == StatusHadir.izin) {
      final c = TextEditingController();
      final alasan = await showDialog<String>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text('Izin - ${s.nama}'),
          content: TextField(controller: c, autofocus: true, decoration: const InputDecoration(hintText: 'Keluar untuk... (mis. ke BK, lomba)')),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Batal')),
            FilledButton(onPressed: () => Navigator.pop(ctx, c.text.trim()), child: const Text('OK')),
          ],
        ),
      );
      if (alasan == null) return;
      setState(() {
        _status[s.id] = st;
        _ket[s.id] = alasan.isEmpty ? 'Izin' : 'Izin - Keluar untuk $alasan';
      });
      return;
    }
    setState(() {
      _status[s.id] = st;
      _ket[s.id] = '';
    });
  }

  int _n(StatusHadir s) => _status.values.where((v) => v == s).length;

  Future<void> _simpan() async {
    setState(() => _saving = true);
    try {
      final data = [
        for (final s in _siswa)
          PresensiModel(
            id: '',
            jadwalId: widget.jadwal.id,
            tanggal: widget.tanggal,
            kelas: widget.jadwal.kelas,
            mapel: widget.jadwal.mapel,
            siswaId: s.id,
            siswaNama: s.nama,
            status: _status[s.id] ?? StatusHadir.hadir,
            keterangan: _ket[s.id] ?? '',
          ),
      ];
      await PresensiService.instance.simpanSesi(widget.jadwal, widget.tanggal, data);
      if (!mounted) return;
      showMsg(context, 'Presensi tersimpan');
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      showMsg(context, pesanError(e), error: true);
      setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final j = widget.jadwal;
    return Scaffold(
      appBar: scpAppBar('Presensi', actions: [
        TextButton(
          onPressed: _loading ? null : () => setState(() {
            for (final s in _siswa) {
              _status[s.id] = StatusHadir.hadir;
              _ket[s.id] = '';
            }
          }),
          child: const Text('Semua hadir', style: TextStyle(color: Colors.white)),
        ),
      ]),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? EmptyState(_error!, icon: Icons.error_outline)
              : ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    SCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('${j.kelas} · ${j.mapel}', style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: AppTheme.navy)),
                          Text('${Fmt.tglPanjang(widget.tanggal)} · ${j.jam}', style: const TextStyle(color: AppTheme.grey)),
                          const SizedBox(height: 10),
                          Wrap(spacing: 8, children: [
                            for (final s in StatusHadir.values) StatusChip('${s.label} ${_n(s)}', warnaHadir(s)),
                          ]),
                          if (_sudahAda) ...[
                            const SizedBox(height: 8),
                            const Text('Presensi sudah pernah diisi. Perubahan akan tercatat di riwayat.', style: TextStyle(fontSize: 12, color: AppTheme.grey)),
                          ],
                        ],
                      ),
                    ),
                    for (final s in _siswa)
                      SCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(s.nama, style: const TextStyle(fontWeight: FontWeight.w600)),
                            if ((_ket[s.id] ?? '').isNotEmpty)
                              Padding(
                                padding: const EdgeInsets.only(top: 2),
                                child: Text(_ket[s.id]!, style: const TextStyle(fontSize: 12, color: AppTheme.grey)),
                              ),
                            const SizedBox(height: 6),
                            Wrap(
                              spacing: 6,
                              children: [
                                for (final st in StatusHadir.values)
                                  ChoiceChip(
                                    label: Text(st.label),
                                    selected: _status[s.id] == st,
                                    showCheckmark: false,
                                    selectedColor: warnaHadir(st).withValues(alpha: 0.2),
                                    labelStyle: TextStyle(
                                      color: _status[s.id] == st ? warnaHadir(st) : Colors.black87,
                                      fontWeight: FontWeight.w600,
                                    ),
                                    visualDensity: VisualDensity.compact,
                                    onSelected: (_) => _pilih(s, st),
                                  ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    const SizedBox(height: 70),
                  ],
                ),
      bottomNavigationBar: _loading || _error != null
          ? null
          : SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: FilledButton.icon(
                  onPressed: _saving ? null : _simpan,
                  icon: const Icon(Icons.save),
                  label: Padding(padding: const EdgeInsets.symmetric(vertical: 12), child: Text(_saving ? 'Menyimpan...' : 'Simpan Presensi')),
                ),
              ),
            ),
    );
  }
}
