import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import '../../models/gurumodel.dart';
import '../../models/jadwalmodel.dart';
import '../../services/api_services.dart';
import '../../services/jadwal_service.dart';
import '../../theme/app_theme.dart';
import '../../utils/blokputaran.dart';
import '../../utils/format.dart';
import '../../widgets/scp_widgets.dart';

class _WData {
  final List<JadwalModel> jadwal;
  final List<String> kelas;
  final bool terkunci;
  _WData(this.jadwal, this.kelas, this.terkunci);
}

class WakaJadwalScreen extends StatefulWidget {
  const WakaJadwalScreen({super.key});

  @override
  State<WakaJadwalScreen> createState() => _WakaJadwalScreenState();
}

class _WakaJadwalScreenState extends State<WakaJadwalScreen> {
  String? _kelas;
  late Future<_WData> _future;

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  Future<_WData> _load() async {
    final kelas = await JadwalService.instance.daftarKelas();
    _kelas ??= kelas.isEmpty ? null : kelas.first;
    final j = await JadwalService.instance.list(kelas: _kelas);
    final k = await JadwalService.instance.terkunci();
    return _WData(j, kelas, k);
  }

  void _reload() => setState(() => _future = _load());

  Future<void> _kunci(bool v) async {
    final ya = await konfirmasi(
      context,
      v ? 'Kunci jadwal?' : 'Buka kunci jadwal?',
      v ? 'Guru tidak dapat menambah/mengubah jadwal sampai dibuka kembali.' : 'Guru dapat kembali mengubah jadwal.',
    );
    if (!ya || !mounted) return;
    try {
      await JadwalService.instance.setKunci(v);
      if (mounted) _reload();
    } catch (e) {
      if (mounted) showMsg(context, pesanError(e), error: true);
    }
  }

  Future<void> _ruangan(JadwalModel j) async {
    final c = TextEditingController(text: j.ruangan ?? '');
    final v = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Ruangan · ${j.mapel}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${j.kelas} · ${j.namaHari} ${j.jam}\n${j.guruNama}', style: const TextStyle(color: AppTheme.grey)),
            const SizedBox(height: 12),
            TextField(controller: c, autofocus: true, decoration: const InputDecoration(hintText: 'Mis. Lab RPL 1')),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Batal')),
          FilledButton(onPressed: () => Navigator.pop(ctx, c.text.trim()), child: const Text('Simpan')),
        ],
      ),
    );
    if (v == null || v.isEmpty || !mounted) return;
    try {
      await JadwalService.instance.setRuangan(j.id, v);
      if (!mounted) return;
      showMsg(context, 'Ruangan diperbarui');
      _reload();
    } catch (e) {
      if (mounted) showMsg(context, pesanError(e), error: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureView<_WData>(
      future: _future,
      onRetry: _reload,
      builder: (c, d) => RefreshIndicator(
        onRefresh: () async => _reload(),
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            SCard(
              padding: const EdgeInsets.symmetric(horizontal: 6),
              child: SwitchListTile(
                value: d.terkunci,
                onChanged: _kunci,
                title: const Text('Kunci jadwal', style: TextStyle(fontWeight: FontWeight.w600)),
                subtitle: Text(d.terkunci ? 'Guru tidak bisa mengubah jadwal' : 'Guru masih bisa input/ubah jadwal'),
              ),
            ),
            OutlinedButton.icon(
              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const WakaSkScreen())),
              icon: const Icon(Icons.upload_file),
              label: const Text('SK Penugasan Guru'),
            ),
            const SizedBox(height: 12),
            DropBox<String>(
              value: _kelas,
              hint: 'Pilih kelas',
              items: [for (final k in d.kelas) DropdownMenuItem<String>(value: k, child: Text(k))],
              onChanged: (v) {
                _kelas = v;
                _reload();
              },
            ),
            if (_kelas != null) ...[
              const SizedBox(height: 10),
              Text('${_kelas!} masuk di Putaran ${BlokPutaran.putaranKelas(_kelas!)}', style: const TextStyle(color: AppTheme.grey, fontSize: 12)),
            ],
            if (d.jadwal.isEmpty) const EmptyState('Belum ada jadwal untuk kelas ini. Guru menginput jadwalnya setelah SK diunggah.', icon: Icons.calendar_month_outlined),
            for (var h = 1; h <= 5; h++)
              if (d.jadwal.any((j) => j.hari == h)) ...[
                SectionTitle(Fmt.namaHari[h]),
                for (final j in d.jadwal.where((j) => j.hari == h))
                  SCard(
                    onTap: () => _ruangan(j),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('${j.jam} · ${j.mapel}', style: const TextStyle(fontWeight: FontWeight.bold)),
                              Text(j.guruNama, style: const TextStyle(color: AppTheme.grey, fontSize: 13)),
                            ],
                          ),
                        ),
                        j.ruangan == null ? const StatusChip('Atur ruangan', AppTheme.orange) : StatusChip(j.ruangan!, AppTheme.teal),
                      ],
                    ),
                  ),
              ],
          ],
        ),
      ),
    );
  }
}

class WakaSkScreen extends StatefulWidget {
  const WakaSkScreen({super.key});

  @override
  State<WakaSkScreen> createState() => _WakaSkScreenState();
}

class _WakaSkScreenState extends State<WakaSkScreen> {
  late Future<List<GuruModel>> _future;

  @override
  void initState() {
    super.initState();
    _future = JadwalService.instance.daftarGuru();
  }

  void _reload() => setState(() => _future = JadwalService.instance.daftarGuru());

  Future<void> _unggah(GuruModel g) async {
    try {
      final r = await FilePicker.platform.pickFiles(type: FileType.custom, allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png']);
      if (r == null || r.files.isEmpty) return;
      final f = r.files.single;
      await JadwalService.instance.unggahSk(g.id, f.name, f.path ?? '');
      if (!mounted) return;
      showMsg(context, 'SK ${g.nama} diunggah');
      _reload();
    } catch (e) {
      if (mounted) showMsg(context, pesanError(e), error: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: scpAppBar('SK Penugasan Guru'),
      body: FutureView<List<GuruModel>>(
        future: _future,
        onRetry: _reload,
        builder: (c, list) => ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: list.length,
          itemBuilder: (c, i) {
            final g = list[i];
            return SCard(
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(g.nama, style: const TextStyle(fontWeight: FontWeight.bold)),
                        Text(g.mapel, style: const TextStyle(color: AppTheme.grey, fontSize: 13)),
                        const SizedBox(height: 4),
                        Text(g.namaSk ?? 'Belum ada SK', style: TextStyle(fontSize: 12, color: g.namaSk == null ? AppTheme.orange : AppTheme.teal)),
                      ],
                    ),
                  ),
                  OutlinedButton(onPressed: () => _unggah(g), child: Text(g.namaSk == null ? 'Unggah' : 'Ganti')),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
