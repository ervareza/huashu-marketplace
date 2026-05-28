import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:dio/dio.dart';
import '../../../core/theme/huashu_theme.dart';
import '../../../core/network/api_service.dart';

class VoucherScreen extends StatefulWidget {
  final bool isSelectionMode;
  const VoucherScreen({super.key, this.isSelectionMode = false});

  @override
  State<VoucherScreen> createState() => _VoucherScreenState();
}

class _VoucherScreenState extends State<VoucherScreen> {
  final ApiService _api = ApiService();
  bool _isLoading = true;
  String? _errorMessage;
  List<dynamic> _vouchers = [];

  @override
  void initState() {
    super.initState();
    _fetchVouchers();
  }

  Future<void> _fetchVouchers() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final response = await _api.dio.get('/api/vouchers');
      if (response.statusCode == 200 && response.data['success'] == true) {
        setState(() {
          _vouchers = response.data['data'] as List<dynamic>? ?? [];
        });
      } else {
        setState(() => _errorMessage = response.data['message']?.toString() ?? 'Gagal memuat voucher');
      }
    } on DioException catch (e) {
      setState(() => _errorMessage = ApiService.extractErrorMessage(e));
    } catch (e) {
      setState(() => _errorMessage = 'Kesalahan sistem: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _onVoucherTapped(Map<String, dynamic> voucher) {
    if (widget.isSelectionMode) {
      Navigator.pop(context, voucher['code']);
    } else {
      Clipboard.setData(ClipboardData(text: voucher['code']));
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Kode voucher disalin!'), backgroundColor: HuashuTheme.mineralJadeGreen),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.isSelectionMode ? 'Pilih Voucher' : 'Voucher Tersedia',
          style: GoogleFonts.notoSerifSc(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: HuashuTheme.mineralJadeGreen))
          : _errorMessage != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const HuashuSeal(character: '誤'),
                      const SizedBox(height: 16),
                      Text(_errorMessage!, style: const TextStyle(color: HuashuTheme.stainedCinnabarRed)),
                      TextButton(onPressed: _fetchVouchers, child: const Text('COBA LAGI')),
                    ],
                  ),
                )
              : _vouchers.isEmpty
                  ? Center(
                      child: Text(
                        'Saat ini tidak ada voucher yang tersedia.',
                        style: GoogleFonts.inter(color: Colors.grey),
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: _fetchVouchers,
                      color: HuashuTheme.mineralJadeGreen,
                      child: ListView.separated(
                        padding: const EdgeInsets.all(HuashuTheme.space24),
                        itemCount: _vouchers.length,
                        separatorBuilder: (context, index) => const SizedBox(height: 16),
                        itemBuilder: (context, index) {
                          final v = _vouchers[index];
                          final code = v['code'] ?? '';
                          final minPurchase = v['min_purchase_formatted'] ?? 'Tanpa minimum';
                          final isPercent = v['type'] == 'percentage';
                          final title = isPercent ? 'Diskon ${v['value']}%' : 'Potongan Langsung';

                          return GestureDetector(
                            onTap: () => _onVoucherTapped(v),
                            child: Container(
                              decoration: BoxDecoration(
                                border: Border.all(color: HuashuTheme.lightInkLine),
                                color: HuashuTheme.xuanPaperBg,
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    width: 100,
                                    height: 100,
                                    color: HuashuTheme.mineralJadeGreen.withValues(alpha: 0.1),
                                    child: Center(
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          const Icon(Icons.local_activity, color: HuashuTheme.mineralJadeGreen, size: 32),
                                          const SizedBox(height: 8),
                                          Text(
                                            isPercent ? '${v['value']}%' : 'FREE',
                                            style: GoogleFonts.notoSerifSc(fontWeight: FontWeight.bold, color: HuashuTheme.mineralJadeGreen),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    child: Padding(
                                      padding: const EdgeInsets.all(16.0),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(title, style: GoogleFonts.notoSerifSc(fontWeight: FontWeight.bold, fontSize: 16)),
                                          const SizedBox(height: 4),
                                          Text('Min. Belanja $minPurchase', style: GoogleFonts.inter(fontSize: 12, color: Colors.grey)),
                                          const SizedBox(height: 8),
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                            decoration: BoxDecoration(
                                              border: Border.all(color: HuashuTheme.stainedCinnabarRed.withValues(alpha: 0.5), style: BorderStyle.solid),
                                              borderRadius: BorderRadius.circular(4),
                                            ),
                                            child: Text(
                                              code,
                                              style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.bold, color: HuashuTheme.stainedCinnabarRed),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
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
