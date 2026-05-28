import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../core/theme/huashu_theme.dart';
import '../../../core/theme/ink_brush_divider.dart';
import '../../../core/network/api_service.dart';
import '../../payment/presentation/snap_webview.dart';

class OrderDetailScreen extends StatefulWidget {
  final int orderId;

  const OrderDetailScreen({super.key, required this.orderId});

  @override
  State<OrderDetailScreen> createState() => _OrderDetailScreenState();
}

class _OrderDetailScreenState extends State<OrderDetailScreen> {
  final _api = ApiService();
  Map<String, dynamic>? _order;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchOrderDetail();
  }

  Future<void> _fetchOrderDetail() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final response = await _api.dio.get('/api/orders/${widget.orderId}');
      final data = response.data;

      if (data is Map<String, dynamic> &&
          response.statusCode == 200 &&
          data['success'] == true) {
        setState(() {
          _order = data['data'] as Map<String, dynamic>?;
        });
      } else {
        setState(() {
          _errorMessage = (data is Map<String, dynamic>)
              ? data['message']?.toString() ?? 'Gagal mengambil detail pesanan'
              : 'Format response tidak valid.';
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

  Future<void> _resumePayment() async {
    if (_order == null) return;
    try {
      final response = await _api.dio.post(
        '/api/payments/create',
        data: {'order_id': widget.orderId},
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
                orderId: widget.orderId,
              ),
            ),
          ).then((_) {
            // Refresh order details when returning from payment
            _fetchOrderDetail();
          });
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
      case 'completed':
        return HuashuTheme.mineralJadeGreen;
      case 'failed':
      case 'cancelled':
      case 'expired':
        return HuashuTheme.stainedCinnabarRed;
      default:
        return HuashuTheme.charcoalBlack;
    }
  }

  String _formatAmount(dynamic amount) {
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
      appBar: AppBar(title: const Text('DETAIL PESANAN')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? HuashuEmptyState(
                  icon: Icons.error_outline,
                  message: _errorMessage!,
                  onRetry: _fetchOrderDetail,
                )
              : _order == null
                  ? const HuashuEmptyState(
                      icon: Icons.not_interested,
                      message: 'Pesanan tidak ditemukan.',
                    )
                  : _buildOrderDetail(),
    );
  }

  Widget _buildOrderDetail() {
    final paymentStatus = _order!['payment_status']?.toString() ?? 'unknown';
    final orderStatus = _order!['status']?.toString() ?? 'unknown';
    final isUnpaid = paymentStatus == 'unpaid';

    final shippingAddress = _order!['shipping_address'];
    final items = _order!['order_items'] as List<dynamic>? ?? [];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(HuashuTheme.space24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Order ID & Status Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'KODE: #${_order!['id']}',
                style: GoogleFonts.inter(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: HuashuTheme.charcoalBlack,
                ),
              ),
              HuashuStampBadge(
                label: orderStatus.toUpperCase(),
                color: _getStatusColor(orderStatus),
              ),
            ],
          ),
          const SizedBox(height: HuashuTheme.space8),
          Text(
            'Dipesan pada: ${_order!['created_at']?.toString() ?? '-'}',
            style: Theme.of(context).textTheme.labelSmall,
          ),
          const SizedBox(height: HuashuTheme.space24),
          const InkBrushDivider(height: 1.5),
          const SizedBox(height: HuashuTheme.space24),

          // Payment Status
          const HuashuSectionLabel(text: 'Status Pembayaran'),
          const SizedBox(height: HuashuTheme.space12),
          Row(
            children: [
              Icon(
                isUnpaid ? Icons.pending_actions : Icons.check_circle_outline,
                color: _getStatusColor(paymentStatus),
              ),
              const SizedBox(width: HuashuTheme.space8),
              Text(
                paymentStatus.toUpperCase(),
                style: GoogleFonts.inter(
                  fontWeight: FontWeight.bold,
                  color: _getStatusColor(paymentStatus),
                ),
              ),
            ],
          ),
          if (isUnpaid) ...[
            const SizedBox(height: HuashuTheme.space16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: HuashuTheme.mineralJadeGreen,
                ),
                onPressed: _resumePayment,
                child: const Text('BAYAR SEKARANG'),
              ),
            ),
          ],
          const SizedBox(height: HuashuTheme.space24),

          // Shipping Address
          const HuashuSectionLabel(text: 'Alamat Pengiriman'),
          const SizedBox(height: HuashuTheme.space12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(HuashuTheme.space16),
            decoration: BoxDecoration(
              border: Border.all(
                color: HuashuTheme.lightInkLine,
                width: HuashuTheme.hairline,
              ),
              color: HuashuTheme.xuanPaperBg.withValues(alpha: 0.5),
            ),
            child: shippingAddress is Map
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        shippingAddress['nama_penerima']?.toString() ?? '-',
                        style: GoogleFonts.inter(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      Text(shippingAddress['nomor_hp']?.toString() ?? '-'),
                      const SizedBox(height: 4),
                      Text(shippingAddress['jalan']?.toString() ?? '-'),
                      const SizedBox(height: 4),
                      Text('${shippingAddress['kota']?.toString() ?? '-'}, ${shippingAddress['provinsi']?.toString() ?? '-'}'),
                      const SizedBox(height: 4),
                      Text(shippingAddress['kode_pos']?.toString() ?? '-'),
                    ],
                  )
                : Text(shippingAddress?.toString() ?? '-'),
          ),
          const SizedBox(height: HuashuTheme.space24),

          // Notes
          if (_order!['notes'] != null && _order!['notes'].toString().isNotEmpty) ...[
            const HuashuSectionLabel(text: 'Catatan'),
            const SizedBox(height: HuashuTheme.space12),
            Text(_order!['notes'].toString()),
            const SizedBox(height: HuashuTheme.space24),
          ],

          // Order Items
          const HuashuSectionLabel(text: 'Daftar Barang'),
          const SizedBox(height: HuashuTheme.space12),
          ...items.map((item) {
            final product = item['product'] ?? {};
            return Container(
              margin: const EdgeInsets.only(bottom: HuashuTheme.space12),
              padding: const EdgeInsets.all(HuashuTheme.space12),
              decoration: BoxDecoration(
                border: Border.all(
                  color: HuashuTheme.lightInkLine,
                  width: HuashuTheme.hairline,
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      border: Border.all(color: HuashuTheme.lightInkLine),
                    ),
                    child: CachedNetworkImage(
                      imageUrl: ApiService.sanitizeImageUrl(product['image_url']?.toString()),
                      fit: BoxFit.cover,
                      errorWidget: (_, __, ___) => Container(
                        color: HuashuTheme.warmStone,
                        child: const Center(
                          child: Icon(Icons.broken_image, color: Colors.white70, size: 24),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: HuashuTheme.space12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          product['name']?.toString() ?? 'Produk',
                          style: GoogleFonts.inter(fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${item['quantity']} x ${_formatAmount(item['price'])}',
                          style: Theme.of(context).textTheme.labelSmall,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }),

          const SizedBox(height: HuashuTheme.space16),
          const InkBrushDivider(height: 1.5),
          const SizedBox(height: HuashuTheme.space16),

          // Total
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'TOTAL PESANAN',
                style: GoogleFonts.inter(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  letterSpacing: 1.0,
                ),
              ),
              HuashuPrice(
                price: _formatAmount(_order!['total_amount']),
                fontSize: 20,
              ),
            ],
          ),
          const SizedBox(height: HuashuTheme.space48),
        ],
      ),
    );
  }
}
