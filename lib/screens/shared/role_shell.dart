import 'package:flutter/material.dart';
import '../../services/notif_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/scp_widgets.dart';
import 'notif_screen.dart';

class ShellTab {
  final String label;
  final IconData icon;
  final IconData iconAktif;
  final WidgetBuilder builder;
  const ShellTab(this.label, this.icon, this.iconAktif, this.builder);
}

class RoleShell extends StatefulWidget {
  final List<ShellTab> tabs;
  const RoleShell({super.key, required this.tabs});

  @override
  State<RoleShell> createState() => _RoleShellState();
}

class _RoleShellState extends State<RoleShell> {
  int _i = 0;
  late Future<int> _unread;

  @override
  void initState() {
    super.initState();
    _unread = NotifService.instance.unread();
  }

  Future<void> _bukaNotif() async {
    await Navigator.push(context, MaterialPageRoute(builder: (_) => const NotifScreen()));
    if (!mounted) return;
    setState(() => _unread = NotifService.instance.unread());
  }

  @override
  Widget build(BuildContext context) {
    final tab = widget.tabs[_i];
    return Scaffold(
      appBar: scpAppBar(tab.label, actions: [
        FutureBuilder<int>(
          future: _unread,
          builder: (c, s) {
            final n = s.data ?? 0;
            return IconButton(
              onPressed: _bukaNotif,
              icon: Badge(
                isLabelVisible: n > 0,
                label: Text('$n'),
                child: const Icon(Icons.notifications_outlined),
              ),
            );
          },
        ),
        const SizedBox(width: 4),
      ]),
      body: KeyedSubtree(key: ValueKey(_i), child: tab.builder(context)),
      bottomNavigationBar: widget.tabs.length < 2
          ? null
          : NavigationBar(
              selectedIndex: _i,
              backgroundColor: Colors.white,
              indicatorColor: AppTheme.navy.withValues(alpha: 0.12),
              onDestinationSelected: (v) => setState(() {
                _i = v;
                _unread = NotifService.instance.unread();
              }),
              destinations: [
                for (final t in widget.tabs)
                  NavigationDestination(icon: Icon(t.icon), selectedIcon: Icon(t.iconAktif), label: t.label),
              ],
            ),
    );
  }
}
