import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:dio/dio.dart';
import '../../../core/theme/huashu_theme.dart';
import '../../../core/theme/ink_brush_divider.dart';
import '../../../core/network/api_service.dart';

class AdminContentScreen extends StatefulWidget {
  const AdminContentScreen({super.key});

  @override
  State<AdminContentScreen> createState() => _AdminContentScreenState();
}

class _AdminContentScreenState extends State<AdminContentScreen> {
  final ApiService _api = ApiService();
  bool _isLoading = false;

  final _bannerTitleCtrl = TextEditingController();
  final _bannerLinkCtrl = TextEditingController();
  XFile? _bannerImage;

  final _categoryNameCtrl = TextEditingController();
  XFile? _categoryIcon;

  Future<void> _pickImage(bool isBanner) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        if (isBanner) {
          _bannerImage = pickedFile;
        } else {
          _categoryIcon = pickedFile;
        }
      });
    }
  }

  Future<void> _uploadBanner() async {
    if (_bannerTitleCtrl.text.isEmpty || _bannerImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Judul dan Gambar Banner wajib diisi!')));
      return;
    }

    setState(() => _isLoading = true);
    try {
      String fileName = _bannerImage!.name;
      FormData formData = FormData.fromMap({
        'title': _bannerTitleCtrl.text,
        'link_url': _bannerLinkCtrl.text,
        'image': MultipartFile.fromBytes(
          await _bannerImage!.readAsBytes(), 
          filename: fileName,
        ),
      });

      final response = await _api.dio.post('/api/admin/banners', data: formData);
      if (response.statusCode == 201) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Banner berhasil ditambahkan!')));
          setState(() {
            _bannerTitleCtrl.clear();
            _bannerLinkCtrl.clear();
            _bannerImage = null;
          });
        }
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Gagal menambah banner: $e')));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _uploadCategory() async {
    if (_categoryNameCtrl.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Nama Kategori wajib diisi!')));
      return;
    }

    setState(() => _isLoading = true);
    try {
      Map<String, dynamic> dataMap = {'name': _categoryNameCtrl.text};
      
      if (_categoryIcon != null) {
        String fileName = _categoryIcon!.name;
        dataMap['icon'] = MultipartFile.fromBytes(
          await _categoryIcon!.readAsBytes(), 
          filename: fileName,
        );
      }

      FormData formData = FormData.fromMap(dataMap);
      final response = await _api.dio.post('/api/admin/categories', data: formData);
      if (response.statusCode == 201) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Kategori berhasil ditambahkan!')));
          setState(() {
            _categoryNameCtrl.clear();
            _categoryIcon = null;
          });
        }
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Gagal menambah kategori: $e')));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Konten & Kategori', style: GoogleFonts.notoSerifSc(fontWeight: FontWeight.w600)),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: HuashuTheme.mineralJadeGreen))
          : ListView(
              padding: const EdgeInsets.all(24),
              children: [
                // ─── TAMBAH BANNER ──────────────────────────────────
                const HuashuSectionLabel(text: 'Tambah Banner Promo'),
                const SizedBox(height: 16),
                TextField(
                  controller: _bannerTitleCtrl,
                  decoration: const InputDecoration(labelText: 'Judul Banner'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _bannerLinkCtrl,
                  decoration: const InputDecoration(labelText: 'Link URL (Opsional)'),
                ),
                const SizedBox(height: 16),
                InkWell(
                  onTap: () => _pickImage(true),
                  child: Container(
                    height: 120,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      border: Border.all(color: HuashuTheme.lightInkLine),
                      borderRadius: BorderRadius.circular(8),
                      color: HuashuTheme.xuanPaperBg,
                    ),
                    child: _bannerImage != null
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: kIsWeb 
                                ? Image.network(_bannerImage!.path, fit: BoxFit.cover)
                                : Image.file(File(_bannerImage!.path), fit: BoxFit.cover),
                          )
                        : Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.add_photo_alternate_outlined, size: 40, color: Colors.grey),
                              const SizedBox(height: 8),
                              Text('Pilih Gambar Banner', style: GoogleFonts.inter(color: Colors.grey)),
                            ],
                          ),
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: HuashuTheme.mineralJadeGreen),
                  onPressed: _uploadBanner,
                  child: const Text('SIMPAN BANNER'),
                ),
                const SizedBox(height: 32),
                const InkBrushDivider(height: 1),
                const SizedBox(height: 32),

                // ─── TAMBAH KATEGORI ────────────────────────────────
                const HuashuSectionLabel(text: 'Tambah Kategori'),
                const SizedBox(height: 16),
                TextField(
                  controller: _categoryNameCtrl,
                  decoration: const InputDecoration(labelText: 'Nama Kategori'),
                ),
                const SizedBox(height: 16),
                InkWell(
                  onTap: () => _pickImage(false),
                  child: Container(
                    height: 100,
                    width: 100,
                    decoration: BoxDecoration(
                      border: Border.all(color: HuashuTheme.lightInkLine),
                      borderRadius: BorderRadius.circular(8),
                      color: HuashuTheme.xuanPaperBg,
                    ),
                    child: _categoryIcon != null
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: kIsWeb
                                ? Image.network(_categoryIcon!.path, fit: BoxFit.cover)
                                : Image.file(File(_categoryIcon!.path), fit: BoxFit.cover),
                          )
                        : Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.add_photo_alternate_outlined, size: 30, color: Colors.grey),
                              const SizedBox(height: 8),
                              Text('Ikon (Ops)', style: GoogleFonts.inter(fontSize: 10, color: Colors.grey)),
                            ],
                          ),
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: HuashuTheme.mineralJadeGreen),
                  onPressed: _uploadCategory,
                  child: const Text('SIMPAN KATEGORI'),
                ),
              ],
            ),
    );
  }
}
