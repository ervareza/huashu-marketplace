# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

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
