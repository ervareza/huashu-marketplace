import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/huashu_theme.dart';
import '../../../core/network/api_service.dart';
import '../../payment/presentation/snap_webview.dart';
import 'order_detail_screen.dart';

class OrderHistoryScreen extends StatefulWidget {
  const OrderHistoryScreen({super.key});

  @override
  State<OrderHistoryScreen> createState() => _OrderHistoryScreenState();
}

class _OrderHistoryScreenState extends State<OrderHistoryScreen> {
  final _api = ApiService();
  List<dynamic> _orders = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchOrders();
  }

  Future<void> _fetchOrders() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final response = await _api.dio.get('/api/orders');

      final data = response.data;
      if (data is Map<String, dynamic> &&
          response.statusCode == 200 &&
          data['success'] == true) {
        final ordersData = data['data'];
        setState(() {
          _orders = (ordersData is List) ? ordersData : [];
        });
      } else {
        setState(() {
          _errorMessage = (data is Map<String, dynamic>)
              ? data['message']?.toString() ?? 'Gagal mengambil riwayat pesanan'
              : 'Format response pesanan tidak valid.';
        });
      }
    } on DioException catch (e) {
      setState(() {
        _errorMessage = ApiService.extractErrorMessage(
          e,
          fallback: 'Gagal menghubungi server.',
        );
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Kesalahan tak terduga: ${e.toString()}';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _resumePayment(dynamic orderId) async {
    try {
      final response = await _api.dio.post(
        '/api/payments/create',
        data: {'order_id': orderId},
      );

      final data = response.data;
      if (data is Map<String, dynamic> &&
          response.statusCode == 200 &&
          data['success'] == true) {
        final redirectUrl = data['data']?['redirect_url']?.toString();

        if (redirectUrl != null && mounted) {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => SnapWebView(
                redirectUrl: redirectUrl,
                orderId: orderId,
              ),
            ),
          );
          return;
        }
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Gagal mendapatkan URL pembayaran.'),
            backgroundColor: HuashuTheme.stainedCinnabarRed,
          ),
        );
      }
    } on DioException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(ApiService.extractErrorMessage(
              e,
              fallback: 'Gagal mengambil tautan pembayaran.',
            )),
            backgroundColor: HuashuTheme.stainedCinnabarRed,
          ),
        );
      }
    }
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'paid':
      case 'processing':
      case 'delivered':
      case 'shipped':
        return HuashuTheme.mineralJadeGreen;
      case 'failed':
      case 'cancelled':
        return HuashuTheme.stainedCinnabarRed;
      default:
        return HuashuTheme.charcoalBlack;
    }
  }

  String _formatOrderAmount(dynamic amount) {
    if (amount == null) return 'Rp 0';
    if (amount is String) {
      if (amount.contains('Rp')) return amount;
      return 'Rp $amount';
    }
    return ApiService.formatPrice(ApiService.parsePrice(amount));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('RIWAYAT PESANAN')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? HuashuEmptyState(
                  icon: Icons.cloud_off,
                  message: _errorMessage!,
                  onRetry: _fetchOrders,
                )
              : _orders.isEmpty
                  ? const HuashuEmptyState(
                      icon: Icons.receipt_long_outlined,
                      message: 'Anda belum melakukan\npemesanan apa pun.',
                    )
                  : RefreshIndicator(
                      color: HuashuTheme.mineralJadeGreen,
                      onRefresh: _fetchOrders,
                      child: ListView.builder(
                        padding: const EdgeInsets.all(HuashuTheme.space24),
                        itemCount: _orders.length,
                        itemBuilder: (context, index) {
                          final order = _orders[index];
                          final paymentStatus = order['payment_status']?.toString() ?? 'unknown';
                          final statusColor = _getStatusColor(paymentStatus);
                          final isUnpaid = paymentStatus == 'unpaid' || paymentStatus == 'pending';

                          return InkWell(
                            onTap: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => OrderDetailScreen(orderId: order['id']),
                                ),
                              ).then((_) {
                                _fetchOrders(); // Refresh status
                              });
                            },
                            child: Container(
                              margin: const EdgeInsets.only(bottom: HuashuTheme.space24),
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: HuashuTheme.lightInkLine,
                                  width: HuashuTheme.hairline,
                                ),
                              ),
                            padding: const EdgeInsets.all(HuashuTheme.space16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'KODE: #${order['id']}',
                                      style: GoogleFonts.inter(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                      ),
                                    ),
                                    HuashuStampBadge(
                                      label: paymentStatus,
                                      color: statusColor,
                                    ),
                                  ],
                                ),
                                const SizedBox(height: HuashuTheme.space12),
                                Text(
                                  'Dipesan pada: ${order['created_at']?.toString() ?? '-'}',
                                  style: Theme.of(context).textTheme.labelSmall,
                                ),
                                const SizedBox(height: HuashuTheme.space16),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'Total Nominal:',
                                      style: GoogleFonts.inter(
                                        color: HuashuTheme.charcoalBlack.withValues(alpha: 0.6),
                                      ),
                                    ),
                                    Text(
                                      _formatOrderAmount(order['total_amount']),
                                      style: GoogleFonts.notoSerifSc(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                        color: HuashuTheme.charcoalBlack,
                                      ),
                                    ),
                                  ],
                                ),
                                if (isUnpaid) ...[
                                  const SizedBox(height: HuashuTheme.space16),
                                  SizedBox(
                                    width: double.infinity,
                                    child: OutlinedButton(
                                      style: OutlinedButton.styleFrom(
                                        foregroundColor: HuashuTheme.stainedCinnabarRed,
                                        side: const BorderSide(
                                          color: HuashuTheme.stainedCinnabarRed,
                                          width: HuashuTheme.hairline,
                                        ),
                                      ),
                                      onPressed: () => _resumePayment(order['id']),
                                      child: const Text('BAYAR SEKARANG'),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        );
                        },
                      ),
                    ),
    );
  }
}
