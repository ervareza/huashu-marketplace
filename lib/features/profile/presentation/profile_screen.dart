import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/huashu_theme.dart';
import '../../../core/theme/ink_brush_divider.dart';
import '../../../core/network/api_service.dart';
import 'address_screen.dart';
import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:image_picker/image_picker.dart';
import 'package:dio/dio.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../auth/presentation/login_screen.dart';
import '../../chat/presentation/chat_list_screen.dart';
import '../../order/presentation/voucher_screen.dart';
import '../../order/presentation/cart_provider.dart';
import '../../product/presentation/wishlist_provider.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final ApiService _api = ApiService();
  bool _isLoading = true;
  Map<String, dynamic>? _profile;

  @override
  void initState() {
    super.initState();
    _fetchProfile();
  }

  Future<void> _fetchProfile() async {
    setState(() => _isLoading = true);
    try {
      final response = await _api.dio.get('/api/users/profile');
      if (response.statusCode == 200 && response.data['success'] == true) {
        setState(() {
          _profile = response.data['data'];
        });
      }
    } catch (e) {
      debugPrint("Gagal mengambil profil: $e");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showEditProfileDialog() {
    final formKey = GlobalKey<FormState>();
    final nameCtrl = TextEditingController(text: _profile?['name']?.toString() ?? '');
    final phoneCtrl = TextEditingController(text: _profile?['phone']?.toString() ?? '');
    XFile? avatarFile;
    bool isSaving = false;

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
              child: Form(
                key: formKey,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('Edit Profil', style: GoogleFonts.notoSerifSc(fontSize: 20, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 16),
                      GestureDetector(
                        onTap: () async {
                          final picker = ImagePicker();
                          final pickedFile = await picker.pickImage(source: ImageSource.gallery);
                          if (pickedFile != null) {
                            setModalState(() => avatarFile = pickedFile);
                          }
                        },
                        child: CircleAvatar(
                          radius: 40,
                          backgroundColor: HuashuTheme.mineralJadeGreen.withValues(alpha: 0.1),
                          backgroundImage: avatarFile != null 
                              ? (kIsWeb ? NetworkImage(avatarFile!.path) : FileImage(File(avatarFile!.path)) as ImageProvider)
                              : (_profile?['avatar_url'] != null ? NetworkImage(ApiService.sanitizeImageUrl(_profile!['avatar_url'])) : null),
                          child: avatarFile == null && _profile?['avatar_url'] == null
                              ? const Icon(Icons.add_a_photo, color: HuashuTheme.mineralJadeGreen)
                              : null,
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: nameCtrl,
                        decoration: const InputDecoration(labelText: 'Nama Lengkap'),
                        validator: (v) => v!.isEmpty ? 'Wajib diisi' : null,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: phoneCtrl,
                        decoration: const InputDecoration(labelText: 'Nomor HP'),
                        keyboardType: TextInputType.phone,
                      ),
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: HuashuTheme.mineralJadeGreen,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                          onPressed: isSaving ? null : () async {
                            if (!formKey.currentState!.validate()) return;
                            setModalState(() => isSaving = true);
                            
                            try {
                              Map<String, dynamic> dataMap = {
                                'name': nameCtrl.text,
                                'phone': phoneCtrl.text,
                              };

                              if (avatarFile != null) {
                                dataMap['avatar'] = MultipartFile.fromBytes(
                                  await avatarFile!.readAsBytes(),
                                  filename: avatarFile!.name,
                                );
                              }

                              final formData = FormData.fromMap(dataMap);
                              final response = await _api.dio.put('/api/users/profile', data: formData);

                              if (response.statusCode == 200) {
                                if (ctx.mounted) Navigator.pop(ctx);
                                _fetchProfile();
                              }
                            } catch (e) {
                              if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Gagal memperbarui profil')));
                            } finally {
                              if (mounted) setModalState(() => isSaving = false);
                            }
                          },
                          child: isSaving 
                              ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white))
                              : const Text('SIMPAN PROFIL'),
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _logout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('KELUAR', style: GoogleFonts.notoSerifSc(fontWeight: FontWeight.bold)),
        content: const Text('Apakah Anda yakin ingin keluar dari akun ini?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('BATAL', style: TextStyle(color: HuashuTheme.charcoalBlack)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('KELUAR', style: TextStyle(color: HuashuTheme.stainedCinnabarRed)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      CartProvider().clearLocal();
      WishlistProvider().clearLocal();
      await _api.secureStorage.deleteAll();
      if (mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const LoginScreen()),
          (route) => false,
        );
      }
    }
  }

  Future<void> _deleteAccount() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('HAPUS AKUN', style: GoogleFonts.notoSerifSc(fontWeight: FontWeight.bold, color: HuashuTheme.stainedCinnabarRed)),
        content: const Text('Apakah Anda yakin ingin menghapus akun secara permanen? Semua data akan hilang dan tidak dapat dikembalikan.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('BATAL', style: TextStyle(color: HuashuTheme.charcoalBlack)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('HAPUS PERMANEN', style: TextStyle(color: HuashuTheme.stainedCinnabarRed)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      setState(() => _isLoading = true);
      try {
        final response = await _api.dio.delete('/api/users/profile');
        if (response.statusCode == 200) {
          CartProvider().clearLocal();
          WishlistProvider().clearLocal();
          await _api.secureStorage.deleteAll();
          if (mounted) {
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (_) => const LoginScreen()),
              (route) => false,
            );
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Akun berhasil dihapus')));
          }
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(ApiService.extractErrorMessage(e as DioException))));
          setState(() => _isLoading = false);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Profil Saya',
          style: GoogleFonts.notoSerifSc(fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: HuashuTheme.mineralJadeGreen))
          : _profile == null
              ? Center(
                  child: Text(
                    'Gagal memuat profil',
                    style: GoogleFonts.inter(color: HuashuTheme.charcoalBlack.withValues(alpha: 0.6)),
                  ),
                )
              : ListView(
                  padding: const EdgeInsets.all(HuashuTheme.space24),
                  children: [
                    // ─── Header Profil ───────────────────
                    Center(
                      child: Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          color: HuashuTheme.mineralJadeGreen.withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                          border: Border.all(color: HuashuTheme.mineralJadeGreen, width: 2),
                        ),
                        child: _profile?['avatar_url'] != null
                            ? ClipOval(
                                child: CachedNetworkImage(
                                  imageUrl: ApiService.sanitizeImageUrl(_profile!['avatar_url']),
                                  width: 100,
                                  height: 100,
                                  fit: BoxFit.cover,
                                ),
                              )
                            : Center(
                                child: Text(
                                  _profile!['name']?.substring(0, 1).toUpperCase() ?? 'U',
                                  style: GoogleFonts.notoSerifSc(
                                    fontSize: 40,
                                    fontWeight: FontWeight.bold,
                                    color: HuashuTheme.mineralJadeGreen,
                                  ),
                                ),
                              ),
                      ),
                    ),
                    const SizedBox(height: HuashuTheme.space16),
                    Center(
                      child: Text(
                        _profile!['name'] ?? 'User',
                        style: GoogleFonts.notoSerifSc(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Center(
                      child: Text(
                        _profile!['email'] ?? '',
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          color: HuashuTheme.charcoalBlack.withValues(alpha: 0.5),
                        ),
                      ),
                    ),
                    const SizedBox(height: HuashuTheme.space32),
                    const InkBrushDivider(height: 1),
                    const SizedBox(height: HuashuTheme.space16),

                    // ─── Menu ─────────────────────────────
                    ListTile(
                      leading: const Icon(Icons.location_on_outlined, color: HuashuTheme.charcoalBlack),
                      title: Text('Daftar Alamat', style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
                      subtitle: Text('Kelola alamat pengiriman Anda', style: GoogleFonts.inter(fontSize: 12)),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const AddressScreen()),
                        );
                      },
                    ),
                    ListTile(
                      leading: const Icon(Icons.edit_outlined, color: HuashuTheme.charcoalBlack),
                      title: Text('Edit Profil', style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
                      subtitle: Text('Ubah nama dan nomor HP', style: GoogleFonts.inter(fontSize: 12)),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: _showEditProfileDialog,
                    ),
                    ListTile(
                      leading: const Icon(Icons.chat_bubble_outline, color: HuashuTheme.charcoalBlack),
                      title: Text('Pesan (Chat)', style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
                      subtitle: Text('Hubungi penjual atau pembeli', style: GoogleFonts.inter(fontSize: 12)),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const ChatListScreen()),
                        );
                      },
                    ),
                    ListTile(
                      leading: const Icon(Icons.local_activity_outlined, color: HuashuTheme.charcoalBlack),
                      title: Text('Voucher Saya', style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
                      subtitle: Text('Klaim dan gunakan diskon', style: GoogleFonts.inter(fontSize: 12)),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const VoucherScreen(isSelectionMode: false)),
                        );
                      },
                    ),
                    ListTile(
                      leading: const Icon(Icons.logout, color: HuashuTheme.charcoalBlack),
                      title: Text('Keluar', style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
                      onTap: _logout,
                    ),
                    ListTile(
                      leading: const Icon(Icons.delete_forever, color: HuashuTheme.stainedCinnabarRed),
                      title: Text('Hapus Akun', style: GoogleFonts.inter(fontWeight: FontWeight.w600, color: HuashuTheme.stainedCinnabarRed)),
                      subtitle: Text('Hapus akun secara permanen', style: GoogleFonts.inter(fontSize: 12, color: HuashuTheme.stainedCinnabarRed.withValues(alpha: 0.8))),
                      onTap: _deleteAccount,
                    ),
                  ],
                ),
    );
  }
}
