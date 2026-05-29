import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../core/theme/huashu_theme.dart';
import '../../../core/theme/ink_brush_divider.dart';
import '../../../core/network/api_service.dart';
import 'product_detail_screen.dart';
import 'wishlist_provider.dart';
import 'wishlist_screen.dart';
import '../../profile/presentation/profile_screen.dart';
import '../../notification/presentation/notification_screen.dart';
import '../../admin/presentation/admin_panel_screen.dart';
import '../../order/presentation/cart_provider.dart';
import '../../order/presentation/cart_screen.dart';
import '../../order/presentation/order_history_screen.dart';

import '../../seller/presentation/seller_dashboard_screen.dart';
import '../../../core/network/global_socket_service.dart';
import '../../../core/network/auth_helper.dart';

class CatalogScreen extends StatefulWidget {
  const CatalogScreen({super.key});

  @override
  State<CatalogScreen> createState() => _CatalogScreenState();
}

class _CatalogScreenState extends State<CatalogScreen> {
  final _api = ApiService();
  List<dynamic> _products = [];
  List<dynamic> _flashSales = [];
  bool _isLoading = true;
  String? _errorMessage;

  String _searchQuery = '';
  String? _selectedCategory;
  List<dynamic> _categories = [{'name': 'Semua'}];
  List<dynamic> _banners = [];

  String _userName = '';
  String _userRole = '';
  bool _hasUnreadNotif = false;

  @override
  void initState() {
    super.initState();
    _loadUserInfo();
    _fetchFlashSales();
    _fetchCategories();
    _fetchBanners();
    _fetchProducts();
    _checkUnreadNotif();
    CartProvider().fetchCart();
    WishlistProvider().fetchWishlist();
  }

  Future<void> _checkUnreadNotif() async {
    try {
      final response = await _api.dio.get('/api/notifications');
      if (response.statusCode == 200 && response.data['success'] == true) {
        final notifications = response.data['data'] as List<dynamic>? ?? [];
        final hasUnread = notifications.any((n) => n['is_read'] == false);
        if (mounted) {
          setState(() {
            _hasUnreadNotif = hasUnread;
          });
        }
      }
    } catch (e) {
      // Abaikan jika error fetch notifikasi background
    }
  }

  Future<void> _loadUserInfo() async {
    final name = await _api.secureStorage.read(key: 'user_name') ?? '';
    final role = await _api.secureStorage.read(key: 'user_role') ?? '';
    setState(() {
      _userName = name;
      _userRole = role;
    });
  }

  Future<void> _fetchFlashSales() async {
    try {
      final response = await _api.dio.get('/api/flash-sales');
      if (response.statusCode == 200 && response.data['success'] == true) {
        setState(() {
          _flashSales = response.data['data'] as List<dynamic>? ?? [];
        });
      }
    } catch (e) {
      debugPrint("Gagal memuat flash sales: $e");
    }
  }

  Future<void> _fetchCategories() async {
    try {
      final response = await _api.dio.get('/api/categories');
      if (response.statusCode == 200 && response.data['success'] == true) {
        if (mounted) {
          setState(() {
            _categories = [{'name': 'Semua'}, ...response.data['data']];
          });
        }
      }
    } catch (e) {
      debugPrint("Gagal memuat kategori: $e");
    }
  }

  Future<void> _fetchBanners() async {
    try {
      final response = await _api.dio.get('/api/banners');
      if (response.statusCode == 200 && response.data['success'] == true) {
        if (mounted) {
          setState(() {
            _banners = response.data['data'] as List<dynamic>? ?? [];
          });
        }
      }
    } catch (e) {
      debugPrint("Gagal memuat banner: $e");
    }
  }

  Future<void> _fetchProducts() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      String url = '/api/products';
      Map<String, dynamic> queryParams = {};
      
      if (_searchQuery.isNotEmpty || (_selectedCategory != null && _selectedCategory != 'Semua')) {
        url = '/api/products/search';
        if (_searchQuery.isNotEmpty) queryParams['q'] = _searchQuery;
        if (_selectedCategory != null && _selectedCategory != 'Semua') queryParams['category'] = _selectedCategory;
      }

      final response = await _api.dio.get(url, queryParameters: queryParams);

