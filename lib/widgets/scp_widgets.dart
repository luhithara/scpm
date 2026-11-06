import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../models/izinmodel.dart';
import '../models/presensimodel.dart';
import '../theme/app_theme.dart';
import '../utils/blokputaran.dart';
import '../utils/format.dart';

Color warnaHadir(StatusHadir s) => switch (s) {
      StatusHadir.hadir => AppTheme.teal,
      StatusHadir.izin => AppTheme.blue,
      StatusHadir.sakit => AppTheme.orange,
      StatusHadir.alpa => AppTheme.red,
    };

Color warnaIzin(StatusIzin s) => switch (s) {
      StatusIzin.menunggu => AppTheme.orange,
      StatusIzin.disetujui => AppTheme.teal,
      StatusIzin.ditolak => AppTheme.red,
    };

void showMsg(BuildContext context, String text, {bool error = false}) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(
      content: Text(text),
      backgroundColor: error ? AppTheme.red : AppTheme.navy,
      behavior: SnackBarBehavior.floating,
    ));
}

Future<bool> konfirmasi(BuildContext context, String judul, String isi, {String ya = 'Ya'}) async {
  final r = await showDialog<bool>(
    context: context,
    builder: (c) => AlertDialog(
      title: Text(judul),
      content: Text(isi),
      actions: [
        TextButton(onPressed: () => Navigator.pop(c, false), child: const Text('Batal')),
        FilledButton(onPressed: () => Navigator.pop(c, true), child: Text(ya)),
      ],
    ),
  );
  return r ?? false;
}

InputDecoration inputDeco(String hint, {IconData? icon}) => InputDecoration(
      hintText: hint,
      prefixIcon: icon == null ? null : Icon(icon),
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
    );

PreferredSizeWidget scpAppBar(String title, {List<Widget>? actions}) => AppBar(
      backgroundColor: AppTheme.navy,
      foregroundColor: Colors.white,
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
      actions: actions,
    );

class SCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets padding;
  final EdgeInsets margin;
  final VoidCallback? onTap;
  final Color? color;

  const SCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(14),
    this.margin = const EdgeInsets.only(bottom: 12),
    this.onTap,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin,
      decoration: BoxDecoration(
        color: color ?? Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Padding(padding: padding, child: child),
        ),
      ),
    );
  }
}

class StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const StatCard({super.key, required this.title, required this.value, required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return SCard(
      margin: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 26),
          const SizedBox(height: 10),
          Text(value, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppTheme.navy)),
          const SizedBox(height: 2),
          Text(title, style: const TextStyle(color: AppTheme.grey, fontSize: 12)),
        ],
      ),
    );
  }
}

/// Grid statistik 2 kolom tanpa tinggi tetap.
class StatGrid extends StatelessWidget {
  final List<StatCard> items;
  const StatGrid({super.key, required this.items});

  @override
  Widget build(BuildContext context) {
    final rows = <Widget>[];
    for (var i = 0; i < items.length; i += 2) {
      rows.add(Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(child: items[i]),
            const SizedBox(width: 12),
            Expanded(child: i + 1 < items.length ? items[i + 1] : const SizedBox()),
          ],
        ),
      ));
    }
    return Column(children: rows);
  }
}

class StatusChip extends StatelessWidget {
  final String label;
  final Color color;
  const StatusChip(this.label, this.color, {super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: color.withValues(alpha: 0.13), borderRadius: BorderRadius.circular(20)),
      child: Text(label, style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w600)),
    );
  }
}

class EmptyState extends StatelessWidget {
  final IconData icon;
  final String text;
  const EmptyState(this.text, {super.key, this.icon = Icons.inbox_outlined});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 48, horizontal: 24),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 52, color: Colors.grey.shade400),
            const SizedBox(height: 12),
            Text(text, textAlign: TextAlign.center, style: const TextStyle(color: AppTheme.grey)),
          ],
        ),
      ),
    );
  }
}

class SectionTitle extends StatelessWidget {
  final String text;
  final Widget? trailing;
  const SectionTitle(this.text, {super.key, this.trailing});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 8, bottom: 12),
      child: Row(
        children: [
          Expanded(
            child: Text(text, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: AppTheme.navy)),
          ),
          if (trailing != null) trailing!,
        ],
      ),
    );
  }
}

class InfoBanner extends StatelessWidget {
  final String text;
  final IconData icon;
  final Color color;
  const InfoBanner(this.text, {super.key, this.icon = Icons.info_outline, this.color = AppTheme.blue});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(14)),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 10),
          Expanded(child: Text(text, style: TextStyle(color: color, fontSize: 13, fontWeight: FontWeight.w500))),
        ],
      ),
    );
  }
}

/// Info putaran blok. Jika [kelas] diberikan dan kelas itu tidak aktif, tampil peringatan.
class PutaranBanner extends StatelessWidget {
  final String? kelas;
  const PutaranBanner({super.key, this.kelas});

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final info = BlokPutaran.info(now);
    if (kelas != null && !BlokPutaran.kelasAktif(kelas!, now)) {
      return InfoBanner('$info. $kelas belum masuk blok minggu ini.', icon: Icons.event_busy, color: AppTheme.orange);
    }
    return InfoBanner(info, icon: Icons.sync_alt);
  }
}

class FutureView<T> extends StatelessWidget {
  final Future<T> future;
  final Widget Function(BuildContext, T) builder;
  final VoidCallback onRetry;

  const FutureView({super.key, required this.future, required this.builder, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<T>(
      future: future,
      builder: (c, s) {
        if (s.connectionState != ConnectionState.done) {
          return const Center(child: CircularProgressIndicator());
        }
        if (s.hasError) {
          final e = s.error;
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.error_outline, size: 48, color: AppTheme.red),
                  const SizedBox(height: 12),
                  Text(e == null ? 'Terjadi kesalahan' : e.toString(), textAlign: TextAlign.center),
                  const SizedBox(height: 12),
                  OutlinedButton(onPressed: onRetry, child: const Text('Coba lagi')),
                ],
              ),
            ),
          );
        }
        return builder(c, s.data as T);
      },
    );
  }
}

class FotoView extends StatelessWidget {
  final String path;
  final double height;
  const FotoView(this.path, {super.key, this.height = 180});

  @override
  Widget build(BuildContext context) {
    Widget placeholder() => Container(
          height: height,
          width: double.infinity,
          decoration: BoxDecoration(color: Colors.grey.shade200, borderRadius: BorderRadius.circular(12)),
          child: const Icon(Icons.image_outlined, size: 40, color: Colors.grey),
        );
    if (path.isEmpty) return placeholder();
    final img = (kIsWeb || path.startsWith('http'))
        ? Image.network(path, height: height, width: double.infinity, fit: BoxFit.cover, errorBuilder: (c, e, s) => placeholder())
        : Image.file(File(path), height: height, width: double.infinity, fit: BoxFit.cover, errorBuilder: (c, e, s) => placeholder());
    return ClipRRect(borderRadius: BorderRadius.circular(12), child: img);
  }
}

class DropBox<T> extends StatelessWidget {
  final T? value;
  final List<DropdownMenuItem<T>> items;
  final ValueChanged<T?> onChanged;
  final String hint;

  const DropBox({super.key, required this.value, required this.items, required this.onChanged, required this.hint});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14)),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<T>(
          isExpanded: true,
          value: value,
          hint: Text(hint),
          items: items,
          onChanged: onChanged,
        ),
      ),
    );
  }
}
