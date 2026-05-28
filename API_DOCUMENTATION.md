# 📦 Marketplace with Payment — API Documentation

> **Base URL:** `http://localhost:5000`
>
> **Version:** 1.0.0
>
> **Author:** @Fyxis

---

## 📑 Daftar Isi

- [Informasi Umum](#-informasi-umum)
- [Authentication](#-authentication)
  - [Register](#1-register)
  - [Login](#2-login)
  - [Refresh Token](#3-refresh-token)
  - [Verify Token](#4-verify-token)
- [Products](#-products)
  - [Get All Products](#1-get-all-products)
  - [Get Product By ID](#2-get-product-by-id)
  - [Create Product](#3-create-product)
  - [Update Product](#4-update-product)
  - [Delete Product](#5-delete-product)
- [Orders](#-orders)
  - [Create Order](#1-create-order)
  - [Get User Orders](#2-get-user-orders)
  - [Get Order By ID](#3-get-order-by-id)
- [Payments](#-payments)
  - [Create Payment](#1-create-payment)
  - [Webhook (Midtrans Notification)](#2-webhook-midtrans-notification)
- [Database Schema](#-database-schema)
- [Error Handling](#-error-handling)

---

## 📌 Informasi Umum

### Tech Stack

| Komponen        | Teknologi                     |
| --------------- | ----------------------------- |
| Runtime         | Node.js                       |
| Framework       | Express.js v5                  |
| Database        | SQLite                         |
| ORM             | Prisma v6                      |
| Authentication  | JWT (jsonwebtoken)             |
| Password Hash   | bcryptjs                       |
| Payment Gateway | Midtrans (Snap API)            |
| File Upload     | Multer                         |

### Format Response

Semua endpoint mengembalikan response dalam format JSON yang konsisten:

```json
{
  "success": true | false,
  "message": "Pesan deskriptif",
  "data": { ... }
}
```

Untuk endpoint yang mendukung pagination:

```json
{
  "success": true,
  "message": "...",
  "data": [ ... ],
  "pagination": {
    "total": 50,
    "page": 1,
    "limit": 10,
    "totalPages": 5
  }
}
```

### Autentikasi

Semua endpoint **kecuali** Auth dan Webhook membutuhkan header `Authorization` dengan format:

```
Authorization: Bearer <access_token>
```

Token didapatkan dari response endpoint **Login**.

### Health Check

```
GET /health
```

**Response:**

```json
{
  "status": "OK",
  "timestamp": "Senin, 26 Mei 2026 - 12:00:00"
}
```

---

## 🔐 Authentication

Base path: `/api/auth`

> ⚠️ Semua endpoint Auth bersifat **Public** (tidak memerlukan Bearer Token).

---

### 1. Register

Mendaftarkan user baru ke dalam sistem.

```
POST /api/auth/register
```

**Content-Type:** `multipart/form-data` atau `application/json`

**Request Body:**

| Field           | Type   | Required | Deskripsi                    |
| --------------- | ------ | -------- | ---------------------------- |
| email           | string | ✅        | Email user (harus unik)      |
| name            | string | ✅        | Nama lengkap user             |
| password        | string | ✅        | Password (min. 6 karakter)    |
| passwordConfirm | string | ✅        | Konfirmasi password           |

**Request Body Example (JSON):**

```json
{
  "email": "user@example.com",
  "name": "John Doe",
  "password": "password123",
  "passwordConfirm": "password123"
}
```

**Success Response (201):**

```json
{
  "success": true,
  "message": "Registrasi berhasil",
  "data": {
    "id": 1,
    "email": "user@example.com",
    "name": "John Doe",
    "role": "customer",
    "is_active": true,
    "created_at": "2026-05-26T05:00:00.000Z"
  }
}
```

**Error Responses:**

| Status | Kondisi                                    |
| ------ | ------------------------------------------ |
| 400    | Password dan konfirmasi password tidak cocok |
| 409    | Email sudah terdaftar                       |
| 500    | Internal server error                       |

---

### 2. Login

Login dan mendapatkan Access Token serta Refresh Token.

```
POST /api/auth/login
```

**Content-Type:** `multipart/form-data` atau `application/json`

**Request Body:**

| Field    | Type   | Required | Deskripsi     |
| -------- | ------ | -------- | ------------- |
| email    | string | ✅        | Email user     |
| password | string | ✅        | Password user  |

**Request Body Example (JSON):**

```json
{
  "email": "user@example.com",
  "password": "password123"
}
```

**Success Response (200):**

```json
{
  "success": true,
  "message": "Login berhasil",
  "data": {
    "id": 1,
    "email": "user@example.com",
    "name": "John Doe",
    "role": "customer",
    "created_at": "Senin, 26 Mei 2026 - 12:00:00",
    "updated_at": "Senin, 26 Mei 2026 - 12:00:00",
    "token": "eyJhbGciOiJIUzI1NiIs...",
    "refresh_token": "eyJhbGciOiJIUzI1NiIs..."
  }
}
```

**Token Details:**

| Token         | Masa Berlaku | Kegunaan                               |
| ------------- | ------------ | -------------------------------------- |
| token         | 7 hari (configurable)  | Access token untuk mengakses semua endpoint protected |
| refresh_token | 30 hari (configurable) | Untuk mendapatkan access token baru tanpa login ulang |

**Error Responses:**

| Status | Kondisi                   |
| ------ | ------------------------- |
| 400    | Email atau password kosong |
| 401    | Password salah             |
| 404    | User tidak ditemukan       |
| 500    | Internal server error      |

---

### 3. Refresh Token

Mendapatkan Access Token baru menggunakan Refresh Token. Digunakan ketika Access Token sudah expired agar user tidak perlu login ulang.

```
POST /api/auth/refresh-token
```

**Content-Type:** `multipart/form-data` atau `application/json`

**Request Body:**

| Field         | Type   | Required | Deskripsi                        |
| ------------- | ------ | -------- | -------------------------------- |
| refresh_token | string | ✅        | Refresh token dari response login |

**Request Body Example (JSON):**

```json
{
  "refresh_token": "eyJhbGciOiJIUzI1NiIs..."
}
```

**Success Response (200):**

```json
{
  "success": true,
  "message": "Token berhasil diperbarui",
  "data": {
    "token": "eyJhbGciOiJIUzI1NiIs..."
  }
}
```

**Error Responses:**

| Status | Kondisi                                          |
| ------ | ------------------------------------------------ |
| 400    | Refresh token tidak disertakan                    |
| 401    | Refresh token tidak valid / expired / user tidak aktif |

---

### 4. Verify Token

Memverifikasi apakah Access Token masih valid.

```
GET /api/auth/verify-token
```

**Headers:**

```
Authorization: Bearer <access_token>
```

**Success Response (200):**

```json
{
  "success": true,
  "message": "Token valid",
  "data": {
    "id": 1,
    "email": "user@example.com",
    "role": "customer",
    "iat": 1716700800,
    "exp": 1717305600
  }
}
```

**Error Responses:**

| Status | Kondisi                |
| ------ | ---------------------- |
| 401    | Token tidak ditemukan / tidak valid |

---

## 📦 Products

Base path: `/api/products`

> 🔒 Semua endpoint Product membutuhkan **Bearer Token** di header `Authorization`.

---

### 1. Get All Products

Mengambil daftar semua produk dengan dukungan pagination dan filter.

```
GET /api/products
```

**Query Parameters:**

| Parameter | Type    | Default | Deskripsi                                    |
| --------- | ------- | ------- | -------------------------------------------- |
| page      | number  | 1       | Nomor halaman                                 |
| limit     | number  | 10      | Jumlah produk per halaman                      |
| category  | string  | -       | Filter berdasarkan kategori (exact match)      |
| seller_id | number  | -       | Filter berdasarkan ID penjual                  |
| search    | string  | -       | Pencarian berdasarkan nama produk              |
| minPrice  | number  | -       | Filter harga minimum                           |
| maxPrice  | number  | -       | Filter harga maksimum                          |
| is_active | boolean | -       | Filter berdasarkan status aktif (`true`/`false`) |

**Contoh Request:**

```
GET /api/products?page=1&limit=5&category=Electronic&minPrice=50000&maxPrice=500000&search=laptop
```

**Success Response (200):**

```json
{
  "success": true,
  "message": "Berhasil mengambil data produk",
  "data": [
    {
      "id": 1,
      "name": "Laptop ASUS",
      "description": "Laptop gaming terbaru",
      "price": "Rp 15.000.000",
      "stock": 10,
      "category": "Electronic",
      "image_url": "http://localhost:5000/public/products/image_url-1716700800.png",
      "seller_id": 1,
      "is_active": true,
      "created_at": "Senin, 26 Mei 2026 - 12:00:00",
      "updated_at": "Senin, 26 Mei 2026 - 12:00:00",
      "seller": {
        "id": 1,
        "name": "John Doe",
        "email": "john@example.com"
      }
    }
  ],
  "pagination": {
    "total": 50,
    "page": 1,
    "limit": 5,
    "totalPages": 10
  }
}
```

---

### 2. Get Product By ID

Mengambil detail satu produk berdasarkan ID.

```
GET /api/products/:id
```

**Path Parameters:**

| Parameter | Type   | Deskripsi    |
| --------- | ------ | ------------ |
| id        | number | ID produk     |

**Contoh Request:**

```
GET /api/products/1
```

**Success Response (200):**

```json
{
  "success": true,
  "message": "Berhasil mengambil data produk",
  "data": {
    "id": 1,
    "name": "Laptop ASUS",
    "description": "Laptop gaming terbaru",
    "price": "Rp 15.000.000",
    "stock": 10,
    "category": "Electronic",
    "image_url": "http://localhost:5000/public/products/image_url-1716700800.png",
    "seller_id": 1,
    "is_active": true,
    "created_at": "Senin, 26 Mei 2026 - 12:00:00",
    "updated_at": "Senin, 26 Mei 2026 - 12:00:00",
    "seller": {
      "id": 1,
      "name": "John Doe",
      "email": "john@example.com"
    }
  }
}
```

**Error Responses:**

| Status | Kondisi               |
| ------ | --------------------- |
| 400    | ID produk tidak valid  |
| 404    | Produk tidak ditemukan |

---

### 3. Create Product

Membuat produk baru. Field `seller_id` otomatis diambil dari user yang sedang login.

```
POST /api/products/create
```

**Content-Type:** `multipart/form-data`

**Request Body (form-data):**

| Field       | Type   | Required | Deskripsi                              |
| ----------- | ------ | -------- | -------------------------------------- |
| name        | string | ✅        | Nama produk                             |
| description | string | ❌        | Deskripsi produk                        |
| price       | number | ✅        | Harga produk (dalam Rupiah)              |
| stock       | number | ❌        | Jumlah stok (default: 0)                |
| category    | string | ❌        | Kategori produk (default: uncategorized) |
| image_url   | file   | ✅        | Gambar produk (max 5MB, format: jpg/png/jpeg) |

**Contoh di Postman:**
- Body → `form-data`
- Key: `name` → Value: `Laptop ASUS`
- Key: `price` → Value: `15000000`
- Key: `stock` → Value: `10`
- Key: `category` → Value: `Electronic`
- Key: `description` → Value: `Laptop gaming terbaru`
- Key: `image_url` (type: File) → Pilih gambar dari komputer

**Success Response (201):**

```json
{
  "success": true,
  "message": "Produk berhasil dibuat",
  "data": {
    "id": 1,
    "name": "Laptop ASUS",
    "description": "Laptop gaming terbaru",
    "price": "Rp 15.000.000",
    "stock": 10,
    "category": "Electronic",
    "image_url": "http://localhost:5000/public/products/image_url-1716700800.png",
    "seller_id": 1,
    "is_active": true,
    "created_at": "Senin, 26 Mei 2026 - 12:00:00",
    "updated_at": "Senin, 26 Mei 2026 - 12:00:00"
  }
}
```

---

### 4. Update Product

Memperbarui data produk. Hanya **pemilik produk** (seller) yang bisa mengubah.

```
PUT /api/products/update/:id
```

**Content-Type:** `multipart/form-data`

**Path Parameters:**

| Parameter | Type   | Deskripsi    |
| --------- | ------ | ------------ |
| id        | number | ID produk     |

**Request Body (form-data):**

| Field       | Type    | Required | Deskripsi                          |
| ----------- | ------- | -------- | ---------------------------------- |
| name        | string  | ❌        | Nama produk baru                    |
| description | string  | ❌        | Deskripsi produk baru               |
| price       | number  | ❌        | Harga produk baru                   |
| stock       | number  | ❌        | Jumlah stok baru                    |
| category    | string  | ❌        | Kategori baru                       |
| image_url   | file    | ❌        | Gambar produk baru                  |
| is_active   | boolean | ❌        | Status aktif (`true` / `false`)     |

> 💡 Hanya field yang dikirim saja yang akan di-update. Field yang tidak dikirim akan tetap menggunakan nilai lama.

**Success Response (200):**

```json
{
  "success": true,
  "message": "Produk berhasil diperbarui",
  "data": { ... }
}
```

**Error Responses:**

| Status | Kondisi                                    |
| ------ | ------------------------------------------ |
| 400    | ID produk tidak valid                       |
| 403    | Bukan pemilik produk (akses ditolak)         |
| 404    | Produk tidak ditemukan                       |

---

### 5. Delete Product

Menghapus produk secara permanen. Hanya **pemilik produk** (seller) yang bisa menghapus.

```
DELETE /api/products/delete/:id
```

**Path Parameters:**

| Parameter | Type   | Deskripsi    |
| --------- | ------ | ------------ |
| id        | number | ID produk     |

**Success Response (200):**

```json
{
  "success": true,
  "message": "Produk berhasil dihapus"
}
```

**Error Responses:**

| Status | Kondisi                              |
| ------ | ------------------------------------ |
| 400    | ID produk tidak valid                 |
| 403    | Bukan pemilik produk (akses ditolak)  |
| 404    | Produk tidak ditemukan                |

---

## 🛒 Orders

Base path: `/api/orders`

> 🔒 Semua endpoint Order membutuhkan **Bearer Token** di header `Authorization`.

---

### 1. Create Order

Membuat pesanan baru. Field `user_id` otomatis diambil dari user yang sedang login.

```
POST /api/orders
```

**Content-Type:** `application/json` (RAW JSON)

**Request Body:**

| Field            | Type   | Required | Deskripsi                                |
| ---------------- | ------ | -------- | ---------------------------------------- |
| items            | array  | ✅        | Daftar barang yang dipesan                |
| items[].product_id | number | ✅      | ID produk                                 |
| items[].quantity  | number | ✅       | Jumlah barang                             |
| items[].price     | number | ✅       | Harga satuan barang                       |
| total_amount     | number | ✅        | Total harga keseluruhan pesanan           |
| shipping_address | object | ❌        | Alamat pengiriman (format bebas)          |
| notes            | string | ❌        | Catatan tambahan untuk pesanan            |

**Request Body Example:**

```json
{
  "total_amount": 250000,
  "shipping_address": {
    "nama_penerima": "Budi Santoso",
    "nomor_hp": "081234567890",
    "jalan": "Jl. Kemerdekaan No. 45",
    "kota": "Jakarta Selatan",
    "provinsi": "DKI Jakarta",
    "kode_pos": "12345"
  },
  "notes": "Tolong dipacking bubble wrap",
  "items": [
    {
      "product_id": 1,
      "quantity": 2,
      "price": 100000
    },
    {
      "product_id": 2,
      "quantity": 1,
      "price": 50000
    }
  ]
}
```

**Success Response (201):**

```json
{
  "success": true,
  "message": "Pesanan berhasil dibuat",
  "data": {
    "id": 1,
    "user_id": 1,
    "status": "pending",
    "payment_status": "unpaid",
    "total_amount": "Rp 250.000",
    "shipping_address": "{...}",
    "notes": "Tolong dipacking bubble wrap",
    "created_at": "Senin, 26 Mei 2026 - 12:00:00",
    "updated_at": "Senin, 26 Mei 2026 - 12:00:00",
    "order_items": [
      {
        "id": 1,
        "order_id": 1,
        "product_id": 1,
        "quantity": 2,
        "price": "Rp 100.000",
        "created_at": "Senin, 26 Mei 2026 - 12:00:00"
      }
    ]
  }
}
```

**Error Responses:**

| Status | Kondisi                          |
| ------ | -------------------------------- |
| 400    | Items kosong / total_amount kosong |
| 500    | Internal server error             |

---

### 2. Get User Orders

Mengambil daftar semua pesanan milik user yang sedang login, dengan dukungan pagination dan filter.

```
GET /api/orders
```

**Query Parameters:**

| Parameter      | Type   | Default | Deskripsi                                          |
| -------------- | ------ | ------- | -------------------------------------------------- |
| page           | number | 1       | Nomor halaman                                       |
| limit          | number | 10      | Jumlah pesanan per halaman                           |
| status         | string | -       | Filter status pesanan (`pending`, `processing`, `shipped`, `delivered`, `cancelled`) |
| payment_status | string | -       | Filter status pembayaran (`unpaid`, `pending`, `paid`, `failed`, `cancelled`)        |

**Contoh Request:**

```
GET /api/orders?page=1&limit=5&status=pending&payment_status=unpaid
```

**Success Response (200):**

```json
{
  "success": true,
  "message": "Berhasil mengambil data pesanan",
  "data": [
    {
      "id": 1,
      "user_id": 1,
      "status": "pending",
      "payment_status": "unpaid",
      "total_amount": "Rp 250.000",
      "shipping_address": {
        "nama_penerima": "Budi Santoso",
        "jalan": "Jl. Kemerdekaan No. 45",
        "kota": "Jakarta Selatan"
      },
      "notes": "Tolong dipacking bubble wrap",
      "created_at": "Senin, 26 Mei 2026 - 12:00:00",
      "updated_at": "Senin, 26 Mei 2026 - 12:00:00",
      "order_items": [
        {
          "id": 1,
          "product_id": 1,
          "quantity": 2,
          "price": "Rp 100.000",
          "product": {
            "id": 1,
            "name": "Laptop ASUS",
            "image_url": "http://localhost:5000/public/products/image.png"
          }
        }
      ]
    }
  ],
  "pagination": {
    "total": 10,
    "page": 1,
    "limit": 5,
    "totalPages": 2
  }
}
```

---

### 3. Get Order By ID

Mengambil detail satu pesanan berdasarkan ID. User hanya bisa melihat pesanannya sendiri (kecuali admin).

```
GET /api/orders/:id
```

**Path Parameters:**

| Parameter | Type   | Deskripsi    |
| --------- | ------ | ------------ |
| id        | number | ID pesanan    |

**Success Response (200):**

```json
{
  "success": true,
  "message": "Berhasil mengambil data pesanan",
  "data": {
    "id": 1,
    "user_id": 1,
    "status": "pending",
    "payment_status": "unpaid",
    "total_amount": "Rp 250.000",
    "shipping_address": { ... },
    "notes": "...",
    "created_at": "...",
    "updated_at": "...",
    "order_items": [ ... ],
    "user": {
      "id": 1,
      "name": "John Doe",
      "email": "john@example.com"
    }
  }
}
```

**Error Responses:**

| Status | Kondisi                              |
| ------ | ------------------------------------ |
| 400    | ID pesanan tidak valid                |
| 403    | Bukan pemilik pesanan (akses ditolak) |
| 404    | Pesanan tidak ditemukan               |

---

## 💳 Payments

Base path: `/api/payments`

---

### 1. Create Payment

Membuat transaksi pembayaran melalui Midtrans berdasarkan Order ID. Mengembalikan `token` dan `redirect_url` untuk menampilkan halaman pembayaran Midtrans Snap.

```
POST /api/payments/create
```

> 🔒 Membutuhkan **Bearer Token**

**Content-Type:** `application/json` (RAW JSON)

**Request Body:**

| Field    | Type   | Required | Deskripsi                   |
| -------- | ------ | -------- | --------------------------- |
| order_id | number | ✅        | ID pesanan yang ingin dibayar |

**Request Body Example:**

```json
{
  "order_id": 1
}
```

**Success Response (200):**

```json
{
  "success": true,
  "message": "Berhasil mendapatkan token pembayaran",
  "data": {
    "token": "66e4fa55-fdac-4ef9-91b5-733b97d1b862",
    "redirect_url": "https://app.sandbox.midtrans.com/snap/v4/redirection/66e4fa55-fdac-4ef9-91b5-733b97d1b862"
  }
}
```

**Cara Penggunaan di Frontend:**

```html
<!-- Tambahkan Midtrans Snap JS -->
<script src="https://app.sandbox.midtrans.com/snap/snap.js"
        data-client-key="SB-Mid-client-xxxxx"></script>

<script>
  // Panggil snap.pay() dengan token dari response
  snap.pay('66e4fa55-fdac-4ef9-91b5-733b97d1b862', {
    onSuccess: function(result) { console.log('Pembayaran berhasil', result); },
    onPending: function(result) { console.log('Menunggu pembayaran', result); },
    onError: function(result)   { console.log('Pembayaran gagal', result); },
    onClose: function()         { console.log('Pop-up ditutup tanpa bayar'); }
  });
</script>
```

Atau, Anda bisa langsung redirect user ke `redirect_url` yang dikembalikan.

**Error Responses:**

| Status | Kondisi                                            |
| ------ | -------------------------------------------------- |
| 400    | Order ID tidak disertakan / status sudah dibayar    |
| 403    | Bukan pemilik pesanan                               |
| 404    | Pesanan tidak ditemukan                              |
| 500    | Gagal koneksi ke Midtrans / Server Key tidak valid   |

---

### 2. Webhook (Midtrans Notification)

Endpoint ini dipanggil **secara otomatis oleh server Midtrans** setiap kali terjadi perubahan status pembayaran. **JANGAN dipanggil manual dari Frontend atau Postman.**

```
POST /api/payments/webhook
```

> ⚠️ **Public endpoint** — Tidak memerlukan Bearer Token karena dipanggil langsung oleh server Midtrans.

**Konfigurasi di Dashboard Midtrans:**

Daftarkan URL berikut di **Settings → Configuration → Payment Notification URL**:

```
https://<domain-anda>/api/payments/webhook
```

> 💡 Jika testing secara lokal, gunakan [Ngrok](https://ngrok.com/) untuk mengekspos `localhost` Anda:
> ```
> https://xxxx.ngrok-free.app/api/payments/webhook
> ```

**Mapping Status dari Midtrans:**

| Midtrans Status        | Payment Status (DB) | Order Payment Status (DB) | Order Status (DB) |
| ---------------------- | ------------------- | -------------------------- | ------------------ |
| `capture` + `accept`   | `completed`         | `paid`                     | `processing`       |
| `settlement`           | `completed`         | `paid`                     | `processing`       |
| `pending`              | `pending`           | `pending`                  | `pending`          |
| `cancel` / `deny` / `expire` | `failed`      | `failed`                   | `pending`          |
| `capture` + `challenge` | `pending`          | `pending`                  | `pending`          |

**Response ke Midtrans (200):**

```json
{
  "success": true,
  "message": "Webhook processed"
}
```

---

## 🗄️ Database Schema

### Entity Relationship Diagram

```mermaid
erDiagram
    User ||--o{ Product : "sells"
    User ||--o{ Order : "places"
    Order ||--o{ OrderItem : "contains"
    Product ||--o{ OrderItem : "included_in"
    Order ||--o| Payment : "has"

    User {
        int id PK
        string email UK
        string name
        string password_hash
        string role
        boolean is_active
        datetime created_at
        datetime updated_at
    }

    Product {
        int id PK
        string name
        string description
        float price
        int stock
        string category
        string image_url
        int seller_id FK
        boolean is_active
        datetime created_at
        datetime updated_at
    }

    Order {
        int id PK
        int user_id FK
        string status
        string payment_status
        float total_amount
        string shipping_address
        string notes
        datetime created_at
        datetime updated_at
    }

    OrderItem {
        int id PK
        int order_id FK
        int product_id FK
        int quantity
        float price
        datetime created_at
    }

    Payment {
        int id PK
        int order_id FK_UK
        float amount
        string payment_method
        string transaction_id UK
        string status
        string metadata
        datetime created_at
        datetime updated_at
    }
```

### Status Values

**Order Status:**

| Status       | Deskripsi                              |
| ------------ | -------------------------------------- |
| `pending`    | Pesanan baru dibuat, belum diproses     |
| `processing` | Pesanan sedang diproses setelah bayar   |
| `shipped`    | Pesanan sedang dikirim                  |
| `delivered`  | Pesanan sudah sampai ke pembeli         |
| `cancelled`  | Pesanan dibatalkan                      |

**Order Payment Status:**

| Status      | Deskripsi                              |
| ----------- | -------------------------------------- |
| `unpaid`    | Belum melakukan pembayaran              |
| `pending`   | Menunggu konfirmasi pembayaran          |
| `paid`      | Pembayaran berhasil/lunas               |
| `failed`    | Pembayaran gagal                        |
| `cancelled` | Pembayaran dibatalkan                   |

**Payment Status (tabel payments):**

| Status      | Deskripsi                              |
| ----------- | -------------------------------------- |
| `pending`   | Menunggu pembayaran                     |
| `completed` | Pembayaran berhasil                     |
| `failed`    | Pembayaran gagal                        |
| `cancelled` | Pembayaran dibatalkan                   |
| `expired`   | Pembayaran kadaluarsa                   |

---

## ⚠️ Error Handling

Semua error response mengikuti format konsisten:

```json
{
  "success": false,
  "message": "Deskripsi error"
}
```

### HTTP Status Codes

| Code | Deskripsi                                      |
| ---- | ---------------------------------------------- |
| 200  | Berhasil (OK)                                   |
| 201  | Berhasil membuat data baru (Created)             |
| 400  | Request tidak valid / data kurang (Bad Request)  |
| 401  | Token tidak ada / expired / tidak valid (Unauthorized) |
| 403  | Tidak memiliki akses (Forbidden)                 |
| 404  | Data tidak ditemukan (Not Found)                 |
| 409  | Data duplikat / konflik (Conflict)               |
| 500  | Kesalahan server internal (Internal Server Error) |

### Authentication Errors

| Kondisi                | Status | Message                                          |
| ---------------------- | ------ | ------------------------------------------------ |
| Token tidak dikirim     | 401    | Akses ditolak. Token tidak ditemukan              |
| Token expired           | 401    | Token sudah kadaluarsa. Silakan login kembali     |
| Token tidak valid       | 401    | Token tidak valid                                 |
| Akun dinonaktifkan      | 403    | Akun telah dinonaktifkan                          |

---

## 🔧 Environment Variables

| Variable                 | Deskripsi                                  | Contoh                    |
| ------------------------ | ------------------------------------------ | ------------------------- |
| `PORT`                   | Port server                                 | `5000`                    |
| `BASE_URL`               | Base URL server                              | `http://localhost:5000`   |
| `DATABASE_URL`           | Koneksi database Prisma (SQLite)             | `file:./dev.db?connection_limit=1` |
| `JWT_SECRET`             | Secret key untuk access token JWT            | `your_secret_key`         |
| `JWT_EXPIRATION`         | Masa berlaku access token                    | `7d`                      |
| `JWT_REFRESH_SECRET`     | Secret key untuk refresh token               | `your_refresh_secret`     |
| `JWT_REFRESH_EXPIRATION` | Masa berlaku refresh token                   | `30d`                     |
| `MIDTRANS_SERVER_KEY`    | Server Key Midtrans                          | `SB-Mid-server-xxxxx`    |
| `MIDTRANS_CLIENT_KEY`    | Client Key Midtrans                          | `SB-Mid-client-xxxxx`    |
| `MIDTRANS_IS_PRODUCTION` | Mode Midtrans (`true` = production)          | `false`                   |
