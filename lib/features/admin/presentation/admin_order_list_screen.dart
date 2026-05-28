import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/huashu_theme.dart';
import '../../../core/network/api_service.dart';
import 'admin_order_detail_screen.dart';

class AdminOrderListScreen extends StatefulWidget {
  const AdminOrderListScreen({super.key});

  @override
  State<AdminOrderListScreen> createState() => _AdminOrderListScreenState();
}

class _AdminOrderListScreenState extends State<AdminOrderListScreen> {
  final ApiService _api = ApiService();
  bool _isLoading = true;
  List<dynamic> _orders = [];

  @override
  void initState() {
    super.initState();
    _fetchOrders();
  }

  Future<void> _fetchOrders() async {
    setState(() => _isLoading = true);
    try {
      final response = await _api.dio.get('/api/admin/orders');
      if (response.statusCode == 200 && response.data['success'] == true) {
        setState(() {
          _orders = response.data['data'] ?? [];
        });
      }
    } catch (e) {
      debugPrint("Gagal fetch admin orders: $e");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending': return Colors.orange;
      case 'processing': return Colors.blue;
      case 'shipped': return Colors.purple;
      case 'delivered': return HuashuTheme.mineralJadeGreen;
      case 'cancelled': return HuashuTheme.stainedCinnabarRed;
      default: return Colors.grey;
    }
  }

  String _formatDate(String isoString) {
    try {
      final date = DateTime.parse(isoString).toLocal();
      return DateFormat('dd MMM yyyy, HH:mm').format(date);
    } catch (e) {
      return isoString;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Kelola Pesanan',
          style: GoogleFonts.notoSerifSc(fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: HuashuTheme.mineralJadeGreen))
          : _orders.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.inbox_outlined, size: 64, color: Colors.grey),
                      const SizedBox(height: 16),
                      Text('Belum ada pesanan masuk.', style: GoogleFonts.inter(color: Colors.grey)),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _fetchOrders,
                  color: HuashuTheme.mineralJadeGreen,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(HuashuTheme.space16),
                    itemCount: _orders.length,
                    itemBuilder: (context, index) {
                      final order = _orders[index];
                      final status = order['status'] ?? 'unknown';
                      final total = order['total_amount'] ?? 0;
                      final date = order['created_at'] ?? '';
                      final user = order['user']?['name'] ?? 'Guest';
                      
                      return Card(
                        margin: const EdgeInsets.only(bottom: 16),
                        color: HuashuTheme.xuanPaperBg,
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                          side: BorderSide(color: HuashuTheme.lightInkLine, width: 1),
                        ),
                        child: InkWell(
                          onTap: () async {
                            final bool? shouldRefresh = await Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => AdminOrderDetailScreen(order: order)),
                            );
                            if (shouldRefresh == true) {
                              _fetchOrders();
                            }
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'Order #${order['id']}',
                                      style: GoogleFonts.inter(fontWeight: FontWeight.bold),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: _getStatusColor(status).withValues(alpha: 0.1),
                                        borderRadius: BorderRadius.circular(4),
                                        border: Border.all(color: _getStatusColor(status)),
                                      ),
                                      child: Text(
                                        status.toUpperCase(),
                                        style: GoogleFonts.inter(
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
                                          color: _getStatusColor(status),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    const Icon(Icons.person_outline, size: 16, color: Colors.grey),
                                    const SizedBox(width: 4),
                                    Text(user, style: GoogleFonts.inter(fontSize: 14)),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    const Icon(Icons.calendar_today_outlined, size: 16, color: Colors.grey),
                                    const SizedBox(width: 4),
                                    Text(_formatDate(date), style: GoogleFonts.inter(fontSize: 12, color: Colors.grey)),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                Align(
                                  alignment: Alignment.centerRight,
                                  child: Text(
                                    ApiService.formatPrice(total.toDouble()),
                                    style: GoogleFonts.inter(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                      color: HuashuTheme.charcoalBlack,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
    );
  }
}
