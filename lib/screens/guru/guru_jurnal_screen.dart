import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../models/jadwalmodel.dart';
import '../../models/jurnalmodel.dart';
import '../../services/api_services.dart';
import '../../services/auth_service.dart';
import '../../services/jurnal_service.dart';
import '../../theme/app_theme.dart';
import '../../utils/format.dart';
import '../../widgets/scp_widgets.dart';

/// Tab riwayat jurnal milik guru.
class GuruJurnalScreen extends StatefulWidget {
  const GuruJurnalScreen({super.key});

  @override
  State<GuruJurnalScreen> createState() => _GuruJurnalScreenState();
}

class _GuruJurnalScreenState extends State<GuruJurnalScreen> {
  late Future<List<JurnalModel>> _future;

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  Future<List<JurnalModel>> _load() => JurnalService.instance.list(guruId: AuthService.instance.current!.id);
  void _reload() => setState(() => _future = _load());

  void _detail(JurnalModel j) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (c) => SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: _DetailJurnal(j),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureView<List<JurnalModel>>(
      future: _future,
      onRetry: _reload,
      builder: (c, list) {
        if (list.isEmpty) return const EmptyState('Belum ada jurnal. Isi jurnal dari tab Beranda.', icon: Icons.menu_book_outlined);
        return RefreshIndicator(
          onRefresh: () async => _reload(),
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: list.length,
            itemBuilder: (c, i) {
              final j = list[i];
              return SCard(
                onTap: () => _detail(j),
                child: Row(
                  children: [
                    const Icon(Icons.lock_outline, color: AppTheme.teal),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('${j.kelas} · ${j.mapel}', style: const TextStyle(fontWeight: FontWeight.bold)),
                          Text(Fmt.tgl(j.tanggal), style: const TextStyle(fontSize: 12, color: AppTheme.grey)),
                          const SizedBox(height: 4),
                          Text(j.materi, maxLines: 2, overflow: TextOverflow.ellipsis),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }
}

class _DetailJurnal extends StatelessWidget {
  final JurnalModel j;
  const _DetailJurnal(this.j);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('${j.kelas} · ${j.mapel}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.navy)),
        Text('${Fmt.tglPanjang(j.tanggal)} · disimpan ${Fmt.jamMenit(j.waktuSimpan)}', style: const TextStyle(color: AppTheme.grey)),
        const SizedBox(height: 12),
        const Text('Materi', style: TextStyle(fontWeight: FontWeight.w600)),
        Text(j.materi),
        if (j.catatan.isNotEmpty) ...[
          const SizedBox(height: 10),
          const Text('Catatan', style: TextStyle(fontWeight: FontWeight.w600)),
          Text(j.catatan),
        ],
        const SizedBox(height: 12),
        FotoView(j.fotoPath),
        const SizedBox(height: 8),
        const InfoBanner('Jurnal terkunci dan tidak dapat diubah.', icon: Icons.lock_outline, color: AppTheme.teal),
      ],
    );
  }
}

/// Form jurnal untuk satu sesi. Foto wajib diambil langsung dari kamera. Setelah disimpan terkunci.
class GuruJurnalForm extends StatefulWidget {
  final JadwalModel jadwal;
  final DateTime tanggal;
  const GuruJurnalForm({super.key, required this.jadwal, required this.tanggal});

  @override
  State<GuruJurnalForm> createState() => _GuruJurnalFormState();
}

class _GuruJurnalFormState extends State<GuruJurnalForm> {
  final _materi = TextEditingController();
  final _catatan = TextEditingController();
  JurnalModel? _ada;
  String _foto = '';
  bool _loading = true;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    JurnalService.instance.sesi(widget.jadwal.id, widget.tanggal).then((v) {
      if (!mounted) return;
      setState(() {
        _ada = v;
        if (v != null) {
          _materi.text = v.materi;
          _catatan.text = v.catatan;
        }
        _loading = false;
      });
    }).catchError((e) {
      if (!mounted) return;
      setState(() => _loading = false);
    });
  }

  @override
  void dispose() {
    _materi.dispose();
    _catatan.dispose();
    super.dispose();
  }

  Future<void> _ambilFoto() async {
    try {
      final x = await ImagePicker().pickImage(source: ImageSource.camera, imageQuality: 70, maxWidth: 1280);
      if (x != null && mounted) setState(() => _foto = x.path);
    } catch (_) {
      if (mounted) showMsg(context, 'Kamera tidak dapat dibuka', error: true);
    }
  }

  Future<void> _simpan() async {
    if (_materi.text.trim().isEmpty) {
      showMsg(context, 'Materi wajib diisi', error: true);
      return;
    }
    if (_foto.isEmpty && _ada == null) {
      showMsg(context, 'Ambil foto kegiatan dari kamera terlebih dahulu', error: true);
      return;
    }
    final ya = await konfirmasi(
      context,
      _ada == null ? 'Simpan jurnal?' : 'Perbarui jurnal?',
      'Perubahan hanya diperbolehkan pada hari ini.',
      ya: _ada == null ? 'Simpan' : 'Perbarui',
    );
    if (!ya || !mounted) return;
    setState(() => _saving = true);
    try {
      await JurnalService.instance.simpan(
        jadwal: widget.jadwal,
        tanggal: widget.tanggal,
        materi: _materi.text,
        catatan: _catatan.text,
        fotoPath: _foto,
      );
      if (!mounted) return;
      showMsg(context, 'Jurnal tersimpan');
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
    final hariIni = Fmt.tanggalSaja(widget.tanggal) == Fmt.hariIni();
    final bolehEdit = hariIni && _ada != null;
    return Scaffold(
      appBar: scpAppBar('Jurnal Mengajar'),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                SCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('${j.kelas} · ${j.mapel}', style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: AppTheme.navy)),
                      Text('${Fmt.tglPanjang(widget.tanggal)} · ${j.jam}', style: const TextStyle(color: AppTheme.grey)),
                    ],
                  ),
                ),
                if (_ada != null && !bolehEdit) SCard(child: _DetailJurnal(_ada!)) else ..._form(edit: bolehEdit),
              ],
            ),
    );
  }

  List<Widget> _form({bool edit = false}) => [
        InfoBanner(
          edit ? 'Jurnal hari ini masih dapat diperbarui.' : 'Jurnal hanya dapat diisi pada hari jadwal dan tidak dapat diubah setelah hari berganti.',
          icon: edit ? Icons.edit_outlined : Icons.info_outline,
        ),
        const Text('Materi *', style: TextStyle(fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        TextField(controller: _materi, maxLines: 2, decoration: inputDeco('Materi yang diajarkan')),
        const SizedBox(height: 14),
        const Text('Catatan', style: TextStyle(fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        TextField(controller: _catatan, maxLines: 3, decoration: inputDeco('Catatan kegiatan / kendala (opsional)')),
        const SizedBox(height: 14),
        const Text('Foto kegiatan *', style: TextStyle(fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        if (_foto.isNotEmpty) ...[FotoView(_foto), const SizedBox(height: 8)],
        OutlinedButton.icon(
          onPressed: _ambilFoto,
          icon: const Icon(Icons.photo_camera_outlined),
          label: Text(_foto.isEmpty ? 'Ambil foto' : 'Ambil ulang foto'),
        ),
        const SizedBox(height: 20),
        FilledButton.icon(
          onPressed: _saving ? null : _simpan,
          icon: const Icon(Icons.lock_outline),
          label: Padding(padding: const EdgeInsets.symmetric(vertical: 12), child: Text(_saving ? 'Menyimpan...' : edit ? 'Perbarui Jurnal' : 'Simpan Jurnal')),
        ),
      ];
}
