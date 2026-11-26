# Otomasi Backup & Pemulihan Data di Linux

**Proyek 5A | Kelompok 6 | Kelas SI-PBI**

Sistem berbasis shell script untuk memvalidasi sumber data, membuat arsip backup, memverifikasi integritasnya, dan memulihkannya kembali. Dilengkapi pengamanan lewat lock (`flock`), pengaturan permission, dan pengujian dengan Docker.

## Anggota dan Pembagian Tugas

| Anggota | Bagian | 
|---|---|
| Adiva Mayyadah Putri Praset | Validasi sumber dan parameter |
| Ahmad Nafis Ridho | Pembuatan arsip `.tar.gz` bertimestamp |
| Khansa | Verifikasi integritas dengan `sha256sum` |
| Muhammad Naufal Ghani | Pemulihan data (restore) |
| Rania Lionar | Lock `flock`, log, laporan, dan Docker |

## Lingkungan

- Ubuntu 26.04 LTS di atas WSL2 (tanpa desktop)
- Bash, `tar`, `sha256sum`, `flock`
- Docker (image Alpine 3.22) untuk uji bind mount read-only

## Struktur Repository

```
.
├── README.md
├── scripts/     # script utama (validasi, backup, verifikasi, restore)
├── config/      # konfigurasi pembatasan akses
├── tests/       # skrip pengujian (positif dan negatif)
├── docs/        # draf analisis konsep SO per anggota
├── evidence/    # bukti uji (output terminal)
└── .gitignore
```

## Cara Menjalankan

> Sesuaikan nama script dan parameter dengan isi folder `scripts/`.

```bash
# 1. Beri izin eksekusi (sekali saja)
chmod +x scripts/*.sh

# 2. Validasi direktori sumber
./scripts/validate.sh <direktori_sumber>

# 3. Buat backup
./scripts/backup.sh <direktori_sumber> <direktori_tujuan>

# 4. Verifikasi integritas arsip
./scripts/verify.sh <file_arsip.tar.gz>

# 5. Restore ke direktori uji
./scripts/restore.sh <file_arsip.tar.gz> <direktori_restore>
```

## Kode Exit Status

| Kode | Arti |
|---|---|
| 0 | Sukses |
| 2 | Direktori sumber tidak valid |
| 3 | Direktori tujuan tidak bisa ditulis |
| 4 | Verifikasi checksum gagal |
| 5 | Arsip rusak saat restore |
| 6 | Proses ditolak karena lock sedang aktif |

Setiap kegagalan punya kode berbeda, sehingga penyebab masalah bisa diketahui langsung dari exit status.

## Pengujian

Setiap bagian diuji dengan skenario positif dan negatif:

- **Validasi:** direktori valid (exit 0), tidak ada atau tidak bisa dibaca (exit 2)
- **Arsip:** arsip terbentuk dan isinya sesuai (`tar -tzf`), tujuan tidak bisa ditulis (exit 3)
- **Verifikasi:** checksum cocok (OK, exit 0), isi arsip diubah (FAILED, exit 4)
- **Restore:** hasil identik dengan sumber (`diff -r`), arsip rusak ditolak (exit 5)
- **Lock:** dua backup bersamaan, proses kedua ditolak (exit 6)
- **Docker:** bind mount read-only, baca berhasil (exit 0), tulis ditolak (exit 1), checksum file host tetap sama

Bukti pengujian ada di folder `evidence/` dan `tests/`.

## Status

Estimasi kesiapan saat Checkpoint 2: sekitar 50%.

Belum selesai: laporan utama teori SO, fork dan `PORTOFOLIO.md`, pengamatan CPU dan memori, serta konfigurasi pembatasan akses di `config/`.

## Catatan

Seluruh pengujian memakai data dummy di VM Linux, tanpa rekayasa keluaran. Repository bebas dari password, token, private key, dan data pribadi.
