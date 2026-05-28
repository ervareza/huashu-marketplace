# 華書 Huashu Marketplace

> Marketplace seni tradisional dengan estetika tinta — *"Keheningan yang berbicara"*

<p align="center">
  <img src="https://img.shields.io/badge/Flutter-3.x-02569B?logo=flutter" alt="Flutter"/>
  <img src="https://img.shields.io/badge/Dart-3.x-0175C2?logo=dart" alt="Dart"/>
  <img src="https://img.shields.io/badge/Midtrans-Payment-FF6600" alt="Midtrans"/>
  <img src="https://img.shields.io/badge/License-Private-red" alt="License"/>
</p>

---

## ✨ Tentang Proyek

**Huashu Marketplace** adalah aplikasi mobile marketplace minimalis yang menggunakan bahasa visual **Huashu Design System** — terinspirasi dari estetika tinta tradisional Tiongkok. Aplikasi ini dibangun dengan Flutter dan terhubung ke backend REST API dengan integrasi pembayaran Midtrans Snap.

### Filosofi Desain
- **Anti-Slop**: Tanpa rounded corner berlebihan, tanpa drop-shadow AI, tanpa gradien plastik
- **0px Border Radius**: Semua elemen menggunakan sudut tajam — terinspirasi stempel dan bingkai kaligrafi
- **Tipografi sebagai Ornamen**: Kombinasi Noto Serif SC (judul) + Inter (body)
- **Palet Mineral**: Kertas Xuan, Arang Tinta, Giok Mineral, Sinabar Usang

---

## 📱 Screenshots

| Login | Katalog | Detail Produk | Checkout |
|:-----:|:-------:|:-------------:|:--------:|
| Stempel 華 | Grid produk | Bingkai ganda | Rincian belanja |

---

## 🏗️ Arsitektur

```
lib/
├── core/
│   ├── network/
│   │   ├── api_service.dart          # Dio singleton + safe error parsing
│   │   └── token_refresh_interceptor.dart  # JWT auto-refresh
│   └── theme/
│       ├── huashu_theme.dart         # Design system lengkap + widgets
│       └── ink_brush_divider.dart    # Custom painter kuas kaligrafi
├── features/
│   ├── auth/
│   │   └── presentation/
│   │       ├── login_screen.dart     # Halaman masuk
│   │       └── register_screen.dart  # Halaman daftar
│   ├── product/
│   │   └── presentation/
│   │       ├── catalog_screen.dart   # Grid katalog + filter + search
│   │       └── product_detail_screen.dart
│   ├── order/
│   │   └── presentation/
│   │       ├── cart_state.dart       # State management keranjang
│   │       ├── checkout_screen.dart  # Form alamat + ringkasan
│   │       └── order_history_screen.dart
│   └── payment/
│       └── presentation/
│           └── snap_webview.dart     # WebView Midtrans Snap
└── main.dart
```

---

## 🎨 Huashu Design System

### Token Warna
| Token | Hex | Kegunaan |
|-------|-----|----------|
| `xuanPaperBg` | `#F7F5F0` | Background utama (kertas Xuan) |
| `charcoalBlack` | `#1E1E1E` | Teks utama & tombol primer |
| `mineralJadeGreen` | `#2D5A43` | Aksi positif, CTA sekunder |
| `stainedCinnabarRed` | `#B83A2C` | Harga, error, stempel |
| `lightInkLine` | `#E2DFD5` | Border, divider, placeholder |
| `warmStone` | `#D4CFC4` | Elemen sekunder |
| `agedGold` | `#8B7D3C` | Aksen premium |

### Komponen Dekoratif
| Widget | Fungsi |
|--------|--------|
| `HuashuSeal` | Stempel merah tradisional (karakter Hanzi) |
| `HuashuDoubleFrame` | Bingkai ganda untuk gambar produk |
| `HuashuStatusBox` | Kotak pesan error/success/info |
| `HuashuStampBadge` | Badge status pesanan |
| `HuashuSectionLabel` | Label section UPPERCASE |
| `HuashuPrice` | Harga dengan font serif sinabar |
| `HuashuEmptyState` | State kosong dengan ikon + retry |
| `InkBrushDivider` | Garis pembatas sapuan kuas kaligrafi |

---

## 🔌 API Endpoints

| Method | Endpoint | Kegunaan |
|--------|----------|----------|
| `POST` | `/api/auth/login` | Login pengguna |
| `POST` | `/api/auth/register` | Registrasi pengguna baru |
| `POST` | `/api/auth/refresh-token` | Refresh JWT token |
| `GET` | `/api/products` | Daftar semua produk |
| `POST` | `/api/orders` | Buat pesanan baru |
| `GET` | `/api/orders` | Riwayat pesanan pengguna |
| `POST` | `/api/payments/create` | Buat transaksi Midtrans Snap |

> **Catatan**: Base URL API dikonfigurasi di satu tempat: `lib/core/network/api_service.dart`

---

## 🚀 Cara Menjalankan

### Prasyarat
- Flutter SDK 3.x
- Android SDK
- NDK 26.3.11579264

### Setup
```bash
# Clone repository
git clone https://github.com/ervareza/huashu-marketplace.git
cd huashu-marketplace

# Install dependencies
flutter pub get

# Ganti base URL API (jika perlu)
# Edit file: lib/core/network/api_service.dart
# Ubah variabel `baseUrl`

# Jalankan di device
flutter run

# Build APK release
flutter build apk --release
```

### APK Release
File APK siap install tersedia di:
```
releases/app-release.apk
```

---

## 📦 Dependencies

| Package | Kegunaan |
|---------|----------|
| `dio` | HTTP client dengan interceptor |
| `flutter_secure_storage` | Penyimpanan token JWT terenkripsi |
| `google_fonts` | Noto Serif SC + Inter |
| `cached_network_image` | Cache gambar produk |
| `webview_flutter` | WebView Midtrans Snap |

---

## 📝 Changelog

Lihat [CHANGELOG.md](CHANGELOG.md) untuk riwayat perubahan lengkap.

---

## 👥 Tim

Dikembangkan sebagai proyek marketplace minimalis dengan pendekatan desain tradisional.

---

<p align="center">
  <sub>— 華 書 —</sub><br/>
  <sub><i>"Tinta di atas kertas Xuan — keheningan yang berbicara"</i></sub>
</p>
