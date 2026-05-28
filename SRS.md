# 📝 Software Requirement Specification (SRS) — Marketplace Flutter App

---

## 1. Pendahuluan

### 1.1 Tujuan
Dokumen **Software Requirement Specification (SRS)** ini menetapkan spesifikasi teknis dan persyaratan rekayasa perangkat lunak untuk aplikasi client mobile **Marketplace with Payment (Huashu Style)** menggunakan framework **Flutter**. Dokumen ini menjadi panduan formal bagi tim pengembang untuk mengimplementasikan fungsionalitas, keamanan, dan integrasi API secara presisi.

### 1.2 Batasan Sistem (System Constraints)
*   **Minimum Operating System**:
    *   Android: OS 6.0 (API Level 23, Marshmallow) atau lebih tinggi.
    *   iOS: iOS 13 atau lebih tinggi.
*   **Konektivitas Jaringan**: Wajib menggunakan protokol transport aman **HTTPS**. Seluruh koneksi HTTP non-aman wajib ditolak secara eksplisit pada level konfigurasi network security config (Android) dan App Transport Security (iOS) di tahap produksi.
*   **Lokalisasi**: Bahasa utama antarmuka pengguna adalah **Bahasa Indonesia** dengan format mata uang **Rupiah (IDR)**.

---

## 2. Kebutuhan Antarmuka Sistem (System Interface Requirements)

### 2.1 Antarmuka Jaringan & API (Network Interface)
Aplikasi Flutter terhubung dengan server backend melalui API RESTful. Client HTTP menggunakan library **Dio** yang dikonfigurasi dengan:
*   `connectTimeout`: 10,000 milidetik (10 detik).
*   `receiveTimeout`: 10,000 milidetik (10 detik).
*   `contentType`: `application/json` (kecuali endpoint multipart untuk upload gambar produk yang menggunakan `multipart/form-data`).

### 2.2 Antarmuka Penyimpanan Data Lokal (Local Storage Interface)
*   **Penyimpanan Kredensial (Secure Storage)**: Informasi sensitif (`access_token` dan `refresh_token`) wajib disimpan secara aman di dalam chip enkripsi perangkat keras menggunakan **Flutter Secure Storage** (`flutter_secure_storage`).
    *   Android: Menggunakan enkripsi berbasis **AES-CBC** dengan kunci yang dilindungi oleh **Android Keystore system**.
    *   iOS: Menggunakan penyimpanan terenkripsi **Keychain Services**.
*   **Penyimpanan Cache Data**: Data non-sensitif seperti daftar produk katalog disimpan secara lokal menggunakan database ringan **Isar** atau **Drift** untuk mendukung mode baca cepat offline (offline first caching policy).

---

## 3. Persyaratan Fungsional Detil (Detailed Functional Requirements)

### 3.1 Otentikasi & Keamanan Sesi

#### F.01: Registrasi Akun Baru
Aplikasi harus menyediakan form pendaftaran terstruktur untuk peran customer yang divalidasi di sisi klien sebelum dikirim ke endpoint `/api/auth/register`.

#### F.02: Login & Manajemen Sesi
Aplikasi harus memverifikasi kredensial pengguna via `/api/auth/login`. Jika sukses, data payload pengguna disimpan ke database lokal dan token disimpan ke Secure Storage.

#### F.03: Siklus Hidup Token Otomatis (Automatic Token Refresh)
Aplikasi harus memiliki Dio Interceptor yang memantau setiap response API. Jika mendeteksi error **HTTP 401 (Unauthorized)** dengan pesan token expired, aplikasi wajib menangguhkan request tersebut, melakukan pemanggilan endpoint `/api/auth/refresh-token` secara asinkron menggunakan refresh token, memperbarui access token di Secure Storage, lalu melanjutkan kembali request asli yang tertunda secara transparan tanpa disadari oleh pengguna.

### 3.2 Manajemen Inventori & Katalog Produk

#### F.04: Pemuatan Katalog Berhalaman (Paged Product List)
Aplikasi harus memuat data katalog secara bertahap menggunakan parameter query `page` dan `limit` untuk mencegah kebocoran memori (out-of-memory) akibat pemuatan data berlebih pada perangkat mobile dengan spesifikasi rendah.

#### F.05: Pembuatan Produk Baru (Khusus Seller)
Penjual harus dapat mengambil foto langsung menggunakan kamera perangkat atau memilih gambar dari galeri melalui library `image_picker`. Aplikasi wajib memvalidasi ekstensi dan batas ukuran file gambar sebelum mengirimkannya melalui request `multipart/form-data` ke `/api/products/create`.

### 3.3 Pemesanan & Alur Transaksi Midtrans

#### F.06: Manajemen Keranjang Belanja Lokal (Local Cart Management)
Aplikasi harus menyediakan state management keranjang belanja yang persisten secara lokal. Pengguna dapat menambah, mengurangi quantity, menghapus item, dan melihat estimasi total belanjaan secara instan.

