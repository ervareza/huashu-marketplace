import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../core/theme/huashu_theme.dart';
import '../../../core/theme/ink_brush_divider.dart';
import 'product_detail_screen.dart';
import '../../order/presentation/cart_state.dart';
import '../../order/presentation/checkout_screen.dart';
import '../../order/presentation/order_history_screen.dart';

class CatalogScreen extends StatefulWidget {
  const CatalogScreen({super.key});

  @override
  State<CatalogScreen> createState() => _CatalogScreenState();
}

class _CatalogScreenState extends State<CatalogScreen> {
  final _dio = Dio();
  final _secureStorage = const FlutterSecureStorage();
  List<dynamic> _products = [];
  bool _isLoading = true;
  String? _errorMessage;

  String _searchQuery = '';
  String? _selectedCategory;
  final List<String> _categories = ['Semua', 'Electronic', 'Minuman', 'Peralatan Rumah', 'Kecantikan'];

  final String _productsUrl = 'https://d04a-2404-c0-b301-8af6-a587-34e-b9b3-3cba.ngrok-free.app/api/products';

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
      final token = await _secureStorage.read(key: 'access_token');
      final response = await _dio.get(
        _productsUrl,
        options: Options(
          headers: {'Authorization': 'Bearer $token'},
        ),
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        setState(() {
          _products = response.data['data'];
        });
      } else {
        setState(() {
          _errorMessage = response.data['message'] ?? 'Gagal mengambil produk';
        });
      }
    } on DioException catch (e) {
      setState(() {
        _errorMessage = e.response?.data['message'] ?? 'Gagal memuat produk dari server.';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  List<dynamic> get _filteredProducts {
    return _products.where((p) {
      final matchesSearch = p['name'].toString().toLowerCase().contains(_searchQuery.toLowerCase());
      final matchesCategory = _selectedCategory == null || 
          _selectedCategory == 'Semua' || 
          p['category'].toString().toLowerCase() == _selectedCategory!.toLowerCase();
      return matchesSearch && matchesCategory;
    }).toList();
  }

  double _parsePrice(dynamic priceStr) {
    if (priceStr == null) return 0.0;
    // Bersihkan mata uang 'Rp ' dan '.' pemisah ribuan
    final cleaned = priceStr.toString().replaceAll('Rp ', '').replaceAll('.', '').trim();
    return double.tryParse(cleaned) ?? 0.0;
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filteredProducts;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: Text(
          'KATALOG HUASHU',
          style: GoogleFonts.notoSerifSc(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: HuashuTheme.charcoalBlack,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.history_edu, color: HuashuTheme.charcoalBlack),
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
                backgroundColor: HuashuTheme.stainedCinnabarRed,
                isLabelVisible: cart.isNotEmpty,
                child: IconButton(
                  icon: const Icon(Icons.shopping_bag_outlined, color: HuashuTheme.charcoalBlack),
                  onPressed: () {
                    if (cart.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Keranjang belanja Anda masih kosong'),
                          backgroundColor: HuashuTheme.stainedCinnabarRed,
                        ),
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
          const SizedBox(width: 16),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Kolom Pencarian Gaya Kaligrafi
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
            child: TextField(
              onChanged: (val) => setState(() => _searchQuery = val),
              decoration: InputDecoration(
                hintText: 'Cari barang seni / produk...',
                prefixIcon: const Icon(Icons.search, color: HuashuTheme.lightInkLine),
                hintStyle: GoogleFonts.inter(color: HuashuTheme.lightInkLine),
              ),
            ),
          ),
          
          // Kategori Horizontal dengan Desain Bersih
          SizedBox(
            height: 48,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 24),
              itemCount: _categories.length,
              itemBuilder: (context, index) {
                final cat = _categories[index];
                final isSelected = _selectedCategory == cat || (_selectedCategory == null && cat == 'Semua');
                return Padding(
                  padding: const EdgeInsets.only(right: 16),
                  child: ChoiceChip(
                    label: Text(cat),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() {
                        _selectedCategory = cat;
                      });
                    },
                    selectedColor: HuashuTheme.charcoalBlack,
                    backgroundColor: Colors.transparent,
                    labelStyle: GoogleFonts.inter(
                      fontSize: 13,
                      color: isSelected ? HuashuTheme.xuanPaperBg : HuashuTheme.charcoalBlack,
                    ),
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.zero,
                    ),
                    side: BorderSide(
                      color: isSelected ? HuashuTheme.charcoalBlack : HuashuTheme.lightInkLine,
                      width: 0.5,
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 12),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.0),
            child: InkBrushDivider(height: 1.5),
          ),
          
          // Grid Asimetris Staggered List
          Expanded(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(color: HuashuTheme.mineralJadeGreen),
                  )
                : _errorMessage != null
                    ? Center(
                        child: Text(
                          _errorMessage!,
                          style: GoogleFonts.inter(color: HuashuTheme.stainedCinnabarRed),
                        ),
                      )
                    : filtered.isEmpty
                        ? Center(
                            child: Text(
                              'Tidak ada produk yang cocok dengan pencarian Anda.',
                              style: GoogleFonts.inter(color: HuashuTheme.lightInkLine),
                            ),
                          )
                        : GridView.builder(
                            padding: const EdgeInsets.all(24),
                            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              crossAxisSpacing: 20,
                              mainAxisSpacing: 24,
                              childAspectRatio: 0.72,
                            ),
                            itemCount: filtered.length,
                            itemBuilder: (context, index) {
                              final p = filtered[index];
                              final priceDouble = _parsePrice(p['price']);

                              return GestureDetector(
                                onTap: () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (_) => ProductDetailScreen(
                                        product: p,
                                        priceDouble: priceDouble,
                                      ),
                                    ),
                                  );
                                },
                                child: Container(
                                  decoration: const BoxDecoration(
                                    border: Border(
                                      bottom: BorderSide(color: HuashuTheme.lightInkLine, width: 0.5),
                                    ),
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      // Gambar dengan Caching dan Bingkai Tipis
                                      Expanded(
                                        child: Container(
                                          width: double.infinity,
                                          decoration: BoxDecoration(
                                            border: Border.all(color: HuashuTheme.lightInkLine, width: 0.5),
                                          ),
                                          child: CachedNetworkImage(
                                            imageUrl: p['image_url'] ?? '',
                                            fit: BoxFit.cover,
                                            placeholder: (context, url) => Container(
                                              color: Colors.transparent,
                                              child: const Center(
                                                child: SizedBox(
                                                  width: 20,
                                                  height: 20,
                                                  child: CircularProgressIndicator(
                                                    strokeWidth: 1.5,
                                                    color: HuashuTheme.lightInkLine,
                                                  ),
                                                ),
                                              ),
                                            ),
                                            errorWidget: (context, url, error) => const Icon(
                                              Icons.image_outlined,
                                              color: HuashuTheme.lightInkLine,
                                              size: 32,
                                            ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 12),
                                      // Kategori Teks Kecil
                                      Text(
                                        p['category'].toString().toUpperCase(),
                                        style: Theme.of(context).textTheme.labelSmall,
                                      ),
                                      const SizedBox(height: 4),
                                      // Nama Produk (Sans-serif tebal)
                                      Text(
                                        p['name'],
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: GoogleFonts.inter(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14,
                                          color: HuashuTheme.charcoalBlack,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      // Harga (Merah Sinabar Serif)
                                      Text(
                                        p['price'] ?? 'Rp 0',
                                        style: GoogleFonts.notoSerifSc(
                                          color: HuashuTheme.stainedCinnabarRed,
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 12),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
          ),
        ],
      ),
    );
  }
}
