import 'package:flutter/material.dart';
import '../../models/jadwalmodel.dart';
import '../../services/api_services.dart';
import '../../services/auth_service.dart';
import '../../services/jadwal_service.dart';
import '../../theme/app_theme.dart';
import '../../utils/format.dart';
import '../../widgets/scp_widgets.dart';

class _JData {
  final List<JadwalModel> jadwal;
  final bool terkunci;
  final List<String> kelas;
  _JData(this.jadwal, this.terkunci, this.kelas);
}

/// Guru menginput jadwal mengajarnya sendiri. Ruangan ditentukan Waka.
class GuruJadwalScreen extends StatefulWidget {
  const GuruJadwalScreen({super.key});

  @override
  State<GuruJadwalScreen> createState() => _GuruJadwalScreenState();
}

class _GuruJadwalScreenState extends State<GuruJadwalScreen> {
  late Future<_JData> _future;
  bool _terkunci = false;
  List<String> _kelas = [];

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  Future<_JData> _load() async {
    final u = AuthService.instance.current!;
    final j = await JadwalService.instance.list(guruId: u.id);
    final k = await JadwalService.instance.terkunci();
    final kelas = await JadwalService.instance.daftarKelas();
    _terkunci = k;
    _kelas = kelas;
    return _JData(j, k, kelas);
  }

  void _reload() => setState(() => _future = _load());

  Future<void> _form([JadwalModel? edit]) async {
    final hasil = await showModalBottomSheet<JadwalModel>(
      context: context,
      isScrollControlled: true,
      builder: (c) => _JadwalForm(kelas: _kelas, edit: edit),
    );
    if (hasil == null || !mounted) return;
    try {
      if (edit == null) {
        await JadwalService.instance.tambah(hasil);
      } else {
        await JadwalService.instance.ubah(hasil);
      }
      if (!mounted) return;
      showMsg(context, 'Jadwal tersimpan');
      _reload();
    } catch (e) {
      if (!mounted) return;
      showMsg(context, pesanError(e), error: true);
    }
  }

  Future<void> _hapus(JadwalModel j) async {
    final ya = await konfirmasi(context, 'Hapus jadwal?', '${j.kelas} · ${j.mapel} (${j.namaHari} ${j.jam})', ya: 'Hapus');
    if (!ya || !mounted) return;
    try {
      await JadwalService.instance.hapus(j.id);
      if (!mounted) return;
      _reload();
    } catch (e) {
      if (!mounted) return;
      showMsg(context, pesanError(e), error: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      floatingActionButton: FutureBuilder<_JData>(
        future: _future,
        builder: (c, s) => (s.hasData && !s.data!.terkunci)
            ? FloatingActionButton.extended(
                onPressed: () => _form(),
                backgroundColor: AppTheme.navy,
                foregroundColor: Colors.white,
                icon: const Icon(Icons.add),
                label: const Text('Tambah Jadwal'),
              )
            : const SizedBox.shrink(),
      ),
      body: FutureView<_JData>(
        future: _future,
        onRetry: _reload,
        builder: (c, d) {
          return RefreshIndicator(
            onRefresh: () async => _reload(),
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 90),
              children: [
                if (d.terkunci)
                  const InfoBanner('Jadwal dikunci oleh Waka Kurikulum. Anda tidak dapat menambah atau mengubah.', icon: Icons.lock_outline, color: AppTheme.orange),
                if (d.jadwal.isEmpty) const EmptyState('Belum ada jadwal. Tambahkan jadwal sesuai SK penugasan.', icon: Icons.calendar_month_outlined),
                for (var h = 1; h <= 5; h++)
                  if (d.jadwal.any((j) => j.hari == h)) ...[
                    SectionTitle(Fmt.namaHari[h]),
                    for (final j in d.jadwal.where((j) => j.hari == h))
                      SCard(
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('${j.jam} · ${j.kelas}', style: const TextStyle(fontWeight: FontWeight.bold)),
                                  Text(j.mapel, style: const TextStyle(color: AppTheme.grey)),
                                  const SizedBox(height: 4),
                                  Text(j.ruangan ?? 'Ruangan belum ditentukan Waka',
                                      style: TextStyle(fontSize: 12, color: j.ruangan == null ? AppTheme.orange : AppTheme.teal)),
                                ],
                              ),
                            ),
                            if (!d.terkunci)
                              PopupMenuButton<String>(
                                onSelected: (v) => v == 'ubah' ? _form(j) : _hapus(j),
                                itemBuilder: (c) => const [
                                  PopupMenuItem(value: 'ubah', child: Text('Ubah')),
                                  PopupMenuItem(value: 'hapus', child: Text('Hapus')),
                                ],
                              ),
                          ],
                        ),
                      ),
                  ],
              ],
            ),
          );
        },
      ),
    );
  }
}

