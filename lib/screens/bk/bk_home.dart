import 'package:flutter/material.dart';
import '../../models/izinmodel.dart';
import '../../services/auth_service.dart';
import '../../services/izin_service.dart';
import '../../theme/app_theme.dart';
import '../../utils/format.dart';
import '../../widgets/scp_widgets.dart';

/// Beranda BK (semua kelas) atau Wali Kelas (isi [kelasTetap]).
class BkHome extends StatefulWidget {
  final String? kelasTetap;
  const BkHome({super.key, this.kelasTetap});

  @override
  State<BkHome> createState() => _BkHomeState();
}

class _BkHomeState extends State<BkHome> {
  late Future<List<IzinModel>> _future;

  @override
  void initState() {
    super.initState();
    _future = IzinService.instance.list(kelas: widget.kelasTetap);
  }

  void _reload() => setState(() => _future = IzinService.instance.list(kelas: widget.kelasTetap));

  @override
  Widget build(BuildContext context) {
    final u = AuthService.instance.current!;
    return FutureView<List<IzinModel>>(
      future: _future,
      onRetry: _reload,
      builder: (c, all) {
        int n(StatusIzin s) => all.where((z) => z.status == s).length;
        final menunggu = all.where((z) => z.status == StatusIzin.menunggu).take(5).toList();
        return RefreshIndicator(
          onRefresh: () async => _reload(),
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text('Halo, ${u.nama}', style: const TextStyle(fontSize: 21, fontWeight: FontWeight.bold, color: AppTheme.navy)),
              Text(widget.kelasTetap == null ? 'Bimbingan Konseling' : 'Wali Kelas ${widget.kelasTetap}', style: const TextStyle(color: AppTheme.grey)),
              const SizedBox(height: 14),
              PutaranBanner(kelas: widget.kelasTetap),
              StatGrid(items: [
                StatCard(title: 'Menunggu', value: '${n(StatusIzin.menunggu)}', icon: Icons.hourglass_top, color: AppTheme.orange),
                StatCard(title: 'Disetujui', value: '${n(StatusIzin.disetujui)}', icon: Icons.check_circle_outline, color: AppTheme.teal),
                StatCard(title: 'Ditolak', value: '${n(StatusIzin.ditolak)}', icon: Icons.cancel_outlined, color: AppTheme.red),
                StatCard(title: 'Total izin', value: '${all.length}', icon: Icons.mail_outline, color: AppTheme.blue),
              ]),
              const SectionTitle('Perlu diproses'),
              if (menunggu.isEmpty) const EmptyState('Tidak ada izin yang menunggu', icon: Icons.done_all),
              for (final z in menunggu)
                SCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(z.siswaNama, style: const TextStyle(fontWeight: FontWeight.bold)),
                      Text('${z.kelas} · ${z.jenis} · ${Fmt.tgl(z.tanggal)}', style: const TextStyle(fontSize: 12, color: AppTheme.grey)),
                      const SizedBox(height: 4),
                      Text(z.alasan, maxLines: 2, overflow: TextOverflow.ellipsis),
                    ],
                  ),
                ),
              if (menunggu.isNotEmpty) const Text('Buka tab Izin untuk menyetujui / menolak.', style: TextStyle(color: AppTheme.grey, fontSize: 12)),
            ],
          ),
        );
      },
    );
  }
}
