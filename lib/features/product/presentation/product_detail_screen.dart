import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../core/theme/huashu_theme.dart';
import '../../../core/theme/ink_brush_divider.dart';
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
      name: widget.product['name'],
      description: widget.product['description'] ?? '',
      price: widget.priceDouble,
      imageUrl: widget.product['image_url'] ?? '',
      quantity: _quantity,
    );

    CartManager.add(cartItem);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${widget.product['name']} berhasil ditambahkan ke keranjang'),
        backgroundColor: HuashuTheme.mineralJadeGreen,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final p = widget.product;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: HuashuTheme.charcoalBlack,
      ),
      body: Column(
        children: [
          // Gambar Atas Scrollable Detail
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Bingkai Ganda Gambar Utama (Huashu Framing)
                  Container(
                    width: double.infinity,
                    height: 300,
                    decoration: BoxDecoration(
                      border: Border.all(color: HuashuTheme.lightInkLine, width: 0.5),
                    ),
                    padding: const EdgeInsets.all(4.0),
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: HuashuTheme.lightInkLine, width: 0.5),
                      ),
                      child: CachedNetworkImage(
                        imageUrl: p['image_url'] ?? '',
                        fit: BoxFit.cover,
                        errorWidget: (context, url, error) => const Icon(
                          Icons.image_outlined,
                          color: HuashuTheme.lightInkLine,
                          size: 48,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  
                  // Label Kategori
                  Text(
                    p['category'].toString().toUpperCase(),
                    style: Theme.of(context).textTheme.labelSmall,
                  ),
                  const SizedBox(height: 8),
                  
                  // Nama Produk (Serif Klasik)
                  Text(
                    p['name'],
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  const SizedBox(height: 12),
                  
                  // Harga Produk (Sinabar Merah)
                  Text(
                    p['price'] ?? 'Rp 0',
                    style: GoogleFonts.notoSerifSc(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: HuashuTheme.stainedCinnabarRed,
                    ),
                  ),
                  const SizedBox(height: 20),
                  
                  // Pembatas Kuas Kaligrafi
                  const InkBrushDivider(height: 2.0),
                  const SizedBox(height: 20),
                  
                  // Deskripsi
                  Text(
                    'DESKRIPSI BARANG',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      letterSpacing: 1.0,
                      fontWeight: FontWeight.bold,
                      color: HuashuTheme.charcoalBlack.withOpacity(0.6),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    p['description'] ?? 'Tidak ada deskripsi untuk barang seni ini.',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  const SizedBox(height: 24),
                  
                  // Detail Toko / Penjual (Seller)
                  if (p['seller'] != null) ...[
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        border: Border.all(color: HuashuTheme.lightInkLine, width: 0.5),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.storefront_outlined, color: HuashuTheme.mineralJadeGreen),
                          const SizedBox(width: 16),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'PENJUAL UTAMA',
                                style: Theme.of(context).textTheme.labelSmall,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                p['seller']['name'] ?? 'Toko Seni',
                                style: GoogleFonts.inter(
                                  fontWeight: FontWeight.bold,
                                  color: HuashuTheme.charcoalBlack,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),
                  ],
                ],
              ),
            ),
          ),
          
          // Panel Jumlah Beli & Beli Sekarang (Sticky Bottom Bar)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            decoration: const BoxDecoration(
              border: Border(
                top: BorderSide(color: HuashuTheme.lightInkLine, width: 0.5),
              ),
              color: HuashuTheme.xuanPaperBg,
            ),
            child: Row(
              children: [
                // Counter Jumlah Kustom (Huashu Underline Style)
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: HuashuTheme.lightInkLine, width: 0.5),
                  ),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.remove, size: 18),
                        onPressed: () {
                          if (_quantity > 1) {
                            setState(() => _quantity--);
                          }
                        },
                      ),
                      Text(
                        _quantity.toString(),
                        style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      IconButton(
                        icon: const Icon(Icons.add, size: 18),
                        onPressed: () {
                          setState(() => _quantity++);
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                
                // Tombol Beli Utama (Mineral Jade Green)
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
