import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../core/theme/huashu_theme.dart';
import '../../../core/theme/ink_brush_divider.dart';
import '../../../core/network/api_service.dart';
import '../../order/presentation/cart_state.dart';

class ProductDetailScreen extends StatefulWidget {
  final dynamic product;
  final double priceDouble;

  const ProductDetailScreen({
    super.key,
    required this.product,
    required this.priceDouble,
  });

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  int _quantity = 1;

  void _addToCart() {
    final cartItem = CartItem(
      id: widget.product['id'],
      name: widget.product['name']?.toString() ?? 'Produk',
      description: widget.product['description']?.toString() ?? '',
      price: widget.priceDouble,
      imageUrl: widget.product['image_url']?.toString() ?? '',
      quantity: _quantity,
    );

    CartManager.add(cartItem);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${widget.product['name']} ditambahkan ke keranjang'),
        backgroundColor: HuashuTheme.mineralJadeGreen,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final p = widget.product;

    return Scaffold(
      appBar: AppBar(),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(
                horizontal: HuashuTheme.space24,
                vertical: HuashuTheme.space12,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ─── Gambar dengan Bingkai Ganda ────────────
                  HuashuDoubleFrame(
                    height: 320,
                    child: CachedNetworkImage(
                      imageUrl: ApiService.sanitizeImageUrl(p['image_url']?.toString()),
                      fit: BoxFit.cover,
                      width: double.infinity,
                      height: double.infinity,
                      errorWidget: (_, __, ___) {
                        final name = p['name']?.toString() ?? '墨';
                        final initial = name.isNotEmpty ? name[0] : '墨';
                        return Container(
                          color: HuashuTheme.warmStone,
                          child: Center(
                            child: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: HuashuTheme.stainedCinnabarRed.withValues(alpha: 0.6),
                                  width: 2.0,
                                ),
                              ),
                              child: Text(
                                initial,
                                style: GoogleFonts.notoSerifSc(
                                  fontSize: 36,
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
                  const SizedBox(height: HuashuTheme.space24),

                  // ─── Label Kategori ─────────────────────────
                  HuashuSectionLabel(text: p['category']?.toString() ?? ''),
                  const SizedBox(height: HuashuTheme.space8),

                  // ─── Nama Produk ────────────────────────────
                  Text(
                    p['name']?.toString() ?? '',
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  const SizedBox(height: HuashuTheme.space12),

                  // ─── Harga ──────────────────────────────────
                  HuashuPrice(
                    price: ApiService.formatPrice(widget.priceDouble),
                    fontSize: 24,
                  ),
                  const SizedBox(height: HuashuTheme.space24),

                  // ─── Pembatas Kuas ──────────────────────────
                  const InkBrushDivider(height: 2.0),
                  const SizedBox(height: HuashuTheme.space24),

                  // ─── Deskripsi ──────────────────────────────
                  const HuashuSectionLabel(text: 'Deskripsi Barang'),
                  const SizedBox(height: HuashuTheme.space12),
                  Text(
                    p['description']?.toString() ?? 'Tidak ada deskripsi untuk barang seni ini.',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  const SizedBox(height: HuashuTheme.space24),

                  // ─── Info Penjual ───────────────────────────
                  if (p['seller'] != null && p['seller'] is Map) ...[
                    Container(
                      padding: const EdgeInsets.all(HuashuTheme.space16),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: HuashuTheme.lightInkLine,
                          width: HuashuTheme.hairline,
                        ),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.storefront_outlined, color: HuashuTheme.mineralJadeGreen),
                          const SizedBox(width: HuashuTheme.space16),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const HuashuSectionLabel(text: 'Penjual Utama'),
                              const SizedBox(height: HuashuTheme.space4),
                              Text(
                                p['seller']['name']?.toString() ?? 'Toko Seni',
                                style: GoogleFonts.inter(
                                  fontWeight: FontWeight.w600,
                                  color: HuashuTheme.charcoalBlack,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: HuashuTheme.space32),
                  ],
                ],
              ),
            ),
          ),

          // ─── Bottom Bar ─────────────────────────────────
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: HuashuTheme.space24,
              vertical: HuashuTheme.space16,
            ),
            decoration: const BoxDecoration(
              border: Border(
                top: BorderSide(color: HuashuTheme.lightInkLine, width: HuashuTheme.hairline),
              ),
              color: HuashuTheme.xuanPaperBg,
            ),
            child: Row(
              children: [
                // Counter
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: HuashuTheme.lightInkLine,
                      width: HuashuTheme.hairline,
                    ),
                  ),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.remove, size: 18),
                        onPressed: () {
                          if (_quantity > 1) setState(() => _quantity--);
                        },
                      ),
                      Text(
                        _quantity.toString(),
                        style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      IconButton(
                        icon: const Icon(Icons.add, size: 18),
                        onPressed: () => setState(() => _quantity++),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: HuashuTheme.space16),

                // Tombol Beli
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: HuashuTheme.mineralJadeGreen,
                    ),
                    onPressed: _addToCart,
                    child: const Text('TAMBAH KE BAG'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
