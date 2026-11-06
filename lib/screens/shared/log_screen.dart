import 'package:flutter/material.dart';
import '../../models/logmodel.dart';
import '../../models/usermodel.dart';
import '../../services/auth_service.dart';
import '../../services/log_service.dart';
import '../../theme/app_theme.dart';
import '../../utils/format.dart';
import '../../widgets/scp_widgets.dart';

/// Riwayat perubahan data. Waka & BK melihat semua, role lain hanya aktivitasnya sendiri.
class LogScreen extends StatefulWidget {
  const LogScreen({super.key});

  @override
  State<LogScreen> createState() => _LogScreenState();
}

class _LogScreenState extends State<LogScreen> {
  static const _modul = ['Semua', 'Jadwal', 'Presensi', 'Jurnal', 'Izin', 'Akun'];
  String _pilih = 'Semua';
  String _q = '';
  late Future<List<LogModel>> _future;

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  Future<List<LogModel>> _load() {
    final u = AuthService.instance.current!;
    final semua = u.role == UserRole.waka || u.role == UserRole.bk;
    return LogService.instance.list(modul: _pilih == 'Semua' ? null : _pilih, q: _q, oleh: semua ? null : u.nama);
  }

  void _reload() => setState(() => _future = _load());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: scpAppBar('Riwayat Aktivitas'),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
            child: TextField(
              decoration: inputDeco('Cari aktivitas...', icon: Icons.search),
              onChanged: (v) {
                _q = v;
                _reload();
              },
            ),
          ),
          SizedBox(
            height: 48,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              children: [
                for (final m in _modul)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
                    child: ChoiceChip(
                      label: Text(m),
                      selected: _pilih == m,
                      onSelected: (_) {
                        _pilih = m;
                        _reload();
                      },
                    ),
                  ),
              ],
            ),
          ),
          Expanded(
            child: FutureView<List<LogModel>>(
              future: _future,
              onRetry: _reload,
              builder: (c, list) {
                if (list.isEmpty) return const EmptyState('Belum ada riwayat', icon: Icons.history);
                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: list.length,
                  itemBuilder: (c, i) {
                    final l = list[i];
                    return SCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              StatusChip(l.modul, AppTheme.blue),
                              const SizedBox(width: 8),
                              Expanded(child: Text(l.aksi, style: const TextStyle(fontWeight: FontWeight.bold))),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text('${l.oleh} · ${Fmt.tglJam(l.waktu)}', style: const TextStyle(fontSize: 12, color: AppTheme.grey)),
                          if (l.sebelum.isNotEmpty) ...[
                            const SizedBox(height: 8),
                            Text('Sebelum: ${l.sebelum}', style: const TextStyle(fontSize: 13)),
                          ],
                          if (l.sesudah.isNotEmpty) ...[
                            const SizedBox(height: 4),
                            Text('Sesudah: ${l.sesudah}', style: const TextStyle(fontSize: 13)),
                          ],
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
