# 🏛️ Software Design Description (SDD) — Arsitektur & Struktur Flutter

---

## 1. Desain Arsitektur Sistem (Clean Architecture)

Aplikasi Flutter ini mengadopsi pola **Clean Architecture** yang memisahkan logika bisnis inti dari detail UI dan infrastruktur eksternal. Struktur kode dibagi menjadi tiga lapisan terisolasi:

```
┌────────────────────────────────────────────────────────┐
│                   PRESENTATION LAYER                   │
│  - UI Screens & Pages    - Custom Paint Paint-Widgets  │
│  - BLoC / Cubit States   - Custom Elegant Dialogs      │
└───────────────────────────┬────────────────────────────┘
                            │ (Mengamati State)
                            ▼
┌────────────────────────────────────────────────────────┐
│                      DOMAIN LAYER                      │
│  - Usecases (Business)   - Entities (Plain Data)       │
│  - Repository Interfaces (Abstraksi Kontrak)            │
└───────────────────────────▲────────────────────────────┘
                            │ (Mengimplementasikan Kontrak)
                            │
┌────────────────────────────────────────────────────────┐
│                       DATA LAYER                       │
│  - Repositories Impl     - Data Sources (Dio Client)   │
│  - Isar Database Cache   - DTOs / Request-Response     │
└────────────────────────────────────────────────────────┘
```

### 1.1 Deskripsi Lapisan (Layer Specification)
*   **Presentation Layer**: Berisi widget UI Flutter dan BLoC/Cubit. Lapisan ini tidak memiliki logika bisnis langsung dan hanya bertugas menggambarkan state saat ini serta mengirimkan event tindakan pengguna.
*   **Domain Layer**: Merupakan inti aplikasi yang tidak bergantung pada framework Flutter maupun database eksternal. Berisi entitas data murni dan Usecase yang mendefinisikan apa saja aksi nyata yang bisa dilakukan oleh pengguna (contoh: `LoginUser`, `CreateProduct`, `FetchCatalog`).
*   **Data Layer**: Bertanggung jawab atas pengambilan dan penyimpanan data. Mengimplementasikan kontrak repositori dari domain layer, berinteraksi dengan API Server backend menggunakan **Dio Client** dan melakukan caching lokal ke **Isar Database**.

---

## 2. Struktur Direktori Proyek (Project Directory Structure)

Proyek Flutter akan diorganisasikan menggunakan pendekatan **Feature-Driven Clean Architecture** (Struktur Berbasis Fitur), membagi direktori di dalam `lib/` berdasarkan fungsionalitas produk untuk memudahkan pembagian tugas tim developer:

```
lib/
├── core/                         # Utilitas global dan token desain
│   ├── theme/                    # Token Huashu ThemeData & Palette warna
│   ├── network/                  # Dio Client instance & Token Interceptor
│   ├── storage/                  # Enkripsi Flutter Secure Storage helper
│   ├── errors/                   # Class Exception dan Failure pemetaan
│   └── di/                       # Service Locator Dependency Injection (GetIt)
├── features/                     # Fitur-fitur modular aplikasi
│   ├── auth/                     # Fitur Registrasi, Login & Logout
│   │   ├── data/                 # Model DTO, AuthDataSource & Repository Impl
│   │   ├── domain/               # Entity User, Usecases & Repository Contract
│   │   └── presentation/         # Cubit state controllers & Login/Register Screen
│   ├── product/                  # Fitur Katalog Produk & Manajemen CRUD (Seller)
│   │   ├── data/
│   │   ├── domain/
│   │   └── presentation/         # Catalog Grid, Detail & CreateProduct Screen
│   ├── order/                    # Fitur Keranjang Belanja & Pembuatan Order
│   │   ├── data/
│   │   ├── domain/
│   │   └── presentation/         # Cart View, Checkout View & Order List Screen
│   └── payment/                  # Fitur Snap WebView & Validasi Status Transaksi
│       ├── data/
│       ├── domain/
│       └── presentation/         # SnapWebViewWidget & Success/Failed Screens
└── main.dart                     # Entrypoint aplikasi utama, inisialisasi DI & DB
```

---

## 3. Pola State Management (BLoC / Cubit)

State Management diimplementasikan menggunakan **Flutter Bloc (Cubit)** untuk kejelasan transisi data, skalabilitas, dan kemudahan pengujian unit:

*   **Pemisahan Aliran Data**: Cubit menerima trigger interaktif dari UI Widget, menjalankan asinkronus call ke Domain Layer (Usecase), menerima callback `Either<Failure, Success>`, lalu memancarkan state yang sesuai (`LoadingState`, `LoadedState`, atau `ErrorState`).
*   **Kejelasan State**: State dideklarasikan sebagai kelas immutable terpisah menggunakan package `freezed` atau secara manual untuk mencegah mutasi state yang tidak disengaja di dalam presentation layer.

---

## 4. Desain Database Cache Lokal (Isar Cache Schema)

Untuk mengoptimalkan pemuatan offline first, data produk dan pesanan yang diambil dari API backend disimpan secara lokal menggunakan database **Isar**. Skema entity didefinisikan sebagai berikut:

### 4.1 Skema `CachedProduct` (Katalog Offline)
```dart
import 'package:isar/isar.dart';

part 'cached_product.g.dart';

@collection
class CachedProduct {
  Id id = Isar.autoIncrement;

  @Index(unique: true, replace: true)
  int? productId; // ID produk dari server backend

  String? name;
  String? description;
  double? price;
  int? stock;
  String? category;
  String? imageUrl;
  int? sellerId;
  bool? isActive;
  DateTime? createdAt;
}
```

### 4.2 Skema `CachedOrder` (Riwayat Pesanan Offline)
```dart
import 'package:isar/isar.dart';

part 'cached_order.g.dart';

@collection
class CachedOrder {
  Id id = Isar.autoIncrement;

  @Index(unique: true, replace: true)
  int? orderId;

  String? status;
  String? paymentStatus;
  double? totalAmount;
  String? shippingAddressJson; // Disimpan sebagai JSON string terkompresi
  String? notes;
  DateTime? createdAt;
}
```

---

## 5. Injeksi Ketergantungan (Dependency Injection)

Pengelolaan siklus hidup (lifecycle) instance class global diatur menggunakan service locator **GetIt** untuk efisiensi alokasi memori RAM perangkat:

*   **Singletons (Dibuat sekali saat startup)**:
    *   `Dio`: Instance HTTP Client global dengan konfigurasi timeout dan interceptor refresh token.
    *   `FlutterSecureStorage`: Instance enkripsi hardware kredensial.
    *   `Isar`: Koneksi database cache lokal.
*   **Factory (Dibuat baru setiap kali diakses)**:
    *   `Cubit` / `Bloc` instances untuk memastikan state dibersihkan secara bersih saat pengguna keluar dari halaman (auto-disposed presentation controllers).
