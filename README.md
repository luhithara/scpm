# SCP Mobile (Flutter)

Aplikasi mobile School Class Progress: presensi, jurnal mengajar, jadwal, dan perizinan siswa.

## Menjalankan
```bash
flutter pub get
flutter run
```
Secara default aplikasi berjalan **mode demo** (data lokal, tanpa server). Di layar login ada panel
"Akun demo" (password `123456`) untuk setiap role.

## Beralih ke API Laravel
Edit `lib/config/api_config.dart`:
- `useMock = false`
- `baseUrl` -> alamat API (emulator Android: `10.0.2.2`, HP fisik: IP laptop)

Daftar endpoint yang dibutuhkan ada di `API.md`.

Login API Laravel menggunakan `identitas`, `password`, dan `jenisakun`. Pada
aplikasi mobile, jenis akun portal yang tersedia adalah **Siswa** dan **Orang
Tua**. Keduanya dapat memakai NISN yang sama tetapi password dan role tetap
dibedakan oleh Laravel.

API portal Laravel sekarang menyediakan `/status`, `/login`, `/register`,
`/user`, `/logout`, `/jadwal`, `/presensi`, `/izin`, `/profil`, dan
`/ganti-password`. Reset password masih berupa permintaan yang diteruskan ke
admin karena server belum dikonfigurasi untuk email/SMS.

## Role & tab
| Role | Tab |
|---|---|
| Waka Kurikulum | Beranda, Jadwal (kunci, ruangan, SK), Monitor presensi, Rekap, Profil |
| Guru | Beranda (presensi + jurnal), Jurnal, Jadwal, Izin (info), Profil |
| Siswa | Beranda, Presensi, Izin, Profil |
| Orang Tua | Izin, Profil |
| BK | Beranda, Izin (approve/tolak), Rekap, Profil |
| Wali Kelas | Beranda, Izin (kelas sendiri), Presensi kelas, Rekap, Profil |

## Struktur
```
lib/config     api_config, app_routes
lib/models     usermodel, jadwalmodel, presensimodel, izinmodel, jurnalmodel, ...
lib/services   api_services (HTTP), mock_store (data demo), *_service (pintu data untuk layar)
lib/screens    auth, guru, siswa, waka, bk, wali_kelas, shared
lib/widgets    scp_widgets (kartu, chip, FutureView, dll)
lib/utils      blokputaran (Putaran 1/2), format, jsonx
```

## Catatan
- Pengingat jurnal 30 menit sebelum pelajaran selesai saat ini berupa banner + notifikasi di dalam aplikasi.
  Push notification saat aplikasi tertutup butuh Firebase Cloud Messaging + scheduler di server.
- `ApiConfig.longgarJam = true` membuat jurnal bisa diisi kapan saja (untuk demo). Set `false` untuk produksi.
- `ApiConfig.blokAnchor` = Senin pertama Putaran 1. Sesuaikan dengan kalender sekolah.
