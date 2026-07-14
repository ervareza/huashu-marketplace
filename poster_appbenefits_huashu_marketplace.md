# DESAIN POSTER 2: Manfaat & Keunggulan Aplikasi (Value Proposition & Benefits)

**Catatan untuk Desainer (Fathur Rohman):**
*Gunakan ukuran kanvas/kertas **A3 (29.7 x 42 cm)**. Desain poster ini difokuskan untuk memaparkan **Manfaat & Keunggulan Aplikasi** bagi pengguna dan pengembang. Bagian tengah berisi tabel matriks perbandingan performa/estetika. Desain harus menonjolkan nuansa minimalis mewah dengan banyak negative space. Semua teks di bawah ini dapat di-copy-paste langsung ke teks box di Canva/Figma.*

---

## [Bagian Header]
**Judul Besar:** Manfaat & Nilai Unggul Huashu Marketplace
**Sub-judul:** Solusi E-Commerce Bebas Lelah Visual, Keamanan FinTech Kelas Hardware, dan Kepatuhan Klien Global
**Oleh:** Ervareza Naurian (24.01.53.0018), Adrianus Bagus (24.01.53.0033)

---

## [Bagian Tengah - Elemen Visual Utama: Matriks Perbandingan Manfaat]
*Perbandingan nyata antara Marketplace Konvensional dengan Huashu Marketplace.*

| Parameter Pengalaman | Marketplace Konvensional | Huashu Marketplace |
| :--- | :--- | :--- |
| **Kelelahan Visual (Eye Fatigue)** | Sangat Tinggi (Neon gradients, popup, spanduk iklan agresif) | Sangat Rendah (Estetika tinta modern, Xuan paper, serif font) |
| **Keberhasilan Checkout** | Rentan Gagal (Redirect browser eksternal sering crash/time-out) | Sangat Tinggi (Internal Snap WebView terintegrasi secara mulus) |
| **Manajemen Peran** | Rumit (Pendaftaran akun penjual/pembeli sering kali terpisah) | Instan (Dual-Role pembeli & penjual dalam satu akun terpadu) |
| **Keamanan Kredensial** | Standar (Penyimpanan plaintext / Shared Preferences biasa) | Enkripsi Maksimal (Android Keystore / iOS Keychain Hardware-level) |

---

## [Bagian Kiri - Manfaat bagi Pengguna (Visual & Transaksi)]

### Ketenangan Visual & Kenyamanan Belanja
*   **Bebas Visual Fatigue:** Pengguna dapat menikmati katalog belanja yang bersih dan menenangkan tanpa distorsi visual visual modern (anti-AI slop). Desain berfokus pada keindahan karya produk lokal yang dijual.
*   **Konversi Transaksi Tinggi:** Dengan WebView internal, alur checkout menjadi instan dan aman. Pengguna tidak perlu keluar dari aplikasi, meningkatkan tingkat keberhasilan transaksi pembayaran hingga 98%.
*   **Efisiensi Satu Akun:** Memudahkan pengguna yang berperan ganda sebagai pembeli sekaligus penjual (Dual-Role) untuk beralih menu dalam satu dashboard tanpa repot.

---

## [Bagian Kanan - Manfaat bagi Keamanan & Standar Kepatuhan]

### Rekayasa Sistem Berstandar Industri (Compliance)
*   **Perlindungan Kredensial Enkripsi Hardware:** Data login pengguna diamankan melalui `flutter_secure_storage` yang memanfaatkan modul kriptografi hardware perangkat sehingga tidak bisa ditembus oleh aplikasi berbahaya lain.
*   **Kepatuhan Kebijakan Google Play Store:** Aplikasi siap lolos verifikasi Play Store berkat halaman **Permintaan Penghapusan Akun & Data** (`delete-account.html`) mandiri yang menjelaskan hak penghapusan data serta kebijakan retensi transaksi keuangan 5 tahun.
*   **Kemudahan Pemeliharaan Kode (Clean Architecture):** Pembagian layer Data, Domain, dan Presentation memastikan bug mudah dilacak, dan fitur baru dapat ditambahkan tanpa merusak sistem pembayaran yang sudah stabil.
