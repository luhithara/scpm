import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'dashboard_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _usernameController =
      TextEditingController();
  final TextEditingController _passwordController =
      TextEditingController();

  // Alamat API Laravel untuk pengujian Flutter di Chrome.
  static const String _baseUrl = 'https://scpskansaba.web.id/api';

  static const Color _primaryColor = Color(0xFF172B4D);
  static const Color _backgroundColor = Color(0xFFF5F7FB);
  static const Color _borderColor = Color(0xFFDCE2EA);

  bool _obscurePassword = true;
  bool _isLoading = false;

  String? _selectedRole = 'siswa';

  final List<Map<String, dynamic>> _roles = [
    {
      'value': 'siswa',
      'label': 'Siswa',
      'icon': Icons.school_outlined,
    },
    {
      'value': 'orangtua',
      'label': 'Orang Tua',
      'icon': Icons.family_restroom_outlined,
    },
    {
      'value': 'guru',
      'label': 'Guru',
      'icon': Icons.person_outline,
    },
    {
      'value': 'bk',
      'label': 'Bimbingan Konseling',
      'icon': Icons.support_agent_outlined,
    },
    {
      'value': 'waka',
      'label': 'Wakil Kepala Sekolah',
      'icon': Icons.admin_panel_settings_outlined,
    },
    {
      'value': 'kelas',
      'label': 'Akun Kelas',
      'icon': Icons.meeting_room_outlined,
    },
  ];

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  InputDecoration _inputDecoration({
    required String hintText,
    required IconData prefixIcon,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      hintText: hintText,
      hintStyle: const TextStyle(
        color: Color(0xFF9AA4B2),
        fontSize: 14,
      ),
      prefixIcon: Icon(
        prefixIcon,
        color: const Color(0xFF7A869A),
        size: 21,
      ),
      suffixIcon: suffixIcon,
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 16,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(
          color: _borderColor,
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(
          color: _borderColor,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(
          color: _primaryColor,
          width: 1.5,
        ),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(
          color: Colors.red,
        ),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(
          color: Colors.red,
          width: 1.5,
        ),
      ),
    );
  }

  /// Mengirim identitas dan password ke API Laravel.
  Future<void> _login() async {
    FocusScope.of(context).unfocus();

    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedRole == null) {
      _showMessage('Pilih jenis akun terlebih dahulu.');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final response = await http
          .post(
            Uri.parse('$_baseUrl/login'),
            headers: {
              'Accept': 'application/json',
              'Content-Type': 'application/json',
            },
            body: jsonEncode({
              'identitas': _usernameController.text.trim(),
              'password': _passwordController.text,
              'jenisakun': _selectedRole,
            }),
          )
          .timeout(const Duration(seconds: 20));

      Map<String, dynamic> responseData;

      try {
        final decoded = jsonDecode(response.body);

        if (decoded is! Map<String, dynamic>) {
          throw const FormatException(
            'Format respons server tidak sesuai.',
          );
        }

        responseData = decoded;
      } on FormatException {
        if (mounted) {
          _showMessage(
            'Respons server tidak valid. Periksa konfigurasi API Laravel.',
          );
        }
        return;
      }

      if (response.statusCode == 200 &&
          responseData['success'] == true) {
        final token = responseData['token'];
        final user = responseData['user'];

        if (token is! String ||
            token.isEmpty ||
            user is! Map<String, dynamic>) {
          if (mounted) {
            _showMessage(
              'Data login dari server tidak lengkap.',
            );
          }
          return;
        }

        // Pastikan role yang diterima sesuai pilihan akun.
        if (user['role'] != _selectedRole) {
          if (mounted) {
            _showMessage(
              'Jenis akun dari server tidak sesuai.',
            );
          }
          return;
        }

        // Simpan token dan data akun untuk penggunaan berikutnya.
        final preferences = await SharedPreferences.getInstance();

        await preferences.setString('auth_token', token);
        await preferences.setString(
          'user_data',
          jsonEncode(user),
        );
        await preferences.setString(
          'user_role',
          user['role'].toString(),
        );

        if (!mounted) return;

        _showMessage('Login berhasil.');

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => DashboardScreen(
              initialRole: user['role'].toString(),
            ),
          ),
        );

        return;
      }

      // Menampilkan pesan kesalahan dari Laravel.
      final message = responseData['message'];

      if (mounted) {
        _showMessage(
          message is String && message.isNotEmpty
              ? message
              : 'Login gagal. Periksa identitas dan password.',
        );
      }
    } on TimeoutException {
      if (mounted) {
        _showMessage(
          'Koneksi ke server terlalu lama. Coba lagi.',
        );
      }
    } on http.ClientException {
      if (mounted) {
        _showMessage(
          'Tidak dapat terhubung ke server Laravel. '
          'Pastikan server aktif dan alamat API benar.',
        );
      }
    } catch (e) {
      if (mounted) {
        _showMessage(
          'Terjadi kesalahan saat login. Silakan coba lagi.',
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        backgroundColor: _primaryColor,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _backgroundColor,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(
              horizontal: 24,
              vertical: 32,
            ),
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: 420,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildHeader(),
                  const SizedBox(height: 32),
                  _buildLoginCard(),
                  const SizedBox(height: 24),
                  const Text(
                    'School Class Progress',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Color(0xFF7A869A),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        Container(
          width: 76,
          height: 76,
          decoration: BoxDecoration(
            color: _primaryColor,
            borderRadius: BorderRadius.circular(22),
          ),
          child: const Icon(
            Icons.school_outlined,
            size: 38,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 20),
        const Text(
          'School Class Progress',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: _primaryColor,
            fontSize: 25,
            fontWeight: FontWeight.bold,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Silakan masuk ke akun Anda',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Color(0xFF7A869A),
            fontSize: 14,
          ),
        ),
      ],
    );
  }

  Widget _buildLoginCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFFE8ECF2),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Masuk',
              style: TextStyle(
                color: _primaryColor,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Pilih jenis akun, lalu masukkan username dan password.',
              style: TextStyle(
                color: Color(0xFF7A869A),
                fontSize: 13,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 24),

            const _FieldLabel('Jenis Akun'),
            const SizedBox(height: 8),

            DropdownButtonFormField<String>(
              value: _selectedRole,
              isExpanded: true,
              decoration: _inputDecoration(
                hintText: 'Pilih jenis akun',
                prefixIcon: Icons.person_outline,
              ),
              items: _roles.map((role) {
                return DropdownMenuItem<String>(
                  value: role['value'] as String,
                  child: Row(
                    children: [
                      Icon(
                        role['icon'] as IconData,
                        color: _primaryColor,
                        size: 20,
                      ),
                      const SizedBox(width: 12),
                      Flexible(
                        child: Text(
                          role['label'] as String,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Color(0xFF253858),
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
              onChanged: _isLoading
                  ? null
                  : (value) {
                      setState(() {
                        _selectedRole = value;
                      });
                    },
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Pilih jenis akun terlebih dahulu.';
                }
                return null;
              },
            ),

            const SizedBox(height: 20),

            const _FieldLabel('Username'),
            const SizedBox(height: 8),

            TextFormField(
              controller: _usernameController,
              keyboardType: TextInputType.text,
              textInputAction: TextInputAction.next,
              enabled: !_isLoading,
              decoration: _inputDecoration(
                hintText: 'Masukkan username',
                prefixIcon: Icons.person_outline,
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Username wajib diisi.';
                }
                return null;
              },
            ),

            const SizedBox(height: 20),

            const _FieldLabel('Password'),
            const SizedBox(height: 8),

            TextFormField(
              controller: _passwordController,
              obscureText: _obscurePassword,
              textInputAction: TextInputAction.done,
              enabled: !_isLoading,
              onFieldSubmitted: (_) => _login(),
              decoration: _inputDecoration(
                hintText: 'Masukkan password',
                prefixIcon: Icons.lock_outline,
                suffixIcon: IconButton(
                  tooltip: _obscurePassword
                      ? 'Tampilkan password'
                      : 'Sembunyikan password',
                  onPressed: () {
                    setState(() {
                      _obscurePassword = !_obscurePassword;
                    });
                  },
                  icon: Icon(
                    _obscurePassword
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined,
                    color: const Color(0xFF7A869A),
                    size: 21,
                  ),
                ),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Password wajib diisi.';
                }
                return null;
              },
            ),

            const SizedBox(height: 28),

            SizedBox(
              height: 50,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _login,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _primaryColor,
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: const Color(0xFF9AA4B2),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isLoading
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Masuk',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          SizedBox(width: 8),
                          Icon(
                            Icons.arrow_forward_rounded,
                            size: 19,
                          ),
                        ],
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FieldLabel extends StatelessWidget {
  final String text;

  const _FieldLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        color: Color(0xFF253858),
        fontSize: 13,
        fontWeight: FontWeight.w600,
      ),
    );
  }
}