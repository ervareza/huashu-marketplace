# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.6.0] - 2026-05-29

### Added
- **API Coverage 100%**: Menyelesaikan implementasi seluruh endpoint dari `API_DOCUMENTATION (1).md` pada sisi client.
- **Batalkan Pesanan**: Penambahan tombol `Batalkan Pesanan` di halaman `OrderDetailScreen` (hanya jika pesanan masih pending).
- **Hapus Akun Pengguna**: Fitur hapus akun secara permanen di dalam halaman `ProfileScreen` dengan konfirmasi popup.
- **Manajemen Alamat**: Fitur *Edit Alamat* dan *Hapus Alamat* di halaman `AddressScreen` terhubung ke backend.
- **Realtime Product Detail**: Refactor halaman `ProductDetailScreen` agar selalu mengambil data produk terbaru menggunakan API `GET /api/products/:id` alih-alih mengandalkan cache route.

## [1.5.0] - 2026-05-29

### Added
- **API v3.0.0 Feature Complete**: Implementasi penuh dari seluruh endpoint baru pada API v3.0.0.
- **Lupa & Reset Kata Sandi**: Integrasi form permintaan dan submit token OTP reset password di `forgot_password_screen.dart` dan `reset_password_screen.dart`.
- **Manajemen Pengguna (Admin)**: Penambahan `admin_user_list_screen.dart` untuk melihat daftar pengguna, memblokir (*ban*), dan mengubah hak akses (*role*).
- **Penyelesaian Komplain (Admin)**: Sinkronisasi endpoint `/api/admin/orders/:id/resolve-dispute` di detail pesanan Admin.
- **Dashboard Penjual (Seller)**: Integrasi khusus penjual dengan endpoint `/api/seller/dashboard/stats` dan tombol navigasi dinamis terpisah dari Admin.
- **Balas Ulasan (Seller)**: Penjual kini dapat memberikan tanggapan langsung pada ulasan pembeli di `product_detail_screen.dart`.

## [1.4.0] - 2026-05-28

### Added
- **API Integration for Categories** (`lib/features/product/presentation/catalog_screen.dart`): Kategori utama kini dimuat langsung dari server melalui `GET /api/categories`.
- **API Integration for Banners** (`lib/features/product/presentation/catalog_screen.dart`): Carousel promo banner kini memuat aset gambar dari endpoint `GET /api/banners`.
- **Server-Side Product Search** (`lib/features/product/presentation/catalog_screen.dart`): Menggantikan filter lokal dengan query dinamis menggunakan `GET /api/products/search?q=X&category=Y` untuk penghematan bandwidth dan efisiensi memori perangkat.

## [1.3.0] - 2026-05-28

### Added
- **Order Detail Screen** (`lib/features/order/presentation/order_detail_screen.dart`): Halaman rincian pesanan dengan status pengiriman, alamat, daftar barang, status pembayaran, dan tombol bayar ulang terintegrasi dengan Snap WebView.
- **Admin Panel Screen** (`lib/features/admin/presentation/admin_panel_screen.dart`): Dashboard utama bagi penjual/admin untuk mengakses Manajemen Produk dan Riwayat Pesanan dari satu layar elegan terpusat.

### Changed
- **Dynamic Pricing**: Bottom bar di halaman Detail Produk kini menghitung dan menampilkan total nominal secara *real-time* seiring dengan penambahan/pengurangan kuantitas.
- **Drawer Navigasi**: Menu "Panel Penjual" di Katalog Utama kini diarahkan ke *Admin Panel Screen*.
- **Clickable Order History**: Riwayat Pesanan kini dapat diklik pada tiap card untuk melihat rincian melalui navigasi ke *Order Detail Screen*.

## [1.2.0] - 2026-05-28

