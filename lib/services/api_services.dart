import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';

class AppException implements Exception {
  final String message;
  const AppException(this.message);

  @override
  String toString() => message;
}

String pesanError(Object e) => e is AppException ? e.message : 'Terjadi kesalahan, coba lagi';

class ApiServices {
  ApiServices._();
  static final ApiServices instance = ApiServices._();

  String? token;

  Map<String, String> get _headers => {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      };

  Uri _uri(String path, [Map<String, dynamic>? query]) {
    final q = <String, String>{};
    query?.forEach((k, v) {
      if (v != null && v.toString().isNotEmpty) q[k] = v.toString();
    });
    return Uri.parse('${ApiConfig.baseUrl}$path').replace(queryParameters: q.isEmpty ? null : q);
  }

  dynamic _decode(http.Response res) {
    dynamic body;
    try {
      body = res.body.isEmpty ? null : jsonDecode(res.body);
    } catch (_) {
      body = null;
    }
    if (res.statusCode >= 200 && res.statusCode < 300) return body;
    var msg = 'Terjadi kesalahan (${res.statusCode})';
    if (body is Map && body['message'] != null) msg = body['message'].toString();
    if (body is Map && body['errors'] is Map && (body['errors'] as Map).isNotEmpty) {
      final first = (body['errors'] as Map).values.first;
      if (first is List && first.isNotEmpty) msg = first.first.toString();
    }
    if (res.statusCode == 401) msg = 'Sesi berakhir, silakan login ulang';
    throw AppException(msg);
  }

  Future<T> _run<T>(Future<T> Function() f) async {
    try {
      return await f().timeout(ApiConfig.timeout);
    } on AppException {
      rethrow;
    } catch (_) {
      throw const AppException('Tidak dapat terhubung ke server');
    }
  }

  Future<dynamic> get(String path, {Map<String, dynamic>? query}) =>
      _run(() async => _decode(await http.get(_uri(path, query), headers: _headers)));

  Future<dynamic> post(String path, {Map<String, dynamic>? body}) =>
      _run(() async => _decode(await http.post(_uri(path), headers: _headers, body: jsonEncode(body ?? {}))));

  Future<dynamic> put(String path, {Map<String, dynamic>? body}) =>
      _run(() async => _decode(await http.put(_uri(path), headers: _headers, body: jsonEncode(body ?? {}))));

  Future<dynamic> delete(String path) =>
      _run(() async => _decode(await http.delete(_uri(path), headers: _headers)));

  Future<dynamic> postMultipart(String path, Map<String, String> fields,
      {Map<String, String> files = const {}}) =>
      _run(() async {
        final req = http.MultipartRequest('POST', _uri(path));
        req.headers.addAll({
          'Accept': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        });
        req.fields.addAll(fields);
        for (final e in files.entries) {
          req.files.add(await http.MultipartFile.fromPath(e.key, e.value));
        }
        return _decode(await http.Response.fromStream(await req.send()));
      });

  Future<List<T>> list<T>(String path, T Function(Map<String, dynamic>) parse,
      {Map<String, dynamic>? query}) async {
    final d = await get(path, query: query);
    final raw = d is List ? d : (d is Map && d['data'] is List ? d['data'] as List : <dynamic>[]);
    return raw.map((e) => parse(Map<String, dynamic>.from(e as Map))).toList();
  }

  Map<String, dynamic> asMap(dynamic d) {
    if (d is Map && d['data'] is Map) return Map<String, dynamic>.from(d['data'] as Map);
    if (d is Map) return Map<String, dynamic>.from(d);
    return {};
  }
}
