import 'package:flutter/material.dart';
import '../../config/app_routes.dart';
import '../../services/api_services.dart';
import '../../services/auth_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/scp_widgets.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nisn = TextEditingController();
  final _nama = TextEditingController();
  final _password = TextEditingController();
  String _jenisAkun = 'siswa';
  bool _loading = false;

  @override
  void dispose() {
    _nisn.dispose();
    _nama.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    try {
      await AuthService.instance.register(
        identitas: _nisn.text,
        nama: _nama.text,
        password: _password.text,
        jenisAkun: _jenisAkun,
      );
      if (!mounted) return;
      Navigator.pushNamedAndRemoveUntil(context, AppRoutes.home, (_) => false);
    } catch (e) {
      if (mounted) showMsg(context, pesanError(e), error: true);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bg,
      appBar: scpAppBar('Registrasi Akun'),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            const Text('Akun hanya dapat dibuat untuk NISN yang sudah terdaftar di sekolah.'),
            const SizedBox(height: 20),
            DropdownButtonFormField<String>(
              value: _jenisAkun,
              decoration: inputDeco('Jenis akun', icon: Icons.people_outline),
              items: const [
                DropdownMenuItem(value: 'siswa', child: Text('Siswa')),
                DropdownMenuItem(value: 'orangtua', child: Text('Orang Tua')),
              ],
              onChanged: _loading ? null : (value) => setState(() => _jenisAkun = value ?? 'siswa'),
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: _nisn,
              keyboardType: TextInputType.number,
              decoration: inputDeco('NISN', icon: Icons.badge_outlined),
              validator: (value) => value == null || value.trim().isEmpty ? 'NISN wajib diisi' : null,
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: _nama,
              decoration: inputDeco('Nama pemilik akun', icon: Icons.person_outline),
              validator: (value) => value == null || value.trim().isEmpty ? 'Nama wajib diisi' : null,
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: _password,
              obscureText: true,
              decoration: inputDeco('Password minimal 6 karakter', icon: Icons.lock_outline),
              validator: (value) => value == null || value.length < 6 ? 'Password minimal 6 karakter' : null,
            ),
            const SizedBox(height: 20),
            FilledButton(
              onPressed: _loading ? null : _register,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 14),
                child: _loading
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                    : const Text('DAFTAR'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
