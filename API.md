# Kontrak API (sisi Laravel)

Dipakai saat `ApiConfig.useMock = false`. Autentikasi: token Bearer (mis. Laravel Sanctum).
Semua respons JSON; daftar boleh berupa `[...]` atau `{ "data": [...] }`.
Error validasi: status 4xx dengan `{ "message": "..." }` (pesan ini ditampilkan langsung ke pengguna).
Nama field memakai camelCase tanpa underscore. Jika kolom/resource Anda berbeda, ubah di `lib/models/*.dart` (`fromJson`).

## Auth
- `POST /login` `{identitas, password, jenisakun}` -> `{token, user:{id,name,email,role,nisn?,kodepegawai?,kodekelas?,kelasid?}}`
  `jenisakun`: siswa | orangtua | guru | bk | waka | kelas
  `role` dari Laravel memakai `orangtua` untuk akun orang tua.
- `POST /logout`
- `GET /user`
- `POST /register` `{identitas,name,password,password_confirmation,jenisakun}`
- `POST /lupa-password` `{identitas,jenisakun}` (mengajukan permintaan ke admin)
- `POST /ganti-password` `{passwordLama,passwordBaru,passwordBaru_confirmation}`
- `GET /profil`, `PUT /profil` `{name,alamat,nomortelepon}`

Catatan: reset password membutuhkan proses admin karena server belum memiliki
email/SMS gateway. Endpoint `/lupa-password` memvalidasi akun dan mencatat
permintaan, tetapi tidak mengubah password secara otomatis.

## Master
- `GET /kelas` -> `["XI RPL 1", ...]`
- `GET /guru` -> `[{id,nama,username,mapel,namaSk?}]`
- `GET /siswa?kelas=` -> `[{id,nisn,nama,kelas,jurusan}]`
- `POST /guru/{id}/sk` multipart `file` (Waka)

## Jadwal
- `GET /jadwal?kelas=&guruId=&hari=` -> `[{id,kelas,hari(1-5),jamMulai,jamSelesai,mapel,guruId,guruNama,ruangan?,putaranBlok?,blok?,tanggalMulaiBlok?,tanggalSelesaiBlok?}]`
- `POST /jadwal` `{kelas,hari,jamMulai,jamSelesai,mapel,guruId}` (Guru). Tolak jika dikunci atau bentrok.
- `PUT /jadwal/{id}`, `DELETE /jadwal/{id}`
- `PUT /jadwal/{id}/ruangan` `{ruangan}` (Waka). Tolak jika ruangan bentrok.
- `GET /jadwal/kunci` -> `{terkunci}`; `PUT /jadwal/kunci` `{terkunci}` (Waka)

Aturan bentrok: jam tumpang tindih pada hari yang sama untuk kelas yang sama, atau guru/ruangan yang sama
pada kelas yang satu putaran (kelas ganjil = Putaran 1, genap = Putaran 2; kelas beda putaran tidak bentrok).

## Presensi
- `GET /presensi?jadwalId=&tanggal=&dari=&sampai=&kelas=&mapel=&siswaId=&guruId=`
  -> `[{id,jadwalId,tanggal,kelas,mapel,siswaId,siswaNama,status,keterangan}]` (`status`: hadir|izin|sakit|alpa)
- `POST /presensi/sesi` `{jadwalId, tanggal, data:[{siswaId,status,keterangan}]}` (mengganti presensi sesi itu; catat riwayat)

## Izin
- `GET /izin?siswaId=&kelas=&status=&tanggal=&dari=&sampai=`
  -> `[{id,siswaId,siswaNama,kelas,tanggal,jenis,alasan,buktiNama?,buktiUrl?,diajukanOleh,waktuAjuan,status,diprosesOleh?,waktuProses?,catatan?}]`
- `POST /izin` multipart `{tanggal,jenis,alasan}` + file `bukti` (Siswa/Ortu; `siswaId` dari token)
- `POST /izin/{id}/bukti` multipart file `bukti` untuk mengirim ulang bukti yang ditolak
- `PUT /izin/{id}/proses` `{setuju, catatan?}` (BK, atau Wali Kelas untuk kelasnya).
  Hanya jika masih `menunggu`; siapa pun yang memproses lebih dulu berlaku, yang kedua dapat 4xx
  `Izin sudah disetujui oleh ...`.
- `GET /izin/info-guru?tanggal=` izin pada kelas yang diajar guru (informasi saja)

## Jurnal
- `GET /jurnal?jadwalId=&tanggal=&guruId=&kelas=&dari=&sampai=` -> `[{id,jadwalId,tanggal,kelas,mapel,guruId,guruNama,materi,catatan,fotoUrl,waktuSimpan}]`
- `POST /jurnal` multipart `{jadwalId,tanggal,materi,catatan}` + file `foto`. Jurnal hari ini dapat diperbarui;
- `POST /import/siswa`, `/import/presensi`, `/import/jurnal` multipart file `.xlsx`
  (Guru/Waka; baris pertama adalah header kolom).
  produksi: hanya saat jam pelajaran berlangsung.
- `GET /jurnal/belum-diisi` -> daftar jadwal (format jadwal) yang sudah masuk 30 menit terakhir pelajaran dan jurnalnya belum ada

## Notifikasi, riwayat, dashboard
- `GET /notifikasi` -> `[{id,judul,isi,waktu,dibaca}]`; `PUT /notifikasi/{id}/baca`; `PUT /notifikasi/baca-semua`
- `POST /notifikasi/peringatan` `{guruId,pesan}` (Waka)
- `GET /riwayat?modul=&q=` -> `[{id,modul,aksi,oleh,waktu,sebelum,sesudah}]`
- `GET /dashboard/waka` -> `{totalSiswa,totalGuru,totalSesi,sesiPresensi,sesiJurnal,persenHadir,izinMenunggu,belumIsi:[{jadwal:{...},presensiOk,jurnalOk}]}`

Aturan keamanan data:
- Presensi dan jurnal hanya dapat dibuat atau diedit pada tanggal hari ini.
- Jurnal wajib memakai foto kamera dari aplikasi; server menolak jurnal baru tanpa foto.
- Izin hanya dapat diproses BK atau wali kelas sesuai kelasnya. Setelah BK memproses,
  wali kelas tidak dapat memproses ulang. Bukti hanya dapat dikirim ulang jika ditolak.
- Endpoint `POST /jurnal` memperbarui jurnal yang sama bila masih tanggal hari ini.
