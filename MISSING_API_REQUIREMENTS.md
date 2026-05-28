# 📌 Dokumen Analisis: Missing Endpoints & Marketplace Flows

Dokumen ini berisi analisis lengkap terkait API dan *flow* apa saja yang **masih belum ada** (missing) di backend saat ini, berdasarkan file `API_DOCUMENTATION.md`. 
Dokumen ini bisa Anda berikan langsung ke teman Anda (Backend Developer) agar aplikasi *marketplace* ini bisa berjalan dengan skala penuh, canggih, dan profesional (Rich Features).

---

## 1. 🛒 Keranjang Belanja (Cart) & Wishlist
Saat ini user hanya bisa melakukan *direct checkout* (beli langsung dari halaman produk). Flow standar marketplace membutuhkan keranjang belanja.
**Missing Endpoints:**
- `GET /api/cart` - Mengambil seluruh isi keranjang user yang sedang login.
- `POST /api/cart` - Menambahkan produk ke keranjang (body: `product_id`, `quantity`).
- `PUT /api/cart/:cart_item_id` - Mengubah jumlah (quantity) produk di keranjang.
- `DELETE /api/cart/:cart_item_id` - Menghapus produk dari keranjang.
- `POST /api/wishlist` & `GET /api/wishlist` - Untuk fitur "Simpan/Favorit" produk agar user bisa beli nanti.

---

## 2. 📦 Manajemen Pesanan Admin / Penjual (Order Management)
Saat ini admin tidak bisa melihat pesanan yang masuk dan tidak bisa mengubah status pesanan (pengiriman).
**Missing Endpoints:**
- `GET /api/admin/orders` - Mengambil **semua** pesanan dari semua user (bisa difilter berdasarkan status `pending`, `processing`, `shipped`, dll).
- `PUT /api/admin/orders/:id/status` - Mengubah status pesanan (misal: dari `pending` -> `processing` -> `shipped` -> `delivered`).
- `PUT /api/admin/orders/:id/tracking` - Menambahkan **Nomor Resi** (Tracking Number) dan nama kurir ke pesanan yang sudah dikirim (`shipped`).

---

## 3. 🚚 Pengiriman (Shipping & Courier)
Saat ini biaya ongkir (shipping fee) masih *hardcoded* (fixed) dari sisi frontend/backend, dan belum ada kalkulasi jarak.
**Missing Endpoints:**
- `POST /api/shipping/calculate` atau `GET /api/shipping/rates` - Menghitung ongkir berdasarkan alamat user, berat produk, dan pilihan kurir (JNE, Sicepat, dll) menggunakan third-party API seperti RajaOngkir.

---

## 4. 👤 Profil User & Manajemen Alamat
User perlu mengelola profil mereka dan menyimpan banyak alamat (Alamat Rumah, Kantor).
**Missing Endpoints:**
- `GET /api/users/profile` - Mengambil data detail profil (termasuk foto profil, no HP).
- `PUT /api/users/profile` - Update profil dan foto avatar.
- `GET /api/users/addresses` - Mengambil daftar alamat yang disimpan user.
- `POST /api/users/addresses` - Menambahkan alamat pengiriman baru (Lengkap dengan Provinsi, Kota, Kode Pos).
- `PUT /api/users/addresses/:id/set-default` - Mengatur alamat utama.

---

## 5. ⭐ Ulasan & Rating Produk (Reviews)
Pembeli yang pesanannya sudah selesai (`delivered`) seharusnya bisa memberikan ulasan.
**Missing Endpoints:**
- `POST /api/products/:id/reviews` - Menambahkan ulasan (text + foto) dan rating (1-5 bintang) untuk produk yang sudah dibeli (wajib validasi bahwa user benar-benar sudah membeli produk ini).
- `GET /api/products/:id/reviews` - Menampilkan daftar ulasan di halaman detail produk.

---

## 6. 📊 Dashboard Analytics (Untuk Admin Panel)
Admin/Seller butuh data statistik untuk memantau performa toko mereka.
**Missing Endpoints:**
- `GET /api/admin/dashboard/stats` - Mengembalikan rekap data: Total Pendapatan (Revenue), Total Pesanan Bulan Ini, Total Produk Aktif, dan Produk Terlaris (Top Selling).

