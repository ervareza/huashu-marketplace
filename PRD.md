# 📋 Product Requirement Document (PRD) — Marketplace with Payment (Huashu Style)

---

## 1. Ringkasan Eksekutif & Visi Produk

### 1.1 Visi Produk
Platform **Marketplace with Payment (Huashu Style)** adalah aplikasi mobile berbasis **Flutter** yang dirancang untuk mendemokrasikan pengalaman berbelanja online melalui kombinasi fungsionalitas transaksi modern dan keanggunan estetika visual tradisional **Huashu Design** (Gaya Kesenian Lukisan Cat Air / Water-Ink Modern). Visi kami adalah membangun platform e-commerce premium yang menyajikan atmosfer belanja yang damai, terstruktur, berfokus pada konten produk, dan bebas dari distorsi visual modern (anti-AI design slop).

### 1.2 Tujuan Bisnis
*   **Pengalaman Transaksi Mulus**: Menyediakan alur pembayaran instan dan aman menggunakan integrasi **Midtrans Snap API** secara seamless di dalam aplikasi mobile.
*   **Apresiasi Nilai Estetika**: Menargetkan segmen pengguna yang menghargai keindahan tata letak minimalis, tipografi klasik, dan transisi visual mikro-animasi premium.
*   **Skalabilitas & Stabilitas Sistem**: Memberikan performa aplikasi mobile yang responsif dengan basis Clean Architecture yang tangguh untuk pengembangan jangka panjang.

---

## 2. Analisis Masalah & Peluang Pasar

| Pernyataan Masalah | Peluang Solusi (Huashu Style) |
| :--- | :--- |
| **Kelelahan Visual (Visual Fatigue)**: Mayoritas aplikasi marketplace saat ini dipenuhi oleh neon gradients yang agresif, bayangan tebal (heavy drop shadows), font sans-serif standar tanpa karakter, dan iklan popup berlebih yang mengganggu fokus pengguna. | **Estetika Water-Ink Modern**: Menggunakan skema warna tenang terinspirasi dari alam batu mineral dan kertas tradisional (Xuan Paper), diimbangi dengan grid garis tipis (0.5dp) yang teratur dan tipografi serif yang anggun untuk memberikan ruang bernapas visual (negative space). |
| **Alur Pembayaran yang Terputus**: Proses pembayaran mobile seringkali memaksa pengguna keluar dari aplikasi menuju browser eksternal, merusak retensi pengguna dan meningkatkan risiko kegagalan checkout. | **Midtrans Snap WebView Seamless**: Integrasi kontainer webview yang elegan di dalam aplikasi Flutter untuk memproses transaksi Midtrans Snap, menangkap status pembayaran secara real-time, dan mengembalikan pengguna secara otomatis ke halaman konfirmasi pesanan. |
| **Manajemen Peran yang Tidak Terstruktur**: Sulitnya membagi alur kerja antara penjual (Seller) dan pembeli (Customer) di dalam satu aplikasi mobile tunggal tanpa merusak pengalaman visual masing-masing peran. | **Dual-Role Interface**: Pembagian arsitektur navigasi yang jelas berdasarkan peran akun yang terverifikasi melalui JWT payload, memberikan menu manajemen inventori untuk Seller dan menu katalog belanja untuk Customer. |

---

## 3. Persona Pengguna & Peran Akun

Sistem mendukung dua peran pengguna utama yang diidentifikasi melalui modul autentikasi JWT:

### 3.1 Pembeli (Customer)
*   **Karakteristik**: Konsumen yang mengutamakan kenyamanan navigasi, pencarian produk yang akurat, serta keamanan proses checkout dan pembayaran.
*   **Kebutuhan Utama**:
    *   Registrasi dan Login yang aman dan cepat.
    *   Menjelajahi katalog produk dengan transisi visual yang halus dan filter kategori/harga yang responsif.
    *   Membuat pesanan dan menyelesaikan pembayaran secara instan menggunakan berbagai metode (e-wallet, bank transfer, dll.) melalui gateway Midtrans.
    *   Memantau riwayat pesanan beserta status pembayaran dan pengirimannya.

### 3.2 Penjual (Seller)
*   **Karakteristik**: Pemilik toko/UMKM lokal yang memerlukan alat manajemen produk yang efisien di platform mobile.
*   **Kebutuhan Utama**:
    *   Mengunggah produk baru dengan menyertakan nama, deskripsi, harga, stok, kategori, dan gambar produk (maksimal 5MB).
    *   Memperbarui data inventori (mengubah stok, harga, nama, deskripsi, atau mengubah status aktif produk).
    *   Menghapus produk yang tidak lagi dijual secara permanen.
    *   Mengelola pesanan masuk dari pembeli secara tertib.

---

## 4. Spesifikasi Fitur Fungsional (Functional Scope)

