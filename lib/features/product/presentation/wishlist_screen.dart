import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../core/theme/huashu_theme.dart';
import '../../../core/network/api_service.dart';
import 'wishlist_provider.dart';
import 'product_detail_screen.dart';

class WishlistScreen extends StatefulWidget {
  const WishlistScreen({super.key});

  @override
  State<WishlistScreen> createState() => _WishlistScreenState();
}

class _WishlistScreenState extends State<WishlistScreen> {
  final WishlistProvider _wishlistProvider = WishlistProvider();

  @override
  void initState() {
    super.initState();
    _wishlistProvider.fetchWishlist();
  }

  void _removeWishlist(int productId, String name) async {
    final success = await _wishlistProvider.toggleWishlist(productId);
    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('$name dihapus dari favorit'),
          backgroundColor: HuashuTheme.charcoalBlack,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Favorit Saya',
          style: GoogleFonts.notoSerifSc(fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
      ),
      body: AnimatedBuilder(
        animation: _wishlistProvider,
        builder: (context, _) {
          if (_wishlistProvider.isLoading && _wishlistProvider.items.isEmpty) {
            return const Center(
              child: CircularProgressIndicator(color: HuashuTheme.mineralJadeGreen),
            );
          }

          if (_wishlistProvider.items.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.favorite_border,
                    size: 80,
                    color: HuashuTheme.charcoalBlack.withValues(alpha: 0.2),
                  ),
                  const SizedBox(height: HuashuTheme.space16),
                  Text(
                    'Belum Ada Favorit',
                    style: GoogleFonts.notoSerifSc(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: HuashuTheme.charcoalBlack.withValues(alpha: 0.6),
                    ),
                  ),
                  const SizedBox(height: HuashuTheme.space8),
                  Text(
                    'Simpan produk yang Anda sukai di sini',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      color: HuashuTheme.charcoalBlack.withValues(alpha: 0.4),
                    ),
                  ),
                ],
              ),
            );
          }

          return GridView.builder(
            padding: const EdgeInsets.all(HuashuTheme.space16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 0.7,
            ),
            itemCount: _wishlistProvider.items.length,
            itemBuilder: (context, index) {
              final item = _wishlistProvider.items[index];
              return InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ProductDetailScreen(
                        product: {
                          'id': item.productId,
                          'name': item.name,
                          'description': item.description,
                          'image_url': item.imageUrl,
                        },
                        priceDouble: item.price,
                      ),
                    ),
                  );
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: HuashuTheme.xuanPaperBg,
                    border: Border.all(color: HuashuTheme.lightInkLine),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: ClipRRect(
                          borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
                          child: CachedNetworkImage(
                            imageUrl: ApiService.sanitizeImageUrl(item.imageUrl),
                            width: double.infinity,
                            fit: BoxFit.cover,
                            errorWidget: (context, url, error) => Container(
                              color: HuashuTheme.warmStone,
                              child: const Icon(Icons.image_not_supported, color: Colors.white),
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.name,
                              style: GoogleFonts.inter(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            HuashuPrice(price: ApiService.formatPrice(item.price), fontSize: 14),
                            const SizedBox(height: 8),
                            Align(
                              alignment: Alignment.centerRight,
                              child: IconButton(
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(),
                                icon: const Icon(Icons.favorite, color: HuashuTheme.stainedCinnabarRed),
                                onPressed: () => _removeWishlist(item.productId, item.name),
                              ),
                            )
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
