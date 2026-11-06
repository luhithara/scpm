import 'package:flutter/material.dart';
import '../../models/izinmodel.dart';
import '../../services/api_services.dart';
import '../../services/izin_service.dart';
import '../../services/jadwal_service.dart';
import '../../theme/app_theme.dart';
import '../../utils/format.dart';
import '../../widgets/scp_widgets.dart';

/// Antrian izin untuk BK (semua kelas) dan Wali Kelas (kelas sendiri).
/// Siapa pun yang memproses lebih dulu, hasilnya berlaku.
class IzinReviewScreen extends StatefulWidget {
  final String? kelasTetap;
  const IzinReviewScreen({super.key, this.kelasTetap});

  @override
  State<IzinReviewScreen> createState() => _IzinReviewScreenState();
}

class _IzinReviewScreenState extends State<IzinReviewScreen> {
  StatusIzin? _status = StatusIzin.menunggu;
  String? _kelas;
  String _q = '';
  List<String> _daftarKelas = [];
  late Future<List<IzinModel>> _future;

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

  Future<List<IzinModel>> _load() => IzinService.instance.list(kelas: _kelas, status: _status);
  void _reload() => setState(() => _future = _load());

  Future<void> _proses(IzinModel z, bool setuju) async {
    String? catatan;
    if (!setuju) {
      final c = TextEditingController();
      catatan = await showDialog<String>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Tolak izin'),
          content: TextField(controller: c, autofocus: true, decoration: const InputDecoration(hintText: 'Alasan penolakan (opsional)')),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Batal')),
            FilledButton(
              style: FilledButton.styleFrom(backgroundColor: AppTheme.red),
              onPressed: () => Navigator.pop(ctx, c.text.trim()),
              child: const Text('Tolak'),
            ),
          ],
        ),
      );
      if (catatan == null) return;
    } else {
      final ya = await konfirmasi(context, 'Setujui izin?', '${z.siswaNama} · ${z.jenis} ${Fmt.tgl(z.tanggal)}', ya: 'Setujui');
      if (!ya) return;
    }
    if (!mounted) return;
    try {
      await IzinService.instance.proses(z.id, setuju: setuju, catatan: catatan);
      if (!mounted) return;
      showMsg(context, setuju ? 'Izin disetujui' : 'Izin ditolak');
    } catch (e) {
      if (!mounted) return;
      showMsg(context, pesanError(e), error: true);
    }
    _reload();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: 52,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            children: [
              Padding(
                padding: const EdgeInsets.only(right: 8),
                child: ChoiceChip(label: const Text('Semua'), selected: _status == null, onSelected: (_) {
                  _status = null;
                  _reload();
                }),
              ),
              for (final s in StatusIzin.values)
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(label: Text(s.label), selected: _status == s, onSelected: (_) {
                    _status = s;
                    _reload();
                  }),
                ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  decoration: inputDeco('Cari nama siswa...', icon: Icons.search),
                  onChanged: (v) => setState(() => _q = v),
                ),
              ),
              if (widget.kelasTetap == null) ...[
                const SizedBox(width: 10),
                SizedBox(
                  width: 130,
                  child: DropBox<String>(
                    value: _kelas,
                    hint: 'Kelas',
                    items: [
                      const DropdownMenuItem<String>(value: null, child: Text('Semua')),
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
          child: FutureView<List<IzinModel>>(
            future: _future,
            onRetry: _reload,
            builder: (c, all) {
              final list = all.where((z) => _q.trim().isEmpty || z.siswaNama.toLowerCase().contains(_q.trim().toLowerCase())).toList();
              if (list.isEmpty) return const EmptyState('Tidak ada pengajuan izin', icon: Icons.mark_email_read_outlined);
              return RefreshIndicator(
                onRefresh: () async => _reload(),
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: list.length,
                  itemBuilder: (c, i) => _kartu(list[i]),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _kartu(IzinModel z) {
    return SCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Expanded(child: Text(z.siswaNama, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15))),
            StatusChip(z.status.label, warnaIzin(z.status)),
          ]),
          Text('${z.kelas} · ${z.jenis} · ${Fmt.tgl(z.tanggal)}', style: const TextStyle(color: AppTheme.grey, fontSize: 12)),
          Text('Diajukan ${z.diajukanOleh}', style: const TextStyle(color: AppTheme.grey, fontSize: 12)),
          const SizedBox(height: 8),
          Text(z.alasan),
          if ((z.buktiPath ?? '').isNotEmpty) ...[const SizedBox(height: 8), FotoView(z.buktiPath!, height: 140)],
          if (z.diprosesOleh != null) ...[
            const SizedBox(height: 8),
            Text('Diproses oleh ${z.diprosesOleh}', style: const TextStyle(fontSize: 12, color: AppTheme.grey)),
            if (z.catatan != null) Text('Catatan: ${z.catatan}', style: const TextStyle(fontSize: 12, color: AppTheme.red)),
          ],
          if (z.status == StatusIzin.menunggu) ...[
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => _proses(z, false),
                    style: OutlinedButton.styleFrom(foregroundColor: AppTheme.red),
                    child: const Text('Tolak'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(child: FilledButton(onPressed: () => _proses(z, true), child: const Text('Setujui'))),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
