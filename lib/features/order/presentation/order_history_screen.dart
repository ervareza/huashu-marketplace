import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/huashu_theme.dart';
import '../../payment/presentation/snap_webview.dart';

class OrderHistoryScreen extends StatefulWidget {
  const OrderHistoryScreen({super.key});

  @override
  State<OrderHistoryScreen> createState() => _OrderHistoryScreenState();
}

class _OrderHistoryScreenState extends State<OrderHistoryScreen> {
  final _dio = Dio();
  final _secureStorage = const FlutterSecureStorage();
  List<dynamic> _orders = [];
  bool _isLoading = true;
  String? _errorMessage;

  final String _ordersUrl = 'https://d04a-2404-c0-b301-8af6-a587-34e-b9b3-3cba.ngrok-free.app/api/orders';
  final String _paymentsUrl = 'https://d04a-2404-c0-b301-8af6-a587-34e-b9b3-3cba.ngrok-free.app/api/payments/create';

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
      final token = await _secureStorage.read(key: 'access_token');
      final response = await _dio.get(
        _ordersUrl,
        options: Options(
          headers: {'Authorization': 'Bearer $token'},
        ),
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        setState(() {
          _orders = response.data['data'];
        });
      } else {
        setState(() {
          _errorMessage = response.data['message'] ?? 'Gagal mengambil riwayat pesanan';
        });
      }
    } on DioException catch (e) {
      setState(() {
        _errorMessage = e.response?.data['message'] ?? 'Gagal menghubungi server.';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _resumePayment(int orderId) async {
    try {
      final token = await _secureStorage.read(key: 'access_token');
      final response = await _dio.post(
        _paymentsUrl,
        options: Options(
          headers: {'Authorization': 'Bearer $token'},
        ),
        data: {'order_id': orderId},
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        final redirectUrl = response.data['data']['redirect_url'];

        if (mounted) {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => SnapWebView(
                redirectUrl: redirectUrl,
                orderId: orderId,
              ),
            ),
          );
        }
      }
    } on DioException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.response?.data['message'] ?? 'Gagal mengambil tautan pembayaran.'),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('RIWAYAT PESANAN'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: HuashuTheme.charcoalBlack,
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: HuashuTheme.mineralJadeGreen),
            )
          : _errorMessage != null
              ? Center(
                  child: Text(
                    _errorMessage!,
                    style: GoogleFonts.inter(color: HuashuTheme.stainedCinnabarRed),
                  ),
                )
              : _orders.isEmpty
                  ? Center(
                      child: Text(
                        'Anda belum melakukan pemesanan apa pun.',
                        style: GoogleFonts.inter(color: HuashuTheme.lightInkLine),
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(24),
                      itemCount: _orders.length,
                      itemBuilder: (context, index) {
                        final order = _orders[index];
                        final statusColor = _getStatusColor(order['payment_status']);
                        final isUnpaid = order['payment_status'] == 'unpaid';

                        return Container(
                          margin: const EdgeInsets.only(bottom: 24),
                          decoration: BoxDecoration(
                            border: Border.all(color: HuashuTheme.lightInkLine, width: 0.5),
                          ),
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'KODE: #${order['id']}',
                                    style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 14),
                                  ),
                                  // Stempel Status
                                  Container(
                                    decoration: BoxDecoration(
                                      border: Border.all(color: statusColor, width: 0.7),
                                    ),
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    child: Text(
                                      order['payment_status'].toString().toUpperCase(),
                                      style: GoogleFonts.inter(
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                        color: statusColor,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Text(
                                'Dipesan pada: ${order['created_at'] ?? '-'}',
                                style: Theme.of(context).textTheme.labelSmall,
                              ),
                              const SizedBox(height: 16),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Total Nominal:',
                                    style: GoogleFonts.inter(color: HuashuTheme.charcoalBlack.withOpacity(0.6)),
                                  ),
                                  Text(
                                    order['total_amount'] ?? 'Rp 0',
                                    style: GoogleFonts.notoSerifSc(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                      color: HuashuTheme.charcoalBlack,
                                    ),
                                  ),
                                ],
                              ),
                              if (isUnpaid) ...[
                                const SizedBox(height: 16),
                                SizedBox(
                                  width: double.infinity,
                                  child: OutlinedButton(
                                    style: OutlinedButton.styleFrom(
                                      foregroundColor: HuashuTheme.stainedCinnabarRed,
                                      side: const BorderSide(color: HuashuTheme.stainedCinnabarRed, width: 0.5),
                                      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
                                    ),
                                    onPressed: () => _resumePayment(order['id']),
                                    child: const Text('BAYAR SEKARANG'),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        );
                      },
                    ),
    );
  }
}