### Added
- **Panel Penjual / Admin** (`lib/features/product/presentation/seller_panel_screen.dart`): Layar pengelolaan produk lengkap bagi penjual dengan fitur CRUD (menampilkan koleksi karya sendiri, menambah karya seni baru, memperbarui detail karya, dan menghapus karya secara permanen).
- **Mock Image Uploader**: Memanfaatkan upload dummy byte stream 1x1 PNG menggunakan Multipart form-data sehingga API backend memproses unggahan gambar dengan sukses tanpa hambatan perizinan native file picker pada perangkat.
- **Visual Stempel Tinta Kaligrafi**: Jika gambar produk gagal dimuat atau merupakan gambar dummy uploader, aplikasi menampilkan visual stempel cinnabar merah estetis (`HuashuSeal` berdasarkan huruf depan nama produk) sebagai bentuk visualisasi tradisional Huashu.
- **Drawer Navigasi Utama**: Menambahkan navigasi Drawer di Katalog Utama untuk mempermudah akses ke Katalog, Riwayat Pesanan, Panel Penjual/Admin, serta keluar akun lengkap dengan stempel dan identitas profil pengguna terintegrasi.
- **Penyimpanan ID Pengguna**: Menyimpan ID pengguna (`user_id`) secara aman di secure storage pada alur masuk (login) untuk pemrosesan filter data galeri penjual.

## [1.1.1] - 2026-05-28

### Changed
- **Base URL API**: Memperbarui domain ngrok ke `https://96a3-2404-c0-b301-8af6-a587-34e-b9b3-3cba.ngrok-free.app` untuk menyelaraskan dengan server backend yang baru diaktifkan.

## [1.1.0] - 2026-05-28

### Added
- **ApiService Singleton** (`lib/core/network/api_service.dart`): Centralized Dio instance dengan base URL satu tempat, timeout 15 detik, header ngrok otomatis, dan helper parsing (safe error extraction, price parser, ID parser).
- **Huashu Design System v2**: Upgrade tema lengkap dengan 3 warna baru (warmStone, agedGold, fadedIndigo), spacing scale 8px, border width scale, dan styling untuk AppBar, Dialog, SnackBar, ChoiceChip, ScrollBar, Badge, dan ProgressIndicator.
- **7 Komponen Dekoratif Huashu**: `HuashuSeal`, `HuashuDoubleFrame`, `HuashuStatusBox`, `HuashuStampBadge`, `HuashuSectionLabel`, `HuashuPrice`, `HuashuEmptyState`.
- Tombol **logout** dengan dialog konfirmasi di halaman Katalog.
- **Pull-to-refresh** di halaman Katalog dan Riwayat Pesanan.
- **Retry button** saat terjadi error koneksi di Katalog dan Riwayat Pesanan.
- Fade-in animation di halaman Login.
- Footer watermark "華 書" di halaman Login.
- Auto-navigate ke halaman Login setelah registrasi berhasil.
- Password visibility toggle di halaman Login dan Register.

### Fixed
- **CRITICAL**: Crash `type 'String' is not a subtype of type 'int'` saat server mengembalikan HTML response (ngrok offline) — semua DioException handler sekarang menggunakan safe error parsing.
- **CartItem.id** dari `int` ke `dynamic` untuk menangani API yang mengirim ID sebagai String atau int.
- **Token Refresh Interceptor**: Hapus hardcoded URL, gunakan baseUrl dari Dio client. Tambah header `ngrok-skip-browser-warning`. Safe JSON parsing untuk refresh response.
- Semua `withOpacity()` deprecated diganti ke `withValues(alpha:)` di 6 file.

### Changed
- Semua screen kini menggunakan `ApiService` singleton (bukan membuat Dio instance masing-masing).
- Base URL API cukup diganti di **satu file** (`api_service.dart`) — tidak perlu edit 6 file terpisah.
- `SnapWebView.orderId` dari `int` ke `dynamic` untuk kompatibilitas API.

## [1.0.0] - 2026-05-28

### Added
- Inisialisasi repositori Git dan setup branch `v1.0.0`.
- PRD.md (Product Requirement Document) berisi visi produk, persona, target pengguna, dan fitur utama marketplace minimalis.
- PRD_ADDENDUM.md mendefinisikan panduan UI/UX flow interaktif dan token sistem visual **Huashu Design** (water-ink palette, grid, typography).
- SRS.md (Software Requirement Specification) menjabarkan fungsionalitas, keamanan JWT credential, regulasi validasi input, dan penanganan error terperinci.
- SRS_ADDENDUM.md menyusun pemetaan API endpoint lengkap untuk client Flutter dan alur transaksi gateway pembayaran Midtrans.
- SDD.md (Software Design Description) merancang arsitektur Clean Architecture Flutter, rancangan folder structure, dan Isar/Drift local cache schema.
- SDD_ADDENDUM.md mendesain implementasi Flutter ThemeData sesuai token warna Huashu, custom paint divider, page transitions, dan WebView Snap Container.