      final data = response.data;
      if (data is Map<String, dynamic> &&
          response.statusCode == 200 &&
          data['success'] == true) {
        final productsData = data['data'];
        setState(() {
          _products = (productsData is List) ? productsData : [];
        });
      } else {
        setState(() {
          _errorMessage = (data is Map<String, dynamic>)
              ? data['message']?.toString() ?? 'Gagal mengambil produk'
              : 'Format response produk tidak valid.';
        });
      }
    } on DioException catch (e) {
      setState(() {
        _errorMessage = ApiService.extractErrorMessage(
          e,
          fallback: 'Gagal memuat produk dari server.',
        );
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Kesalahan tak terduga: ${e.toString()}';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _logout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('KELUAR'),
        content: const Text('Apakah Anda yakin ingin keluar dari akun ini?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('BATAL'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: HuashuTheme.stainedCinnabarRed,
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('KELUAR'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      AuthHelper.forceLogoutAndRedirect('Anda telah keluar.');
    }
  }

  List<dynamic> get _filteredProducts {
    return _products;
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filteredProducts;

    return Scaffold(
      drawer: Drawer(
        backgroundColor: HuashuTheme.xuanPaperBg,
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(24, 60, 24, 24),
              color: HuashuTheme.charcoalBlack,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const HuashuSeal(character: '書'),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _userName.toUpperCase(),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.notoSerifSc(
                                color: HuashuTheme.xuanPaperBg,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              _userRole == 'seller' ? 'PENJUAL' : 'PEMBELI',
                              style: GoogleFonts.notoSerifSc(
                                color: HuashuTheme.stainedCinnabarRed,
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            ListTile(
              leading: const Icon(Icons.grid_view_outlined, color: HuashuTheme.charcoalBlack),
              title: Text('Katalog Utama', style: GoogleFonts.notoSerifSc(fontWeight: FontWeight.bold)),
              onTap: () => Navigator.pop(context),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: InkBrushDivider(height: 1),
            ),
            ListTile(
              leading: const Icon(Icons.history_edu_outlined, color: HuashuTheme.charcoalBlack),
              title: Text('Riwayat Pesanan', style: GoogleFonts.notoSerifSc(fontWeight: FontWeight.bold)),
              onTap: () {
                Navigator.pop(context);
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const OrderHistoryScreen()),
                );
              },
            ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: InkBrushDivider(height: 1),
            ),
            ListTile(
              leading: const Icon(Icons.person_outline, color: HuashuTheme.charcoalBlack),
              title: Text('Profil & Alamat', style: GoogleFonts.notoSerifSc(fontWeight: FontWeight.bold)),
              onTap: () {
                Navigator.pop(context);
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const ProfileScreen()),
                );
              },
            ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: InkBrushDivider(height: 1),
            ),
            if (_userRole == 'admin') ...[
              ListTile(
                leading: const Icon(Icons.shield_outlined, color: HuashuTheme.stainedCinnabarRed),
                title: Text(
                  'Panel Admin',
                  style: GoogleFonts.notoSerifSc(
                    fontWeight: FontWeight.bold,
                    color: HuashuTheme.stainedCinnabarRed,
                  ),
                ),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const AdminPanelScreen()),
                  );
                },
              ),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: InkBrushDivider(height: 1),
              ),
            ] else if (_userRole == 'seller') ...[
              ListTile(
                leading: const Icon(Icons.storefront_outlined, color: HuashuTheme.mineralJadeGreen),
                title: Text(
                  'Dashboard Penjual',
                  style: GoogleFonts.notoSerifSc(
                    fontWeight: FontWeight.bold,
                    color: HuashuTheme.mineralJadeGreen,
                  ),
                ),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const SellerDashboardScreen()),
                  );
                },
              ),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: InkBrushDivider(height: 1),
              ),
            ],
            const Spacer(),
            const InkBrushDivider(height: 8),
            ListTile(
              leading: const Icon(Icons.logout, color: HuashuTheme.stainedCinnabarRed),
              title: Text('Keluar Akun', style: GoogleFonts.notoSerifSc(fontWeight: FontWeight.bold)),
              onTap: () {
                Navigator.pop(context);
                _logout();
              },
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
      appBar: AppBar(
        title: Text(
          '華書 KATALOG',
          style: GoogleFonts.notoSerifSc(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: HuashuTheme.charcoalBlack,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.history_edu),
            tooltip: 'Riwayat Pesanan',
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const OrderHistoryScreen()),
              );
            },
          ),
          // ─── Notification Icon ─────────────
          AnimatedBuilder(
            animation: GlobalSocketService(),
            builder: (context, _) {
              return Stack(
                alignment: Alignment.center,
                children: [
                  IconButton(
                    icon: const Icon(Icons.notifications_none),
                    tooltip: 'Notifikasi',
                    onPressed: () async {
                      await Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const NotificationScreen()),
                      );
                      GlobalSocketService().markNotificationsAsRead();
                      _checkUnreadNotif(); // Cek lagi setelah kembali
                    },
                  ),
                  if (_hasUnreadNotif || GlobalSocketService().hasUnreadNotifications)
                    const Positioned(
                      right: 6,
                      top: 6,
                      child: HuashuStampBadge(label: 'New', color: HuashuTheme.stainedCinnabarRed),
                    ),
                ],
              );
            },
          ),
          
          // ─── Wishlist Icon ─────────────
          IconButton(
            icon: const Icon(Icons.favorite_border),
            tooltip: 'Favorit',
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const WishlistScreen()),
              );
            },
          ),
          
          // ─── Cart Icon ─────────────
          AnimatedBuilder(
            animation: CartProvider(),
            builder: (context, _) {
              final cart = CartProvider().items;
              return Badge(
                label: Text(cart.length.toString()),
                isLabelVisible: cart.isNotEmpty,
                child: IconButton(
                  icon: const Icon(Icons.shopping_bag_outlined),
                  tooltip: 'Keranjang',
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const CartScreen()),
                    );
                  },
                ),
              );
            },
          ),
          const SizedBox(width: HuashuTheme.space8),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ─── Kolom Pencarian ───────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: HuashuTheme.space24,
              vertical: HuashuTheme.space12,
            ),
            child: TextField(
              onSubmitted: (val) {
                setState(() => _searchQuery = val);
                _fetchProducts();
              },
              decoration: InputDecoration(
                hintText: 'Cari barang seni / produk...',
                prefixIcon: const Icon(Icons.search, color: HuashuTheme.warmStone),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.search, color: HuashuTheme.mineralJadeGreen),
                  onPressed: () {
                    FocusScope.of(context).unfocus();
                    _fetchProducts();
                  },
                ),
              ),
            ),
          ),

          // ─── Kategori Horizontal ──────────────────────
          SizedBox(
            height: 44,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: HuashuTheme.space24),
              itemCount: _categories.length,
              itemBuilder: (context, index) {
                final catMap = _categories[index];
                final catName = catMap['name']?.toString() ?? 'Semua';
                final isSelected = _selectedCategory == catName || (_selectedCategory == null && catName == 'Semua');
                return Padding(
                  padding: const EdgeInsets.only(right: HuashuTheme.space12),
                  child: ChoiceChip(
                    label: Text(
                      catName,
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        letterSpacing: 0.5,
                        color: isSelected ? HuashuTheme.xuanPaperBg : HuashuTheme.charcoalBlack,
                      ),
                    ),
                    selected: isSelected,
                    onSelected: (_) {
                      setState(() => _selectedCategory = catName);
                      _fetchProducts();
                    },
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: HuashuTheme.space12),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: HuashuTheme.space24),
            child: InkBrushDivider(height: 1.5),
          ),
          const SizedBox(height: HuashuTheme.space12),
          
          // ─── Banners ──────────────────────────────────
          if (_banners.where((b) => (b['image_url'] ?? '').toString().isNotEmpty).isNotEmpty && (_searchQuery.isEmpty && (_selectedCategory == null || _selectedCategory == 'Semua'))) ...[
            Builder(builder: (context) {
              final validBanners = _banners.where((b) => (b['image_url'] ?? '').toString().isNotEmpty).toList();
              return SizedBox(
                height: 160,
                child: PageView.builder(
                  controller: PageController(viewportFraction: 0.9),
                  itemCount: validBanners.length,
                  itemBuilder: (context, index) {
                    final banner = validBanners[index];
                    final imageUrl = ApiService.sanitizeImageUrl(banner['image_url']?.toString());
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: HuashuTheme.lightInkLine),
                        ),
                        child: ClipRect(
                          child: imageUrl.isNotEmpty
                              ? CachedNetworkImage(
                                  imageUrl: imageUrl,
                                  fit: BoxFit.cover,
                                  width: double.infinity,
                                  height: double.infinity,
                                  errorWidget: (_, __, ___) => const Center(
                                    child: Icon(Icons.broken_image_outlined, color: HuashuTheme.warmStone, size: 40),
                                  ),
                                )
                              : const SizedBox.shrink(),
                        ),
                      ),
                    );
                  },
                ),
              );
            }),
            const SizedBox(height: HuashuTheme.space12),
          ],
          
          if (_flashSales.isNotEmpty && (_searchQuery.isEmpty && (_selectedCategory == null || _selectedCategory == 'Semua'))) ...[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: HuashuTheme.space24, vertical: HuashuTheme.space12),
              child: Row(
                children: [
                  const Icon(Icons.flash_on, color: HuashuTheme.stainedCinnabarRed),
                  const SizedBox(width: 8),
                  Text(
                    'FLASH SALE BERAKHIR DALAM 02:45:10',
                    style: GoogleFonts.notoSerifSc(fontWeight: FontWeight.bold, color: HuashuTheme.stainedCinnabarRed, fontSize: 14),
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 160,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: HuashuTheme.space24),
                itemCount: _flashSales.length,
                itemBuilder: (context, index) {
                  final sale = _flashSales[index];
                  final product = sale['Product'] ?? sale;
                  final price = ApiService.parsePrice(product['price']);
                  final discountPrice = sale['discount_price'] != null ? ApiService.parsePrice(sale['discount_price']) : price * 0.8;
                  
                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => ProductDetailScreen(product: product, priceDouble: discountPrice)),
                      );
                    },
                    child: Container(
                      width: 120,
                      margin: const EdgeInsets.only(right: 16),
                      decoration: BoxDecoration(
                        border: Border.all(color: HuashuTheme.stainedCinnabarRed.withValues(alpha: 0.3)),
                        color: HuashuTheme.xuanPaperBg,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: CachedNetworkImage(
                              imageUrl: ApiService.sanitizeImageUrl(product['image_url']),
                              fit: BoxFit.cover,
                              width: double.infinity,
                              errorWidget: (context, url, error) => const Icon(Icons.image_not_supported),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  product['name'] ?? '',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  ApiService.formatPrice(price),
                                  style: GoogleFonts.inter(fontSize: 10, color: Colors.grey, decoration: TextDecoration.lineThrough),
                                ),
                                Text(
                                  ApiService.formatPrice(discountPrice),
                                  style: GoogleFonts.notoSerifSc(fontSize: 12, color: HuashuTheme.stainedCinnabarRed, fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: HuashuTheme.space24, vertical: 8),
              child: InkBrushDivider(height: 1.5),
            ),
          ],

          // ─── Grid Produk ──────────────────────────────
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _errorMessage != null
                    ? HuashuEmptyState(
                        icon: Icons.cloud_off,
                        message: _errorMessage!,
                        onRetry: _fetchProducts,
                      )
                    : filtered.isEmpty
                        ? const HuashuEmptyState(
                            icon: Icons.search_off,
                            message: 'Tidak ada produk yang cocok\ndengan pencarian Anda.',
                          )
                        : RefreshIndicator(
                            color: HuashuTheme.mineralJadeGreen,
                            onRefresh: _fetchProducts,
                            child: GridView.builder(
                              padding: const EdgeInsets.all(HuashuTheme.space24),
                              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                crossAxisSpacing: 16,
                                mainAxisSpacing: 20,
                                childAspectRatio: 0.68,
                              ),
                              itemCount: filtered.length,
                              itemBuilder: (context, index) => _buildProductCard(filtered[index]),
                            ),
                          ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductCard(dynamic p) {
    final priceDouble = ApiService.parsePrice(p['price']);

    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => ProductDetailScreen(product: p, priceDouble: priceDouble),
          ),
        );
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Gambar dengan border tipis
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                border: Border.all(color: HuashuTheme.lightInkLine, width: HuashuTheme.hairline),
              ),
              child: CachedNetworkImage(
                imageUrl: ApiService.sanitizeImageUrl(p['image_url']?.toString()),
                fit: BoxFit.cover,
                placeholder: (_, __) => const Center(
                  child: SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 1.5),
                  ),
                ),
                errorWidget: (_, __, ___) {
                  final name = p['name']?.toString() ?? '墨';
                  final initial = name.isNotEmpty ? name[0] : '墨';
                  return Container(
                    color: HuashuTheme.warmStone,
                    child: Center(
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: HuashuTheme.stainedCinnabarRed.withValues(alpha: 0.6),
                            width: 1.5,
                          ),
                        ),
                        child: Text(
                          initial,
                          style: GoogleFonts.notoSerifSc(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: HuashuTheme.stainedCinnabarRed.withValues(alpha: 0.8),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          const SizedBox(height: HuashuTheme.space8),

          // Kategori
          HuashuSectionLabel(text: p['category']?.toString() ?? ''),
          const SizedBox(height: HuashuTheme.space4),

          // Nama Produk
          Text(
            p['name']?.toString() ?? '',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.inter(
              fontWeight: FontWeight.w600,
              fontSize: 13,
              color: HuashuTheme.charcoalBlack,
            ),
          ),
          const SizedBox(height: HuashuTheme.space4),

          // Harga
          HuashuPrice(price: ApiService.formatPrice(priceDouble)),

          const SizedBox(height: HuashuTheme.space8),

          // Garis bawah
          Container(
            height: HuashuTheme.hairline,
            color: HuashuTheme.lightInkLine,
          ),
        ],
      ),
    );
  }
}
