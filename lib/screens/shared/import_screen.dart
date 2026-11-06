import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import '../../services/api_services.dart';
import '../../services/import_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/scp_widgets.dart';

class ImportScreen extends StatefulWidget {
  const ImportScreen({super.key});

  @override
  State<ImportScreen> createState() => _ImportScreenState();
}

class _ImportScreenState extends State<ImportScreen> {
  bool _loading = false;

  Future<void> _import(String jenis, String label) async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: const ['xlsx'],
      withData: false,
    );
    final path = result?.files.single.path;
    if (path == null || !mounted) return;
    setState(() => _loading = true);
    try {
      final count = await ImportService.instance.upload(jenis, path);
      if (mounted) showMsg(context, '$count data $label berhasil diimport');
    } catch (e) {
      if (mounted) showMsg(context, pesanError(e), error: true);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: scpAppBar('Import Excel'),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const InfoBanner('Gunakan file .xlsx dengan baris pertama sebagai nama kolom. Import jurnal ditujukan untuk data historis; jurnal hari ini tetap wajib memakai kamera.', icon: Icons.info_outline),
          const SizedBox(height: 12),
          for (final item in const [
            ('siswa', 'Data Siswa', Icons.people_outline),
            ('presensi', 'Data Presensi', Icons.fact_check_outlined),
            ('jurnal', 'Data Jurnal Historis', Icons.menu_book_outlined),
          ])
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: OutlinedButton.icon(
                onPressed: _loading ? null : () => _import(item.$1, item.$2),
                icon: Icon(item.$3, color: AppTheme.navy),
                label: Padding(padding: const EdgeInsets.symmetric(vertical: 14), child: Text('Import ${item.$2}')),
              ),
            ),
        ],
      ),
    );
  }
}
