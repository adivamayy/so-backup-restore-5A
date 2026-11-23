# Analisis Backup, Lock, Logging, dan Laporan (Rania)

## Identitas
Nama: Rania Lionar
Bagian: Backup, Lock, Logging, dan Laporan
Project: so-backup-restore-5A

## 1. Lock Mechanism
Mekanisme lock menggunakan `flock` untuk memastikan hanya satu
proses backup yang berjalan dalam satu waktu.

Lock menggunakan mode non-blocking (`flock -n`). Jika proses lain
sedang menggunakan lock, proses berikutnya ditolak dengan exit code 6.

Pengujian konkurensi telah dilakukan dengan menjalankan dua proses
backup secara bersamaan. Proses pertama berhasil mendapatkan lock,
sedangkan proses kedua ditolak.

## 2. Logging
Aktivitas dicatat ke folder `logs` dengan nama file berdasarkan tanggal.

Informasi log meliputi:
- Waktu aktivitas
- Level log (INFO/ERROR)
- Process ID (PID)
- Pesan aktivitas

## 3. Backup Report
Script `scripts/report.sh` digunakan untuk membuat laporan backup
di `output/laporan.txt`.

Informasi laporan meliputi:
- Waktu backup
- Nama dan lokasi arsip
- File checksum yang digunakan
- Hasil verifikasi integritas arsip
- Detail keluaran proses verifikasi

Script laporan memanggil `scripts/verify.sh` untuk memeriksa
integritas arsip berdasarkan SHA-256.

Integrasi dengan arsip hasil backup sebenarnya menunggu script
pembuatan arsip dan format checksum dari anggota tim terkait.

## 4. Docker Read-Only Testing
Pengujian Docker dilakukan menggunakan image Alpine 3.22 dan
bind mount dengan opsi `readonly`.

Hasil pengujian:
- Container berhasil membaca file laporan.
- Percobaan menulis ke file ditolak dengan pesan
  `Read-only file system`.
- Exit code percobaan menulis adalah 1.
- Checksum file sebelum dan sesudah percobaan tetap sama.

Bukti disimpan di `evidence/docker_readonly_rania.txt`.

## 5. Testing Evidence
Bukti pekerjaan Rania disimpan di folder `evidence`:
- `uji_lock.txt`: pengujian konkurensi menggunakan flock.
- `log_contoh.txt`: contoh hasil logging.
- `docker_readonly_rania.txt`: pengujian Docker read-only.

## 6. Implementation Status
- Lock mechanism: Implemented and tested.
- Logging: Implemented and tested.
- Docker read-only: Implemented and tested.
- Backup report generator: Implemented; integration test uses a temporary archive.
- Actual backup archive integration: Waiting for the team's backup script.
- Actual checksum integration: Waiting for the team's checksum output.
