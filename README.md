# 華書 Huashu Marketplace

> Marketplace seni tradisional dengan estetika tinta — *"Keheningan yang berbicara"*

<p align="center">
  <a href="https://flutter.dev"><img src="https://img.shields.io/badge/Flutter-3.x-02569B?logo=flutter" alt="Flutter"/></a>
  <a href="https://dart.dev"><img src="https://img.shields.io/badge/Dart-3.x-0175C2?logo=dart" alt="Dart"/></a>
  <a href="https://midtrans.com"><img src="https://img.shields.io/badge/Midtrans-Payment-FF6600" alt="Midtrans"/></a>
  <a href="https://socket.io/"><img src="https://img.shields.io/badge/Socket.IO-Realtime-010101?logo=socket.io" alt="Socket.IO"/></a>
  <a href="LICENSE"><img src="https://img.shields.io/badge/License-MIT-blue.svg" alt="License"/></a>
</p>

---

## 📖 Tentang Proyek

**Huashu Marketplace** adalah aplikasi *mobile commerce* revolusioner yang dirancang khusus untuk memperdagangkan karya seni tradisional, barang antik, dan kerajinan tangan. Aplikasi ini membuang gaya *modern-generic* yang membosankan dan menggantinya dengan bahasa visual **Huashu Design System** — terinspirasi dari estetika tinta tradisional Tiongkok, kertas *Xuan*, dan stempel *Cinnabar*.

Aplikasi ini dibangun menggunakan **Flutter** untuk antarmuka lintas platform (Android/iOS) dan terhubung ke backend REST API berbasis **Node.js**. Selain itu, aplikasi ini dilengkapi fitur premium seperti *Real-time Chat* menggunakan Socket.IO, dan gerbang pembayaran *seamless* menggunakan **Midtrans Snap**.

---

## ✨ Fitur Utama

### 🛍️ Untuk Pembeli
- **Katalog & Pencarian Cerdas**: Pencarian server-side (`/api/products/search`) dan filter Kategori dinamis.
- **Promo Banners & Flash Sales**: Komidi putar (carousel) *banner* interaktif dan hitung mundur Flash Sale secara *real-time*.
- **Keranjang & Wishlist**: Manajemen keranjang belanja dan fitur *Wishlist* dengan integrasi state provider terpusat.
- **Sistem Voucher**: Klaim kode promo dan terapkan saat *Checkout* untuk mendapatkan diskon langsung.
- **Real-time Chat (Socket.IO)**: Mengobrol langsung dengan penjual layaknya aplikasi *chatting* sungguhan. Terhubung secara global untuk update instan di seluruh layar.
- **Pembayaran Aman (Midtrans)**: Beli produk melalui WebView Snap Midtrans (Virtual Account, GoPay, Kartu Kredit).
- **Notifikasi & Deep Linking**: Lacak pesanan secara komprehensif. Lonceng notifikasi menyala *real-time*, dan ketukan pada pesan akan otomatis membawa Anda ke layar detail terkait (*Deep Linking*).
- **Resolusi Sengketa (Disputes)**: Ajukan komplain jika pesanan tidak sesuai, dilengkapi *upload* bukti keluhan.
- **Autentikasi Canggih**: Dukungan registrasi, pemulihan lupa sandi (OTP Email), dan refresh token cerdas di latar belakang.

### 🏪 Untuk Penjual / Admin
- **Panel Dashboard Eksklusif (Seller/Admin)**: Tampilan manajemen terpisah. Pantau seluruh pesanan, pendapatan, produk terlaris dari satu layar elegan.
- **Manajemen Pesanan & Resi**: Ubah status pesanan dan kirim resi pelacakan kurir langsung dari aplikasi.
- **Balas Ulasan (Seller)**: Seller dapat membalas ulasan pembeli, yang akan langsung termuat di layar Detail Produk.
- **Manajemen Pengguna (Admin)**: Blokir pengguna (*banned*), ganti *role* dari pembeli ke penjual, dan putus sengketa *dispute* secara adil.
- **Manajemen Konten (Admin)**: Buat Banner Promo dan Kategori baru dengan antarmuka dinamis.
- **Manajemen Produk (CRUD)**: Unggah produk baru, kelola stok, dan hapus katalog usang dengan mudah (*mock uploader* terintegrasi).

---

## 🎨 Huashu Design System

Kami mengimplementasikan UI/UX yang sangat ketat (*Anti-Slop*).

- **Anti-Slop**: Tanpa *rounded corner* berlebihan, tanpa gradien plastik, tanpa bayangan *drop-shadow* *AI-generated*.
- **0px Border Radius**: Semua elemen desain menggunakan sudut tajam — terinspirasi bingkai kayu kaligrafi kuno.
- **Tipografi sebagai Ornamen**: Kombinasi **Noto Serif SC** (untuk judul/harga) dan **Inter** (untuk deskripsi/body).
- **Palet Mineral Tradisional**:

| Token Warna | Hex Code | Visualisasi Kegunaan |
|-------------|----------|-----------------------|
| `xuanPaperBg` | `#F7F5F0` | Latar belakang utama (Kertas Xuan) |
| `charcoalBlack` | `#1E1E1E` | Teks utama, *AppBar*, tombol primer (Tinta Arang) |
| `mineralJadeGreen` | `#2D5A43` | Aksi positif, tombol 'Beli', status sukses (Giok Mineral) |
| `stainedCinnabarRed` | `#B83A2C` | Harga diskon, *error*, tombol batal, *Seal/Stamp* (Sinabar Usang) |
| `lightInkLine` | `#E2DFD5` | Border input, *divider*, placeholder gambar |
| `warmStone` | `#D4CFC4` | Elemen UI sekunder, teks *hint* |
| `agedGold` | `#8B7D3C` | Aksen keanggotaan/Premium (Emas Tua) |

