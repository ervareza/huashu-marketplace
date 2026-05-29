# 📦 Marketplace with Payment — API Documentation

> **Base URL:** `http://localhost:5000`
>
> **Version:** 3.0.0
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
  - [Forgot Password](#5-forgot-password)
  - [Reset Password](#6-reset-password)
- [Products](#-products)
  - [Get All Products](#1-get-all-products)
  - [Get Product By ID](#2-get-product-by-id)
  - [Create Product](#3-create-product)
  - [Update Product](#4-update-product)
  - [Delete Product](#5-delete-product)
  - [Search Products](#6-search-products)
- [Product Reviews](#-product-reviews)
  - [Get Product Reviews](#1-get-product-reviews)
  - [Create Review](#2-create-review)
  - [Seller Reply to Review](#3-seller-reply-to-review)
- [Cart (Keranjang Belanja)](#-cart-keranjang-belanja)
  - [Get Cart](#1-get-cart)
  - [Add to Cart](#2-add-to-cart)
  - [Update Cart Item](#3-update-cart-item)
  - [Remove Cart Item](#4-remove-cart-item)
- [Wishlist](#-wishlist)
  - [Get Wishlist](#1-get-wishlist)
  - [Add to Wishlist](#2-add-to-wishlist)
  - [Remove from Wishlist](#3-remove-from-wishlist)
- [Orders](#-orders)
  - [Create Order](#1-create-order)
  - [Get User Orders](#2-get-user-orders)
  - [Get Order By ID](#3-get-order-by-id)
  - [Cancel Order](#4-cancel-order)
  - [Apply Voucher](#5-apply-voucher)
  - [Submit Dispute](#6-submit-dispute)
- [Payments](#-payments)
  - [Create Payment](#1-create-payment)
  - [Webhook (Midtrans Notification)](#2-webhook-midtrans-notification)
- [User Profile & Addresses](#-user-profile--addresses)
  - [Get Profile](#1-get-profile)
  - [Update Profile](#2-update-profile)
  - [Delete Account](#3-delete-account)
  - [Get Addresses](#4-get-addresses)
  - [Add Address](#5-add-address)
  - [Update Address](#6-update-address)
  - [Delete Address](#7-delete-address)
  - [Set Default Address](#8-set-default-address)
- [Shipping](#-shipping)
  - [Calculate Shipping](#1-calculate-shipping)
- [Categories](#-categories)
  - [Get Categories](#1-get-categories)
- [Chat (Real-time)](#-chat-real-time)
  - [Get Chat Rooms](#1-get-chat-rooms)
  - [Start Chat](#2-start-chat)
  - [Get Chat Messages](#3-get-chat-messages)
  - [Send Message](#4-send-message)
- [Vouchers & Flash Sale](#-vouchers--flash-sale)
  - [Get Vouchers](#1-get-vouchers)
  - [Get Flash Sales](#2-get-flash-sales)
- [Notifications](#-notifications)
  - [Get Notifications](#1-get-notifications)
  - [Mark All Read](#2-mark-all-read)
- [Banners](#-banners)
  - [Get Banners](#1-get-banners)
- [Seller Dashboard](#-seller-dashboard)
  - [Get Dashboard Stats](#1-get-seller-dashboard-stats)
- [Admin Panel](#-admin-panel)
  - [Get All Orders](#1-get-all-orders-admin)
  - [Update Order Status](#2-update-order-status)
  - [Update Order Tracking](#3-update-order-tracking)
  - [Dashboard Stats](#4-dashboard-stats)
  - [Resolve Dispute](#5-resolve-dispute)
  - [Create Banner](#6-create-banner)
  - [Create Category](#7-create-category)
  - [Get All Users](#8-get-all-users)
  - [Ban User](#9-ban-user)
  - [Change User Role](#10-change-user-role)
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
| Real-time Chat  | Socket.io                      |

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

Endpoint dibagi menjadi 3 level akses:

| Level | Deskripsi | Header |
| ----- | --------- | ------ |
| 🟢 Public | Tidak perlu login | - |
| 🔒 Protected | Perlu Bearer Token | `Authorization: Bearer <access_token>` |
| 🔴 Admin | Perlu Bearer Token + role `admin` | `Authorization: Bearer <access_token>` |

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

> ⚠️ Semua endpoint Auth bersifat **🟢 Public** (tidak memerlukan Bearer Token).

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

### 5. Forgot Password

Meminta token reset password. Token dikirim via response (development) atau email (production).

> 💡 Menggunakan **stateless JWT** — token ditandatangani dengan password hash user sehingga otomatis invalid setelah password diubah (single-use).

```
POST /api/auth/forgot-password
```

**Content-Type:** `application/json`

**Request Body:**

| Field | Type   | Required | Deskripsi      |
| ----- | ------ | -------- | -------------- |
| email | string | ✅        | Email user      |

**Request Body Example:**

```json
{
  "email": "user@example.com"
}
```

**Success Response (200):**

```json
{
  "success": true,
  "message": "Jika email terdaftar, link reset password telah dikirim",
  "data": {
    "reset_token": "eyJhbGciOiJIUzI1NiIs..."
  }
}
```

> ⚠️ Field `data.reset_token` hanya muncul di **development mode** (`NODE_ENV !== 'production'`). Di production, token dikirim via email.

**Error Responses:**

| Status | Kondisi                  |
| ------ | ------------------------ |
| 400    | Email tidak diisi         |
| 403    | Akun telah dinonaktifkan  |

> 💡 Jika email tidak terdaftar, response tetap `200 OK` untuk mencegah **email enumeration attack**.

---

### 6. Reset Password

Mengatur password baru menggunakan token yang didapat dari endpoint Forgot Password.

```
POST /api/auth/reset-password
```

**Content-Type:** `application/json`

**Request Body:**

| Field           | Type   | Required | Deskripsi                      |
| --------------- | ------ | -------- | ------------------------------ |
| token           | string | ✅        | Token dari forgot-password      |
| password        | string | ✅        | Password baru (min. 6 karakter) |
| passwordConfirm | string | ✅        | Konfirmasi password baru        |

**Request Body Example:**

```json
{
  "token": "eyJhbGciOiJIUzI1NiIs...",
  "password": "newpassword123",
  "passwordConfirm": "newpassword123"
}
```

**Success Response (200):**

```json
{
  "success": true,
  "message": "Password berhasil direset. Silakan login dengan password baru."
}
```

**Error Responses:**

| Status | Kondisi                                              |
| ------ | ---------------------------------------------------- |
| 400    | Token tidak disertakan / password tidak cocok         |
| 400    | Token tidak valid atau sudah kadaluarsa (1 jam)       |
| 400    | Token sudah pernah digunakan (single-use by design)   |

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

> 💡 Hanya field yang dikirim saja yang akan di-update.

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

### 6. Search Products

Pencarian produk lanjutan dengan filter harga, kategori, dan penjual. Hanya menampilkan produk aktif.

```
GET /api/products/search
```

**Query Parameters:**

| Parameter | Type   | Default | Deskripsi                         |
| --------- | ------ | ------- | --------------------------------- |
| q         | string | -       | Kata kunci pencarian (nama produk) |
| category  | string | -       | Filter berdasarkan kategori        |
| minPrice  | number | -       | Filter harga minimum               |
| maxPrice  | number | -       | Filter harga maksimum              |
| seller_id | number | -       | Filter berdasarkan ID penjual      |
| page      | number | 1       | Nomor halaman                      |
| limit     | number | 10      | Jumlah per halaman                 |

**Contoh Request:**

```
GET /api/products/search?q=laptop&category=Electronic&minPrice=5000000&maxPrice=20000000
```

**Success Response (200):**

```json
{
  "success": true,
  "message": "Berhasil mencari produk",
  "data": [
    {
      "id": 1,
      "name": "Laptop ASUS",
      "price_formatted": "Rp 15.000.000",
      "category": "Electronic",
      ...
    }
  ],
  "pagination": {
    "total": 5,
    "page": 1,
    "limit": 10,
    "totalPages": 1
  }
}
```

---

## ⭐ Product Reviews

Base path: `/api/products/:id/reviews`

> 🔒 Membutuhkan **Bearer Token**.

---

### 1. Get Product Reviews

Mengambil daftar ulasan untuk produk tertentu, termasuk rata-rata rating.

```
GET /api/products/:id/reviews
```

**Path Parameters:**

| Parameter | Type   | Deskripsi    |
| --------- | ------ | ------------ |
| id        | number | ID produk     |

**Query Parameters:**

| Parameter | Type   | Default | Deskripsi              |
| --------- | ------ | ------- | ---------------------- |
| page      | number | 1       | Nomor halaman           |
| limit     | number | 10      | Jumlah ulasan per halaman |

**Success Response (200):**

```json
{
  "success": true,
  "message": "Berhasil mengambil data ulasan",
  "data": [
    {
      "id": 1,
      "user_id": 2,
      "product_id": 1,
      "rating": 5,
      "comment": "Produk bagus sekali, pengiriman cepat!",
      "image_url": "http://localhost:5000/public/reviews/review-1716700800.jpg",
      "created_at": "2026-05-27 10:30:00",
      "updated_at": "2026-05-27 10:30:00",
      "user": {
        "id": 2,
        "name": "Jane Doe",
        "avatar_url": null
      }
    }
  ],
  "summary": {
    "average_rating": 4.5,
    "total_reviews": 12
  },
  "pagination": {
    "total": 12,
    "page": 1,
    "limit": 10,
    "totalPages": 2
  }
}
```

---

### 2. Create Review

Menambahkan ulasan dan rating untuk produk yang sudah dibeli dan diterima (`delivered`).

```
POST /api/products/:id/reviews
```

**Content-Type:** `multipart/form-data`

> ⚠️ User hanya bisa memberikan **1 ulasan per produk**, dan produk harus sudah berstatus `delivered`.

**Request Body (form-data):**

| Field   | Type   | Required | Deskripsi                              |
| ------- | ------ | -------- | -------------------------------------- |
| rating  | number | ✅        | Rating 1-5 bintang                      |
| comment | string | ❌        | Teks ulasan                             |
| image   | file   | ❌        | Foto ulasan (max 5MB, format: jpg/png)  |

**Success Response (201):**

```json
{
  "success": true,
  "message": "Ulasan berhasil ditambahkan",
  "data": {
    "id": 1,
    "user_id": 2,
    "product_id": 1,
    "rating": 5,
    "comment": "Produk bagus sekali!",
    "image_url": "http://localhost:5000/public/reviews/review-1716700800.jpg",
    "created_at": "2026-05-27 10:30:00",
    "updated_at": "2026-05-27 10:30:00",
    "user": {
      "id": 2,
      "name": "Jane Doe",
      "avatar_url": null
    }
  }
}
```

**Error Responses:**

| Status | Kondisi                                              |
| ------ | ---------------------------------------------------- |
| 400    | Rating tidak diisi / rating bukan 1-5                |
| 400    | Sudah pernah memberikan ulasan untuk produk ini       |
| 400    | Produk belum diterima (status bukan `delivered`)      |

---

### 3. Seller Reply to Review

Penjual membalas ulasan pembeli pada produknya. Setiap ulasan hanya bisa dibalas **satu kali**.

```
POST /api/products/:id/reviews/:review_id/reply
```

> 🔒 Hanya **pemilik produk (seller)** yang bisa membalas ulasan.

**Path Parameters:**

| Parameter | Type   | Deskripsi    |
| --------- | ------ | ------------ |
| id        | number | ID produk     |
| review_id | number | ID ulasan     |

**Request Body:**

| Field | Type   | Required | Deskripsi     |
| ----- | ------ | -------- | ------------- |
| reply | string | ✅        | Teks balasan   |

**Request Body Example:**

```json
{
  "reply": "Terima kasih atas ulasannya! Senang Anda puas dengan produk kami 🙏"
}
```

**Success Response (200):**

```json
{
  "success": true,
  "message": "Balasan berhasil ditambahkan",
  "data": {
    "id": 1,
    "rating": 5,
    "comment": "Produk bagus sekali!",
    "reply": "Terima kasih atas ulasannya!",
    "reply_at": "2026-05-29 10:30:00",
    "user": { "id": 2, "name": "Jane Doe", "avatar_url": null }
  }
}
```

**Error Responses:**

| Status | Kondisi                                    |
| ------ | ------------------------------------------ |
| 400    | Balasan kosong / ulasan sudah dibalas        |
| 403    | Bukan pemilik produk                         |
| 404    | Ulasan tidak ditemukan                       |

---

## 🛒 Cart (Keranjang Belanja)

Base path: `/api/cart`

> 🔒 Semua endpoint Cart membutuhkan **Bearer Token**.

---

### 1. Get Cart

Mengambil seluruh isi keranjang user yang sedang login, termasuk subtotal.

```
GET /api/cart
```

**Success Response (200):**

```json
{
  "success": true,
  "message": "Berhasil mengambil data keranjang",
  "data": {
    "items": [
      {
        "id": 1,
        "user_id": 1,
        "product_id": 3,
        "quantity": 2,
        "item_total": 30000000,
        "item_total_formatted": "Rp 30.000.000",
        "product": {
          "id": 3,
          "name": "Laptop ASUS",
          "price": 15000000,
          "price_formatted": "Rp 15.000.000",
          "stock": 10,
          "image_url": "http://localhost:5000/public/products/image.png",
          "is_active": true,
          "seller": { "id": 1, "name": "Toko Jaya" }
        },
        "created_at": "2026-05-27 10:30:00",
        "updated_at": "2026-05-27 10:30:00"
      }
    ],
    "total_items": 1,
    "subtotal": 30000000,
    "subtotal_formatted": "Rp 30.000.000"
  }
}
```

---

### 2. Add to Cart

Menambahkan produk ke keranjang. Jika produk sudah ada di keranjang, quantity akan ditambahkan.

```
POST /api/cart
```

**Content-Type:** `application/json`

**Request Body:**

| Field      | Type   | Required | Deskripsi                |
| ---------- | ------ | -------- | ------------------------ |
| product_id | number | ✅        | ID produk                 |
| quantity   | number | ❌        | Jumlah (default: 1)       |

**Request Body Example:**

```json
{
  "product_id": 3,
  "quantity": 2
}
```

**Success Response (201):**

```json
{
  "success": true,
  "message": "Produk berhasil ditambahkan ke keranjang",
  "data": {
    "id": 1,
    "user_id": 1,
    "product_id": 3,
    "quantity": 2,
    "product": { "id": 3, "name": "Laptop ASUS", ... }
  }
}
```

**Error Responses:**

| Status | Kondisi                              |
| ------ | ------------------------------------ |
| 400    | Product ID kosong / stok tidak cukup  |
| 404    | Produk tidak ditemukan / tidak aktif  |

---

### 3. Update Cart Item

Mengubah jumlah (quantity) produk di keranjang.

```
PUT /api/cart/:cart_item_id
```

**Path Parameters:**

| Parameter    | Type   | Deskripsi       |
| ------------ | ------ | --------------- |
| cart_item_id | number | ID cart item     |

**Request Body:**

| Field    | Type   | Required | Deskripsi          |
| -------- | ------ | -------- | ------------------ |
| quantity | number | ✅        | Jumlah baru (> 0)   |

**Success Response (200):**

```json
{
  "success": true,
  "message": "Keranjang berhasil diperbarui",
  "data": { ... }
}
```

**Error Responses:**

| Status | Kondisi                              |
| ------ | ------------------------------------ |
| 400    | Quantity ≤ 0 / stok tidak mencukupi   |
| 403    | Bukan pemilik cart item               |
| 404    | Cart item tidak ditemukan             |

---

### 4. Remove Cart Item

Menghapus produk dari keranjang.

```
DELETE /api/cart/:cart_item_id
```

**Success Response (200):**

```json
{
  "success": true,
  "message": "Item berhasil dihapus dari keranjang"
}
```

**Error Responses:**

| Status | Kondisi                   |
| ------ | ------------------------- |
| 403    | Bukan pemilik cart item    |
| 404    | Cart item tidak ditemukan  |

---

## ❤️ Wishlist

Base path: `/api/wishlist`

> 🔒 Semua endpoint Wishlist membutuhkan **Bearer Token**.

---

### 1. Get Wishlist

Mengambil daftar produk favorit user.

```
GET /api/wishlist
```

**Query Parameters:**

| Parameter | Type   | Default | Deskripsi              |
| --------- | ------ | ------- | ---------------------- |
| page      | number | 1       | Nomor halaman           |
| limit     | number | 20      | Jumlah per halaman      |

**Success Response (200):**

```json
{
  "success": true,
  "message": "Berhasil mengambil data wishlist",
  "data": [
    {
      "id": 1,
      "user_id": 1,
      "product_id": 5,
      "product": {
        "id": 5,
        "name": "Headphone Sony",
        "price": 1500000,
        "price_formatted": "Rp 1.500.000",
        "image_url": "...",
        "is_active": true,
        "stock": 25,
        "seller": { "id": 2, "name": "Audio Store" }
      },
      "created_at": "2026-05-27 10:30:00"
    }
  ],
  "pagination": { "total": 3, "page": 1, "limit": 20, "totalPages": 1 }
}
```

---

### 2. Add to Wishlist

Menambahkan produk ke wishlist/favorit.

```
POST /api/wishlist
```

**Request Body:**

| Field      | Type   | Required | Deskripsi    |
| ---------- | ------ | -------- | ------------ |
| product_id | number | ✅        | ID produk     |

**Success Response (201):**

```json
{
  "success": true,
  "message": "Produk berhasil ditambahkan ke wishlist",
  "data": { ... }
}
```

**Error Responses:**

| Status | Kondisi                      |
| ------ | ---------------------------- |
| 404    | Produk tidak ditemukan        |
| 409    | Produk sudah ada di wishlist  |

---

### 3. Remove from Wishlist

Menghapus produk dari wishlist.

```
DELETE /api/wishlist/:id
```

**Success Response (200):**

```json
{
  "success": true,
  "message": "Produk berhasil dihapus dari wishlist"
}
```

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
    { "product_id": 1, "quantity": 2, "price": 100000 },
    { "product_id": 2, "quantity": 1, "price": 50000 }
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

Mengambil daftar semua pesanan milik user yang sedang login dengan dukungan filter.

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
| date_from      | string | -       | Filter tanggal mulai (format: `YYYY-MM-DD`)         |
| date_to        | string | -       | Filter tanggal akhir (format: `YYYY-MM-DD`)         |

**Contoh Request:**

```
GET /api/orders?status=delivered&date_from=2026-01-01&date_to=2026-12-31&page=1&limit=10
```

**Success Response (200):**

```json
{
  "success": true,
  "message": "Berhasil mengambil data pesanan",
  "data": [ ... ],
  "pagination": { "total": 10, "page": 1, "limit": 5, "totalPages": 2 }
}
```

---

### 3. Get Order By ID

Mengambil detail satu pesanan berdasarkan ID. User hanya bisa melihat pesanannya sendiri (kecuali admin).

```
GET /api/orders/:id
```

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
    "tracking_number": null,
    "courier": null,
    "discount_amount": 0,
    "shipping_address": { ... },
    "order_items": [ ... ],
    "user": { "id": 1, "name": "John Doe", "email": "john@example.com" }
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

### 4. Cancel Order

Membatalkan pesanan yang masih berstatus `pending` dan belum dibayar.

```
PUT /api/orders/:id/cancel
```

**Path Parameters:**

| Parameter | Type   | Deskripsi     |
| --------- | ------ | ------------- |
| id        | number | ID pesanan     |

**Success Response (200):**

```json
{
  "success": true,
  "message": "Pesanan berhasil dibatalkan",
  "data": {
    "id": 1,
    "status": "cancelled",
    "payment_status": "cancelled",
    ...
  }
}
```

> 📬 Otomatis membuat **notifikasi** ke pembeli.

**Error Responses:**

| Status | Kondisi                                                           |
| ------ | ----------------------------------------------------------------- |
| 400    | ID tidak valid                                                     |
| 400    | Status bukan `pending` — tidak bisa dibatalkan                     |
| 400    | Pesanan sudah dibayar — harus ajukan dispute/komplain              |
| 403    | Bukan pemilik pesanan (kecuali admin)                              |
| 404    | Pesanan tidak ditemukan                                            |

---

### 5. Apply Voucher

Mengecek dan memvalidasi voucher sebelum checkout. Mengembalikan detail diskon dan total bayar setelah potongan.

```
POST /api/orders/apply-voucher
```

**Content-Type:** `application/json`

**Request Body:**

| Field        | Type   | Required | Deskripsi                     |
| ------------ | ------ | -------- | ----------------------------- |
| code         | string | ✅        | Kode voucher                   |
| total_amount | number | ✅        | Total belanja sebelum diskon   |

**Request Body Example:**

```json
{
  "code": "DISKON50",
  "total_amount": 500000
}
```

**Success Response (200):**

```json
{
  "success": true,
  "message": "Voucher valid",
  "data": {
    "voucher_id": 1,
    "code": "DISKON50",
    "type": "percentage",
    "discount": 50000,
    "discount_formatted": "Rp 50.000",
    "original_amount": 500000,
    "original_amount_formatted": "Rp 500.000",
    "final_amount": 450000,
    "final_amount_formatted": "Rp 450.000"
  }
}
```

**Error Responses:**

| Status | Kondisi                                             |
| ------ | --------------------------------------------------- |
| 400    | Kode kosong / total amount tidak valid               |
| 400    | Voucher tidak ditemukan / expired / limit tercapai   |
| 400    | Minimum pembelian tidak terpenuhi                    |

---

### 6. Submit Dispute

Mengajukan komplain/komplain untuk pesanan (unggah bukti foto/video).

```
POST /api/orders/:id/dispute
```

**Content-Type:** `multipart/form-data`

**Path Parameters:**

| Parameter | Type   | Deskripsi     |
| --------- | ------ | ------------- |
| id        | number | ID pesanan     |

**Request Body (form-data):**

| Field       | Type   | Required | Deskripsi                                  |
| ----------- | ------ | -------- | ------------------------------------------ |
| reason      | string | ✅        | Alasan komplain                             |
| description | string | ❌        | Deskripsi detail masalah                    |
| evidence    | file   | ❌        | Bukti foto/video (max 10MB, gambar/video)   |

**Success Response (201):**

```json
{
  "success": true,
  "message": "Komplain berhasil diajukan",
  "data": {
    "id": 1,
    "order_id": 5,
    "user_id": 1,
    "reason": "Barang rusak",
    "description": "LCD retak saat sampai",
    "evidence_url": "http://localhost:5000/public/disputes/evidence-1716700800.jpg",
    "status": "open",
    "resolution": null,
    "created_at": "2026-05-27 10:30:00",
    "updated_at": "2026-05-27 10:30:00",
    "order": { "id": 5, "status": "delivered", "total_amount": 15000000 },
    "user": { "id": 1, "name": "John Doe", "email": "john@example.com" }
  }
}
```

**Error Responses:**

| Status | Kondisi                                               |
| ------ | ----------------------------------------------------- |
| 400    | Alasan kosong / pesanan tidak ditemukan                |
| 400    | Bukan pemilik pesanan                                  |
| 400    | Sudah ada komplain yang sedang diproses untuk pesanan ini |

---

## 💳 Payments

Base path: `/api/payments`

---

### 1. Create Payment

Membuat transaksi pembayaran melalui Midtrans berdasarkan Order ID.

```
POST /api/payments/create
```

> 🔒 Membutuhkan **Bearer Token**

**Request Body:**

| Field    | Type   | Required | Deskripsi                   |
| -------- | ------ | -------- | --------------------------- |
| order_id | number | ✅        | ID pesanan yang ingin dibayar |

**Success Response (200):**

```json
{
  "success": true,
  "message": "Berhasil mendapatkan token pembayaran",
  "data": {
    "token": "66e4fa55-fdac-4ef9-91b5-733b97d1b862",
    "redirect_url": "https://app.sandbox.midtrans.com/snap/v4/redirection/66e4fa55..."
  }
}
```

**Cara Penggunaan di Frontend:**

```html
<script src="https://app.sandbox.midtrans.com/snap/snap.js"
        data-client-key="SB-Mid-client-xxxxx"></script>

<script>
  snap.pay('66e4fa55-fdac-4ef9-91b5-733b97d1b862', {
    onSuccess: function(result) { console.log('Pembayaran berhasil', result); },
    onPending: function(result) { console.log('Menunggu pembayaran', result); },
    onError: function(result)   { console.log('Pembayaran gagal', result); },
    onClose: function()         { console.log('Pop-up ditutup tanpa bayar'); }
  });
</script>
```

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

> ⚠️ **🟢 Public endpoint** — Tidak memerlukan Bearer Token karena dipanggil langsung oleh server Midtrans.

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

## 👤 User Profile & Addresses

Base path: `/api/users`

> 🔒 Semua endpoint membutuhkan **Bearer Token**.

---

### 1. Get Profile

Mengambil data detail profil user yang sedang login.

```
GET /api/users/profile
```

**Success Response (200):**

```json
{
  "success": true,
  "message": "Berhasil mengambil data profil",
  "data": {
    "id": 1,
    "email": "user@example.com",
    "name": "John Doe",
    "role": "customer",
    "phone": "081234567890",
    "avatar_url": "http://localhost:5000/public/avatars/avatar-1-1716700800.jpg",
    "is_active": true,
    "created_at": "2026-05-26 12:00:00",
    "updated_at": "2026-05-27 10:30:00"
  }
}
```

---

### 2. Update Profile

Update profil dan foto avatar.

```
PUT /api/users/profile
```

**Content-Type:** `multipart/form-data`

**Request Body (form-data):**

| Field  | Type   | Required | Deskripsi                           |
| ------ | ------ | -------- | ----------------------------------- |
| name   | string | ❌        | Nama baru                            |
| phone  | string | ❌        | Nomor HP baru                        |
| avatar | file   | ❌        | Foto profil baru (max 2MB, gambar)   |

**Success Response (200):**

```json
{
  "success": true,
  "message": "Profil berhasil diperbarui",
  "data": {
    "id": 1,
    "email": "user@example.com",
    "name": "John Doe Updated",
    "phone": "081234567890",
    "avatar_url": "http://localhost:5000/public/avatars/avatar-1-1716700800.jpg",
    ...
  }
}
```

---

### 3. Delete Account

Menghapus akun user secara **permanen** beserta semua data terkait (pesanan, keranjang, wishlist, ulasan, chat, dll) melalui **cascading delete**.

```
DELETE /api/users/profile
```

> ⚠️ **HATI-HATI!** Aksi ini **tidak bisa dibatalkan**.

**Success Response (200):**

```json
{
  "success": true,
  "message": "Akun berhasil dihapus secara permanen"
}
```

---

### 4. Get Addresses

Mengambil daftar alamat yang disimpan user. Diurutkan dengan alamat default di paling atas.

```
GET /api/users/addresses
```

**Success Response (200):**

```json
{
  "success": true,
  "message": "Berhasil mengambil data alamat",
  "data": [
    {
      "id": 1,
      "user_id": 1,
      "label": "Rumah",
      "recipient": "John Doe",
      "phone": "081234567890",
      "address": "Jl. Kemerdekaan No. 45",
      "city": "Jakarta Selatan",
      "province": "DKI Jakarta",
      "postal_code": "12345",
      "is_default": true,
      "created_at": "2026-05-26 12:00:00",
      "updated_at": "2026-05-26 12:00:00"
    }
  ]
}
```

---

### 5. Add Address

Menambahkan alamat pengiriman baru. Alamat pertama otomatis menjadi default.

```
POST /api/users/addresses
```

**Content-Type:** `application/json`

**Request Body:**

| Field       | Type    | Required | Deskripsi                        |
| ----------- | ------- | -------- | -------------------------------- |
| label       | string  | ❌        | Label alamat (default: "Rumah")   |
| recipient   | string  | ✅        | Nama penerima                     |
| phone       | string  | ✅        | Nomor HP penerima                 |
| address     | string  | ✅        | Alamat lengkap                    |
| city        | string  | ✅        | Kota                              |
| province    | string  | ✅        | Provinsi                          |
| postal_code | string  | ✅        | Kode pos                          |
| is_default  | boolean | ❌        | Jadikan alamat utama              |

**Request Body Example:**

```json
{
  "label": "Kantor",
  "recipient": "John Doe",
  "phone": "081234567890",
  "address": "Jl. Sudirman No. 123, Gedung ABC Lt. 5",
  "city": "Jakarta Pusat",
  "province": "DKI Jakarta",
  "postal_code": "10110",
  "is_default": false
}
```

**Success Response (201):**

```json
{
  "success": true,
  "message": "Alamat berhasil ditambahkan",
  "data": { ... }
}
```

---

### 6. Update Address

Memperbarui data alamat yang sudah ada. Hanya **pemilik alamat** yang bisa mengubah.

```
PUT /api/users/addresses/:id
```

**Path Parameters:**

| Parameter | Type   | Deskripsi     |
| --------- | ------ | ------------- |
| id        | number | ID alamat      |

**Request Body (semua field opsional):**

| Field       | Type    | Required | Deskripsi                       |
| ----------- | ------- | -------- | ------------------------------- |
| label       | string  | ❌        | Label alamat                     |
| recipient   | string  | ❌        | Nama penerima                    |
| phone       | string  | ❌        | Nomor HP penerima                |
| address     | string  | ❌        | Alamat lengkap                   |
| city        | string  | ❌        | Kota                             |
| province    | string  | ❌        | Provinsi                         |
| postal_code | string  | ❌        | Kode pos                         |
| is_default  | boolean | ❌        | Jadikan alamat utama             |

> 💡 Hanya field yang dikirim saja yang akan di-update.

**Request Body Example:**

```json
{
  "label": "Kantor Baru",
  "address": "Jl. Thamrin No. 99"
}
```

**Success Response (200):**

```json
{
  "success": true,
  "message": "Alamat berhasil diperbarui",
  "data": { ... }
}
```

**Error Responses:**

| Status | Kondisi                    |
| ------ | -------------------------- |
| 400    | Address ID tidak valid      |
| 403    | Bukan pemilik alamat        |
| 404    | Alamat tidak ditemukan      |

---

### 7. Delete Address

Menghapus alamat. Jika alamat yang dihapus adalah default, alamat pertama yang tersisa otomatis menjadi default.

```
DELETE /api/users/addresses/:id
```

**Path Parameters:**

| Parameter | Type   | Deskripsi     |
| --------- | ------ | ------------- |
| id        | number | ID alamat      |

**Success Response (200):**

```json
{
  "success": true,
  "message": "Alamat berhasil dihapus"
}
```

**Error Responses:**

| Status | Kondisi                    |
| ------ | -------------------------- |
| 400    | Address ID tidak valid      |
| 403    | Bukan pemilik alamat        |
| 404    | Alamat tidak ditemukan      |

---

### 8. Set Default Address

Mengatur satu alamat sebagai alamat utama. Alamat default sebelumnya akan diubah.

```
PUT /api/users/addresses/:id/set-default
```

**Path Parameters:**

| Parameter | Type   | Deskripsi     |
| --------- | ------ | ------------- |
| id        | number | ID alamat      |

**Success Response (200):**

```json
{
  "success": true,
  "message": "Alamat utama berhasil diubah",
  "data": { "id": 2, "is_default": true, ... }
}
```

**Error Responses:**

| Status | Kondisi                       |
| ------ | ----------------------------- |
| 403    | Bukan pemilik alamat           |
| 404    | Alamat tidak ditemukan          |

---

## 🚚 Shipping

Base path: `/api/shipping`

> 🔒 Membutuhkan **Bearer Token**.

---

### 1. Calculate Shipping

Menghitung ongkos kirim berdasarkan tujuan, berat, dan pilihan kurir.

> 💡 Saat ini menggunakan **mock calculator**. Bisa diganti dengan integrasi RajaOngkir API.

```
POST /api/shipping/calculate
```

**Content-Type:** `application/json`

**Request Body:**

| Field       | Type   | Required | Deskripsi                                     |
| ----------- | ------ | -------- | --------------------------------------------- |
| origin      | string | ❌        | Kota asal (default: "Jakarta")                 |
| destination | string | ✅        | Kota tujuan                                    |
| weight      | number | ✅        | Berat paket dalam kg                           |
| courier     | string | ❌        | Kurir spesifik (`jne`, `sicepat`, `jnt`, `pos`) |

**Request Body Example:**

```json
{
  "origin": "Jakarta",
  "destination": "Surabaya",
  "weight": 1.5,
  "courier": "jne"
}
```

**Success Response (200):**

```json
{
  "success": true,
  "message": "Berhasil menghitung ongkos kirim",
  "data": {
    "origin": "Jakarta",
    "destination": "Surabaya",
    "weight": 1.5,
    "rates": [
      {
        "courier": "JNE",
        "service": "REG",
        "description": "JNE Reguler (2-3 hari)",
        "cost": 18000,
        "cost_formatted": "Rp 18.000",
        "etd": "2-3 hari"
      },
      {
        "courier": "JNE",
        "service": "YES",
        "description": "JNE YES (1 hari)",
        "cost": 36000,
        "cost_formatted": "Rp 36.000",
        "etd": "1 hari"
      }
    ]
  }
}
```

**Available Couriers:**

| Kode      | Nama Kurir | Services          |
| --------- | ---------- | ----------------- |
| `jne`     | JNE        | REG, YES, OKE     |
| `sicepat` | SiCepat    | REG, BEST          |
| `jnt`     | J&T        | EZ, EXPRESS        |
| `pos`     | Pos Indonesia | KILAT, EXPRESS  |

---

## 🏷️ Categories

Base path: `/api/categories`

---

### 1. Get Categories

Mengambil daftar semua kategori aktif beserta jumlah produk di tiap kategori.

> 🟢 **Public** — tidak memerlukan Bearer Token.

```
GET /api/categories
```

**Success Response (200):**

```json
{
  "success": true,
  "message": "Berhasil mengambil data kategori",
  "data": [
    {
      "id": 1,
      "name": "Electronic",
      "icon_url": "http://localhost:5000/public/categories/category-1716700800.png",
      "image_url": "http://localhost:5000/public/categories/category-1716700800.png",
      "is_active": true,
      "created_at": "2026-05-26 12:00:00",
      "updated_at": "2026-05-26 12:00:00",
      "_count": { "products": 15 }
    }
  ]
}
```

---

## 💬 Chat (Real-time)

Base path: `/api/chats`

> 🔒 Semua endpoint Chat membutuhkan **Bearer Token**.
>
> 💡 **WebSocket (Socket.io)** tersedia untuk real-time messaging. Gunakan HTTP endpoint di bawah sebagai fallback.

### Socket.io Events

| Event | Direction | Deskripsi |
| ----- | --------- | --------- |
| `join_room` | Client → Server | Bergabung ke room: `socket.emit('join_room', roomId)` |
| `leave_room` | Client → Server | Keluar dari room |
| `send_message` | Client → Server | Kirim pesan: `{ room_id, content, ... }` |
| `new_message` | Server → Client | Pesan baru masuk dari room |
| `typing` | Client → Server | Mengetik: `{ room_id, user_id, name }` |
| `user_typing` | Server → Client | User lain sedang mengetik |
| `stop_typing` | Client → Server | Berhenti mengetik |
| `user_stop_typing` | Server → Client | User lain berhenti mengetik |

---

### 1. Get Chat Rooms

Mengambil daftar riwayat chat/room milik user. Termasuk pesan terakhir dan jumlah belum dibaca.

```
GET /api/chats
```

**Success Response (200):**

```json
{
  "success": true,
  "message": "Berhasil mengambil daftar chat",
  "data": [
    {
      "id": 1,
      "created_at": "2026-05-26 12:00:00",
      "updated_at": "2026-05-27 10:30:00",
      "participants": [
        {
          "id": 1,
          "user": { "id": 1, "name": "John Doe", "avatar_url": null }
        },
        {
          "id": 2,
          "user": { "id": 3, "name": "Toko Jaya", "avatar_url": "..." }
        }
      ],
      "last_message": {
        "id": 15,
        "content": "Barangnya ready gan?",
        "created_at": "2026-05-27 10:30:00",
        "sender_id": 1,
        "is_read": false
      },
      "unread_count": 2
    }
  ]
}
```

---

### 2. Start Chat

Membuat atau menemukan chat room yang sudah ada antara 2 user. Digunakan untuk memulai percakapan baru (misal klik "Chat Penjual" di halaman produk).

```
POST /api/chats/start
```

**Request Body:**

| Field          | Type   | Required | Deskripsi                  |
| -------------- | ------ | -------- | -------------------------- |
| target_user_id | number | ✅        | ID user yang ingin di-chat  |

**Request Body Example:**

```json
{
  "target_user_id": 3
}
```

**Success Response (200):**

```json
{
  "success": true,
  "message": "Chat room berhasil dibuat/ditemukan",
  "data": {
    "id": 1,
    "participants": [
      { "user": { "id": 1, "name": "John Doe" } },
      { "user": { "id": 3, "name": "Toko Jaya" } }
    ]
  }
}
```

---

### 3. Get Chat Messages

Mengambil riwayat pesan dalam satu obrolan. Otomatis menandai pesan dari lawan bicara sebagai sudah dibaca.

```
GET /api/chats/:room_id/messages
```

**Query Parameters:**

| Parameter | Type   | Default | Deskripsi             |
| --------- | ------ | ------- | --------------------- |
| page      | number | 1       | Nomor halaman          |
| limit     | number | 50      | Jumlah pesan per halaman |

**Success Response (200):**

```json
{
  "success": true,
  "message": "Berhasil mengambil riwayat pesan",
  "data": [
    {
      "id": 1,
      "room_id": 1,
      "sender_id": 1,
      "content": "Barangnya ready gan?",
      "image_url": null,
      "is_read": true,
      "created_at": "2026-05-27 10:30:00",
      "is_mine": true,
      "sender": { "id": 1, "name": "John Doe", "avatar_url": null }
    },
    {
      "id": 2,
      "room_id": 1,
      "sender_id": 3,
      "content": "Ready kak, silakan order ya",
      "image_url": null,
      "is_read": true,
      "created_at": "2026-05-27 10:31:00",
      "is_mine": false,
      "sender": { "id": 3, "name": "Toko Jaya", "avatar_url": "..." }
    }
  ],
  "pagination": { "total": 2, "page": 1, "limit": 50, "totalPages": 1 }
}
```

**Error Responses:**

| Status | Kondisi                           |
| ------ | --------------------------------- |
| 403    | Bukan anggota chat room ini        |

---

### 4. Send Message

Mengirim pesan (teks atau lampiran gambar) dalam chat room.

```
POST /api/chats/:room_id/messages
```

**Content-Type:** `multipart/form-data`

**Request Body (form-data):**

| Field   | Type   | Required | Deskripsi                              |
| ------- | ------ | -------- | -------------------------------------- |
| content | string | ❌*       | Isi pesan teks                          |
| image   | file   | ❌*       | Lampiran gambar (max 5MB)               |

> \* Minimal satu dari `content` atau `image` harus diisi.

**Success Response (201):**

```json
{
  "success": true,
  "message": "Pesan berhasil dikirim",
  "data": {
    "id": 3,
    "room_id": 1,
    "sender_id": 1,
    "content": "Terima kasih!",
    "image_url": null,
    "is_mine": true,
    "created_at": "2026-05-27 10:35:00",
    "sender": { "id": 1, "name": "John Doe", "avatar_url": null }
  }
}
```

---

## 🎟️ Vouchers & Flash Sale

---

### 1. Get Vouchers

Mengambil daftar voucher/diskon yang sedang aktif dan belum kadaluarsa.

> 🔒 Membutuhkan **Bearer Token**.

```
GET /api/vouchers
```

**Success Response (200):**

```json
{
  "success": true,
  "message": "Berhasil mengambil daftar voucher",
  "data": [
    {
      "id": 1,
      "code": "DISKON50",
      "type": "percentage",
      "value": 50,
      "value_formatted": "50%",
      "min_purchase": 100000,
      "min_purchase_formatted": "Rp 100.000",
      "max_discount": 50000,
      "max_discount_formatted": "Rp 50.000",
      "usage_limit": 100,
      "used_count": 23,
      "is_active": true,
      "expires_at": "2026-06-30 23:59:59",
      "created_at": "2026-05-01 00:00:00",
      "updated_at": "2026-05-27 10:30:00"
    },
    {
      "id": 2,
      "code": "FREEONGKIR",
      "type": "free_shipping",
      "value": 15000,
      "value_formatted": "Rp 15.000",
      "min_purchase": 50000,
      "min_purchase_formatted": "Rp 50.000",
      "max_discount": null,
      "max_discount_formatted": null,
      ...
    }
  ]
}
```

**Voucher Types:**

| Type             | Deskripsi                                              |
| ---------------- | ------------------------------------------------------ |
| `percentage`     | Diskon persentase (misal 10% dari total, max discount)  |
| `fixed`          | Diskon nominal tetap (misal Rp 25.000)                  |
| `free_shipping`  | Gratis ongkir (nominal ongkir di-cover)                 |

---

### 2. Get Flash Sales

Mengambil daftar produk yang sedang dalam flash sale (diskon terbatas waktu).

> 🔒 Membutuhkan **Bearer Token**.

```
GET /api/flash-sales
```

**Success Response (200):**

```json
{
  "success": true,
  "message": "Berhasil mengambil data flash sale",
  "data": [
    {
      "id": 1,
      "product_id": 5,
      "discount_price": 7500000,
      "discount_price_formatted": "Rp 7.500.000",
      "stock": 50,
      "sold_count": 32,
      "remaining_stock": 18,
      "discount_percentage": 50,
      "starts_at": "2026-05-28 00:00:00",
      "ends_at": "2026-05-28 23:59:59",
      "is_active": true,
      "original_price_formatted": "Rp 15.000.000",
      "product": {
        "id": 5,
        "name": "Laptop ASUS",
        "price": 15000000,
        "image_url": "...",
        "seller": { "id": 1, "name": "Toko Jaya" }
      }
    }
  ]
}
```

---

## 🔔 Notifications

Base path: `/api/notifications`

> 🔒 Semua endpoint Notifikasi membutuhkan **Bearer Token**.

Notifikasi dibuat otomatis oleh sistem saat:
- Status pesanan berubah (dikirim, sampai, dibatalkan)
- Nomor resi ditambahkan
- Komplain diselesaikan

---

### 1. Get Notifications

Mengambil daftar notifikasi milik user, termasuk jumlah yang belum dibaca.

```
GET /api/notifications
```

**Query Parameters:**

| Parameter | Type   | Default | Deskripsi              |
| --------- | ------ | ------- | ---------------------- |
| page      | number | 1       | Nomor halaman           |
| limit     | number | 20      | Jumlah per halaman      |

**Success Response (200):**

```json
{
  "success": true,
  "message": "Berhasil mengambil notifikasi",
  "data": [
    {
      "id": 1,
      "user_id": 1,
      "title": "Pesanan Dikirim",
      "message": "Pesanan #5 sudah dikirim via JNE dengan nomor resi: JNE123456",
      "type": "order",
      "is_read": false,
      "metadata": { "order_id": 5, "tracking_number": "JNE123456", "courier": "JNE" },
      "created_at": "2026-05-27 10:30:00"
    }
  ],
  "unread_count": 3,
  "pagination": { "total": 15, "page": 1, "limit": 20, "totalPages": 1 }
}
```

**Notification Types:**

| Type      | Deskripsi                  |
| --------- | -------------------------- |
| `info`    | Informasi umum              |
| `order`   | Update status pesanan       |
| `dispute` | Update komplain             |

---

### 2. Mark All Read

Menandai semua notifikasi sebagai sudah dibaca (tanda lonceng merah hilang).

```
PUT /api/notifications/read-all
```

**Success Response (200):**

```json
{
  "success": true,
  "message": "Semua notifikasi berhasil ditandai sudah dibaca",
  "data": { "updated": 3 }
}
```

---

## 🖼️ Banners

Base path: `/api/banners`

---

### 1. Get Banners

Mengambil daftar gambar banner promosi untuk ditampilkan di halaman utama (carousel/slider).

> 🟢 **Public** — tidak memerlukan Bearer Token.

```
GET /api/banners
```

**Success Response (200):**

```json
{
  "success": true,
  "message": "Berhasil mengambil data banner",
  "data": [
    {
      "id": 1,
      "title": "Promo Lebaran 2026",
      "image_url": "http://localhost:5000/public/banners/banner-1716700800.jpg",
      "link_url": "/promo/lebaran",
      "is_active": true,
      "sort_order": 1,
      "created_at": "2026-05-26 12:00:00",
      "updated_at": "2026-05-26 12:00:00"
    }
  ]
}
```

---

## 📊 Seller Dashboard

Base path: `/api/seller`

> 🔒 Membutuhkan **Bearer Token**. Data di-scope ke produk milik seller yang sedang login.

---

### 1. Get Seller Dashboard Stats

Menampilkan statistik penjualan untuk seller: pendapatan, jumlah produk, pesanan, dan produk terlaris.

```
GET /api/seller/dashboard/stats
```

**Success Response (200):**

```json
{
  "success": true,
  "message": "Berhasil mengambil data dashboard penjual",
  "data": {
    "total_revenue": 45000000,
    "total_revenue_formatted": "Rp 45.000.000",
    "monthly_revenue": 12000000,
    "monthly_revenue_formatted": "Rp 12.000.000",
    "total_products": 15,
    "active_products": 12,
    "total_orders": 48,
    "orders_this_month": 12,
    "total_items_sold": 95,
    "orders_by_status": {
      "pending": 2,
      "processing": 3,
      "shipped": 5,
      "delivered": 35,
      "cancelled": 3
    },
    "top_selling_products": [
      {
        "id": 1,
        "name": "Laptop ASUS ROG",
        "image_url": "...",
        "price": 15000000,
        "price_formatted": "Rp 15.000.000",
        "total_quantity_sold": 25
      }
    ]
  }
}
```

---

## 🔴 Admin Panel

Base path: `/api/admin`

> 🔴 **Semua endpoint Admin membutuhkan Bearer Token + role `admin`.**
>
> User dengan role selain `admin` akan mendapat response `403 Forbidden`.

---

### 1. Get All Orders (Admin)

Mengambil **semua** pesanan dari semua user. Bisa difilter berdasarkan status.

```
GET /api/admin/orders
```

**Query Parameters:**

| Parameter      | Type   | Default | Deskripsi                                    |
| -------------- | ------ | ------- | -------------------------------------------- |
| page           | number | 1       | Nomor halaman                                 |
| limit          | number | 10      | Jumlah pesanan per halaman                     |
| status         | string | -       | Filter: `pending`, `processing`, `shipped`, `delivered`, `cancelled` |
| payment_status | string | -       | Filter: `unpaid`, `pending`, `paid`, `failed`, `cancelled` |
| date_from      | string | -       | Filter tanggal mulai (format: `YYYY-MM-DD`)   |
| date_to        | string | -       | Filter tanggal akhir (format: `YYYY-MM-DD`)   |

**Success Response (200):**

```json
{
  "success": true,
  "message": "Berhasil mengambil semua pesanan",
  "data": [
    {
      "id": 1,
      "user_id": 2,
      "status": "processing",
      "payment_status": "paid",
      "total_amount": 250000,
      "total_amount_formatted": "Rp 250.000",
      "tracking_number": null,
      "courier": null,
      "user": { "id": 2, "name": "Budi", "email": "budi@example.com" },
      ...
    }
  ],
  "pagination": { ... }
}
```

---

### 2. Update Order Status

Mengubah status pesanan (misal: `pending` → `processing` → `shipped` → `delivered`).

> 📬 Otomatis membuat **notifikasi** ke pembeli.

```
PUT /api/admin/orders/:id/status
```

**Request Body:**

| Field  | Type   | Required | Deskripsi                                              |
| ------ | ------ | -------- | ------------------------------------------------------ |
| status | string | ✅        | Status baru: `pending`, `processing`, `shipped`, `delivered`, `cancelled` |

**Request Body Example:**

```json
{
  "status": "shipped"
}
```

**Success Response (200):**

```json
{
  "success": true,
  "message": "Status pesanan berhasil diubah menjadi 'shipped'",
  "data": { "id": 1, "status": "shipped", ... }
}
```

---

### 3. Update Order Tracking

Menambahkan nomor resi dan nama kurir ke pesanan. Otomatis mengubah status menjadi `shipped`.

> 📬 Otomatis membuat **notifikasi** ke pembeli dengan info nomor resi.

```
PUT /api/admin/orders/:id/tracking
```

**Request Body:**

| Field           | Type   | Required | Deskripsi          |
| --------------- | ------ | -------- | ------------------ |
| tracking_number | string | ✅        | Nomor resi          |
| courier         | string | ❌        | Nama kurir          |

**Request Body Example:**

```json
{
  "tracking_number": "JNE123456789",
  "courier": "JNE"
}
```

**Success Response (200):**

```json
{
  "success": true,
  "message": "Nomor resi berhasil ditambahkan",
  "data": {
    "id": 1,
    "status": "shipped",
    "tracking_number": "JNE123456789",
    "courier": "JNE",
    ...
  }
}
```

---

### 4. Dashboard Stats

Mengembalikan rekap data statistik untuk dashboard admin: Total Pendapatan, Pesanan, Produk Aktif, Produk Terlaris, dll.

```
GET /api/admin/dashboard/stats
```

**Success Response (200):**

```json
{
  "success": true,
  "message": "Berhasil mengambil data dashboard",
  "data": {
    "total_revenue": 150000000,
    "total_revenue_formatted": "Rp 150.000.000",
    "monthly_revenue": 25000000,
    "monthly_revenue_formatted": "Rp 25.000.000",
    "orders_this_month": 42,
    "active_products": 128,
    "total_users": 350,
    "orders_by_status": {
      "pending": 5,
      "processing": 10,
      "shipped": 8,
      "delivered": 120,
      "cancelled": 3
    },
    "top_selling_products": [
      {
        "id": 3,
        "name": "Laptop ASUS",
        "image_url": "...",
        "total_quantity_sold": 45
      }
    ]
  }
}
```

---

### 5. Resolve Dispute

Admin menengahi dan menyelesaikan komplain dari pembeli. Bisa menerima (refund) atau menolak.

> 📬 Otomatis membuat **notifikasi** ke pembeli tentang hasil resolusi.

```
PUT /api/admin/disputes/:id/resolve
```

**Request Body:**

| Field      | Type   | Required | Deskripsi                                   |
| ---------- | ------ | -------- | ------------------------------------------- |
| resolution | string | ✅        | Penjelasan resolusi                          |
| status     | string | ❌        | `resolved` (default) atau `rejected`         |

**Request Body Example:**

```json
{
  "resolution": "Refund penuh telah diproses ke rekening pembeli",
  "status": "resolved"
}
```

**Success Response (200):**

```json
{
  "success": true,
  "message": "Komplain berhasil diselesaikan",
  "data": {
    "id": 1,
    "order_id": 5,
    "status": "resolved",
    "resolution": "Refund penuh telah diproses ke rekening pembeli",
    "resolved_at": "2026-05-28T10:00:00.000Z",
    ...
  }
}
```

---

### 6. Create Banner

Admin menambahkan banner promo baru untuk ditampilkan di halaman utama.

```
POST /api/admin/banners
```

**Content-Type:** `multipart/form-data`

**Request Body (form-data):**

| Field      | Type   | Required | Deskripsi                              |
| ---------- | ------ | -------- | -------------------------------------- |
| title      | string | ✅        | Judul banner                            |
| image      | file   | ✅        | Gambar banner (max 5MB, format gambar)  |
| link_url   | string | ❌        | URL tujuan saat banner diklik           |
| sort_order | number | ❌        | Urutan tampil (default: 0)              |

**Success Response (201):**

```json
{
  "success": true,
  "message": "Banner berhasil ditambahkan",
  "data": {
    "id": 1,
    "title": "Promo Lebaran 2026",
    "image_url": "http://localhost:5000/public/banners/banner-1716700800.jpg",
    "link_url": "/promo/lebaran",
    "sort_order": 1,
    ...
  }
}
```

---

### 7. Create Category

Admin menambahkan kategori produk baru.

```
POST /api/admin/categories
```

**Content-Type:** `multipart/form-data`

**Request Body (form-data):**

| Field | Type   | Required | Deskripsi                              |
| ----- | ------ | -------- | -------------------------------------- |
| name  | string | ✅        | Nama kategori (harus unik)              |
| icon  | file   | ❌        | Icon/gambar kategori (max 2MB, gambar)  |

**Success Response (201):**

```json
{
  "success": true,
  "message": "Kategori berhasil ditambahkan",
  "data": {
    "id": 1,
    "name": "Electronic",
    "icon_url": "http://localhost:5000/public/categories/category-1716700800.png",
    "image_url": "http://localhost:5000/public/categories/category-1716700800.png",
    "is_active": true,
    ...
  }
}
```

**Error Responses:**

| Status | Kondisi                                |
| ------ | -------------------------------------- |
| 409    | Kategori dengan nama tersebut sudah ada |

---

### 8. Get All Users

Mengambil daftar semua user yang terdaftar dengan dukungan pencarian dan filter.

```
GET /api/admin/users
```

**Query Parameters:**

| Parameter | Type    | Default | Deskripsi                              |
| --------- | ------- | ------- | -------------------------------------- |
| page      | number  | 1       | Nomor halaman                           |
| limit     | number  | 10      | Jumlah user per halaman                  |
| search    | string  | -       | Cari berdasarkan nama atau email         |
| role      | string  | -       | Filter: `customer`, `seller`, `admin`    |
| is_active | boolean | -       | Filter status aktif (`true` / `false`)   |

**Contoh Request:**

```
GET /api/admin/users?search=john&role=customer&page=1&limit=10
```

**Success Response (200):**

```json
{
  "success": true,
  "message": "Berhasil mengambil data pengguna",
  "data": [
    {
      "id": 1,
      "email": "user@example.com",
      "name": "John Doe",
      "role": "customer",
      "phone": "081234567890",
      "avatar_url": null,
      "is_active": true,
      "created_at": "2026-05-26 12:00:00",
      "updated_at": "2026-05-27 10:30:00"
    }
  ],
  "pagination": { "total": 50, "page": 1, "limit": 10, "totalPages": 5 }
}
```

---

### 9. Ban User

Mengaktifkan/menonaktifkan (toggle) akun user. User yang di-ban tidak bisa login.

```
PUT /api/admin/users/:id/ban
```

**Path Parameters:**

| Parameter | Type   | Deskripsi    |
| --------- | ------ | ------------ |
| id        | number | ID user       |

> ⚠️ Admin tidak bisa ban diri sendiri.

**Success Response (200):**

```json
{
  "success": true,
  "message": "User berhasil diblokir",
  "data": {
    "id": 1,
    "email": "user@example.com",
    "name": "John Doe",
    "role": "customer",
    "is_active": false
  }
}
```

> 💡 Panggil endpoint yang sama lagi untuk **unban** (toggle `is_active` kembali ke `true`).

**Error Responses:**

| Status | Kondisi                                  |
| ------ | ---------------------------------------- |
| 400    | User ID tidak valid / ban diri sendiri    |
| 404    | User tidak ditemukan                      |

---

### 10. Change User Role

Mengubah role user (misal: menjadikan customer sebagai seller atau admin).

```
PUT /api/admin/users/:id/role
```

**Path Parameters:**

| Parameter | Type   | Deskripsi    |
| --------- | ------ | ------------ |
| id        | number | ID user       |

> ⚠️ Admin tidak bisa mengubah role diri sendiri.

**Request Body:**

| Field | Type   | Required | Deskripsi                                  |
| ----- | ------ | -------- | ------------------------------------------ |
| role  | string | ✅        | Role baru: `customer`, `seller`, atau `admin` |

**Request Body Example:**

```json
{
  "role": "seller"
}
```

**Success Response (200):**

```json
{
  "success": true,
  "message": "Role user berhasil diubah menjadi 'seller'",
  "data": {
    "id": 2,
    "email": "seller@example.com",
    "name": "Toko Maju",
    "role": "seller",
    "is_active": true
  }
}
```

**Error Responses:**

| Status | Kondisi                                         |
| ------ | ----------------------------------------------- |
| 400    | Role kosong / tidak valid / ubah role sendiri    |
| 404    | User tidak ditemukan                              |

---

## 🗄️ Database Schema

### Entity Relationship Diagram

```mermaid
erDiagram
    User ||--o{ Product : "sells"
    User ||--o{ Order : "places"
    User ||--o{ CartItem : "has"
    User ||--o{ Wishlist : "favorites"
    User ||--o{ Address : "owns"
    User ||--o{ Review : "writes"
    User ||--o{ Notification : "receives"
    User ||--o{ Dispute : "files"
    User ||--o{ ChatParticipant : "joins"
    User ||--o{ ChatMessage : "sends"
    Order ||--o{ OrderItem : "contains"
    Order ||--o{ Dispute : "has"
    Order ||--o| Payment : "has"
    Product ||--o{ OrderItem : "included_in"
    Product ||--o{ CartItem : "in_cart"
    Product ||--o{ Wishlist : "favorited"
    Product ||--o{ Review : "reviewed"
    Product ||--o{ FlashSale : "on_sale"
    Category ||--o{ Product : "categorizes"
    ChatRoom ||--o{ ChatParticipant : "has"
    ChatRoom ||--o{ ChatMessage : "contains"

    User {
        int id PK
        string email UK
        string name
        string password_hash
        string role
        string phone
        string avatar_url
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
        int category_id FK
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
        string tracking_number
        string courier
        int voucher_id
        float discount_amount
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

    CartItem {
        int id PK
        int user_id FK
        int product_id FK
        int quantity
        datetime created_at
        datetime updated_at
    }

    Wishlist {
        int id PK
        int user_id FK
        int product_id FK
        datetime created_at
    }

    Address {
        int id PK
        int user_id FK
        string label
        string recipient
        string phone
        string address
        string city
        string province
        string postal_code
        boolean is_default
    }

    Review {
        int id PK
        int user_id FK
        int product_id FK
        int rating
        string comment
        string image_url
        string reply
        datetime reply_at
    }

    Category {
        int id PK
        string name UK
        string icon_url
        string image_url
        boolean is_active
    }

    ChatRoom {
        int id PK
        datetime created_at
        datetime updated_at
    }

    ChatParticipant {
        int id PK
        int room_id FK
        int user_id FK
    }

    ChatMessage {
        int id PK
        int room_id FK
        int sender_id FK
        string content
        string image_url
        boolean is_read
    }

    Voucher {
        int id PK
        string code UK
        string type
        float value
        float min_purchase
        float max_discount
        int usage_limit
        int used_count
        boolean is_active
        datetime expires_at
    }

    FlashSale {
        int id PK
        int product_id FK
        float discount_price
        int stock
        int sold_count
        datetime starts_at
        datetime ends_at
        boolean is_active
    }

    Notification {
        int id PK
        int user_id FK
        string title
        string message
        string type
        boolean is_read
        string metadata
    }

    Dispute {
        int id PK
        int order_id FK
        int user_id FK
        string reason
        string description
        string evidence_url
        string status
        string resolution
        datetime resolved_at
    }

    Banner {
        int id PK
        string title
        string image_url
        string link_url
        boolean is_active
        int sort_order
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

**Dispute Status:**

| Status      | Deskripsi                              |
| ----------- | -------------------------------------- |
| `open`      | Komplain baru diajukan                  |
| `in_review` | Sedang ditinjau admin                   |
| `resolved`  | Komplain diselesaikan (refund/dll)      |
| `rejected`  | Komplain ditolak                        |

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
| 403  | Tidak memiliki akses / bukan admin (Forbidden)   |
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
| Bukan admin             | 403    | Akses ditolak. Hanya admin yang bisa mengakses endpoint ini |

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

---

## 📋 Ringkasan Endpoint

### 🟢 Public (No Token)

| Method | Endpoint | Deskripsi |
| ------ | -------- | --------- |
| POST | `/api/auth/register` | Register user baru |
| POST | `/api/auth/login` | Login |
| POST | `/api/auth/refresh-token` | Refresh access token |
| GET | `/api/auth/verify-token` | Verify token |
| GET | `/api/categories` | Daftar kategori |
| GET | `/api/banners` | Daftar banner promo |
| POST | `/api/payments/webhook` | Midtrans webhook |

### 🔒 Protected (Bearer Token)

| Method | Endpoint | Deskripsi |
| ------ | -------- | --------- |
| GET | `/api/products` | Daftar produk |
| GET | `/api/products/:id` | Detail produk |
| GET | `/api/products/search` | Cari produk |
| POST | `/api/products/create` | Buat produk |
| PUT | `/api/products/update/:id` | Update produk |
| DELETE | `/api/products/delete/:id` | Hapus produk |
| GET | `/api/products/:id/reviews` | Ulasan produk |
| POST | `/api/products/:id/reviews` | Tambah ulasan |
| POST | `/api/products/:id/reviews/:review_id/reply` | Balas ulasan (seller) |
| GET | `/api/cart` | Lihat keranjang |
| POST | `/api/cart` | Tambah ke keranjang |
| PUT | `/api/cart/:cart_item_id` | Update quantity |
| DELETE | `/api/cart/:cart_item_id` | Hapus dari keranjang |
| GET | `/api/wishlist` | Lihat wishlist |
| POST | `/api/wishlist` | Tambah ke wishlist |
| DELETE | `/api/wishlist/:id` | Hapus dari wishlist |
| POST | `/api/orders` | Buat pesanan |
| GET | `/api/orders` | Daftar pesanan (+ filter tanggal) |
| GET | `/api/orders/:id` | Detail pesanan |
| PUT | `/api/orders/:id/cancel` | Batalkan pesanan |
| POST | `/api/orders/apply-voucher` | Validasi voucher |
| POST | `/api/orders/:id/dispute` | Ajukan komplain |
| POST | `/api/payments/create` | Buat pembayaran |
| GET | `/api/users/profile` | Lihat profil |
| PUT | `/api/users/profile` | Update profil |
| DELETE | `/api/users/profile` | Hapus akun permanen |
| GET | `/api/users/addresses` | Daftar alamat |
| POST | `/api/users/addresses` | Tambah alamat |
| PUT | `/api/users/addresses/:id` | Update alamat |
| DELETE | `/api/users/addresses/:id` | Hapus alamat |
| PUT | `/api/users/addresses/:id/set-default` | Set alamat utama |
| POST | `/api/shipping/calculate` | Hitung ongkir |
| GET | `/api/chats` | Daftar chat room |
| POST | `/api/chats/start` | Mulai chat |
| GET | `/api/chats/:room_id/messages` | Riwayat pesan |
| POST | `/api/chats/:room_id/messages` | Kirim pesan |
| GET | `/api/vouchers` | Daftar voucher |
| GET | `/api/flash-sales` | Daftar flash sale |
| GET | `/api/notifications` | Daftar notifikasi |
| PUT | `/api/notifications/read-all` | Tandai semua dibaca |
| GET | `/api/seller/dashboard/stats` | Dashboard penjual |

### 🔴 Admin (Bearer Token + Admin Role)

| Method | Endpoint | Deskripsi |
| ------ | -------- | --------- |
| GET | `/api/admin/orders` | Semua pesanan (+ filter tanggal) |
| PUT | `/api/admin/orders/:id/status` | Ubah status pesanan |
| PUT | `/api/admin/orders/:id/tracking` | Tambah nomor resi |
| GET | `/api/admin/dashboard/stats` | Dashboard analytics |
| PUT | `/api/admin/disputes/:id/resolve` | Selesaikan komplain |
| POST | `/api/admin/banners` | Tambah banner |
| POST | `/api/admin/categories` | Tambah kategori |
| GET | `/api/admin/users` | Daftar semua user |
| PUT | `/api/admin/users/:id/ban` | Ban/unban user |
| PUT | `/api/admin/users/:id/role` | Ubah role user |
