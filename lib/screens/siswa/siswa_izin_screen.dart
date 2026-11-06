import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../models/izinmodel.dart';
import '../../services/api_services.dart';
import '../../services/auth_service.dart';
import '../../services/izin_service.dart';
import '../../theme/app_theme.dart';
import '../../utils/format.dart';
import '../../widgets/scp_widgets.dart';

/// Daftar izin + tombol ajukan. Dipakai Siswa dan Orang Tua.
class SiswaIzinScreen extends StatefulWidget {
  const SiswaIzinScreen({super.key});

  @override
  State<SiswaIzinScreen> createState() => _SiswaIzinScreenState();
}

class _SiswaIzinScreenState extends State<SiswaIzinScreen> {
  late Future<List<IzinModel>> _future;

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  Future<List<IzinModel>> _load() => IzinService.instance.list(siswaId: AuthService.instance.current!.id);
  void _reload() => setState(() => _future = _load());

  Future<void> _ajukan() async {
    final ok = await Navigator.push<bool>(context, MaterialPageRoute(builder: (_) => const IzinFormScreen()));
    if (ok == true && mounted) _reload();
  }

  void _detail(IzinModel z) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (c) => SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(children: [
                Expanded(child: Text('${z.jenis} · ${Fmt.tgl(z.tanggal)}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold))),
                StatusChip(z.status.label, warnaIzin(z.status)),
              ]),
              const SizedBox(height: 8),
              Text('Diajukan ${z.diajukanOleh} · ${Fmt.tglJam(z.waktuAjuan)}', style: const TextStyle(color: AppTheme.grey, fontSize: 12)),
              const SizedBox(height: 12),
              Text(z.alasan),
              const SizedBox(height: 12),
              FotoView(z.buktiPath ?? ''),
              if (z.diprosesOleh != null) ...[
                const SizedBox(height: 12),
                Text('Diproses oleh ${z.diprosesOleh}${z.waktuProses == null ? '' : ' · ${Fmt.tglJam(z.waktuProses!)}'}'),
              ],
              if (z.catatan != null) ...[
                const SizedBox(height: 6),
                Text('Catatan: ${z.catatan}', style: const TextStyle(color: AppTheme.red)),
              ],
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _ajukan,
        backgroundColor: AppTheme.navy,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('Ajukan Izin'),
      ),
      body: FutureView<List<IzinModel>>(
        future: _future,
        onRetry: _reload,
        builder: (c, list) {
          if (list.isEmpty) return const EmptyState('Belum ada pengajuan izin', icon: Icons.mail_outline);
          return RefreshIndicator(
            onRefresh: () async => _reload(),
            child: ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 90),
              itemCount: list.length,
              itemBuilder: (c, i) {
                final z = list[i];
                return SCard(
                  onTap: () => _detail(z),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(children: [
                        Expanded(child: Text('${z.jenis} · ${Fmt.tgl(z.tanggal)}', style: const TextStyle(fontWeight: FontWeight.bold))),
                        StatusChip(z.status.label, warnaIzin(z.status)),
                      ]),
                      const SizedBox(height: 6),
                      Text(z.alasan, maxLines: 2, overflow: TextOverflow.ellipsis),
                      if (z.diprosesOleh != null) ...[
                        const SizedBox(height: 6),
                        Text('Oleh ${z.diprosesOleh}', style: const TextStyle(fontSize: 12, color: AppTheme.grey)),
                      ],
                    ],
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}

class IzinFormScreen extends StatefulWidget {
  const IzinFormScreen({super.key});

  @override
  State<IzinFormScreen> createState() => _IzinFormScreenState();
}

class _IzinFormScreenState extends State<IzinFormScreen> {
  DateTime _tgl = Fmt.hariIni();
  String _jenis = 'Izin';
  final _alasan = TextEditingController();
  String? _bukti;
  String? _buktiNama;
  bool _saving = false;

  @override
  void dispose() {
    _alasan.dispose();
    super.dispose();
  }

  Future<void> _pilihTanggal() async {
    final d = await showDatePicker(
      context: context,
      initialDate: _tgl,
      firstDate: Fmt.hariIni(),
      lastDate: Fmt.hariIni().add(const Duration(days: 60)),
    );
    if (d != null) setState(() => _tgl = Fmt.tanggalSaja(d));
  }

  Future<void> _ambil(ImageSource src) async {
    try {
      final x = await ImagePicker().pickImage(source: src, imageQuality: 70, maxWidth: 1600);
      if (x != null && mounted) {
        setState(() {
          _bukti = x.path;
          _buktiNama = x.name;
        });
      }
    } catch (_) {
      if (mounted) showMsg(context, 'Tidak dapat mengambil gambar', error: true);
    }
  }

  void _pilihSumber() {
    showModalBottomSheet(
      context: context,
      builder: (c) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_camera_outlined),
              title: const Text('Kamera'),
              onTap: () {
                Navigator.pop(c);
                _ambil(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library_outlined),
              title: const Text('Galeri'),
              onTap: () {
                Navigator.pop(c);
                _ambil(ImageSource.gallery);
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _kirim() async {
    if (_alasan.text.trim().isEmpty) {
      showMsg(context, 'Alasan wajib diisi', error: true);
      return;
    }
    if (_bukti == null) {
      showMsg(context, 'Lampirkan foto surat izin', error: true);
      return;
    }
    setState(() => _saving = true);
    try {
      await IzinService.instance.ajukan(
        tanggal: _tgl,
        jenis: _jenis,
        alasan: _alasan.text,
        buktiPath: _bukti,
        buktiNama: _buktiNama,
      );
      if (!mounted) return;
      showMsg(context, 'Pengajuan izin terkirim');
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      showMsg(context, pesanError(e), error: true);
      setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: scpAppBar('Ajukan Izin'),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text('Tanggal', style: TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          OutlinedButton.icon(onPressed: _pilihTanggal, icon: const Icon(Icons.event), label: Text(Fmt.tglPanjang(_tgl))),
          const SizedBox(height: 16),
          const Text('Jenis', style: TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          Wrap(spacing: 8, children: [
            for (final j in const ['Izin', 'Sakit'])
              ChoiceChip(label: Text(j), selected: _jenis == j, onSelected: (_) => setState(() => _jenis = j)),
          ]),
          const SizedBox(height: 16),
          const Text('Alasan', style: TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          TextField(controller: _alasan, maxLines: 4, decoration: inputDeco('Tuliskan alasan izin')),
          const SizedBox(height: 16),
          const Text('Bukti surat izin *', style: TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          if (_bukti != null) ...[FotoView(_bukti!), const SizedBox(height: 8)],
          OutlinedButton.icon(
            onPressed: _pilihSumber,
            icon: const Icon(Icons.attach_file),
            label: Text(_bukti == null ? 'Lampirkan foto' : 'Ganti foto'),
          ),
          const SizedBox(height: 24),
          FilledButton(
            onPressed: _saving ? null : _kirim,
            child: Padding(padding: const EdgeInsets.symmetric(vertical: 14), child: Text(_saving ? 'Mengirim...' : 'Kirim Pengajuan')),
          ),
        ],
      ),
    );
  }
}
