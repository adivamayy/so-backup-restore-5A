
# Analisis Implementasi Verifikasi Integritas Backup dan Proteksi Akses

## 1. Verifikasi Integritas Backup Menggunakan SHA-256

Verifikasi integritas backup dilakukan untuk memastikan bahwa file arsip backup tidak mengalami perubahan atau kerusakan setelah proses pembuatan arsip. Proses verifikasi menggunakan algoritma SHA-256 melalui perintah `sha256sum`.

Script `scripts/verify.sh` digunakan untuk membandingkan nilai checksum aktual dari file arsip dengan nilai checksum yang tersimpan pada file checksum. Apabila kedua nilai sesuai, arsip dinyatakan berhasil diverifikasi. Sebaliknya, apabila nilainya berbeda, script akan memberikan pesan kegagalan.

## 2. Mekanisme Kerja Script

Script verifikasi melakukan beberapa tahapan, yaitu:

1. Memeriksa jumlah parameter yang diberikan.
2. Memastikan file arsip tersedia dan dapat dibaca.
3. Memastikan file checksum tersedia dan dapat dibaca.
4. Memeriksa format checksum agar terdiri dari 64 karakter hexadecimal.
5. Menghitung checksum aktual menggunakan `sha256sum`.
6. Membandingkan checksum aktual dengan checksum yang tersimpan.
7. Menampilkan hasil verifikasi beserta exit status.

Exit status digunakan untuk menunjukkan hasil proses verifikasi. Exit code 0 menunjukkan verifikasi berhasil, sedangkan exit code 4 menunjukkan checksum tidak sesuai. Kesalahan input atau file ditangani menggunakan exit status sesuai implementasi script.

## 3. Hasil Pengujian

Pengujian dilakukan menggunakan file dummy untuk memastikan mekanisme verifikasi berjalan sesuai skenario yang ditentukan.

### A. Skenario Positif

File arsip dan file checksum memiliki nilai SHA-256 yang sesuai. Script berhasil melakukan verifikasi dan menghasilkan status OK dengan exit code 0.

### B. Skenario Negatif

Isi file arsip diubah setelah checksum dibuat, sehingga nilai checksum aktual berbeda dari nilai checksum yang tersimpan. Script berhasil mendeteksi perbedaan tersebut dan menghasilkan status FAILED dengan exit code 4.

Pengujian menggunakan arsip backup asli proyek masih perlu dilakukan setelah file arsip dari proses backup tersedia.

## 4. Proteksi Akses Backup

Proteksi akses backup berkaitan dengan pengaturan permission, user, dan group pada sistem Linux. Pengaturan ini bertujuan membatasi akses terhadap file atau direktori backup agar hanya pengguna yang memiliki izin yang sesuai dapat mengaksesnya.

Pengujian pembatasan akses backup oleh Khansa perlu dilengkapi dengan pengaturan permission serta pengujian menggunakan akun yang berbeda. Hasil pengujian tersebut didokumentasikan setelah implementasinya dilakukan.

## 5. Kesimpulan

Implementasi verifikasi SHA-256 memungkinkan sistem mendeteksi perubahan pada file arsip backup melalui perbandingan checksum. Berdasarkan pengujian menggunakan file dummy, script dapat mengenali kondisi checksum yang sesuai maupun berbeda.

Pengujian lanjutan menggunakan arsip backup asli serta pengujian pembatasan akses menggunakan user dan group diperlukan untuk melengkapi integrasi dan validasi fitur.
