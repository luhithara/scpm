import 'package:flutter/material.dart';
import '../../config/api_config.dart';
import '../../config/app_routes.dart';
import '../../services/api_services.dart';
import '../../services/auth_service.dart';
import '../../services/mock_store.dart';
import '../../theme/app_theme.dart';
import '../../widgets/scp_widgets.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  String _jenisAkun = 'siswa';
  bool _obscurePassword = true;
  bool _loading = false;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    try {
      await AuthService.instance.login(
        _usernameController.text,
        _passwordController.text,
        jenisAkun: _jenisAkun,
      );
      if (!mounted) return;
      Navigator.pushReplacementNamed(context, AppRoutes.home);
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
      backgroundColor: AppTheme.bg,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(25),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 20),
                  Center(
                    child: Container(
                      width: 85,
                      height: 85,
                      decoration: BoxDecoration(color: AppTheme.navy, borderRadius: BorderRadius.circular(25)),
                      child: const Icon(Icons.school_rounded, color: Colors.white, size: 48),
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text('SCP',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: AppTheme.navy)),
                  const SizedBox(height: 4),
                  const Text('School Class Progress',
                      textAlign: TextAlign.center, style: TextStyle(fontSize: 15, color: Colors.grey)),
                  const SizedBox(height: 36),
                  const Text('Selamat Datang!',
                      style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppTheme.navy)),
                  const SizedBox(height: 6),
                  const Text('Silakan login untuk melanjutkan.', style: TextStyle(color: Colors.grey)),
                  const SizedBox(height: 24),
                  const Text('Jenis akun', style: TextStyle(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 10),
                  DropdownButtonFormField<String>(
                    value: _jenisAkun,
                    decoration: inputDeco('Pilih jenis akun', icon: Icons.people_outline),
                    items: const [
                      DropdownMenuItem(value: 'siswa', child: Text('Siswa')),
                      DropdownMenuItem(value: 'orangtua', child: Text('Orang Tua')),
                    ],
                    onChanged: _loading ? null : (value) => setState(() => _jenisAkun = value ?? 'siswa'),
                  ),
                  const SizedBox(height: 20),
                  const Text('NISN', style: TextStyle(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: _usernameController,
                    textInputAction: TextInputAction.next,
                    decoration: inputDeco('Masukkan NISN', icon: Icons.person_outline),
                    validator: (v) => (v == null || v.trim().isEmpty) ? 'Wajib diisi' : null,
                  ),
                  const SizedBox(height: 20),
                  const Text('Password', style: TextStyle(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: _passwordController,
                    obscureText: _obscurePassword,
                    onFieldSubmitted: (_) => _login(),
                    decoration: InputDecoration(
                      hintText: 'Masukkan password',
                      prefixIcon: const Icon(Icons.lock_outline),
                      suffixIcon: IconButton(
                        icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility),
                        onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                      ),
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
                    ),
                    validator: (v) => (v == null || v.isEmpty) ? 'Wajib diisi' : null,
                  ),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () => Navigator.pushNamed(context, AppRoutes.lupa),
                      child: const Text('Lupa password?'),
                    ),
                  ),
                  const SizedBox(height: 6),
                  SizedBox(
                    height: 55,
                    child: FilledButton(
                      onPressed: _loading ? null : _login,
                      style: FilledButton.styleFrom(
                        backgroundColor: AppTheme.navy,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                      child: _loading
                          ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white))
                          : const Text('MASUK', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    ),
                  ),
                  TextButton(
                    onPressed: _loading ? null : () => Navigator.pushNamed(context, AppRoutes.register),
                    child: const Text('Belum punya akun? Daftar'),
                  ),
                  if (ApiConfig.useMock) ...[
                    const SizedBox(height: 24),
                    _demoPanel(),
                  ],
                  const SizedBox(height: 28),
                  const Text('© 2026 SCP - School Class Progress',
                      textAlign: TextAlign.center, style: TextStyle(color: Colors.grey, fontSize: 12)),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _demoPanel() {
    return SCard(
      padding: EdgeInsets.zero,
      child: ExpansionTile(
        shape: const Border(),
        collapsedShape: const Border(),
        leading: const Icon(Icons.science_outlined, color: AppTheme.blue),
        title: const Text('Akun demo (password 123456)', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
        children: [
          for (final a in MockStore.instance.demoAkun)
            ListTile(
              dense: true,
              title: Text(a.label),
              subtitle: Text(a.username),
              trailing: const Icon(Icons.touch_app_outlined, size: 18),
              onTap: () => setState(() {
                _usernameController.text = a.username;
                _passwordController.text = a.password;
              }),
            ),
        ],
      ),
    );
  }
}
