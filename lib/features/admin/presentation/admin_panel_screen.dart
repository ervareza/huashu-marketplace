import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/huashu_theme.dart';
import '../../../core/theme/ink_brush_divider.dart';
import '../../../core/network/api_service.dart';
import '../../product/presentation/seller_panel_screen.dart';
import 'admin_order_list_screen.dart';
import 'admin_content_screen.dart';

class AdminPanelScreen extends StatefulWidget {
  const AdminPanelScreen({super.key});

  @override
  State<AdminPanelScreen> createState() => _AdminPanelScreenState();
}

class _AdminPanelScreenState extends State<AdminPanelScreen> {
  final ApiService _api = ApiService();
  bool _isLoading = true;
  Map<String, dynamic>? _stats;

  @override
  void initState() {
    super.initState();
    _fetchStats();
  }

  Future<void> _fetchStats() async {
    setState(() => _isLoading = true);
    try {
      final response = await _api.dio.get('/api/admin/dashboard/stats');
      if (response.statusCode == 200 && response.data['success'] == true) {
        setState(() {
          _stats = response.data['data'];
        });
      }
    } catch (e) {
      debugPrint("Gagal mengambil statistik: $e");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'ADMIN DASHBOARD',
          style: GoogleFonts.notoSerifSc(fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _fetchStats,
          color: HuashuTheme.mineralJadeGreen,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(HuashuTheme.space24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const HuashuSectionLabel(text: 'Statistik Toko'),
                const SizedBox(height: HuashuTheme.space16),
                
                if (_isLoading)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.all(32.0),
                      child: CircularProgressIndicator(color: HuashuTheme.mineralJadeGreen),
                    ),
                  )
                else if (_stats != null) ...[
                  // ─── Grid Statistik ─────────────────────
                  GridView.count(
                    crossAxisCount: 2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    childAspectRatio: 1.2,
                    children: [
                      _buildStatCard(
                        'Pendapatan Bulan Ini',
                        ApiService.formatPrice((_stats!['monthly_revenue'] ?? 0).toDouble()),
                        Icons.payments_outlined,
                      ),
                      _buildStatCard(
                        'Pesanan Bulan Ini',
                        '${_stats!['orders_this_month'] ?? 0}',
                        Icons.shopping_cart_checkout,
                      ),
                      _buildStatCard(
                        'Total Produk Aktif',
                        '${_stats!['active_products'] ?? 0}',
                        Icons.inventory_2_outlined,
                      ),
                      _buildStatCard(
                        'Total Pengguna',
                        '${_stats!['total_users'] ?? 0}',
                        Icons.people_outline,
                      ),
                    ],
                  ),
                  const SizedBox(height: HuashuTheme.space24),
                  const InkBrushDivider(height: 1),
                  const SizedBox(height: HuashuTheme.space24),
                ],

                const HuashuSectionLabel(text: 'Navigasi Panel'),
                const SizedBox(height: HuashuTheme.space16),
                _buildDashboardCard(
                  context,
                  title: 'Manajemen Produk',
                  subtitle: 'Atur inventaris, tambah atau hapus produk Anda dari katalog.',
                  icon: Icons.storefront_outlined,
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const SellerPanelScreen()),
                    );
                  },
                ),
                const SizedBox(height: HuashuTheme.space16),
                _buildDashboardCard(
                  context,
                  title: 'Kelola Pesanan',
                  subtitle: 'Lihat seluruh riwayat pesanan masuk, update status pesanan, dan detail pengiriman.',
                  icon: Icons.receipt_long_outlined,
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const AdminOrderListScreen()),
                    );
                  },
                ),
                const SizedBox(height: HuashuTheme.space16),
                _buildDashboardCard(
                  context,
                  title: 'Konten & Kategori',
                  subtitle: 'Kelola kategori produk dan atur banner promosi di halaman utama.',
                  icon: Icons.app_registration,
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const AdminContentScreen()),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: HuashuTheme.xuanPaperBg,
        border: Border.all(color: HuashuTheme.lightInkLine),
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: HuashuTheme.charcoalBlack.withValues(alpha: 0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: HuashuTheme.mineralJadeGreen, size: 24),
          const Spacer(),
          Text(
            value,
            style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 16),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: GoogleFonts.inter(
              fontSize: 10,
              color: HuashuTheme.charcoalBlack.withValues(alpha: 0.6),
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildDashboardCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          border: Border.all(
            color: HuashuTheme.lightInkLine,
            width: HuashuTheme.hairline,
          ),
          color: HuashuTheme.xuanPaperBg,
          boxShadow: [
            BoxShadow(
              color: HuashuTheme.charcoalBlack.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(2, 4),
            ),
          ],
        ),
        padding: const EdgeInsets.all(HuashuTheme.space24),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                border: Border.all(color: HuashuTheme.mineralJadeGreen, width: 1.5),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: HuashuTheme.mineralJadeGreen,
                size: 28,
              ),
            ),
            const SizedBox(width: HuashuTheme.space24),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.notoSerifSc(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: HuashuTheme.charcoalBlack,
                    ),
                  ),
                  const SizedBox(height: HuashuTheme.space8),
                  Text(
                    subtitle,
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: HuashuTheme.charcoalBlack.withValues(alpha: 0.7),
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.chevron_right,
              color: HuashuTheme.warmStone,
            ),
          ],
        ),
      ),
    );
  }
}
