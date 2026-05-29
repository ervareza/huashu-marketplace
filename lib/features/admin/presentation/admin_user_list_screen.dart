import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:dio/dio.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../core/theme/huashu_theme.dart';
import '../../../core/theme/ink_brush_divider.dart';
import '../../../core/network/api_service.dart';

class AdminUserListScreen extends StatefulWidget {
  const AdminUserListScreen({super.key});

  @override
  State<AdminUserListScreen> createState() => _AdminUserListScreenState();
}

class _AdminUserListScreenState extends State<AdminUserListScreen> {
  final ApiService _api = ApiService();
  bool _isLoading = true;
  List<dynamic> _users = [];
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchUsers();
  }

  Future<void> _fetchUsers() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final response = await _api.dio.get('/api/admin/users');
      if (response.statusCode == 200 && response.data['success'] == true) {
        setState(() {
          _users = response.data['data'] ?? [];
        });
      } else {
        setState(() => _errorMessage = response.data['message']);
      }
    } on DioException catch (e) {
      setState(() => _errorMessage = ApiService.extractErrorMessage(e));
    } catch (e) {
      setState(() => _errorMessage = 'Gagal memuat pengguna: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _toggleBanStatus(int userId, bool currentStatus) async {
    try {
      final response = await _api.dio.put('/api/admin/users/$userId/ban');
      if (response.statusCode == 200) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Status pengguna berhasil diubah')),
          );
          _fetchUsers();
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal mengubah status: $e')),
        );
      }
    }
  }

  Future<void> _changeRole(int userId, String newRole) async {
    try {
      final response = await _api.dio.put('/api/admin/users/$userId/role', data: {'role': newRole});
      if (response.statusCode == 200) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Role berhasil diubah')),
          );
          _fetchUsers();
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal mengubah role: $e')),
        );
      }
    }
  }

  void _showRoleDialog(int userId, String currentRole) {
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: Text('Ubah Role Pengguna', style: GoogleFonts.notoSerifSc(fontWeight: FontWeight.bold)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: ['customer', 'seller', 'admin'].map((role) {
              return RadioListTile<String>(
                title: Text(role.toUpperCase()),
                value: role,
                groupValue: currentRole,
                onChanged: (val) {
                  Navigator.pop(ctx);
                  if (val != null && val != currentRole) {
                    _changeRole(userId, val);
                  }
                },
              );
            }).toList(),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'MANAJEMEN PENGGUNA',
          style: GoogleFonts.notoSerifSc(
            fontWeight: FontWeight.w600,
            fontSize: 20,
            letterSpacing: 2.0,
          ),
        ),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? Center(child: Text(_errorMessage!, style: const TextStyle(color: Colors.red)))
              : RefreshIndicator(
                  onRefresh: _fetchUsers,
                  color: HuashuTheme.charcoalBlack,
                  child: ListView.separated(
                    padding: const EdgeInsets.all(HuashuTheme.space16),
                    itemCount: _users.length,
                    separatorBuilder: (_, __) => const InkBrushDivider(),
                    itemBuilder: (context, index) {
                      final user = _users[index];
                      final bool isActive = user['is_active'] ?? true;
                      
                      return ListTile(
                        leading: CircleAvatar(
                          backgroundImage: user['avatar_url'] != null
                              ? CachedNetworkImageProvider(ApiService.sanitizeImageUrl(user['avatar_url']))
                              : null,
                          backgroundColor: HuashuTheme.warmStone,
                          child: user['avatar_url'] == null ? const Icon(Icons.person, color: Colors.white) : null,
                        ),
                        title: Text(
                          user['name'] ?? 'No Name',
                          style: GoogleFonts.notoSerifSc(
                            fontWeight: FontWeight.bold,
                            decoration: !isActive ? TextDecoration.lineThrough : null,
                          ),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(user['email'] ?? ''),
                            const SizedBox(height: 4),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                border: Border.all(color: HuashuTheme.charcoalBlack),
                                color: user['role'] == 'admin' ? HuashuTheme.charcoalBlack : Colors.transparent,
                              ),
                              child: Text(
                                (user['role'] ?? 'user').toUpperCase(),
                                style: GoogleFonts.inter(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: user['role'] == 'admin' ? HuashuTheme.xuanPaperBg : HuashuTheme.charcoalBlack,
                                ),
                              ),
                            ),
                          ],
                        ),
                        trailing: PopupMenuButton<String>(
                          onSelected: (val) {
                            if (val == 'role') {
                              _showRoleDialog(user['id'], user['role']);
                            } else if (val == 'ban') {
                              _toggleBanStatus(user['id'], isActive);
                            }
                          },
                          itemBuilder: (context) => [
                            const PopupMenuItem(
                              value: 'role',
                              child: Text('Ubah Role'),
                            ),
                            PopupMenuItem(
                              value: 'ban',
                              child: Text(
                                isActive ? 'Banned Pengguna' : 'Unban Pengguna',
                                style: TextStyle(color: isActive ? Colors.red : Colors.green),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
    );
  }
}
