import 'package:flutter/material.dart';
import '../../models/notifmodel.dart';
import '../../services/notif_service.dart';
import '../../theme/app_theme.dart';
import '../../utils/format.dart';
import '../../widgets/scp_widgets.dart';

class NotifScreen extends StatefulWidget {
  const NotifScreen({super.key});

  @override
  State<NotifScreen> createState() => _NotifScreenState();
}

class _NotifScreenState extends State<NotifScreen> {
  late Future<List<NotifModel>> _future;

  @override
  void initState() {
    super.initState();
    _future = NotifService.instance.list();
  }

  void _reload() => setState(() => _future = NotifService.instance.list());

  Future<void> _semua() async {
    await NotifService.instance.bacaSemua();
    _reload();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: scpAppBar('Notifikasi', actions: [
        IconButton(tooltip: 'Tandai semua dibaca', onPressed: _semua, icon: const Icon(Icons.done_all)),
      ]),
      body: FutureView<List<NotifModel>>(
        future: _future,
        onRetry: _reload,
        builder: (c, list) {
          if (list.isEmpty) return const EmptyState('Belum ada notifikasi', icon: Icons.notifications_none);
          return RefreshIndicator(
            onRefresh: () async => _reload(),
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: list.length,
              itemBuilder: (c, i) {
                final n = list[i];
                return SCard(
                  color: n.dibaca ? Colors.white : const Color(0xFFEAF1FB),
                  onTap: () async {
                    await NotifService.instance.baca(n.id);
                    _reload();
                  },
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(n.dibaca ? Icons.notifications_none : Icons.notifications_active, color: AppTheme.navy),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(n.judul, style: const TextStyle(fontWeight: FontWeight.bold)),
                            const SizedBox(height: 4),
                            Text(n.isi),
                            const SizedBox(height: 6),
                            Text(Fmt.tglJam(n.waktu), style: const TextStyle(fontSize: 12, color: AppTheme.grey)),
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
      ),
    );
  }
}