#### F.07: Pembuatan Order & Token Pembayaran
Saat checkout, aplikasi mengirim data item belanja ke `/api/orders`. Setelah order sukses dibuat (status `pending`), aplikasi langsung mengirimkan request ke `/api/payments/create` untuk mengambil `token` transaksi Snap Midtrans dan `redirect_url`.

#### F.08: WebView Interceptor Midtrans Snap
Aplikasi harus memuat `redirect_url` Midtrans Snap di dalam widget WebView (`webview_flutter`). Aplikasi wajib mengonfigurasi `NavigationDelegate` untuk menangkap perubahan URL callback guna menentukan status transaksi:
*   Jika URL berisi keyword callback sukses pembayaran, tutup WebView dan arahkan pengguna ke Layar Sukses.
*   Jika URL berisi status pending/menunggu pembayaran, tutup WebView dan arahkan pengguna ke Layar Pending.
*   Jika URL berisi status error/gagal pembayaran, tutup WebView dan kembalikan pengguna ke Layar Checkout dengan menampilkan pesan kegagalan.

---

## 4. Matriks Validasi Form & Aturan Input

Sebelum data dikirim ke API backend, sistem client Flutter wajib menerapkan validasi input yang ketat pada form antarmuka guna meminimalkan beban request server:

| Field Input | Form Terkait | Aturan Validasi Sisi Klien (Client-Side Validation) | Reaksi Kegagalan Validasi |
| :--- | :--- | :--- | :--- |
| **Email** | Register, Login | Harus sesuai ekspresi reguler (regex): `^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$` | Tampilkan error: *"Format alamat email tidak valid"* |
| **Password** | Register, Login | Panjang minimal **6 karakter** bebas. | Tampilkan error: *"Password minimal terdiri dari 6 karakter"* |
| **Confirm Password** | Register | Harus memiliki nilai string yang sama persis dengan field Password. | Tampilkan error: *"Konfirmasi password tidak cocok"* |
| **Nama Lengkap** | Register | Tidak boleh kosong (Required), minimal **3 karakter** alfabet. | Tampilkan error: *"Nama lengkap minimal 3 karakter"* |
| **Harga Produk** | Create Product | Harus bertipe data numerik positif (harga > 0). | Tampilkan error: *"Harga produk harus berupa angka positif"* |
| **Stok Produk** | Create Product | Harus bertipe data integer non-negatif (stok >= 0). | Tampilkan error: *"Stok produk minimal bernilai 0"* |
| **Gambar Produk** | Create Product | Format file wajib **JPG, JPEG, atau PNG**. Ukuran maksimum file **5,242,880 bytes (5MB)**. | Tampilkan error: *"Format gambar harus JPG/PNG & ukuran max 5MB"* |

---

## 5. Matriks Penanganan Error (Error Handling Matrix)

Aplikasi mobile harus menangani kegagalan sistem secara elegan sesuai dengan kode status HTTP yang dikembalikan oleh API backend, menyajikannya dalam pesan ramah pengguna menggunakan SnackBar bergaya Huashu Design:

| HTTP Status Code | Kondisi Error Sistem | Pesan Kesalahan untuk Pengguna (User-Facing Message) | Aksi Mitigasi Klien |
| :--- | :--- | :--- | :--- |
| **400** | Request tidak valid / parameter input form kurang atau salah format. | *"Mohon periksa kembali data yang Anda masukkan."* | Klien menandai bidang input yang salah dengan warna Merah Sinabar (`#B83A2C`). |
| **401** | Token tidak valid / kadaluarsa / tidak ditemukan di header authorization. | *"Sesi Anda telah berakhir. Silakan masuk kembali."* | Bersihkan Secure Storage, paksa navigasi kembali ke Layar Login. |
| **403** | Pengguna diblokir / mengakses produk milik seller lain / bukan pemilik pesanan. | *"Akses ditolak. Anda tidak memiliki wewenang untuk tindakan ini."* | Tutup operasi saat ini, tampilkan dialog peringatan tegas. |
| **404** | Produk sudah dihapus / pesanan tidak ditemukan di database backend. | *"Data tidak ditemukan atau telah dihapus."* | Segarkan halaman, hapus item dari list cache lokal klien. |
| **409** | Email sudah terdaftar saat register / konflik data database. | *"Email tersebut sudah terdaftar di sistem kami."* | Fokuskan kursor kembali ke kolom email dengan teks peringatan. |
| **500** | Kegagalan koneksi database SQLite di server / error server internal. | *"Layanan kami sedang mengalami gangguan internal. Mohon coba beberapa saat lagi."* | Log error ke Crashlytics lokal klien untuk keperluan debugging. |
| **No Network** | Perangkat tidak terhubung ke internet / DNS gagal meresolusi domain. | *"Koneksi internet Anda terputus. Harap periksa jaringan Anda."* | Aktifkan mode baca lokal menggunakan data dari Isar Database Cache. |
