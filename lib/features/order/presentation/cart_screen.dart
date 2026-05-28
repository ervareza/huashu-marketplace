import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../core/theme/huashu_theme.dart';
import '../../../core/theme/ink_brush_divider.dart';
import '../../../core/network/api_service.dart';
import 'cart_provider.dart';
import 'checkout_screen.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  final CartProvider _cartProvider = CartProvider();

  @override
  void initState() {
    super.initState();
    _cartProvider.fetchCart();
  }

  void _updateQuantity(CartItem item, int delta) async {
    final newQty = item.quantity + delta;
    if (newQty < 1) {
      _removeItem(item);
      return;
    }
    await _cartProvider.updateQuantity(item.id, newQty);
  }

  void _removeItem(CartItem item) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Hapus Barang?', style: GoogleFonts.notoSerifSc(fontWeight: FontWeight.bold)),
        content: Text('Apakah Anda yakin ingin menghapus ${item.name} dari keranjang?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Batal', style: TextStyle(color: HuashuTheme.charcoalBlack)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Hapus', style: TextStyle(color: HuashuTheme.stainedCinnabarRed)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await _cartProvider.remove(item.id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${item.name} dihapus dari keranjang'),
            backgroundColor: HuashuTheme.charcoalBlack,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Keranjang Belanja',
          style: GoogleFonts.notoSerifSc(fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
      ),
      body: AnimatedBuilder(
        animation: _cartProvider,
        builder: (context, _) {
          if (_cartProvider.isLoading && _cartProvider.items.isEmpty) {
            return const Center(
              child: CircularProgressIndicator(color: HuashuTheme.mineralJadeGreen),
            );
          }

          if (_cartProvider.items.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.shopping_bag_outlined,
                    size: 80,
                    color: HuashuTheme.charcoalBlack.withValues(alpha: 0.2),
                  ),
                  const SizedBox(height: HuashuTheme.space16),
                  Text(
                    'Keranjang Anda Kosong',
                    style: GoogleFonts.notoSerifSc(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: HuashuTheme.charcoalBlack.withValues(alpha: 0.6),
                    ),
                  ),
                  const SizedBox(height: HuashuTheme.space8),
                  Text(
                    'Mari temukan produk terbaik untuk Anda',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      color: HuashuTheme.charcoalBlack.withValues(alpha: 0.4),
                    ),
                  ),
                  const SizedBox(height: HuashuTheme.space24),
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: HuashuTheme.mineralJadeGreen,
                      padding: const EdgeInsets.symmetric(
                        horizontal: HuashuTheme.space32,
                        vertical: HuashuTheme.space16,
                      ),
                    ),
                    child: const Text('KEMBALI BELANJA'),
                  )
                ],
              ),
            );
          }

          return Column(
            children: [
              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.all(HuashuTheme.space16),
                  itemCount: _cartProvider.items.length,
                  separatorBuilder: (context, index) => const InkBrushDivider(height: 1),
                  itemBuilder: (context, index) {
                    final item = _cartProvider.items[index];
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: HuashuTheme.space12),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // ─── Gambar Produk ─────────────────
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: CachedNetworkImage(
                              imageUrl: ApiService.sanitizeImageUrl(item.imageUrl),
                              width: 80,
                              height: 80,
                              fit: BoxFit.cover,
                              errorWidget: (context, url, error) => Container(
                                width: 80,
                                height: 80,
                                color: HuashuTheme.warmStone,
                                child: const Icon(Icons.image_not_supported, color: Colors.white),
                              ),
                            ),
                          ),
                          const SizedBox(width: HuashuTheme.space16),
                          
                          // ─── Info Produk ───────────────────
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item.name,
                                  style: GoogleFonts.inter(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: HuashuTheme.space4),
                                HuashuPrice(price: ApiService.formatPrice(item.price), fontSize: 14),
                                const SizedBox(height: HuashuTheme.space8),
                                
                                // ─── Kuantitas & Hapus ─────────────
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Container(
                                      decoration: BoxDecoration(
                                        border: Border.all(color: HuashuTheme.lightInkLine),
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: Row(
                                        children: [
                                          IconButton(
                                            icon: const Icon(Icons.remove, size: 16),
                                            padding: EdgeInsets.zero,
                                            constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                                            onPressed: () => _updateQuantity(item, -1),
                                          ),
                                          Text(
                                            '${item.quantity}',
                                            style: GoogleFonts.inter(fontWeight: FontWeight.bold),
                                          ),
                                          IconButton(
                                            icon: const Icon(Icons.add, size: 16),
                                            padding: EdgeInsets.zero,
                                            constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                                            onPressed: () => _updateQuantity(item, 1),
                                          ),
                                        ],
                                      ),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.delete_outline, color: HuashuTheme.stainedCinnabarRed),
                                      onPressed: () => _removeItem(item),
                                    ),
                                  ],
                                )
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
              
              // ─── Bottom Bar ───────────────────────────
              Container(
                padding: const EdgeInsets.all(HuashuTheme.space24),
                decoration: BoxDecoration(
                  color: HuashuTheme.xuanPaperBg,
                  border: const Border(top: BorderSide(color: HuashuTheme.lightInkLine)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 10,
                      offset: const Offset(0, -4),
                    )
                  ],
                ),
                child: SafeArea(
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'TOTAL BELANJA',
                              style: GoogleFonts.inter(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1.0,
                                color: HuashuTheme.charcoalBlack.withValues(alpha: 0.6),
                              ),
                            ),
                            const SizedBox(height: 2),
                            HuashuPrice(
                              price: ApiService.formatPrice(_cartProvider.totalAmount),
                              fontSize: 20,
                            ),
                          ],
                        ),
                      ),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: HuashuTheme.mineralJadeGreen,
                          padding: const EdgeInsets.symmetric(
                            horizontal: HuashuTheme.space32,
                            vertical: HuashuTheme.space16,
                          ),
                        ),
                        onPressed: _cartProvider.isLoading
                            ? null
                            : () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (_) => const CheckoutScreen()),
                                );
                              },
                        child: const Text('CHECKOUT'),
                      )
                    ],
                  ),
                ),
              )
            ],
          );
        },
      ),
    );
  }
}