---

## 7. 🏷️ Kategori Dinamis & Filter Lanjutan (Categories & Search)
Saat ini kategori produk masih *hardcoded*. Sebaiknya kategori memiliki tabel sendiri di database.
**Missing Endpoints:**
- `GET /api/categories` - Mengambil daftar kategori beserta icon/gambarnya.
- `POST /api/categories` - (Admin) Menambah kategori baru.
- `GET /api/products/search` - Pencarian produk yang mendukung filter (Berdasarkan harga min-max, rating, dan kategori).

---

## 8. 💬 Sistem Chat Real-time (Penjual & Pembeli)
Fitur wajib di marketplace modern agar pembeli bisa bertanya langsung ke penjual sebelum membeli. Disarankan menggunakan **WebSockets (Socket.io)**.
**Missing Endpoints:**
- `GET /api/chats` - Mengambil daftar riwayat chat/room milik user.
- `GET /api/chats/:room_id/messages` - Mengambil riwayat pesan dalam satu obrolan.
- `POST /api/chats/:room_id/messages` - Mengirim pesan (teks atau lampiran gambar).

---

## 9. 🎟️ Promo, Diskon & Flash Sale (Vouchers)
Agar aplikasi terasa hidup dan dinamis, perlu ada sistem diskon atau potongan harga.
**Missing Endpoints:**
- `GET /api/vouchers` - Melihat daftar voucher gratis ongkir atau diskon yang sedang aktif.
- `POST /api/orders/apply-voucher` - Mengecek dan memvalidasi voucher sebelum checkout (mengurangi total bayar).
- `GET /api/flash-sales` - Endpoint khusus untuk mengambil daftar produk yang sedang diskon terbatas waktu (countdown timer).

---

## 10. 🔔 Notifikasi In-App (Real-time Notifications)
Mengingatkan user jika pesanan sudah dikirim atau ada pesan masuk.
**Missing Endpoints:**
- `GET /api/notifications` - Mengambil daftar notifikasi milik user.
- `PUT /api/notifications/read-all` - Menandai semua notifikasi sudah dibaca (Tanda lonceng merah hilang).

---

## 11. ⚖️ Komplain & Pengembalian Dana (Refund / Dispute)
Jika barang yang dikirim rusak, user bisa mengajukan komplain alih-alih uangnya langsung masuk ke penjual.
**Missing Endpoints:**
- `POST /api/orders/:id/dispute` - Pembeli mengajukan komplain (unggah bukti foto/video).
- `PUT /api/admin/disputes/:id/resolve` - Admin menengahi dan menyelesaikan komplain (Apakah refund atau ditolak).

---

## 12. 🖼️ Manajemen Banner Beranda (Dynamic Homepage)
Beranda (Home) marketplace biasanya memiliki Carousel/Banner promosi yang bisa diganti-ganti oleh admin.
**Missing Endpoints:**
- `GET /api/banners` - Mengambil daftar gambar banner promosi untuk ditampilkan di halaman utama.
- `POST /api/admin/banners` - Admin menambahkan banner promo baru.

---

### Saran & Rekomendasi Tambahan (Best Practices) Untuk Backend Dev:
1. **Transaction & Rollback:** Saat `POST /api/orders` (Create Order), pastikan backend menggunakan *Database Transaction* (contoh: Prisma `$transaction`). Jika pembuatan order gagal atau stok tidak cukup, proses insert ke tabel `order_items` harus di-*rollback*.
2. **Stock Deduction Constraint:** Stok produk sebaiknya dikurangi saat order dibuat (*Reserve Stock*), dan jika pembayaran kedaluwarsa, stok otomatis dikembalikan (Bisa pakai *Cronjob* otomatis atau Webhook Expired Midtrans).
3. **Role Based Access Control (RBAC):** Endpoint berawalan `/api/admin/*` harus dilindungi oleh middleware auth ekstra yang mengecek `req.user.role === 'admin'`.
4. **Soft Delete:** Untuk Produk dan Order, sebaiknya gunakan *Soft Delete* (kolom `deleted_at`) daripada menghapus permanen dari database, agar riwayat transaksi dan invoice tidak rusak (Foreign Key constraint).
