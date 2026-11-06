import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../config/app_routes.dart';
import '../../models/usermodel.dart';
import '../../services/api_services.dart';
import '../../services/auth_service.dart';
import '../../theme/app_theme.dart';
import '../../utils/format.dart';
import '../../widgets/scp_widgets.dart';
import 'log_screen.dart';
import 'import_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  Future<void> _keluar(BuildContext context) async {
    final ya = await konfirmasi(context, 'Keluar', 'Yakin ingin keluar dari akun ini?', ya: 'Keluar');
    if (!ya || !context.mounted) return;
    await AuthService.instance.logout();
    if (!context.mounted) return;
    Navigator.pushNamedAndRemoveUntil(context, AppRoutes.login, (_) => false);
  }

  @override
  Widget build(BuildContext context) {
    final u = AuthService.instance.current!;
    final portal = u.role == UserRole.siswa || u.role == UserRole.ortu;
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        SCard(
          child: Column(
            children: [
              _FotoProfilEditor(user: u),
              const SizedBox(height: 12),
              Text(u.nama, textAlign: TextAlign.center, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.navy)),
              const SizedBox(height: 4),
              Text(u.role.label, style: const TextStyle(color: AppTheme.grey)),
              const SizedBox(height: 12),
              _baris(Icons.badge_outlined, u.role == UserRole.siswa || u.role == UserRole.ortu ? 'NISN / ID' : 'Username', u.username),
              if (u.kelas != null) _baris(Icons.class_outlined, 'Kelas', u.kelas!),
              if (u.mapel != null) _baris(Icons.menu_book_outlined, 'Mata pelajaran', u.mapel!),
            ],
          ),
        ),
        SCard(
          padding: EdgeInsets.zero,
          child: Column(
            children: [
              ListTile(
                leading: const Icon(Icons.lock_reset, color: AppTheme.navy),
                title: const Text('Ganti Password'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => _gantiPassword(context),
              ),
              if (portal) ...[
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.edit_outlined, color: AppTheme.navy),
                  title: const Text('Edit Profil'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => _editProfil(context),
                ),
              ],
              if (!portal) ...[
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.history, color: AppTheme.navy),
                  title: const Text('Riwayat Aktivitas'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const LogScreen())),
                ),
                if (u.role == UserRole.guru || u.role == UserRole.waka) ...[
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.upload_file, color: AppTheme.navy),
                    title: const Text('Import Excel'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ImportScreen())),
                  ),
                ],
              ],
            ],
          ),
        ),
        const SizedBox(height: 8),
        OutlinedButton.icon(
          onPressed: () => _keluar(context),
          icon: const Icon(Icons.logout),
          label: const Text('Keluar'),
          style: OutlinedButton.styleFrom(foregroundColor: AppTheme.red, padding: const EdgeInsets.all(15)),
        ),
      ],
    );
  }

  class _FotoProfilEditor extends StatefulWidget {
    final UserModel user;
    const _FotoProfilEditor({required this.user});

    @override
    State<_FotoProfilEditor> createState() => _FotoProfilEditorState();
  }

  class _FotoProfilEditorState extends State<_FotoProfilEditor> {
    bool _loading = false;

    Future<void> _pilih() async {
      final source = await showModalBottomSheet<ImageSource>(
        context: context,
        builder: (c) => SafeArea(
          child: Wrap(children: [
            ListTile(leading: const Icon(Icons.camera_alt), title: const Text('Kamera'), onTap: () => Navigator.pop(c, ImageSource.camera)),
            ListTile(leading: const Icon(Icons.photo_library), title: const Text('Galeri'), onTap: () => Navigator.pop(c, ImageSource.gallery)),
          ]),
        ),
      );
      if (source == null) return;
      final file = await ImagePicker().pickImage(source: source, imageQuality: 75, maxWidth: 1200);
      if (file == null || !mounted) return;
      setState(() => _loading = true);
      try {
        await AuthService.instance.uploadProfilePhoto(file.path);
        if (mounted) showMsg(context, 'Foto profil berhasil diperbarui');
      } catch (e) {
        if (mounted) showMsg(context, pesanError(e), error: true);
      } finally {
        if (mounted) setState(() => _loading = false);
      }
    }

    @override
    Widget build(BuildContext context) {
      final foto = AuthService.instance.current?.fotoProfil;
      return Stack(
        children: [
          CircleAvatar(
            radius: 40,
            backgroundColor: AppTheme.navy,
            backgroundImage: foto == null ? null : NetworkImage(foto),
            child: foto == null ? Text(Fmt.inisial(widget.user.nama), style: const TextStyle(fontSize: 24, color: Colors.white, fontWeight: FontWeight.bold)) : null,
          ),
          Positioned(
            right: -4,
            bottom: -4,
            child: IconButton.filled(
              onPressed: _loading ? null : _pilih,
              icon: _loading ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2)) : const Icon(Icons.camera_alt, size: 16),
            ),
          ),
        ],
      );
    }
  }

  Widget _baris(IconData icon, String label, String nilai) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Row(
          children: [
            Icon(icon, size: 20, color: AppTheme.grey),
            const SizedBox(width: 10),
            Text(label, style: const TextStyle(color: AppTheme.grey)),
            const Spacer(),
            Flexible(child: Text(nilai, textAlign: TextAlign.right, style: const TextStyle(fontWeight: FontWeight.w600))),
          ],
        ),
      );

  void _gantiPassword(BuildContext context) {
    final lama = TextEditingController();
    final baru = TextEditingController();
    final ulang = TextEditingController();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (c) => Padding(
        padding: EdgeInsets.fromLTRB(20, 20, 20, 20 + MediaQuery.of(c).viewInsets.bottom),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text('Ganti Password', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            TextField(controller: lama, obscureText: true, decoration: inputDeco('Password lama', icon: Icons.lock_outline)),
            const SizedBox(height: 12),
            TextField(controller: baru, obscureText: true, decoration: inputDeco('Password baru (min. 6 karakter)', icon: Icons.lock)),
            const SizedBox(height: 12),
            TextField(controller: ulang, obscureText: true, decoration: inputDeco('Ulangi password baru', icon: Icons.lock)),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: () async {
                if (baru.text.length < 6) {
                  showMsg(c, 'Password baru minimal 6 karakter', error: true);
                  return;
                }
                if (baru.text != ulang.text) {
                  showMsg(c, 'Konfirmasi password tidak sama', error: true);
                  return;
                }
                try {
                  await AuthService.instance.gantiPassword(lama.text, baru.text);
                  if (c.mounted) Navigator.pop(c);
                  if (context.mounted) showMsg(context, 'Password berhasil diganti');
                } catch (e) {
                  if (c.mounted) showMsg(c, pesanError(e), error: true);
                }
              },
              child: const Padding(padding: EdgeInsets.symmetric(vertical: 12), child: Text('Simpan')),
            ),
          ],
        ),
      ),
    );
  }

  void _editProfil(BuildContext context) {
    final nama = TextEditingController(text: AuthService.instance.current!.nama);
    final alamat = TextEditingController();
    final telepon = TextEditingController();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (c) => Padding(
        padding: EdgeInsets.fromLTRB(20, 20, 20, 20 + MediaQuery.of(c).viewInsets.bottom),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text('Edit Profil', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 14),
            TextField(controller: nama, decoration: inputDeco('Nama', icon: Icons.person_outline)),
            const SizedBox(height: 12),
            TextField(controller: alamat, decoration: inputDeco('Alamat', icon: Icons.home_outlined)),
            const SizedBox(height: 12),
            TextField(controller: telepon, keyboardType: TextInputType.phone, decoration: inputDeco('Nomor telepon', icon: Icons.phone_outlined)),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: () async {
                if (nama.text.trim().isEmpty) {
                  showMsg(c, 'Nama wajib diisi', error: true);
                  return;
                }
                try {
                  await AuthService.instance.updateProfile(nama: nama.text, alamat: alamat.text, telepon: telepon.text);
                  if (c.mounted) Navigator.pop(c);
                  if (context.mounted) showMsg(context, 'Profil berhasil diperbarui');
                } catch (e) {
                  if (c.mounted) showMsg(c, pesanError(e), error: true);
                }
              },
              child: const Text('Simpan'),
            ),
          ],
        ),
      ),
    );
  }
}
