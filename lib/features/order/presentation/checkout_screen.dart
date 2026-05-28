import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/huashu_theme.dart';
import '../../../core/theme/ink_brush_divider.dart';
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

  final _dio = Dio();
  final _secureStorage = const FlutterSecureStorage();
  bool _isProcessing = false;

  final String _ordersUrl = 'https://d04a-2404-c0-b301-8af6-a587-34e-b9b3-3cba.ngrok-free.app/api/orders';
  final String _paymentsUrl = 'https://d04a-2404-c0-b301-8af6-a587-34e-b9b3-3cba.ngrok-free.app/api/payments/create';

  Future<void> _processCheckout() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isProcessing = true);

    try {
      final token = await _secureStorage.read(key: 'access_token');
      final headers = {'Authorization': 'Bearer $token'};

      // 1. Susun payload item belanja
      final List<Map<String, dynamic>> itemsPayload = CartManager.items.value.map((item) {
        return {
          'product_id': item.id,
          'quantity': item.quantity,
          'price': item.price.toInt(),
        };
      }).toList();

      // 2. Buat Order Baru
      final orderResponse = await _dio.post(
        _ordersUrl,
        options: Options(headers: headers),
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

      if (orderResponse.statusCode == 201 && orderResponse.data['success'] == true) {
        final orderId = orderResponse.data['data']['id'];

        // 3. Buat Transaksi Pembayaran Midtrans Snap
        final paymentResponse = await _dio.post(
          _paymentsUrl,
          options: Options(headers: headers),
          data: {'order_id': orderId},
        );

        if (paymentResponse.statusCode == 200 && paymentResponse.data['success'] == true) {
          final redirectUrl = paymentResponse.data['data']['redirect_url'];

          if (mounted) {
            // Bersihkan keranjang sebelum masuk ke WebView
            CartManager.clear();
            
            // 4. Buka WebView Snap Pembayaran
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(
                builder: (_) => SnapWebView(
                  redirectUrl: redirectUrl,
                  orderId: orderId,
                ),
              ),
            );
          }
        }
      }
    } on DioException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.response?.data['message'] ?? 'Proses checkout gagal. Harap coba lagi.'),
            backgroundColor: HuashuTheme.stainedCinnabarRed,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isProcessing = false);
      }
    }
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
      appBar: AppBar(
        title: const Text('CHECKOUT'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: HuashuTheme.charcoalBlack,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Ilustrasi Amplop Pengiriman (Gaya Surat Klasik)
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    border: Border.all(color: HuashuTheme.lightInkLine, width: 0.5),
                  ),
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'ALAMAT PENGIRIMAN (SURAT)',
                        style: Theme.of(context).textTheme.labelSmall,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _nameController,
                        decoration: const InputDecoration(labelText: 'Nama Penerima'),
                        validator: (v) => v == null || v.trim().isEmpty ? 'Nama penerima wajib diisi' : null,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _phoneController,
                        keyboardType: TextInputType.phone,
                        decoration: const InputDecoration(labelText: 'Nomor Handphone'),
                        validator: (v) => v == null || v.trim().isEmpty ? 'Nomor handphone wajib diisi' : null,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _addressController,
                        decoration: const InputDecoration(labelText: 'Jalan & Nomor Rumah'),
                        validator: (v) => v == null || v.trim().isEmpty ? 'Alamat pengiriman wajib diisi' : null,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _cityController,
                        decoration: const InputDecoration(labelText: 'Kota Penerima'),
                        validator: (v) => v == null || v.trim().isEmpty ? 'Kota wajib diisi' : null,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                
                // Catatan Pesanan
                TextFormField(
                  controller: _notesController,
                  decoration: const InputDecoration(
                    labelText: 'Catatan Pengiriman (Opsional)',
                    hintText: 'Tolong dibungkus bubble wrap...',
                  ),
                ),
                const SizedBox(height: 32),
                
                // Ringkasan Belanja (Grid Box)
                Text(
                  'RINCIAN BELANJAAN',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.0,
                    color: HuashuTheme.charcoalBlack.withOpacity(0.6),
                  ),
                ),
                const SizedBox(height: 12),
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
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  '${item.name} (x${item.quantity})',
                                  style: GoogleFonts.inter(color: HuashuTheme.charcoalBlack),
                                ),
                              ),
                              Text(
                                'Rp ${(item.price * item.quantity).toInt()}',
                                style: GoogleFonts.notoSerifSc(
                                  fontWeight: FontWeight.bold,
                                  color: HuashuTheme.charcoalBlack,
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  },
                ),
                const SizedBox(height: 16),
                const InkBrushDivider(height: 1.5),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'TOTAL PEMBAYARAN',
                      style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 14),
                    ),
                    Text(
                      'Rp ${CartManager.totalAmount.toInt()}',
                      style: GoogleFonts.notoSerifSc(
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                        color: HuashuTheme.stainedCinnabarRed,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 48),
                
                // Tombol Eksekusi Checkout
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
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: HuashuTheme.xuanPaperBg,
                            ),
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
