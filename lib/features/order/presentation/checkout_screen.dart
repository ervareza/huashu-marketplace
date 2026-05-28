import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/huashu_theme.dart';
import '../../../core/theme/ink_brush_divider.dart';
import '../../../core/network/api_service.dart';
import 'cart_state.dart';
import '../../payment/presentation/snap_webview.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _cityController = TextEditingController();
  final _notesController = TextEditingController();

  final _api = ApiService();
  bool _isProcessing = false;

  Future<void> _processCheckout() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isProcessing = true);

    try {
      final List<Map<String, dynamic>> itemsPayload = CartManager.items.value.map((item) {
        return {
          'product_id': item.id,
          'quantity': item.quantity,
          'price': item.price.toInt(),
        };
      }).toList();

      final orderResponse = await _api.dio.post(
        '/api/orders',
        data: {
          'total_amount': CartManager.totalAmount.toInt(),
          'shipping_address': {
            'nama_penerima': _nameController.text.trim(),
            'nomor_hp': _phoneController.text.trim(),
            'jalan': _addressController.text.trim(),
            'kota': _cityController.text.trim(),
            'provinsi': 'Indonesia',
            'kode_pos': '12345',
          },
          'notes': _notesController.text.trim(),
          'items': itemsPayload,
        },
      );

      final orderData = orderResponse.data;
      if (orderData is! Map<String, dynamic> ||
          orderResponse.statusCode != 201 ||
          orderData['success'] != true) {
        final msg = (orderData is Map<String, dynamic>)
            ? orderData['message']?.toString() ?? 'Gagal membuat pesanan.'
            : 'Response order tidak valid dari server.';
        _showError(msg);
        return;
      }

      final orderId = orderData['data']?['id'];
      if (orderId == null) {
        _showError('Order ID tidak ditemukan dalam response.');
        return;
      }

      final paymentResponse = await _api.dio.post(
        '/api/payments/create',
        data: {'order_id': orderId},
      );

      final paymentData = paymentResponse.data;
      if (paymentData is Map<String, dynamic> &&
          paymentResponse.statusCode == 200 &&
          paymentData['success'] == true) {
        final redirectUrl = paymentData['data']?['redirect_url']?.toString();

        if (redirectUrl != null && mounted) {
          CartManager.clear();

          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (_) => SnapWebView(
                redirectUrl: redirectUrl,
                orderId: orderId,
              ),
            ),
          );
          return;
        }

        _showError('URL pembayaran tidak ditemukan.');
      } else {
        final msg = (paymentData is Map<String, dynamic>)
            ? paymentData['message']?.toString() ?? 'Gagal membuat transaksi pembayaran.'
            : 'Response pembayaran tidak valid.';
        _showError(msg);
      }
    } on DioException catch (e) {
      _showError(ApiService.extractErrorMessage(
        e,
        fallback: 'Proses checkout gagal. Harap coba lagi.',
      ));
    } catch (e) {
      _showError('Kesalahan tak terduga: ${e.toString()}');
    } finally {
      if (mounted) {
        setState(() => _isProcessing = false);
      }
    }
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: HuashuTheme.stainedCinnabarRed,
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('CHECKOUT')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(HuashuTheme.space24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ─── Alamat Pengiriman ─────────────────────
                Container(
                  width: double.infinity,
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
                      const HuashuSectionLabel(text: 'Alamat Pengiriman'),
                      const SizedBox(height: HuashuTheme.space16),
                      TextFormField(
                        controller: _nameController,
                        decoration: const InputDecoration(labelText: 'Nama Penerima'),
                        validator: (v) => v == null || v.trim().isEmpty ? 'Nama penerima wajib diisi' : null,
                      ),
                      const SizedBox(height: HuashuTheme.space16),
                      TextFormField(
                        controller: _phoneController,
                        keyboardType: TextInputType.phone,
                        decoration: const InputDecoration(labelText: 'Nomor Handphone'),
                        validator: (v) => v == null || v.trim().isEmpty ? 'Nomor handphone wajib diisi' : null,
                      ),
                      const SizedBox(height: HuashuTheme.space16),
                      TextFormField(
                        controller: _addressController,
                        decoration: const InputDecoration(labelText: 'Jalan & Nomor Rumah'),
                        validator: (v) => v == null || v.trim().isEmpty ? 'Alamat wajib diisi' : null,
                      ),
                      const SizedBox(height: HuashuTheme.space16),
                      TextFormField(
                        controller: _cityController,
                        decoration: const InputDecoration(labelText: 'Kota'),
                        validator: (v) => v == null || v.trim().isEmpty ? 'Kota wajib diisi' : null,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: HuashuTheme.space24),

                // ─── Catatan ──────────────────────────────
                TextFormField(
                  controller: _notesController,
                  decoration: const InputDecoration(
                    labelText: 'Catatan Pengiriman (Opsional)',
                    hintText: 'Tolong dibungkus bubble wrap...',
                  ),
                ),
                const SizedBox(height: HuashuTheme.space32),

                // ─── Ringkasan ────────────────────────────
                const HuashuSectionLabel(text: 'Rincian Belanjaan'),
                const SizedBox(height: HuashuTheme.space12),
                ValueListenableBuilder<List<CartItem>>(
                  valueListenable: CartManager.items,
                  builder: (context, cart, _) {
                    return ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: cart.length,
                      itemBuilder: (context, idx) {
                        final item = cart[idx];
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: HuashuTheme.space8),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  '${item.name} (x${item.quantity})',
                                  style: GoogleFonts.inter(color: HuashuTheme.charcoalBlack),
                                ),
                              ),
                              HuashuPrice(
                                price: ApiService.formatPrice(item.price * item.quantity),
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  },
                ),
                const SizedBox(height: HuashuTheme.space16),
                const InkBrushDivider(height: 1.5),
                const SizedBox(height: HuashuTheme.space16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'TOTAL',
                      style: GoogleFonts.inter(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        letterSpacing: 1.0,
                      ),
                    ),
                    HuashuPrice(
                      price: ApiService.formatPrice(CartManager.totalAmount),
                      fontSize: 20,
                    ),
                  ],
                ),
                const SizedBox(height: HuashuTheme.space48),

                // ─── Tombol ───────────────────────────────
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: HuashuTheme.mineralJadeGreen,
                    ),
                    onPressed: _isProcessing ? null : _processCheckout,
                    child: _isProcessing
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('KONFIRMASI & BAYAR'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
