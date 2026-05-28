import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../core/theme/huashu_theme.dart';
import '../../../core/theme/ink_brush_divider.dart';
import '../../../core/network/api_service.dart';
import 'product_detail_screen.dart';
import '../../order/presentation/cart_state.dart';
import '../../order/presentation/checkout_screen.dart';
import '../../order/presentation/order_history_screen.dart';
import '../../auth/presentation/login_screen.dart';

class CatalogScreen extends StatefulWidget {
  const CatalogScreen({super.key});

  @override
  State<CatalogScreen> createState() => _CatalogScreenState();
}

class _CatalogScreenState extends State<CatalogScreen> {
  final _api = ApiService();
  List<dynamic> _products = [];
  bool _isLoading = true;
  String? _errorMessage;

  String _searchQuery = '';
  String? _selectedCategory;
  final List<String> _categories = ['Semua', 'Electronic', 'Minuman', 'Peralatan Rumah', 'Kecantikan'];

  @override
  void initState() {
    super.initState();
    _fetchProducts();
  }

  Future<void> _fetchProducts() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final response = await _api.dio.get('/api/products');

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
      await _api.secureStorage.deleteAll();
      CartManager.clear();
      if (mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const LoginScreen()),
          (route) => false,
        );
      }
    }
  }

  List<dynamic> get _filteredProducts {
    return _products.where((p) {
      final name = p['name']?.toString() ?? '';
      final category = p['category']?.toString() ?? '';
      final matchesSearch = name.toLowerCase().contains(_searchQuery.toLowerCase());
      final matchesCategory = _selectedCategory == null ||
          _selectedCategory == 'Semua' ||
          category.toLowerCase() == _selectedCategory!.toLowerCase();
      return matchesSearch && matchesCategory;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filteredProducts;

    return Scaffold(
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
          ValueListenableBuilder<List<CartItem>>(
            valueListenable: CartManager.items,
            builder: (context, cart, _) {
              return Badge(
                label: Text(cart.length.toString()),
                isLabelVisible: cart.isNotEmpty,
                child: IconButton(
                  icon: const Icon(Icons.shopping_bag_outlined),
                  tooltip: 'Keranjang',
                  onPressed: () {
                    if (cart.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Keranjang belanja Anda masih kosong')),
                      );
                      return;
                    }
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const CheckoutScreen()),
                    );
                  },
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout, size: 20),
            tooltip: 'Keluar',
            onPressed: _logout,
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
              onChanged: (val) => setState(() => _searchQuery = val),
              decoration: const InputDecoration(
                hintText: 'Cari barang seni / produk...',
                prefixIcon: Icon(Icons.search, color: HuashuTheme.warmStone),
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
                final cat = _categories[index];
                final isSelected = _selectedCategory == cat || (_selectedCategory == null && cat == 'Semua');
                return Padding(
                  padding: const EdgeInsets.only(right: HuashuTheme.space12),
                  child: ChoiceChip(
                    label: Text(
                      cat,
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        letterSpacing: 0.5,
                        color: isSelected ? HuashuTheme.xuanPaperBg : HuashuTheme.charcoalBlack,
                      ),
                    ),
                    selected: isSelected,
                    onSelected: (_) => setState(() => _selectedCategory = cat),
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
                imageUrl: p['image_url']?.toString() ?? '',
                fit: BoxFit.cover,
                placeholder: (_, __) => const Center(
                  child: SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 1.5),
                  ),
                ),
                errorWidget: (_, __, ___) => Center(
                  child: Icon(
                    Icons.image_outlined,
                    color: HuashuTheme.charcoalBlack.withValues(alpha: 0.15),
                    size: 32,
                  ),
                ),
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
