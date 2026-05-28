import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/huashu_theme.dart';
import '../../../core/network/api_service.dart';

class AdminOrderDetailScreen extends StatefulWidget {
  final dynamic order;

  const AdminOrderDetailScreen({super.key, required this.order});

  @override
  State<AdminOrderDetailScreen> createState() => _AdminOrderDetailScreenState();
}

class _AdminOrderDetailScreenState extends State<AdminOrderDetailScreen> {
  final ApiService _api = ApiService();
  late Map<String, dynamic> _order;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _order = Map<String, dynamic>.from(widget.order);
  }

  Future<void> _updateStatus(String newStatus) async {
    setState(() => _isLoading = true);
    try {
      final response = await _api.dio.put(
        '/api/admin/orders/${_order['id']}/status',
        data: {'status': newStatus},
      );
      if (response.statusCode == 200 && response.data['success'] == true) {
        setState(() {
          _order['status'] = newStatus;
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Status berhasil diupdate')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal update status: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showTrackingDialog() {
    final trackingCtrl = TextEditingController(text: _order['tracking_number'] ?? '');
    final courierCtrl = TextEditingController(text: _order['courier'] ?? '');
    
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Update Resi', style: GoogleFonts.notoSerifSc(fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: courierCtrl,
              decoration: const InputDecoration(labelText: 'Kurir (Opsional)'),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: trackingCtrl,
              decoration: const InputDecoration(labelText: 'Nomor Resi'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('BATAL'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: HuashuTheme.mineralJadeGreen),
            onPressed: () async {
              if (trackingCtrl.text.isEmpty) {
                return;
              }
              Navigator.pop(ctx);
              _updateTracking(trackingCtrl.text, courierCtrl.text);
            },
            child: const Text('SIMPAN'),
          ),
        ],
      ),
    );
  }

  Future<void> _updateTracking(String trackingNumber, String courier) async {
    setState(() => _isLoading = true);
    try {
      final response = await _api.dio.put(
        '/api/admin/orders/${_order['id']}/tracking',
        data: {
          'tracking_number': trackingNumber,
          'courier': courier,
        },
      );
      if (response.statusCode == 200 && response.data['success'] == true) {
        setState(() {
          _order['tracking_number'] = trackingNumber;
          _order['courier'] = courier;
          _order['status'] = 'shipped'; // Update lokal untuk ui instan
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Nomor resi berhasil disimpan')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal menyimpan resi: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showResolveDisputeDialog() {
    final resolutionCtrl = TextEditingController();
    String resolveStatus = 'resolved';

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Selesaikan Komplain', style: GoogleFonts.notoSerifSc(fontWeight: FontWeight.bold)),
        content: StatefulBuilder(
          builder: (context, setModalState) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<String>(
                  value: resolveStatus,
                  decoration: const InputDecoration(labelText: 'Status Keputusan'),
                  items: const [
                    DropdownMenuItem(value: 'resolved', child: Text('Terima (Refund/Ganti)')),
                    DropdownMenuItem(value: 'rejected', child: Text('Tolak Komplain')),
                  ],
                  onChanged: (val) {
                    if (val != null) setModalState(() => resolveStatus = val);
                  },
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: resolutionCtrl,
                  decoration: const InputDecoration(labelText: 'Penjelasan Resolusi', border: OutlineInputBorder()),
                  maxLines: 3,
                ),
              ],
            );
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('BATAL'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: HuashuTheme.mineralJadeGreen),
            onPressed: () async {
              if (resolutionCtrl.text.isEmpty) {
                return;
              }
              Navigator.pop(ctx);
              _resolveDispute(resolutionCtrl.text, resolveStatus);
            },
            child: const Text('SIMPAN KEPUTUSAN'),
          ),
        ],
      ),
    );
  }

  Future<void> _resolveDispute(String resolution, String status) async {
    // Mencari ID dispute. Jika backend melampirkannya di _order['dispute']['id']
    final dispute = _order['dispute'];
    int? disputeId;
    
    if (dispute != null && dispute is Map) {
      disputeId = dispute['id'];
    } else if (_order['disputes'] != null && _order['disputes'] is List && _order['disputes'].isNotEmpty) {
      disputeId = _order['disputes'][0]['id'];
    }

    if (disputeId == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('ID Komplain tidak ditemukan pada pesanan ini')));
      return;
    }

    setState(() => _isLoading = true);
    try {
      final response = await _api.dio.put(
        '/api/admin/disputes/$disputeId/resolve',
        data: {
          'resolution': resolution,
          'status': status,
        },
      );
      if (response.statusCode == 200 && response.data['success'] == true) {
        setState(() {
          _order['status'] = 'resolved'; // Atau sesuai response
          if (_order['dispute'] != null) {
            _order['dispute']['status'] = status;
            _order['dispute']['resolution'] = resolution;
          }
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Komplain berhasil diselesaikan')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal menyelesaikan komplain: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final items = _order['items'] as List<dynamic>? ?? [];
    final address = _order['shipping_address'] as Map<String, dynamic>? ?? {};

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        Navigator.pop(context, true);
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text('Order #${_order['id']}', style: GoogleFonts.notoSerifSc(fontWeight: FontWeight.w600)),
          centerTitle: true,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.pop(context, true),
          ),
        ),
        body: _isLoading
            ? const Center(child: CircularProgressIndicator(color: HuashuTheme.mineralJadeGreen))
            : ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  // ─── Status ────────────────────────
                  Card(
                    color: HuashuTheme.xuanPaperBg,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Status Pesanan', style: GoogleFonts.notoSerifSc(fontWeight: FontWeight.bold, fontSize: 16)),
                          const SizedBox(height: 12),
                          DropdownButtonFormField<String>(
                            value: _order['status']?.toString().toLowerCase(),
                            decoration: const InputDecoration(
                              border: OutlineInputBorder(),
                              contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            ),
                            items: const [
                              DropdownMenuItem(value: 'pending', child: Text('Pending')),
                              DropdownMenuItem(value: 'processing', child: Text('Processing')),
                              DropdownMenuItem(value: 'shipped', child: Text('Shipped')),
                              DropdownMenuItem(value: 'delivered', child: Text('Delivered')),
                              DropdownMenuItem(value: 'cancelled', child: Text('Cancelled')),
                              DropdownMenuItem(value: 'disputed', child: Text('Disputed (Komplain)')),
                            ],
                            onChanged: (val) {
                              if (val != null && val != _order['status']) {
                                _updateStatus(val);
                              }
                            },
                          ),
                          const SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('Nomor Resi: ${_order['tracking_number'] ?? '-'}', style: GoogleFonts.inter()),
                              TextButton(
                                onPressed: _showTrackingDialog,
                                child: Text(_order['tracking_number'] == null ? 'Input Resi' : 'Edit Resi', style: const TextStyle(color: HuashuTheme.mineralJadeGreen)),
                              )
                            ],
                          )
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // ─── Bagian Khusus Dispute (Komplain) ───
                  if (_order['status'] == 'disputed') ...[
                    Card(
                      color: HuashuTheme.stainedCinnabarRed.withValues(alpha: 0.1),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                        side: const BorderSide(color: HuashuTheme.stainedCinnabarRed, width: 1),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.warning_amber_rounded, color: HuashuTheme.stainedCinnabarRed),
                                const SizedBox(width: 8),
                                Text('Pesanan Dalam Komplain (Disputed)', style: GoogleFonts.notoSerifSc(fontWeight: FontWeight.bold, color: HuashuTheme.stainedCinnabarRed)),
                              ],
                            ),
                            const SizedBox(height: 12),
                            if (_order['dispute'] != null) ...[
                              Text('Alasan: ${_order['dispute']['reason']}', style: GoogleFonts.inter(fontWeight: FontWeight.bold)),
                              const SizedBox(height: 4),
                              Text('Deskripsi: ${_order['dispute']['description'] ?? '-'}'),
                              const SizedBox(height: 12),
                            ],
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(backgroundColor: HuashuTheme.stainedCinnabarRed),
                                onPressed: _showResolveDisputeDialog,
                                child: const Text('SELESAIKAN KOMPLAIN (RESOLVE)'),
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],

                  // ─── Detail Pengiriman ────────────────────────
                  Card(
                    color: HuashuTheme.xuanPaperBg,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Alamat Pengiriman', style: GoogleFonts.notoSerifSc(fontWeight: FontWeight.bold, fontSize: 16)),
                          const SizedBox(height: 12),
                          if (address.isNotEmpty) ...[
                            Text(address['recipient'] ?? '', style: GoogleFonts.inter(fontWeight: FontWeight.bold)),
                            Text(address['phone'] ?? ''),
                            const SizedBox(height: 4),
                            Text('${address['address']}, ${address['city']}, ${address['province']} ${address['postal_code']}'),
                          ] else
                            const Text('Tidak ada detail alamat'),
                          if (_order['notes'] != null && _order['notes'].toString().isNotEmpty) ...[
                            const Divider(height: 24),
                            Text('Catatan Pembeli:', style: GoogleFonts.inter(fontWeight: FontWeight.bold)),
                            Text(_order['notes']),
                          ]
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // ─── Daftar Barang ────────────────────────
                  Card(
                    color: HuashuTheme.xuanPaperBg,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Barang yang Dipesan', style: GoogleFonts.notoSerifSc(fontWeight: FontWeight.bold, fontSize: 16)),
                          const SizedBox(height: 12),
                          ...items.map((item) {
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 8.0),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Text('${item['product']?['name'] ?? 'Item'} x${item['quantity']}'),
                                  ),
                                  Text(ApiService.formatPrice((item['price'] as num).toDouble())),
                                ],
                              ),
                            );
                          }),
                          const Divider(height: 24),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('Total Pembayaran', style: GoogleFonts.inter(fontWeight: FontWeight.bold)),
                              Text(
                                ApiService.formatPrice((_order['total_amount'] as num).toDouble()),
                                style: GoogleFonts.inter(fontWeight: FontWeight.bold, color: HuashuTheme.mineralJadeGreen, fontSize: 18),
                              ),
                            ],
                          )
                        ],
                      ),
                    ),
                  )
                ],
              ),
      ),
    );
  }
}
