## 7. Hasil Eksperimen Permission Direktori

Pengujian dilakukan menggunakan dua akun Linux, yaitu `adivamay` sebagai pemilik direktori dan `penguji` sebagai pengguna berbeda.

### A. Pengujian Permission 700

Direktori `/tmp/uji_tertutup` diberikan permission 700. Hasil pengujian menunjukkan bahwa akun `penguji` tidak dapat mengakses direktori tersebut.

Script validasi memberikan pesan bahwa sumber tidak dapat dibaca dan menghasilkan exit status 2.

### B. Pengujian Permission 704

Pada permission 704, pengguna lain dapat membaca daftar nama file dalam direktori, tetapi tidak dapat mengakses isi file karena tidak memiliki izin execute pada direktori.

### C. Pengujian Permission 701

Pada permission 701, pengguna lain tidak dapat menampilkan daftar isi direktori. Namun, pengguna masih dapat mengakses file melalui nama yang sudah diketahui apabila permission file mengizinkannya.

### Kesimpulan Eksperimen

Pengujian membuktikan bahwa permission read dan execute memiliki fungsi berbeda dalam pengelolaan direktori Linux. Script validasi memanfaatkan pemeriksaan akses untuk mencegah proses backup berjalan menggunakan sumber yang tidak dapat diakses oleh pengguna.
