import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/huashu_theme.dart';
import '../../../core/theme/ink_brush_divider.dart';
import '../../../core/network/api_service.dart';
import 'cart_provider.dart';
import '../../payment/presentation/snap_webview.dart';
import '../../profile/presentation/address_screen.dart';
import 'voucher_screen.dart';
import 'order_detail_screen.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final ApiService _api = ApiService();
  bool _isProcessing = false;
  bool _isLoadingData = true;
  
  List<dynamic> _addresses = [];
  Map<String, dynamic>? _selectedAddress;

  final _notesController = TextEditingController();

  List<dynamic> _shippingRates = [];
  Map<String, dynamic>? _selectedRate;
  bool _isCalculatingShipping = false;
  
  String _selectedCourier = 'jne';
  final List<String> _availableCouriers = ['jne', 'pos', 'tiki', 'jnt', 'sicepat'];

  String? _appliedVoucherCode;
  double _discountAmount = 0.0;

  @override
  void initState() {
    super.initState();
    _fetchAddresses();
  }

  Future<void> _fetchAddresses() async {
    setState(() => _isLoadingData = true);
    try {
      final response = await _api.dio.get('/api/users/addresses');
      if (response.statusCode == 200 && response.data['success'] == true) {
        final List<dynamic> list = response.data['data'] ?? [];
        setState(() {
          _addresses = list;
          if (list.isNotEmpty) {
            _selectedAddress = list.firstWhere((a) => a['is_default'] == true, orElse: () => list.first);
            _calculateShipping();
          }
        });
      }
    } catch (e) {
      debugPrint("Gagal fetch addresses: $e");
    } finally {
      if (mounted) setState(() => _isLoadingData = false);
    }
  }

  Future<void> _calculateShipping() async {
    if (_selectedAddress == null) return;
    
    final destinationId = _selectedAddress!['city_id'];
    if (destinationId == null) {
      if (mounted) {
        setState(() {
          _shippingRates = [];
          _selectedRate = null;
        });
        _showError('Alamat Anda harus diperbarui (Pilih Kota via Pencarian) untuk menghitung ongkir.');
      }
      return;
    }

    setState(() => _isCalculatingShipping = true);
    try {
      final response = await _api.dio.post('/api/shipping/calculate', data: {
        'origin': 501, // Default Yogyakarta
        'destination': int.parse(destinationId.toString()),
        'weight': 1000, // 1 kg
        'courier': _selectedCourier,
      });
      if (response.statusCode == 200 && response.data['success'] == true) {
        final rates = response.data['data']['rates'] ?? [];
        setState(() {
          _shippingRates = rates;
          if (rates.isNotEmpty) {
            _selectedRate = rates.first;
          } else {
            _selectedRate = null;
          }
        });
      }
    } catch (e) {
      debugPrint("Gagal hitung ongkir: $e");
      if (mounted) {
        _showError('Gagal menghitung ongkos kirim untuk kurir $_selectedCourier.');
        setState(() {
          _shippingRates = [];
          _selectedRate = null;
        });
      }
    } finally {
      if (mounted) setState(() => _isCalculatingShipping = false);
    }
  }

  Future<void> _applyVoucher(String code) async {
    final subtotal = CartProvider().totalAmount.toInt();
    try {
      final response = await _api.dio.post('/api/orders/apply-voucher', data: {
        'code': code,
        'total_amount': subtotal,
      });

      if (response.statusCode == 200 && response.data['success'] == true) {
        final data = response.data['data'];
        setState(() {
          _appliedVoucherCode = code;
          _discountAmount = (data['discount'] as num).toDouble();
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Voucher berhasil digunakan!'), backgroundColor: HuashuTheme.mineralJadeGreen));
        }
      } else {
        if (mounted) _showError(response.data['message']?.toString() ?? 'Voucher tidak valid');
      }
    } catch (e) {
      if (mounted) _showError('Gagal menggunakan voucher');
    }
  }

  Future<void> _processCheckout() async {
    if (_selectedAddress == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Pilih alamat pengiriman terlebih dahulu')));
      return;
    }

    if (_selectedRate == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Pilih kurir pengiriman terlebih dahulu')));
      return;
    }

    setState(() => _isProcessing = true);

    try {
      final List<Map<String, dynamic>> itemsPayload = CartProvider().items.map((item) {
        return {
          'product_id': item.productId,
          'quantity': item.quantity,
          'price': item.price.toInt(),
        };
      }).toList();

      final subtotal = CartProvider().totalAmount.toInt();
      final shippingCost = (_selectedRate!['cost'] as num).toInt();
      final totalAmount = subtotal + shippingCost - _discountAmount.toInt();

      final payload = {
        'total_amount': totalAmount > 0 ? totalAmount : 0,
        'shipping_address': _selectedAddress,
        'notes': _notesController.text.trim(),
        'items': itemsPayload,
      };

      if (_appliedVoucherCode != null) {
        payload['voucher_code'] = _appliedVoucherCode;
        payload['discount_amount'] = _discountAmount.toInt();
      }

      final orderResponse = await _api.dio.post(
        '/api/orders',
        data: payload,
      );

      final orderData = orderResponse.data;
      if (orderData is! Map<String, dynamic> || orderResponse.statusCode != 201 || orderData['success'] != true) {
        _showError(orderData is Map ? orderData['message'] : 'Gagal membuat pesanan');
        return;
      }

      final orderId = orderData['data']?['id'];
      final paymentResponse = await _api.dio.post('/api/payments/create', data: {'order_id': orderId});

      final paymentData = paymentResponse.data;
      if (paymentData is Map<String, dynamic> && paymentResponse.statusCode == 200 && paymentData['success'] == true) {
        final redirectUrl = paymentData['data']?['redirect_url']?.toString();

        if (redirectUrl != null && mounted) {
          CartProvider().clearLocal();
          CartProvider().fetchCart();

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
      }
      
      if (mounted) {
        CartProvider().clearLocal();
        CartProvider().fetchCart();
        _showError('Gagal memproses link pembayaran. Anda dapat melanjutkannya di Detail Pesanan.');
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (_) => OrderDetailScreen(orderId: orderId),
          ),
        );
      }
    } on DioException catch (e) {
      if (mounted) _showError(ApiService.extractErrorMessage(e));
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: HuashuTheme.stainedCinnabarRed),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Checkout', style: GoogleFonts.notoSerifSc(fontWeight: FontWeight.w600)),
        centerTitle: true,
      ),
      body: _isLoadingData
          ? const Center(child: CircularProgressIndicator(color: HuashuTheme.mineralJadeGreen))
          : Column(
              children: [
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.all(HuashuTheme.space24),
                    children: [
                      // ─── Alamat Pengiriman ────────────────────────────
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const HuashuSectionLabel(text: 'Alamat Pengiriman'),
                          TextButton(
                            onPressed: () async {
                              await Navigator.push(
                                context,
                                MaterialPageRoute(builder: (_) => const AddressScreen()),
                              );
                              _fetchAddresses();
                            },
                            child: const Text('Ubah / Tambah', style: TextStyle(color: HuashuTheme.mineralJadeGreen)),
                          ),
                        ],
                      ),
                      const SizedBox(height: HuashuTheme.space12),
                      
                      if (_addresses.isEmpty)
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            border: Border.all(color: HuashuTheme.stainedCinnabarRed),
                            borderRadius: BorderRadius.circular(8),
                            color: HuashuTheme.stainedCinnabarRed.withValues(alpha: 0.1),
                          ),
                          child: Text(
                            'Anda belum memiliki alamat pengiriman. Silakan tambah alamat terlebih dahulu.',
                            style: GoogleFonts.inter(color: HuashuTheme.stainedCinnabarRed),
                          ),
                        )
                      else if (_selectedAddress != null)
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            border: Border.all(color: HuashuTheme.lightInkLine),
                            borderRadius: BorderRadius.circular(8),
                            color: HuashuTheme.xuanPaperBg,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${_selectedAddress!['recipient']} (${_selectedAddress!['label']})',
                                style: GoogleFonts.inter(fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 4),
                              Text(_selectedAddress!['phone'], style: GoogleFonts.inter(fontSize: 13)),
                              const SizedBox(height: 4),
                              Text(
                                '${_selectedAddress!['address']}, ${_selectedAddress!['city']}, ${_selectedAddress!['province']} ${_selectedAddress!['postal_code']}',
                                style: GoogleFonts.inter(fontSize: 13),
                              ),
                            ],
                          ),
                        ),

                      const SizedBox(height: HuashuTheme.space24),
                      const InkBrushDivider(height: 1),
                      const SizedBox(height: HuashuTheme.space24),

                      // ─── Pengiriman ────────────────────────────
                      const HuashuSectionLabel(text: 'Metode Pengiriman'),
                      const SizedBox(height: HuashuTheme.space12),
                      
                      DropdownButtonFormField<String>(
                        value: _selectedCourier,
                        decoration: const InputDecoration(labelText: 'Pilih Kurir'),
                        items: _availableCouriers.map((c) => DropdownMenuItem(value: c, child: Text(c.toUpperCase()))).toList(),
                        onChanged: (val) {
                          if (val != null) {
                            setState(() => _selectedCourier = val);
                            _calculateShipping();
                          }
                        },
                      ),
                      const SizedBox(height: HuashuTheme.space12),

                      if (_isCalculatingShipping)
                        const Center(child: Padding(padding: EdgeInsets.all(16.0), child: CircularProgressIndicator(color: HuashuTheme.mineralJadeGreen)))
                      else if (_shippingRates.isNotEmpty)
                        Container(
                          decoration: BoxDecoration(
                            border: Border.all(color: HuashuTheme.lightInkLine),
                            borderRadius: BorderRadius.circular(8),
                            color: HuashuTheme.xuanPaperBg,
                          ),
                          child: Column(
                            children: _shippingRates.map((rate) {
                              return RadioListTile<Map<String, dynamic>>(
                                value: rate,
                                groupValue: _selectedRate,
                                title: Text('${rate['courier']} - ${rate['service']}', style: GoogleFonts.inter(fontWeight: FontWeight.bold)),
                                subtitle: Text('${rate['description']} (Estimasi: ${rate['etd']} hari)', style: GoogleFonts.inter(fontSize: 12)),
                                secondary: Text(ApiService.formatPrice((rate['cost'] as num).toDouble()), style: GoogleFonts.inter(fontWeight: FontWeight.bold, color: HuashuTheme.mineralJadeGreen)),
                                activeColor: HuashuTheme.mineralJadeGreen,
                                onChanged: (value) {
                                  setState(() => _selectedRate = value);
                                },
                              );
                            }).toList(),
                          ),
                        )
                      else if (_selectedAddress == null)
                        Text('Pilih alamat untuk melihat opsi pengiriman.', style: GoogleFonts.inter(color: Colors.grey))
                      else
                        Text('Tidak ada layanan pengiriman untuk kurir ini.', style: GoogleFonts.inter(color: HuashuTheme.stainedCinnabarRed)),

                      const SizedBox(height: HuashuTheme.space24),
                      const InkBrushDivider(height: 1),
                      const SizedBox(height: HuashuTheme.space24),

                      // ─── Pesanan ────────────────────────────
                      const HuashuSectionLabel(text: 'Pesanan'),
                      const SizedBox(height: HuashuTheme.space12),
                      Column(
                        children: CartProvider().items.map((item) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    '${item.name} (x${item.quantity})',
                                    style: GoogleFonts.inter(),
                                  ),
                                ),
                                HuashuPrice(price: ApiService.formatPrice(item.price * item.quantity)),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
                      
                      const SizedBox(height: HuashuTheme.space24),
                      TextField(
                        controller: _notesController,
                        decoration: InputDecoration(
                          labelText: 'Catatan (Opsional)',
                          hintText: 'Misal: Titip di pos satpam',
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                          enabledBorder: OutlineInputBorder(borderSide: const BorderSide(color: HuashuTheme.lightInkLine), borderRadius: BorderRadius.circular(8)),
                          focusedBorder: OutlineInputBorder(borderSide: const BorderSide(color: HuashuTheme.mineralJadeGreen), borderRadius: BorderRadius.circular(8)),
                        ),
                        maxLines: 2,
                      ),
                      const SizedBox(height: HuashuTheme.space24),
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: const Icon(Icons.local_activity_outlined, color: HuashuTheme.stainedCinnabarRed),
                        title: Text('Gunakan Voucher', style: GoogleFonts.notoSerifSc(fontWeight: FontWeight.bold)),
                        subtitle: Text(_appliedVoucherCode != null ? 'Voucher $_appliedVoucherCode terpasang' : 'Pilih atau masukkan kode voucher'),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (_appliedVoucherCode != null)
                              Text('-${ApiService.formatPrice(_discountAmount)}', style: GoogleFonts.inter(color: HuashuTheme.stainedCinnabarRed, fontWeight: FontWeight.bold)),
                            const Icon(Icons.chevron_right),
                          ],
                        ),
                        onTap: () async {
                          final code = await Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const VoucherScreen(isSelectionMode: true)),
                          );
                          if (code != null && code is String) {
                            _applyVoucher(code);
                          }
                        },
                      ),
                    ],
                  ),
                ),
                
                // ─── Bottom Bar ───────────────────────────
                Container(
                  padding: const EdgeInsets.all(HuashuTheme.space24),
                  decoration: BoxDecoration(
                    color: HuashuTheme.xuanPaperBg,
                    border: const Border(top: BorderSide(color: HuashuTheme.lightInkLine)),
                    boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, -4))],
                  ),
                  child: SafeArea(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Subtotal', style: GoogleFonts.inter(color: Colors.grey)),
                            Text(ApiService.formatPrice(CartProvider().totalAmount), style: GoogleFonts.inter()),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Ongkos Kirim', style: GoogleFonts.inter(color: Colors.grey)),
                            Text(ApiService.formatPrice((_selectedRate?['cost'] as num?)?.toDouble() ?? 0), style: GoogleFonts.inter()),
                          ],
                        ),
                        if (_discountAmount > 0) ...[
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('Diskon Voucher', style: GoogleFonts.inter(color: HuashuTheme.stainedCinnabarRed)),
                              Text('-${ApiService.formatPrice(_discountAmount)}', style: GoogleFonts.inter(color: HuashuTheme.stainedCinnabarRed)),
                            ],
                          ),
                        ],
                        const SizedBox(height: 12),
                        const InkBrushDivider(height: 1),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('TOTAL PEMBAYARAN', style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 12)),
                            HuashuPrice(price: ApiService.formatPrice((CartProvider().totalAmount + ((_selectedRate?['cost'] as num?)?.toDouble() ?? 0) - _discountAmount).clamp(0, double.infinity)), fontSize: 18),
                          ],
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: HuashuTheme.mineralJadeGreen,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                            ),
                            onPressed: _isProcessing || _addresses.isEmpty || _selectedRate == null ? null : _processCheckout,
                            child: _isProcessing
                                ? const SizedBox(
                                    width: 24, height: 24,
                                    child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                                  )
                                : const Text('BUAT PESANAN & BAYAR'),
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              ],
            ),
    );
  }
}
