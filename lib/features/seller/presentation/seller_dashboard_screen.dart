import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../core/theme/huashu_theme.dart';
import '../../../core/theme/ink_brush_divider.dart';
import '../../../core/network/api_service.dart';
import '../../product/presentation/seller_panel_screen.dart';

class SellerDashboardScreen extends StatefulWidget {
  const SellerDashboardScreen({super.key});

  @override
  State<SellerDashboardScreen> createState() => _SellerDashboardScreenState();
}

class _SellerDashboardScreenState extends State<SellerDashboardScreen> {
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
      final response = await _api.dio.get('/api/seller/dashboard/stats');
      if (response.statusCode == 200 && response.data['success'] == true) {
        setState(() {
          _stats = response.data['data'];
        });
      }
    } catch (e) {
      debugPrint("Gagal mengambil statistik seller: $e");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'DASHBOARD PENJUAL',
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
                const HuashuSectionLabel(text: 'Statistik Penjualan'),
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
                        'Total Pendapatan',
                        _stats!['total_revenue_formatted']?.toString() ?? 'Rp 0',
                        Icons.account_balance_wallet_outlined,
                      ),
                      _buildStatCard(
                        'Pendapatan Bulanan',
                        _stats!['monthly_revenue_formatted']?.toString() ?? 'Rp 0',
                        Icons.payments_outlined,
                      ),
                      _buildStatCard(
                        'Produk Terjual',
                        '${_stats!['total_items_sold'] ?? 0}',
                        Icons.shopping_bag_outlined,
                      ),
                      _buildStatCard(
                        'Produk Aktif',
                        '${_stats!['active_products'] ?? 0} / ${_stats!['total_products'] ?? 0}',
                        Icons.inventory_2_outlined,
                      ),
                    ],
                  ),
                  const SizedBox(height: HuashuTheme.space24),
                  const InkBrushDivider(height: 1),
                  const SizedBox(height: HuashuTheme.space24),

                  const HuashuSectionLabel(text: 'Navigasi Panel'),
                  const SizedBox(height: HuashuTheme.space16),
                  InkWell(
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const SellerPanelScreen()),
                      );
                    },
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        border: Border.all(color: HuashuTheme.lightInkLine),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: HuashuTheme.charcoalBlack.withValues(alpha: 0.05),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.storefront_outlined, color: HuashuTheme.charcoalBlack),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Manajemen Produk',
                                  style: GoogleFonts.notoSerifSc(fontWeight: FontWeight.bold, fontSize: 16),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Atur inventaris, tambah produk, dan stok.',
                                  style: Theme.of(context).textTheme.bodySmall,
                                ),
                              ],
                            ),
                          ),
                          const Icon(Icons.chevron_right, color: HuashuTheme.warmStone),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: HuashuTheme.space24),

                  if (_stats!['top_selling_products'] != null && (_stats!['top_selling_products'] as List).isNotEmpty) ...[
                    const HuashuSectionLabel(text: 'Produk Terlaris'),
                    const SizedBox(height: HuashuTheme.space16),
                    ...(_stats!['top_selling_products'] as List).map((product) {
                      return ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: product['image_url'] != null
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(4),
                                child: CachedNetworkImage(
                                  imageUrl: product['image_url'],
                                  width: 50,
                                  height: 50,
                                  fit: BoxFit.cover,
                                  errorWidget: (_, __, ___) => Container(color: HuashuTheme.warmStone, width: 50, height: 50),
                                ),
                              )
                            : Container(color: HuashuTheme.warmStone, width: 50, height: 50),
                        title: Text(product['name'] ?? 'Item', style: GoogleFonts.inter(fontWeight: FontWeight.bold)),
                        subtitle: Text(product['price_formatted'] ?? ''),
                        trailing: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text('${product['total_quantity_sold'] ?? 0}', style: GoogleFonts.notoSerifSc(fontWeight: FontWeight.bold, fontSize: 16)),
                            const Text('Terjual', style: TextStyle(fontSize: 10)),
                          ],
                        ),
                      );
                    }),
                  ]
                ],
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
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            children: [
              Icon(icon, size: 20, color: HuashuTheme.warmStone),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: GoogleFonts.inter(fontSize: 11, color: HuashuTheme.charcoalBlack.withValues(alpha: 0.7)),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const Spacer(),
          Text(
            value,
            style: GoogleFonts.notoSerifSc(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: HuashuTheme.charcoalBlack,
            ),
          ),
        ],
      ),
    );
  }
}
