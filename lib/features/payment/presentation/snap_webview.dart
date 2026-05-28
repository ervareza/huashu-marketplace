import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/huashu_theme.dart';
import '../../product/presentation/catalog_screen.dart';

class SnapWebView extends StatefulWidget {
  final String redirectUrl;
  final dynamic orderId; // Handle int/String dari API

  const SnapWebView({
    super.key,
    required this.redirectUrl,
    required this.orderId,
  });

  @override
  State<SnapWebView> createState() => _SnapWebViewState();
}

class _SnapWebViewState extends State<SnapWebView> {
  late final WebViewController _controller;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onNavigationRequest: (NavigationRequest request) {
            final url = request.url.toLowerCase();

            // Deteksi Status dari Callback URL Redirect Midtrans
            if (url.contains('status_code=200') || url.contains('transaction_status=settlement') || url.contains('transaction_status=capture')) {
              _navigateToStatus('sukses');
              return NavigationDecision.prevent;
            } else if (url.contains('status_code=201') || url.contains('transaction_status=pending')) {
              _navigateToStatus('pending');
              return NavigationDecision.prevent;
            } else if (url.contains('status_code=202') || url.contains('transaction_status=deny') || url.contains('transaction_status=expire') || url.contains('transaction_status=cancel')) {
              _navigateToStatus('gagal');
              return NavigationDecision.prevent;
            } else if (url.contains('cancel') || url.contains('close')) {
              _navigateToStatus('cancel');
              return NavigationDecision.prevent;
            }
            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.redirectUrl));
  }

  void _navigateToStatus(String status) {
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => TransactionResultScreen(status: status, orderId: widget.orderId),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('PENYELESAIAN TRANSAKSI'),
        backgroundColor: HuashuTheme.xuanPaperBg,
        foregroundColor: HuashuTheme.charcoalBlack,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => _navigateToStatus('cancel'),
        ),
      ),
      body: WebViewWidget(controller: _controller),
    );
  }
}

class TransactionResultScreen extends StatelessWidget {
  final String status;
  final dynamic orderId;

  const TransactionResultScreen({
    super.key,
    required this.status,
    required this.orderId,
  });

  @override
  Widget build(BuildContext context) {
    Color themeColor = HuashuTheme.charcoalBlack;
    String title = 'TRANSAKSI';
    String message = 'Status transaksi Anda sedang diproses.';
    IconData icon = Icons.info_outline;

    if (status == 'sukses') {
      themeColor = HuashuTheme.mineralJadeGreen;
      title = 'PEMBAYARAN\nBERHASIL';
      message = 'Terima kasih, pembayaran Anda telah diterima dengan baik oleh sistem kami.';
      icon = Icons.verified_user;
    } else if (status == 'pending') {
      themeColor = HuashuTheme.charcoalBlack;
      title = 'MENUNGGU\nPEMBAYARAN';
      message = 'Pesanan telah dibuat. Harap selesaikan transfer sesuai instruksi tagihan Anda.';
      icon = Icons.pending_actions;
    } else if (status == 'gagal' || status == 'cancel') {
      themeColor = HuashuTheme.stainedCinnabarRed;
      title = 'TRANSAKSI\nBATAL / GAGAL';
      message = 'Pembayaran dibatalkan atau tidak disetujui oleh bank terkait.';
      icon = Icons.gavel;
    }

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 48.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 32),
              // Stempel Tradisional Bergaya Status
              Container(
                width: 70,
                height: 70,
                decoration: BoxDecoration(
                  border: Border.all(
                    color: themeColor,
                    width: 2.0,
                  ),
                ),
                alignment: Alignment.center,
                child: Icon(icon, color: themeColor, size: 36),
              ),
              const SizedBox(height: 48),

              // Judul Puitis
              Text(
                title,
                style: GoogleFonts.notoSerifSc(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: themeColor,
                  height: 1.3,
                ),
              ),
              const SizedBox(height: 24),

              // Detail Order ID
              Text(
                'KODE TRANSAKSI: #$orderId',
                style: Theme.of(context).textTheme.labelSmall,
              ),
              const SizedBox(height: 16),

              // Deskripsi Pesan
              Text(
                message,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const Spacer(),

              // Tombol Kembali
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: themeColor,
                  ),
                  onPressed: () {
                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(builder: (_) => const CatalogScreen()),
                      (route) => false,
                    );
                  },
                  child: const Text('KEMBALI KE BERANDA'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
