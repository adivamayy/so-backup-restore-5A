# Analisis Backup, Lock, Logging, dan Laporan (Rania)

## Identitas
Nama: Rania Lionar
Bagian: Backup, Lock, Logging, dan Laporan
Project: so-backup-restore-5A

## 1. Backup Archive

Script `scripts/backup.sh` digunakan untuk membuat arsip
backup dengan format `.tar.gz`.

Proses backup meliputi:
- Memeriksa parameter dan direktori sumber.
- Membuat direktori tujuan jika belum tersedia.
- Membuat arsip menggunakan perintah `tar`.
- Menyimpan arsip dengan nama berdasarkan waktu.
- Menghasilkan checksum SHA-256 menggunakan `sha256sum`.

Pengujian dilakukan menggunakan direktori sumber yang berisi
file `contoh.txt`. Arsip berhasil dibuat dan isi arsip
sesuai dengan direktori sumber.

## 2. Lock Mechanism

Mekanisme lock menggunakan `flock` untuk memastikan hanya satu
proses backup yang berjalan dalam satu waktu.

Lock menggunakan mode non-blocking (`flock -n`).
Jika proses lain sedang menggunakan lock, proses berikutnya
ditolak dengan exit code 6.

Pengujian:
- Proses pertama berhasil mendapatkan lock.
- Proses kedua ditolak ketika lock masih aktif.
- Exit code proses kedua adalah 6.

## 3. Logging

Aktivitas backup dicatat ke folder `logs` dengan nama file
berdasarkan tanggal.

Informasi log meliputi:
- Waktu aktivitas.
- Level log (INFO/ERROR).
- Process ID (PID).
- Pesan aktivitas.

Log mencatat proses mendapatkan lock, memulai backup,
membuat arsip, membuat checksum, membuat laporan,
dan menyelesaikan backup.

## 4. Backup Report

Script `scripts/report.sh` digunakan untuk membuat laporan
backup di `output/laporan.txt` secara default.

Informasi laporan meliputi:
- Waktu backup.
- Nama dan lokasi arsip.
- File checksum yang digunakan.
- Hasil verifikasi integritas arsip.
- Detail keluaran proses verifikasi.

Script laporan memanggil `scripts/verify.sh` untuk memeriksa
integritas arsip berdasarkan SHA-256.

Pengujian menunjukkan laporan berhasil dibuat dengan
hasil verifikasi VALID.

## 5. SHA-256 Integrity Testing

Pengujian verifikasi dilakukan menggunakan script
`scripts/verify.sh`.

Skenario positif:
- Arsip dan checksum sesuai.
- Hasil verifikasi RESULT: OK.
- Exit code 0.

Skenario negatif:
- Arsip dimodifikasi setelah checksum dibuat.
- Nilai hash aktual berbeda dengan hash yang diharapkan.
- Hasil verifikasi RESULT: FAILED.
- Exit code 4.

## 6. Docker Read-Only Testing

Pengujian Docker dilakukan menggunakan image Alpine 3.22
dan bind mount dengan opsi read-only.

Hasil pengujian:
- Container berhasil membaca file.
- Percobaan menulis ditolak dengan pesan
  `Read-only file system`.
- Exit code percobaan menulis adalah 1.
- Checksum file sebelum dan sesudah percobaan tetap sama.

Bukti disimpan di `evidence/docker_readonly_rania.txt`.

## 7. Testing Evidence

Bukti pekerjaan Rania disimpan di folder `evidence`:
- `uji_lock.txt`: pengujian konkurensi menggunakan flock.
- `log_contoh.txt`: contoh hasil logging.
- `docker_readonly_rania.txt`: pengujian Docker read-only.
- `uji_backup_rania.txt`: pengujian pembuatan arsip,
  checksum, logging, dan laporan.
- `uji_checksum_lock_rania.txt`: pengujian checksum rusak
  dan penolakan backup bersamaan.

## 8. Implementation Status

- Backup archive generation: Implemented and tested.
- SHA-256 checksum generation: Implemented and tested.
- Lock mechanism: Implemented and tested.
- Logging: Implemented and tested.
- Backup report generator: Implemented and tested.
- Checksum integrity verification: Tested for valid and
  modified archives.
- Docker read-only testing: Implemented and tested.

Catatan:
Pengujian backup dilakukan menggunakan direktori sementara
di `/tmp/rania_backup_test`. Integrasi dengan script dan
kontribusi anggota tim lainnya masih dapat dilanjutkan
pada tahap integrasi sistem.
