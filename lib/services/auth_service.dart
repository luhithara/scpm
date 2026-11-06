import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../config/api_config.dart';
import '../models/usermodel.dart';
import 'api_services.dart';
import 'mock_store.dart';

class AuthService {
  AuthService._();
  static final AuthService instance = AuthService._();

  UserModel? current;

  Future<void> restore() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString('scpuser');
      if (raw != null) {
        current = UserModel.fromJson(Map<String, dynamic>.from(jsonDecode(raw) as Map));
        ApiServices.instance.token = current?.token;
      }
    } catch (_) {
      current = null;
    }
  }

  Future<UserModel> login(String username, String password, {String jenisAkun = 'siswa'}) async {
    UserModel user;
    if (ApiConfig.useMock) {
      await Future.delayed(const Duration(milliseconds: 400));
      user = MockStore.instance.login(username, password);
    } else {
      final res = await ApiServices.instance.post('/login', body: {
        'identitas': username.trim(),
        'password': password,
        'jenisakun': jenisAkun,
      });
      final map = Map<String, dynamic>.from(res as Map);
      user = UserModel.fromJson(Map<String, dynamic>.from(map['user'] as Map), token: map['token']?.toString());
    }
    current = user;
    ApiServices.instance.token = user.token;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('scpuser', jsonEncode(user.toJson()));
    return user;
  }

  Future<void> logout() async {
    if (!ApiConfig.useMock) {
      try {
        await ApiServices.instance.post('/logout');
      } catch (_) {}
    }
    current = null;
    ApiServices.instance.token = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('scpuser');
  }

  Future<void> gantiPassword(String lama, String baru) async {
    if (ApiConfig.useMock) {
      MockStore.instance.gantiPassword(current!.username, lama, baru);
      return;
    }
    await ApiServices.instance.post('/ganti-password', body: {
      'passwordLama': lama,
      'passwordBaru': baru,
      'passwordBaru_confirmation': baru,
    });
  }

  Future<void> updateProfile({required String nama, String? alamat, String? telepon}) async {
    if (ApiConfig.useMock) return;
    await ApiServices.instance.put('/profil', body: {
      'name': nama,
      'alamat': alamat,
      'nomortelepon': telepon,
    });
    final old = current!;
    current = UserModel(
      id: old.id,
      nama: nama,
      username: old.username,
      role: old.role,
      kelas: old.kelas,
      mapel: old.mapel,
      token: old.token,
    );
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('scpuser', jsonEncode(current!.toJson()));
  }

  Future<String> lupaPassword(String username, {String jenisAkun = 'siswa'}) async {
    if (ApiConfig.useMock) return MockStore.instance.lupaPassword(username);
    final res = await ApiServices.instance.post('/lupa-password', body: {
      'identitas': username.trim(),
      'jenisakun': jenisAkun,
    });
    return (res is Map && res['message'] != null) ? res['message'].toString() : 'Permintaan reset password terkirim.';
  }

  Future<UserModel> register({
    required String identitas,
    required String nama,
    required String password,
    required String jenisAkun,
  }) async {
    final UserModel user;
    if (ApiConfig.useMock) {
      user = MockStore.instance.register(identitas, nama, password, jenisAkun);
    } else {
      final res = await ApiServices.instance.post('/register', body: {
        'identitas': identitas.trim(),
        'name': nama.trim(),
        'password': password,
        'password_confirmation': password,
        'jenisakun': jenisAkun,
      });
      final map = Map<String, dynamic>.from(res as Map);
      user = UserModel.fromJson(Map<String, dynamic>.from(map['user'] as Map), token: map['token']?.toString());
    }
    current = user;
    ApiServices.instance.token = user.token;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('scpuser', jsonEncode(user.toJson()));
    return user;
  }
}
