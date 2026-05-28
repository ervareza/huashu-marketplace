import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/huashu_theme.dart';
import '../../product/presentation/seller_panel_screen.dart';
import '../../order/presentation/order_history_screen.dart';

class AdminPanelScreen extends StatelessWidget {
  const AdminPanelScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ADMIN DASHBOARD'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(HuashuTheme.space24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const HuashuSectionLabel(text: 'Navigasi Panel'),
              const SizedBox(height: HuashuTheme.space24),
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
                title: 'Riwayat Pesanan',
                subtitle: 'Lihat seluruh riwayat pesanan, status pembayaran, dan detail pengiriman.',
                icon: Icons.receipt_long_outlined,
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const OrderHistoryScreen()),
                  );
                },
              ),
              // Tambahan menu admin lainnya bisa ditaruh di sini ke depannya.
            ],
          ),
        ),
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