class _JadwalForm extends StatefulWidget {
  final List<String> kelas;
  final JadwalModel? edit;
  const _JadwalForm({required this.kelas, this.edit});

  @override
  State<_JadwalForm> createState() => _JadwalFormState();
}

class _JadwalFormState extends State<_JadwalForm> {
  String? _kelas;
  int _hari = 1;
  String _mulai = '07:00';
  String _selesai = '08:30';

  @override
  void initState() {
    super.initState();
    final e = widget.edit;
    if (e != null) {
      _kelas = e.kelas;
      _hari = e.hari;
      _mulai = e.jamMulai;
      _selesai = e.jamSelesai;
    }
  }

  Future<void> _pilihJam(bool mulai) async {
    final cur = Fmt.menit(mulai ? _mulai : _selesai);
    final t = await showTimePicker(context: context, initialTime: TimeOfDay(hour: cur ~/ 60, minute: cur % 60));
    if (t == null) return;
    setState(() {
      final s = '${Fmt.dua(t.hour)}:${Fmt.dua(t.minute)}';
      if (mulai) {
        _mulai = s;
      } else {
        _selesai = s;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final u = AuthService.instance.current!;
    return Padding(
      padding: EdgeInsets.fromLTRB(20, 20, 20, 20 + MediaQuery.of(context).viewInsets.bottom),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(widget.edit == null ? 'Tambah Jadwal' : 'Ubah Jadwal', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 14),
          DropBox<String>(
            value: _kelas,
            hint: 'Pilih kelas',
            items: [for (final k in widget.kelas) DropdownMenuItem<String>(value: k, child: Text(k))],
            onChanged: (v) => setState(() => _kelas = v),
          ),
          const SizedBox(height: 10),
          DropBox<int>(
            value: _hari,
            hint: 'Hari',
            items: [for (var h = 1; h <= 5; h++) DropdownMenuItem<int>(value: h, child: Text(Fmt.namaHari[h]))],
            onChanged: (v) => setState(() => _hari = v ?? 1),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(child: OutlinedButton(onPressed: () => _pilihJam(true), child: Text('Mulai $_mulai'))),
              const SizedBox(width: 10),
              Expanded(child: OutlinedButton(onPressed: () => _pilihJam(false), child: Text('Selesai $_selesai'))),
            ],
          ),
          const SizedBox(height: 10),
          Text('Mata pelajaran: ${u.mapel ?? '-'}', style: const TextStyle(color: AppTheme.grey)),
          const Text('Ruangan ditentukan oleh Waka Kurikulum.', style: TextStyle(color: AppTheme.grey, fontSize: 12)),
          const SizedBox(height: 16),
          FilledButton(
            onPressed: () {
              if (_kelas == null) {
                showMsg(context, 'Pilih kelas terlebih dahulu', error: true);
                return;
              }
              Navigator.pop(
                context,
                JadwalModel(
                  id: widget.edit?.id ?? '',
                  kelas: _kelas!,
                  hari: _hari,
                  jamMulai: _mulai,
                  jamSelesai: _selesai,
                  mapel: u.mapel ?? '',
                  guruId: u.id,
                  guruNama: u.nama,
                  ruangan: widget.edit?.ruangan,
                ),
              );
            },
            child: const Padding(padding: EdgeInsets.symmetric(vertical: 12), child: Text('Simpan')),
          ),
        ],
      ),
    );
  }
}
