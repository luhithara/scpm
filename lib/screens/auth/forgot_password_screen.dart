import 'package:flutter/material.dart';
import '../../services/api_services.dart';
import '../../services/auth_service.dart';
import '../../widgets/scp_widgets.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _c = TextEditingController();
  bool _loading = false;
  String? _hasil;
  String _jenisAkun = 'siswa';

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  Future<void> _kirim() async {
    if (_c.text.trim().isEmpty) {
      showMsg(context, 'Masukkan NISN / username', error: true);
      return;
    }
    setState(() => _loading = true);
    try {
      final msg = await AuthService.instance.lupaPassword(_c.text, jenisAkun: _jenisAkun);
      if (!mounted) return;
      setState(() => _hasil = msg);
    } catch (e) {
      if (!mounted) return;
      showMsg(context, pesanError(e), error: true);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: scpAppBar('Lupa Password'),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Text('Masukkan NISN atau username akun Anda untuk meminta reset password.'),
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            value: _jenisAkun,
            decoration: inputDeco('Jenis akun', icon: Icons.people_outline),
            items: const [
              DropdownMenuItem(value: 'siswa', child: Text('Siswa')),
              DropdownMenuItem(value: 'orangtua', child: Text('Orang Tua')),
            ],
            onChanged: (value) => setState(() => _jenisAkun = value ?? 'siswa'),
          ),
          const SizedBox(height: 16),
          TextField(controller: _c, decoration: inputDeco('NISN / Username', icon: Icons.person_outline)),
          const SizedBox(height: 16),
          FilledButton(
            onPressed: _loading ? null : _kirim,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 14),
              child: _loading ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)) : const Text('Kirim Permintaan'),
            ),
          ),
          if (_hasil != null) ...[
            const SizedBox(height: 20),
            InfoBanner(_hasil!, icon: Icons.check_circle_outline),
          ],
        ],
      ),
    );
  }
}
