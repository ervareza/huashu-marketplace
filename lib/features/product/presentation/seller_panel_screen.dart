import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../core/theme/huashu_theme.dart';
import '../../../core/theme/ink_brush_divider.dart';
import '../../../core/network/api_service.dart';

class SellerPanelScreen extends StatefulWidget {
  const SellerPanelScreen({super.key});

  @override
  State<SellerPanelScreen> createState() => _SellerPanelScreenState();
}

class _SellerPanelScreenState extends State<SellerPanelScreen> with SingleTickerProviderStateMixin {
  final _api = ApiService();
  late TabController _tabController;
  
  List<dynamic> _myProducts = [];
  bool _isLoadingProducts = true;
  String? _productsError;
  String? _mySellerId;

  // Form Controllers untuk Tambah/Edit Produk
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descController = TextEditingController();
  final _priceController = TextEditingController();
  final _stockController = TextEditingController();
  String _selectedCategory = 'Peralatan Rumah';
  final List<String> _categories = ['Electronic', 'Minuman', 'Peralatan Rumah', 'Kecantikan'];
  
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadSellerInfo();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _nameController.dispose();
    _descController.dispose();
    _priceController.dispose();
    _stockController.dispose();
    super.dispose();
  }

  Future<void> _loadSellerInfo() async {
    final sellerId = await _api.secureStorage.read(key: 'user_id');
    setState(() {
      _mySellerId = sellerId;
    });
    _fetchMyProducts();
  }

  Future<void> _fetchMyProducts() async {
    setState(() {
      _isLoadingProducts = true;
      _productsError = null;
    });

    try {
      // Ambil semua produk, lalu filter berdasarkan seller_id milik kita
      final response = await _api.dio.get('/api/products');
      final data = response.data;

      if (data is Map<String, dynamic> && response.statusCode == 200 && data['success'] == true) {
        final productsData = data['data'];
        if (productsData is List) {
          setState(() {
            // Filter berdasarkan seller_id (bisa int atau String dari API)
            _myProducts = productsData.where((p) {
              final sId = p['seller_id']?.toString();
              return sId == _mySellerId;
            }).toList();
          });
        }
      } else {
        setState(() {
          _productsError = data['message']?.toString() ?? 'Gagal mengambil produk Anda';
        });
      }
    } on DioException catch (e) {
      setState(() {
        _productsError = ApiService.extractErrorMessage(e, fallback: 'Gagal menghubungi server.');
      });
    } catch (e) {
      setState(() {
        _productsError = 'Kesalahan sistem: ${e.toString()}';
      });
    } finally {
      setState(() {
        _isLoadingProducts = false;
      });
    }
  }

  /// Membuat produk baru di server
  Future<void> _createProduct() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isSubmitting = true;
    });

    try {
      // 1x1 Transparent PNG bytes untuk melompati Multer multipart file upload di backend
      final dummyPngBytes = [
        137, 80, 78, 71, 13, 10, 26, 10, 0, 0, 0, 13, 73, 72, 68, 82, 0, 0, 0, 1,
        0, 0, 0, 1, 8, 6, 0, 0, 0, 31, 21, 108, 137, 0, 0, 0, 10, 73, 68, 65, 84,
        120, 156, 99, 0, 1, 0, 0, 5, 0, 1, 13, 10, 45, 180, 0, 0, 0, 0, 73, 69, 78, 68, 174, 66, 96, 130
      ];

      final multipartFile = MultipartFile.fromBytes(
        dummyPngBytes,
        filename: 'huashu_artwork.png',
        contentType: DioMediaType('image', 'png'),
      );

      final formData = FormData.fromMap({
        'name': _nameController.text.trim(),
        'description': _descController.text.trim(),
        'price': double.parse(_priceController.text.trim()),
        'stock': int.tryParse(_stockController.text.trim()) ?? 0,
        'category': _selectedCategory,
        'image_url': multipartFile,
      });

      final response = await _api.dio.post(
        '/api/products/create',
        data: formData,
        options: Options(contentType: 'multipart/form-data'),
      );

      final data = response.data;
      if (data is Map<String, dynamic> && (response.statusCode == 201 || data['success'] == true)) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Produk berhasil ditambahkan ke katalog'),
              backgroundColor: HuashuTheme.mineralJadeGreen,
            ),
          );
        }
        _clearForm();
        _tabController.animateTo(0);
        _fetchMyProducts();
      } else {
        _showErrorSnackBar(data['message']?.toString() ?? 'Gagal membuat produk');
      }
    } on DioException catch (e) {
      _showErrorSnackBar(ApiService.extractErrorMessage(e));
    } catch (e) {
      _showErrorSnackBar('Gagal menambahkan produk: ${e.toString()}');
    } finally {
      setState(() {
        _isSubmitting = false;
      });
    }
  }

  /// Menghapus produk dari server
  Future<void> _deleteProduct(dynamic productId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('HAPUS PRODUK'),
        content: const Text('Apakah Anda yakin ingin menghapus produk ini secara permanen dari galeri Anda?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('BATAL'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: HuashuTheme.stainedCinnabarRed),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('HAPUS'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      final response = await _api.dio.delete('/api/products/delete/$productId');
      final data = response.data;

      if (data is Map<String, dynamic> && data['success'] == true) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Produk berhasil dihapus dari galeri')),
          );
        }
        _fetchMyProducts();
      } else {
        _showErrorSnackBar(data['message']?.toString() ?? 'Gagal menghapus produk');
      }
    } on DioException catch (e) {
      _showErrorSnackBar(ApiService.extractErrorMessage(e));
    } catch (e) {
      _showErrorSnackBar('Gagal menghapus produk: ${e.toString()}');
    }
  }

  /// Mengedit produk (membuka dialog form edit)
  Future<void> _editProductDialog(Map<String, dynamic> product) async {
    final editNameCtrl = TextEditingController(text: product['name']?.toString());
    final editDescCtrl = TextEditingController(text: product['description']?.toString());
    
    // Parse price
    final parsedPrice = ApiService.parsePrice(product['price']);
    final editPriceCtrl = TextEditingController(text: parsedPrice.toInt().toString());
    final editStockCtrl = TextEditingController(text: product['stock']?.toString());
    
    String editCategory = product['category']?.toString() ?? 'Peralatan Rumah';
    if (!_categories.contains(editCategory)) {
      editCategory = _categories.first;
    }
    
    bool editIsActive = product['is_active'] == true;
    bool isSaving = false;

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            title: Text(
              'EDIT PRODUK',
              style: GoogleFonts.notoSerifSc(fontWeight: FontWeight.bold),
            ),
            content: SizedBox(
              width: MediaQuery.of(context).size.width * 0.9,
              child: SingleChildScrollView(
                child: Form(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextFormField(
                        controller: editNameCtrl,
                        decoration: const InputDecoration(
                          labelText: 'Nama Produk',
                          hintText: 'Masukkan nama produk',
                        ),
                      ),
                      const SizedBox(height: HuashuTheme.space12),
                      TextFormField(
                        controller: editDescCtrl,
                        maxLines: 2,
                        decoration: const InputDecoration(
                          labelText: 'Deskripsi',
                          hintText: 'Deskripsikan detail produk Anda',
                        ),
                      ),
                      const SizedBox(height: HuashuTheme.space12),
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: editPriceCtrl,
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(
                                labelText: 'Harga (Rp)',
                                hintText: '100000',
                              ),
                            ),
                          ),
                          const SizedBox(width: HuashuTheme.space12),
                          Expanded(
                            child: TextFormField(
                              controller: editStockCtrl,
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(
                                labelText: 'Stok',
                                hintText: '10',
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: HuashuTheme.space12),
                      DropdownButtonFormField<String>(
                        value: editCategory,
                        decoration: const InputDecoration(labelText: 'Kategori'),
                        items: _categories.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                        onChanged: (val) {
                          if (val != null) {
                            setDialogState(() => editCategory = val);
                          }
                        },
                      ),
                      const SizedBox(height: HuashuTheme.space16),
                      SwitchListTile(
                        title: const Text('Status Aktif di Galeri'),
                        subtitle: const Text('Nonaktifkan untuk menyembunyikan dari katalog pembeli'),
                        value: editIsActive,
                        activeColor: HuashuTheme.mineralJadeGreen,
                        onChanged: (val) {
                          setDialogState(() => editIsActive = val);
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: isSaving ? null : () => Navigator.pop(ctx),
                child: const Text('BATAL'),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: HuashuTheme.charcoalBlack,
                  foregroundColor: HuashuTheme.xuanPaperBg,
                ),
                onPressed: isSaving
                    ? null
                    : () async {
                        setDialogState(() => isSaving = true);
                        try {
                          final formData = FormData.fromMap({
                            'name': editNameCtrl.text.trim(),
                            'description': editDescCtrl.text.trim(),
                            'price': double.parse(editPriceCtrl.text.trim()),
                            'stock': int.tryParse(editStockCtrl.text.trim()) ?? 0,
                            'category': editCategory,
                            'is_active': editIsActive,
                          });

                          final response = await _api.dio.put(
                            '/api/products/update/${product['id']}',
                            data: formData,
                            options: Options(contentType: 'multipart/form-data'),
                          );

                          final resData = response.data;
                          if (resData is Map<String, dynamic> && resData['success'] == true) {
                            if (ctx.mounted) {
                              ScaffoldMessenger.of(ctx).showSnackBar(
                                const SnackBar(content: Text('Produk berhasil diperbarui')),
                              );
                              Navigator.pop(ctx);
                            }
                            _fetchMyProducts();
                          } else {
                            _showErrorSnackBar(resData['message']?.toString() ?? 'Gagal memperbarui produk');
                          }
                        } on DioException catch (e) {
                          _showErrorSnackBar(ApiService.extractErrorMessage(e));
                        } catch (e) {
                          _showErrorSnackBar('Gagal memperbarui: ${e.toString()}');
                        } finally {
                          if (ctx.mounted) {
                            setDialogState(() => isSaving = false);
                          }
                        }
                      },
                child: isSaving
                    ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 1.5, color: Colors.white))
                    : const Text('SIMPAN'),
              ),
            ],
          );
        },
      ),
    );
    
    editNameCtrl.dispose();
    editDescCtrl.dispose();
    editPriceCtrl.dispose();
    editStockCtrl.dispose();
  }

  void _clearForm() {
    _nameController.clear();
    _descController.clear();
    _priceController.clear();
    _stockController.clear();
    setState(() {
      _selectedCategory = 'Peralatan Rumah';
    });
  }

  void _showErrorSnackBar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: HuashuTheme.stainedCinnabarRed,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'KELOLA PRODUK SAYA',
          style: GoogleFonts.notoSerifSc(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: HuashuTheme.charcoalBlack,
          ),
        ),
        bottom: TabBar(
          controller: _tabController,
          labelColor: HuashuTheme.charcoalBlack,
          unselectedLabelColor: HuashuTheme.charcoalBlack.withValues(alpha: 0.4),
          indicatorColor: HuashuTheme.charcoalBlack,
          indicatorSize: TabBarIndicatorSize.tab,
          tabs: const [
            Tab(icon: Icon(Icons.palette_outlined), text: 'Galeri Saya'),
            Tab(icon: Icon(Icons.add_photo_alternate_outlined), text: 'Tambah Produk'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildMyProductsTab(),
          _buildAddProductTab(),
        ],
      ),
    );
  }

  Widget _buildMyProductsTab() {
    if (_isLoadingProducts) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_productsError != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(HuashuTheme.space24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const HuashuSeal(character: '誤'),
              const SizedBox(height: HuashuTheme.space16),
              Text(
                _productsError!,
                textAlign: TextAlign.center,
                style: const TextStyle(color: HuashuTheme.stainedCinnabarRed),
              ),
              const SizedBox(height: HuashuTheme.space16),
              ElevatedButton(
                onPressed: _fetchMyProducts,
                child: const Text('COBA LAGI'),
              ),
            ],
          ),
        ),
      );
    }

    if (_myProducts.isEmpty) {
      return const HuashuEmptyState(
        icon: Icons.palette_outlined,
        message: 'Daftar produk Anda kosong.\nTambahkan produk pertama Anda sekarang.',
      );
    }

    return RefreshIndicator(
      onRefresh: _fetchMyProducts,
      child: ListView.separated(
        padding: const EdgeInsets.all(HuashuTheme.space24),
        itemCount: _myProducts.length,
        separatorBuilder: (_, __) => const Column(
          children: [
            SizedBox(height: HuashuTheme.space8),
            InkBrushDivider(height: 12),
            SizedBox(height: HuashuTheme.space8),
          ],
        ),
        itemBuilder: (context, index) {
          final p = _myProducts[index];
          final price = ApiService.parsePrice(p['price']);
          final stock = p['stock'] ?? 0;
          final isActive = p['is_active'] == true;
          final name = p['name']?.toString() ?? 'Produk';
          final initial = name.isNotEmpty ? name[0] : '墨';

          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Cover Produk
              Container(
                width: 90,
                height: 90,
                decoration: BoxDecoration(
                  border: Border.all(color: HuashuTheme.lightInkLine, width: HuashuTheme.hairline),
                ),
                child: CachedNetworkImage(
                  imageUrl: ApiService.sanitizeImageUrl(p['image_url']?.toString()),
                  fit: BoxFit.cover,
                  errorWidget: (_, __, ___) => Container(
                    color: HuashuTheme.warmStone,
                    child: Center(
                      child: Text(
                        initial,
                        style: GoogleFonts.notoSerifSc(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: HuashuTheme.stainedCinnabarRed.withValues(alpha: 0.7),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: HuashuTheme.space16),
              // Detail Deskripsi
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.notoSerifSc(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: HuashuTheme.charcoalBlack,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      p['category']?.toString() ?? 'Lain-lain',
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                    const SizedBox(height: 4),
                    HuashuPrice(price: ApiService.formatPrice(price), fontSize: 14),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        HuashuStampBadge(
                          label: 'Stok: $stock',
                          color: stock > 0 ? HuashuTheme.mineralJadeGreen : HuashuTheme.stainedCinnabarRed,
                        ),
                        const SizedBox(width: 8),
                        HuashuStampBadge(
                          label: isActive ? 'AKTIF' : 'NONAKTIF',
                          color: isActive ? HuashuTheme.charcoalBlack : Colors.grey,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              // Aksi Edit & Hapus
              Column(
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit_outlined, size: 20),
                    tooltip: 'Edit Produk',
                    onPressed: () => _editProductDialog(p),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete_outline, size: 20, color: HuashuTheme.stainedCinnabarRed),
                    tooltip: 'Hapus Produk',
                    onPressed: () => _deleteProduct(p['id']),
                  ),
                ],
              )
            ],
          );
        },
      ),
    );
  }

  Widget _buildAddProductTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(HuashuTheme.space24),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'TAMBAH PRODUK BARU',
              style: GoogleFonts.notoSerifSc(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.5,
                color: HuashuTheme.charcoalBlack,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'Tambahkan produk baru Anda ke dalam katalog untuk mulai berjualan.',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
            const SizedBox(height: 8),
            const InkBrushDivider(height: 16),
            const SizedBox(height: HuashuTheme.space12),

            // Form inputs
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'NAMA PRODUK',
                hintText: 'contoh: Teko Teh Keramik Zisha Yixing',
              ),
              validator: (val) {
                if (val == null || val.trim().isEmpty) {
                  return 'Nama produk tidak boleh kosong';
                }
                return null;
              },
            ),
            const SizedBox(height: HuashuTheme.space16),

            TextFormField(
              controller: _descController,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'DESKRIPSI ESTETIKA',
                hintText: 'Deskripsikan bahan, makna gubahan, dan guratan seninya...',
              ),
              validator: (val) {
                if (val == null || val.trim().isEmpty) {
                  return 'Deskripsi produk tidak boleh kosong';
                }
                return null;
              },
            ),
            const SizedBox(height: HuashuTheme.space16),

            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _priceController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'HARGA JUAL (RP)',
                      hintText: 'contoh: 250000',
                    ),
                    validator: (val) {
                      if (val == null || val.trim().isEmpty) {
                        return 'Harga tidak boleh kosong';
                      }
                      if (double.tryParse(val.trim()) == null) {
                        return 'Format nominal salah';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: HuashuTheme.space16),
                Expanded(
                  child: TextFormField(
                    controller: _stockController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'STOK PRODUK',
                      hintText: 'contoh: 5',
                    ),
                    validator: (val) {
                      if (val == null || val.trim().isEmpty) {
                        return 'Stok tidak boleh kosong';
                      }
                      if (int.tryParse(val.trim()) == null) {
                        return 'Format stok salah';
                      }
                      return null;
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: HuashuTheme.space16),

            DropdownButtonFormField<String>(
              value: _selectedCategory,
              decoration: const InputDecoration(
                labelText: 'KATEGORI PRODUK',
              ),
              items: _categories.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
              onChanged: (val) {
                if (val != null) {
                  setState(() {
                    _selectedCategory = val;
                  });
                }
              },
            ),
            const SizedBox(height: HuashuTheme.space24),

            // Indikasi mock image
            Container(
              padding: const EdgeInsets.all(HuashuTheme.space16),
              decoration: BoxDecoration(
                color: HuashuTheme.warmStone,
                border: Border.all(color: HuashuTheme.lightInkLine, width: HuashuTheme.hairline),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.auto_awesome,
                    color: HuashuTheme.stainedCinnabarRed,
                  ),
                  const SizedBox(width: HuashuTheme.space12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'MOCK IMAGE UPLOADER AKTIF',
                          style: GoogleFonts.notoSerifSc(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: HuashuTheme.charcoalBlack,
                          ),
                        ),
                        const SizedBox(height: 2),
                        const Text(
                          'Sistem otomatis memproses upload 1x1 PNG. Di halaman depan, inisial produk akan ditampilkan sebagai visual representasi produk Anda.',
                          style: TextStyle(fontSize: 10, color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: HuashuTheme.space24),

            // Tombol Submit
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: HuashuTheme.charcoalBlack,
                  foregroundColor: HuashuTheme.xuanPaperBg,
                ),
                onPressed: _isSubmitting ? null : _createProduct,
                child: _isSubmitting
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                      )
                    : Text(
                        'SIMPAN PRODUK',
                        style: GoogleFonts.notoSerifSc(
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.5,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