---

## 🚀 Instalasi & Persiapan

### Prasyarat (*Prerequisites*)
Pastikan lingkungan *development* Anda sudah terinstal:
- [Flutter SDK](https://flutter.dev/docs/get-started/install) (versi 3.x ke atas)
- [Dart SDK](https://dart.dev/get-dart)
- Android Studio / VS Code dengan ekstensi Flutter
- (Khusus Android) **Android NDK 26.3.11579264** atau versi di atasnya.

### Langkah Instalasi

1. **Clone Repositori**
   ```bash
   git clone https://github.com/ervareza/huashu-marketplace.git
   cd huashu-marketplace
   ```

2. **Unduh Dependencies**
   ```bash
   flutter pub get
   ```

3. **Konfigurasi Lingkungan (API URL)**
   Ubah *Base URL* server backend Anda di `lib/core/network/api_service.dart`:
   ```dart
   final String baseUrl = 'http://IP_SERVER_ANDA:5000'; 
   // Gunakan 10.0.2.2 untuk Android Emulator yang mengarah ke localhost
   ```

4. **Jalankan Aplikasi**
   ```bash
   flutter run
   ```

5. **Build APK Release**
   ```bash
   flutter build apk --release
   ```
   *File APK siap install akan berada di:* `build/app/outputs/flutter-apk/app-release.apk`

---

## 🔌 Dokumentasi API (*Endpoints*)

Aplikasi menggunakan pola JWT (JSON Web Token) dengan *Auto-Refresh Interceptor*.

| Fitur | Method | Endpoint | Kegunaan |
|---|---|---|---|
| **Auth** | `POST` | `/api/auth/login` | Autentikasi Pengguna |
| | `POST` | `/api/auth/register` | Registrasi Akun Baru |
| | `POST` | `/api/auth/refresh-token` | Memperbarui JWT Access Token |
| **Profil** | `PUT` | `/api/users/profile` | Update info & Avatar Profil |
| **Katalog** | `GET` | `/api/products` | Muat daftar semua produk |
| | `GET` | `/api/products/search` | Mencari & memfilter produk (Server-side) |
| | `GET` | `/api/categories` | Mendapatkan daftar kategori dinamis |
| | `GET` | `/api/banners` | Menampilkan Promo Banners |
| | `GET` | `/api/flash-sales` | Menampilkan event Flash Sale saat ini |
| **Keranjang** | `GET/POST` | `/api/cart` | Manajemen Keranjang & Checkout |
| **Pesanan** | `POST` | `/api/orders` | Membuat pesanan baru |
| | `GET` | `/api/orders` | Melihat Riwayat Pesanan Pribadi |
| | `POST` | `/api/orders/apply-voucher`| Menggunakan Voucher Belanja |
| **Admin** | `PUT` | `/api/orders/:id/status`| Mengubah status order (Kirim Resi) |
| **Payment**| `POST` | `/api/payments/create` | Inisiasi transaksi Midtrans Snap WebView |
| **Chat** | `GET` | `/api/chats` | Melihat daftar ruang percakapan |

---

## 🏗️ Struktur Proyek

Proyek ini dibangun dengan mengedepankan modul *Feature-Based Architecture*:

```text
lib/
├── core/
│   ├── network/       # Dio singleton, Interceptors, HTTP Client
│   └── theme/         # Huashu Design System, Kustomisasi Komponen (Seal, InkDivider)
├── features/
│   ├── admin/         # Layar khusus penjual/admin (Panel, Order Detail)
│   ├── auth/          # Layar login & register
│   ├── chat/          # Real-time chat list & room (REST + Socket.io)
│   ├── notification/  # Riwayat notifikasi
│   ├── order/         # Checkout, riwayat, lacak resi, Snap Midtrans, Cart, Voucher
│   ├── product/       # Katalog, detail barang, pencarian, flash sale, Wishlist
│   └── profile/       # Edit profil (nama, foto) dan manajemen alamat pengiriman
└── main.dart          # Entry point aplikasi & Provider registrations
```

---

## 🤝 Pedoman Kontribusi (Contributing)

Kami sangat menghargai kontribusi dari komunitas! Baik itu pelaporan *bug*, penambahan fitur, maupun perbaikan dokumentasi.

1. **Fork** repositori ini.
2. Buat cabang fitur Anda (`git checkout -b feature/FiturKerenAnda`).
3. Lakukan komit perubahan Anda sesuai standar [Conventional Commits](https://www.conventionalcommits.org/en/v1.0.0/) (`git commit -m 'feat: menambahkan fitur keren'`).
4. **Push** ke cabang Anda (`git push origin feature/FiturKerenAnda`).
5. Buka sebuah **Pull Request** ke *branch* `main`.

> Harap pastikan kode Anda selalu lulus pemeriksaan linter (`flutter analyze`) sebelum membuat *Pull Request*.

---

## 📜 Lisensi

Proyek ini dilisensikan di bawah **MIT License**.
Lihat file [LICENSE](LICENSE) untuk detail lebih lanjut.

Sederhananya: Anda **bebas** untuk menggunakan, menyalin, memodifikasi, menggabungkan, menerbitkan, mendistribusikan, mensublisensikan, dan/atau menjual salinan perangkat lunak ini asalkan mencantumkan atribusi hak cipta dan pemberitahuan lisensi asli.

---

<p align="center">
  <sub>— 華 書 —</sub><br/>
  <sub><i>"Tinta di atas kertas Xuan — keheningan yang berbicara"</i></sub>
</p>
