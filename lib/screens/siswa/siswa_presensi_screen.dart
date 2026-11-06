import 'package:flutter/material.dart';
import '../../models/presensimodel.dart';
import '../../services/auth_service.dart';
import '../../services/presensi_service.dart';
import '../../theme/app_theme.dart';
import '../../utils/format.dart';
import '../../widgets/scp_widgets.dart';

class SiswaPresensiScreen extends StatefulWidget {
  const SiswaPresensiScreen({super.key});

  @override
  State<SiswaPresensiScreen> createState() => _SiswaPresensiScreenState();
}

class _SiswaPresensiScreenState extends State<SiswaPresensiScreen> {
  StatusHadir? _filter;
  late Future<List<PresensiModel>> _future;

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  Future<List<PresensiModel>> _load() async {
    final u = AuthService.instance.current!;
    final r = await PresensiService.instance.rekap(siswaId: u.id);
    r.sort((a, b) => b.tanggal.compareTo(a.tanggal));
    return r;
  }

  void _reload() => setState(() => _future = _load());

  @override
  Widget build(BuildContext context) {
    return FutureView<List<PresensiModel>>(
      future: _future,
      onRetry: _reload,
      builder: (c, all) {
        final list = _filter == null ? all : all.where((p) => p.status == _filter).toList();
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
                    child: ChoiceChip(label: Text('Semua ${all.length}'), selected: _filter == null, onSelected: (_) => setState(() => _filter = null)),
                  ),
                  for (final s in StatusHadir.values)
                    Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: ChoiceChip(
                        label: Text('${s.label} ${all.where((p) => p.status == s).length}'),
                        selected: _filter == s,
                        onSelected: (_) => setState(() => _filter = s),
                      ),
                    ),
                ],
              ),
            ),
            Expanded(
              child: list.isEmpty
                  ? const EmptyState('Belum ada data presensi', icon: Icons.fact_check_outlined)
                  : RefreshIndicator(
                      onRefresh: () async => _reload(),
                      child: ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: list.length,
                        itemBuilder: (c, i) {
                          final p = list[i];
                          return SCard(
                            child: Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(p.mapel, style: const TextStyle(fontWeight: FontWeight.bold)),
                                      Text(Fmt.tglPanjang(p.tanggal), style: const TextStyle(fontSize: 12, color: AppTheme.grey)),
                                      if (p.keterangan.isNotEmpty) Text(p.keterangan, style: const TextStyle(fontSize: 12)),
                                    ],
                                  ),
                                ),
                                StatusChip(p.status.label, warnaHadir(p.status)),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
            ),
          ],
        );
      },
    );
  }
}
