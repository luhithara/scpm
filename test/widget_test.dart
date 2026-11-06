import 'package:flutter_test/flutter_test.dart';
import 'package:scp/utils/blokputaran.dart';

void main() {
  test('putaran kelas: ganjil = 1, genap = 2', () {
    expect(BlokPutaran.putaranKelas('XI RPL 1'), 1);
    expect(BlokPutaran.putaranKelas('XI RPL 2'), 2);
    expect(BlokPutaran.putaranKelas('XI TKJ 3'), 1);
  });

  test('putaran aktif bergantian tiap 2 minggu', () {
    expect(BlokPutaran.putaranAktif(DateTime(2026, 10, 26)), 1);
    expect(BlokPutaran.putaranAktif(DateTime(2026, 11, 2)), 1);
    expect(BlokPutaran.putaranAktif(DateTime(2026, 11, 9)), 2);
    expect(BlokPutaran.putaranAktif(DateTime(2026, 11, 23)), 1);
    expect(BlokPutaran.mingguKe(DateTime(2026, 11, 2)), 2);
  });
}
