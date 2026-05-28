import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:image_picker/image_picker.dart';
import 'package:dio/dio.dart';
import '../../../core/theme/huashu_theme.dart';
import '../../../core/theme/ink_brush_divider.dart';
import '../../../core/network/api_service.dart';
import '../../order/presentation/cart_provider.dart';
import 'wishlist_provider.dart';

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
  final ApiService _api = ApiService();
  int _quantity = 1;

  List<dynamic> _reviews = [];
  bool _isLoadingReviews = true;

  @override
  void initState() {
    super.initState();
    _fetchReviews();
  }

  Future<void> _fetchReviews() async {
    setState(() => _isLoadingReviews = true);
    try {
      final response = await _api.dio.get('/api/products/${widget.product['id']}/reviews');
      if (response.statusCode == 200 && response.data['success'] == true) {
        setState(() {
          _reviews = response.data['data'] ?? [];
        });
      }
    } catch (e) {
      debugPrint("Gagal fetch reviews: $e");
    } finally {
      if (mounted) setState(() => _isLoadingReviews = false);
    }
  }

  void _addToCart() async {
    final success = await CartProvider().addToCart(widget.product['id'], _quantity);
    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${widget.product['name']} ditambahkan ke keranjang'),
          backgroundColor: HuashuTheme.mineralJadeGreen,
        ),
      );
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Gagal menambahkan ke keranjang'),
          backgroundColor: HuashuTheme.stainedCinnabarRed,
        ),
      );
    }
  }

  void _showAddReviewDialog() {
    int rating = 5;
    final commentCtrl = TextEditingController();
    XFile? imageFile;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: HuashuTheme.xuanPaperBg,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(ctx).viewInsets.bottom,
                left: 24,
                right: 24,
                top: 24,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Tulis Ulasan', style: GoogleFonts.notoSerifSc(fontSize: 20, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(5, (index) {
                        return IconButton(
                          icon: Icon(
                            index < rating ? Icons.star : Icons.star_border,
                            color: Colors.amber,
                            size: 32,
                          ),
                          onPressed: () => setModalState(() => rating = index + 1),
                        );
                      }),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: commentCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Ulasan (Opsional)',
                        border: OutlineInputBorder(),
                      ),
                      maxLines: 3,
                    ),
                    const SizedBox(height: 16),
                    InkWell(
                      onTap: () async {
                        final picker = ImagePicker();
                        final pickedFile = await picker.pickImage(source: ImageSource.gallery);
                        if (pickedFile != null) {
                          setModalState(() => imageFile = pickedFile);
                        }
                      },
                      child: Container(
                        height: 100,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          border: Border.all(color: HuashuTheme.lightInkLine),
                          borderRadius: BorderRadius.circular(8),
                          color: HuashuTheme.xuanPaperBg,
                        ),
                        child: imageFile != null
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: kIsWeb
                                    ? Image.network(imageFile!.path, fit: BoxFit.cover)
                                    : Image.file(File(imageFile!.path), fit: BoxFit.cover),
                              )
                            : Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(Icons.add_photo_alternate_outlined, size: 30, color: Colors.grey),
                                  const SizedBox(height: 8),
                                  Text('Tambah Foto (Opsional)', style: GoogleFonts.inter(fontSize: 12, color: Colors.grey)),
                                ],
                              ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: HuashuTheme.mineralJadeGreen,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        onPressed: () async {
                          Navigator.pop(ctx);
                          _submitReview(rating, commentCtrl.text, imageFile);
                        },
                        child: const Text('KIRIM ULASAN'),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _submitReview(int rating, String comment, XFile? image) async {
    try {
      Map<String, dynamic> dataMap = {
        'rating': rating,
        'comment': comment,
      };

      if (image != null) {
        String fileName = image.name;
        dataMap['image'] = MultipartFile.fromBytes(
          await image.readAsBytes(),
          filename: fileName,
        );
      }

      FormData formData = FormData.fromMap(dataMap);
      final response = await _api.dio.post('/api/products/${widget.product['id']}/reviews', data: formData);

      if (response.statusCode == 201) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Ulasan berhasil ditambahkan!')));
          _fetchReviews();
        }
      }
    } on DioException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(ApiService.extractErrorMessage(e))));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Gagal menambah ulasan: $e')));
      }
    }
  }

  Widget _buildStars(int rating) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (index) {
        return Icon(
          index < rating ? Icons.star : Icons.star_border,
          color: Colors.amber,
          size: 16,
        );
      }),
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
                  // ─── Gambar Utama ───────────────────────────
                  Container(
                    width: double.infinity,
                    height: 300,
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: HuashuTheme.lightInkLine,
                        width: HuashuTheme.hairline,
                      ),
                      color: HuashuTheme.xuanPaperBg,
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(HuashuTheme.space8),
                      child: ClipRect(
                        child: CachedNetworkImage(
                          imageUrl: ApiService.sanitizeImageUrl(p['image_url']?.toString()),
                          fit: BoxFit.cover,
                          errorWidget: (context, url, error) => Container(
                            color: HuashuTheme.warmStone,
                            child: const Icon(Icons.broken_image, size: 50, color: Colors.white),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: HuashuTheme.space24),

                  // ─── Label Kategori ─────────────────────────
                  HuashuSectionLabel(text: p['category']?.toString() ?? ''),
                  const SizedBox(height: HuashuTheme.space8),

                  // ─── Nama Produk & Wishlist ───────────────
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          p['name']?.toString() ?? '',
                          style: Theme.of(context).textTheme.headlineMedium,
                        ),
                      ),
                      AnimatedBuilder(
                        animation: WishlistProvider(),
                        builder: (ctx, _) {
                          final isSaved = WishlistProvider().isWishlisted(p['id']);
                          return IconButton(
                            icon: Icon(
                              isSaved ? Icons.favorite : Icons.favorite_border,
                              color: isSaved ? HuashuTheme.stainedCinnabarRed : HuashuTheme.charcoalBlack.withValues(alpha: 0.5),
                              size: 28,
                            ),
                            onPressed: () async {
                              final success = await WishlistProvider().toggleWishlist(p['id']);
                              if (success && context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(isSaved ? 'Dihapus dari favorit' : 'Ditambahkan ke favorit'),
                                    backgroundColor: HuashuTheme.charcoalBlack,
                                  ),
                                );
                              }
                            },
                          );
                        }
                      ),
                    ],
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
                    const SizedBox(height: HuashuTheme.space24),
                  ],

                  const InkBrushDivider(height: 2.0),
                  const SizedBox(height: HuashuTheme.space24),

                  // ─── Ulasan (Reviews) ────────────────────────
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const HuashuSectionLabel(text: 'Ulasan Pembeli'),
                      TextButton(
                        onPressed: _showAddReviewDialog,
                        child: const Text('Tulis Ulasan', style: TextStyle(color: HuashuTheme.mineralJadeGreen)),
                      )
                    ],
                  ),
                  const SizedBox(height: 12),
                  
                  if (_isLoadingReviews)
                    const Center(child: Padding(padding: EdgeInsets.all(16), child: CircularProgressIndicator(color: HuashuTheme.mineralJadeGreen)))
                  else if (_reviews.isEmpty)
                    Text('Belum ada ulasan untuk produk ini.', style: GoogleFonts.inter(color: Colors.grey))
                  else
                    Column(
                      children: _reviews.map((review) {
                        return Container(
                          margin: const EdgeInsets.only(bottom: 16),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            border: Border.all(color: HuashuTheme.lightInkLine),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  CircleAvatar(
                                    backgroundColor: HuashuTheme.warmStone,
                                    radius: 14,
                                    child: const Icon(Icons.person, size: 16, color: Colors.white),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      review['user']?['name'] ?? 'User',
                                      style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 12),
                                    ),
                                  ),
                                  Text(
                                    review['created_at'] != null ? review['created_at'].split('T')[0] : '',
                                    style: GoogleFonts.inter(fontSize: 10, color: Colors.grey),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              _buildStars(review['rating'] ?? 5),
                              if (review['comment'] != null && review['comment'].toString().isNotEmpty) ...[
                                const SizedBox(height: 8),
                                Text(review['comment'], style: GoogleFonts.inter(fontSize: 13)),
                              ],
                              if (review['image_url'] != null) ...[
                                const SizedBox(height: 8),
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(4),
                                  child: CachedNetworkImage(
                                    imageUrl: ApiService.sanitizeImageUrl(review['image_url']),
                                    height: 80,
                                    width: 80,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ]
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  
                  const SizedBox(height: HuashuTheme.space32),
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
                // Counter & Total
                Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'TOTAL',
                      style: GoogleFonts.inter(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.0,
                        color: HuashuTheme.charcoalBlack.withValues(alpha: 0.6),
                      ),
                    ),
                    const SizedBox(height: 2),
                    HuashuPrice(
                      price: ApiService.formatPrice(widget.priceDouble * _quantity),
                      fontSize: 16,
                    ),
                    const SizedBox(height: HuashuTheme.space8),
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
                            onPressed: () {
                              final stock = (p['stock'] as num?)?.toInt() ?? 0;
                              if (_quantity < stock) {
                                setState(() => _quantity++);
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('Maksimal stok tercapai: $stock')),
                                );
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: HuashuTheme.space24),
                // Tombol Beli
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      backgroundColor: HuashuTheme.charcoalBlack,
                      foregroundColor: HuashuTheme.xuanPaperBg,
                      shape: const BeveledRectangleBorder(),
                    ),
                    onPressed: _addToCart,
                    child: Text(
                      'TAMBAH KERANJANG',
                      style: GoogleFonts.notoSerifSc(
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.2,
                        fontSize: 14,
                      ),
                    ),
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