### 4.1 Modul Autentikasi (Authentication)
*   **Registrasi Akun (Register)**: Pendaftaran akun baru menggunakan nama, email unik, dan password aman. Mendukung role default `customer`.
*   **Login Akun**: Autentikasi kredensial pengguna untuk mendapatkan `access_token` (berlaku 7 hari) dan `refresh_token` (berlaku 30 hari).
*   **Token Lifecycle Management**: Sistem secara otomatis melakukan refresh token sebelum access token kadaluarsa tanpa mengganggu sesi pengguna (silent token refresh).
*   **Verifikasi Token**: Validasi keaktifan sesi di latar belakang untuk menjamin hak akses endpoint yang dilindungi (protected routes).

### 4.2 Modul Katalog Produk (Products)
*   **Pencarian & Penyaringan (Search & Filter)**: Pencarian dinamis berdasarkan nama produk, penyaringan berdasarkan kategori, rentang harga (minPrice & maxPrice), serta nama penjual.
*   **Pagination Katalog**: Pemuatan produk dalam format halaman terstruktur (misalnya 10 produk per halaman) untuk mengoptimalkan penggunaan memori dan bandwidth data.
*   **Detail Produk**: Tampilan detail komprehensif mencakup foto produk berkualitas tinggi, deskripsi tekstual, stok real-time, kategori, nama penjual, dan tombol checkout langsung.
*   **Manajemen Inventori (Khusus Seller)**:
    *   *Create*: Unggah produk baru dengan validasi file gambar (format JPG/PNG/JPEG, ukuran maksimum 5MB).
    *   *Update*: Modifikasi atribut produk secara parsial (hanya memperbarui field yang dikirim).
    *   *Delete*: Penghapusan permanen data produk dari sistem.

### 4.3 Modul Pemesanan (Orders)
*   **Pembuatan Pesanan (Create Order)**: Penggabungan beberapa barang pesanan dengan kalkulasi total nominal belanja, alamat pengiriman yang terstruktur, dan catatan khusus untuk penjual (notes).
*   **Histori Pesanan (Order History)**: List riwayat pesanan milik pembeli yang mendukung filter status pemesanan (`pending`, `processing`, `shipped`, `delivered`, `cancelled`) dan status pembayaran (`unpaid`, `pending`, `paid`, `failed`, `cancelled`).
*   **Detail Pesanan**: Rincian transaksi mencakup daftar item produk, harga satuan saat dibeli, alamat pengiriman, status pembayaran, serta metode pembayaran yang digunakan.

### 4.4 Modul Pembayaran (Payments)
*   **Pembuatan Transaksi Midtrans**: Mengirimkan Order ID ke API backend untuk menghasilkan token transaksi Midtrans Snap dan tautan pembayaran (`redirect_url`).
*   **WebView Integration**: Menampilkan layar pembayaran Snap secara internal di dalam aplikasi Flutter.
*   **Sinkronisasi Webhook**: Memproses perubahan status pembayaran secara asinkron dari server Midtrans ke database lokal aplikasi, memperbarui status pesanan secara real-time.

---

## 5. Persyaratan Non-Fungsional (Non-Functional Requirements)

### 5.1 Kinerja & Efisiensi (Performance)
*   **Responsivitas Interface**: Frame rate aplikasi wajib dipertahankan pada kisaran **60fps hingga 120fps** pada perangkat modern untuk memastikan kelembutan transisi mikro-animasi Huashu.
*   **Image Caching**: Setiap gambar produk yang dimuat dari server wajib disimpan dalam cache lokal (`cached_network_image`) untuk mengurangi konsumsi kuota data dan mempercepat visualisasi katalog berulang.
*   **Cold Start**: Aplikasi harus dapat masuk ke halaman beranda (untuk user tersesi) dalam waktu kurang dari **2.0 detik** di koneksi internet standar.

### 5.2 Keamanan & Proteksi Data (Security)
*   **Enkripsi Penyimpanan Lokal**: Sesi kredensial (`access_token` dan `refresh_token`) wajib disimpan menggunakan enkripsi tingkat perangkat keras melalui **Flutter Secure Storage** (menggunakan Keychain untuk iOS dan AES-CBC dengan Android Keystore).
*   **Transport Layer Security (TLS)**: Semua transmisi data dengan API eksternal wajib melalui protokol **HTTPS** yang aman.
*   **Validasi Sisi Klien**: Proteksi awal terhadap serangan injeksi sederhana melalui pembersihan input teks form dan sanitasi data input numerik sebelum dikirim ke API backend.

### 5.3 Stabilitas & Maintainabilitas
*   **Clean Architecture**: Kode program Flutter dibagi menjadi tiga layer terisolasi (Data, Domain, Presentation) guna memisahkan logika bisnis dari implementasi framework UI.
*   **Laporan Crash**: Integrasi monitoring error asinkron untuk menangkap bug runtime sebelum berdampak pada kenyamanan pengguna.
