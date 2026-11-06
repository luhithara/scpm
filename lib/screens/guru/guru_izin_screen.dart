import 'package:flutter/material.dart';
import '../../models/izinmodel.dart';
import '../../services/izin_service.dart';
import '../../theme/app_theme.dart';
import '../../utils/format.dart';
import '../../widgets/scp_widgets.dart';

/// Informasi izin siswa untuk kelas yang diajar guru (hanya lihat).
class GuruIzinScreen extends StatefulWidget {
  const GuruIzinScreen({super.key});

  @override
  State<GuruIzinScreen> createState() => _GuruIzinScreenState();
}

class _GuruIzinScreenState extends State<GuruIzinScreen> {
  DateTime _tgl = Fmt.hariIni();
  late Future<List<IzinModel>> _future;

  @override
  void initState() {
    super.initState();
    _future = IzinService.instance.infoGuru(_tgl);
  }

  void _reload() => setState(() => _future = IzinService.instance.infoGuru(_tgl));

  Future<void> _pilih() async {
    final d = await showDatePicker(context: context, initialDate: _tgl, firstDate: DateTime(2025), lastDate: DateTime(2030));
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
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
          child: Column(
            children: [
              OutlinedButton.icon(onPressed: _pilih, icon: const Icon(Icons.event), label: Text(Fmt.tglPanjang(_tgl))),
              const SizedBox(height: 10),
              const InfoBanner('Informasi saja. Persetujuan izin dilakukan oleh BK atau Wali Kelas.'),
            ],
          ),
        ),
        Expanded(
          child: FutureView<List<IzinModel>>(
            future: _future,
            onRetry: _reload,
            builder: (c, list) {
              if (list.isEmpty) return const EmptyState('Tidak ada izin siswa di kelas yang Anda ajar pada tanggal ini');
              return ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: list.length,
                itemBuilder: (c, i) {
                  final z = list[i];
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
                        Text('${z.kelas} · ${z.jenis}', style: const TextStyle(color: AppTheme.grey, fontSize: 12)),
                        const SizedBox(height: 6),
                        Text(z.alasan),
                      ],
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}
