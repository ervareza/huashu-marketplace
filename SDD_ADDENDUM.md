# 💻 SDD Addendum — Blueprint Kode & Implementasi Flutter (Huashu Design)

---

## 1. Implementasi Tema Visual (Huashu Color & Theme System)

Berikut adalah blueprint kode Dart untuk mengonfigurasi palet warna mineral tradisional dan tipografi Huashu ke dalam `ThemeData` global aplikasi Flutter:

```dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class HuashuTheme {
  // Token Warna Mineral Tradisional
  static const Color xuanPaperBg = Color(0xFFF7F5F0);
  static const Color charcoalBlack = Color(0xFF1E1E1E);
  static const Color mineralJadeGreen = Color(0xFF2D5A43);
  static const Color stainedCinnabarRed = Color(0xFFB83A2C);
  static const Color lightInkLine = Color(0xFFE2DFD5);

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: xuanPaperBg,
      colorScheme: const ColorScheme.light(
        primary: mineralJadeGreen,
        secondary: charcoalBlack,
        error: stainedCinnabarRed,
        surface: xuanPaperBg,
      ),
      
      // Pembatalan Card Radius Tebal (Anti-Slop)
      cardTheme: const CardTheme(
        color: Colors.transparent,
        elevation: 0,
        shape: RoundedRectangleBorder(
          side: BorderSide(color: lightInkLine, width: 0.5),
          borderRadius: BorderRadius.zero,
        ),
      ),
      
      // Tipografi Ritme Puitis (Serif Klasik + Sans-Serif Bersih)
      textTheme: TextTheme(
        displayLarge: GoogleFonts.notoSerifSc(
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: charcoalBlack,
        ),
        headlineMedium: GoogleFonts.notoSerifSc(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: charcoalBlack,
        ),
        bodyLarge: GoogleFonts.inter(
          fontSize: 16,
          height: 1.6,
          color: charcoalBlack,
        ),
        bodyMedium: GoogleFonts.inter(
          fontSize: 14,
          height: 1.5,
          color: charcoalBlack.withOpacity(0.8),
        ),
        labelSmall: GoogleFonts.inter(
          fontSize: 11,
          letterSpacing: 1.5,
          fontWeight: FontWeight.w500,
          color: charcoalBlack.withOpacity(0.6),
        ),
      ),

      // Input Field Bergaya Underscore Tradisional
      inputDecorationTheme: const InputDecorationTheme(
        filled: false,
        border: UnderlineInputBorder(
          borderSide: BorderSide(color: charcoalBlack, width: 0.5),
        ),
        enabledBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: lightInkLine, width: 0.5),
        ),
        focusedBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: mineralJadeGreen, width: 1.0),
        ),
        errorBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: stainedCinnabarRed, width: 0.5),
        ),
      ),

      // Tombol Aksi Persegi Tajam (0px Radius)
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: charcoalBlack,
          foregroundColor: xuanPaperBg,
          elevation: 0,
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.zero, // Persegi tajam
          ),
          textStyle: GoogleFonts.inter(
            fontWeight: FontWeight.w600,
            letterSpacing: 1.0,
          ),
        ),
      ),
    );
  }
}
```

---

## 2. Aksen Kustom Kuas Tinta (Ink Brush Divider Widget)

Custom widget menggambar pembatas tipis berkarakter kaligrafi/sapuan tinta alami menggunakan `CustomPainter` Flutter:

```dart
import 'package:flutter/material.dart';

class InkBrushDivider extends StatelessWidget {
  final double height;
  final Color color;

  const InkBrushDivider({
    super.key,
    this.height = 2.0,
    this.color = const Color(0xFFE2DFD5),
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(double.infinity, height),
      painter: _InkBrushPainter(color: color),
    );
  }
}

class _InkBrushPainter extends CustomPainter {
  final Color color;

  _InkBrushPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = size.height
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final path = Path();
    // Membuat garis pembatas melengkung mikro menyerupai sapuan kuas halus alami
    path.moveTo(0, size.height / 2);
    path.quadraticBezierTo(
      size.width * 0.25, size.height * 0.1,
      size.width * 0.5, size.height / 2,
    );
    path.quadraticBezierTo(
      size.width * 0.75, size.height * 0.9,
      size.width, size.height / 2,
    );

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
```

---

## 3. Interceptor Autentikasi Dio (Token Refresh Interceptor)

Implementasi otomatis pembaharuan JWT Token access secara senyap (silent renew) saat terdeteksi status `HTTP 401 Unauthorized`:

```dart
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class TokenRefreshInterceptor extends QueuedInterceptorsWrapper {
  final Dio dioClient;
  final _secureStorage = const FlutterSecureStorage();
  final String _authBaseUrl = 'https://96a3-2404-c0-b301-8af6-a587-34e-b9b3-3cba.ngrok-free.app';

  TokenRefreshInterceptor({required this.dioClient});

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    final token = await _secureStorage.read(key: 'access_token');
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    return handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    // Intercept saat terdeteksi HTTP 401 Unauthorized
    if (err.response?.statusCode == 401) {
      final refreshToken = await _secureStorage.read(key: 'refresh_token');
      if (refreshToken == null) {
        return handler.next(err); // Tidak ada refresh token, teruskan error login
      }

      try {
        // Melakukan request pembaharuan token secara terisolasi (Queued)
        final refreshResponse = await dioClient.post(
          '$_authBaseUrl/api/auth/refresh-token',
          data: {'refresh_token': refreshToken},
        );

        if (refreshResponse.statusCode == 200) {
          final newAccessToken = refreshResponse.data['data']['token'];
          
          // Simpan token baru ke Secure Storage
          await _secureStorage.write(key: 'access_token', value: newAccessToken);

          // Susun kembali header request yang gagal dengan token baru
          final options = err.requestOptions;
          options.headers['Authorization'] = 'Bearer $newAccessToken';

          // Ulangi request asli yang gagal
          final cloneRequest = await dioClient.request(
            options.path,
            options: Options(
              method: options.method,
              headers: options.headers,
            ),
            data: options.data,
            queryParameters: options.queryParameters,
          );

          return handler.resolve(cloneRequest); // Kembalikan response sukses kloning
        }
      } catch (refreshError) {
        // Refresh token gagal / kadaluarsa, hapus sesi dan paksa login ulang
        await _secureStorage.delete(key: 'access_token');
        await _secureStorage.delete(key: 'refresh_token');
        // Pemicu navigasi global ke layar login dapat ditempatkan di sini
      }
    }
    return handler.next(err); // Teruskan error asli jika bukan 401 / refresh gagal
  }
}
```

---

## 4. WebView Midtrans Snap (WebView Transaction Container)

Kontainer WebView Flutter (`webview_flutter`) terintegrasi untuk memuat tautan pembayaran Snap, menyaring navigasi sukses/gagal, dan mengeksekusi aksi callback:

```dart
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class MidtransSnapWebView extends StatefulWidget {
  final String redirectUrl;
  final VoidCallback onSuccess;
  final VoidCallback onPending;
  final VoidCallback onError;
  final VoidCallback onCancel;

  const MidtransSnapWebView({
    super.key,
    required this.redirectUrl,
    required this.onSuccess,
    required this.onPending,
    required this.onError,
    required this.onCancel,
  });

  @override
  State<MidtransSnapWebView> createState() => _MidtransSnapWebViewState();
}

class _MidtransSnapWebViewState extends State<MidtransSnapWebView> {
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

            // Intercept URL Callback status pembayaran dari Snap
            if (url.contains('status_code=200') || url.contains('transaction_status=settlement') || url.contains('transaction_status=capture')) {
              widget.onSuccess();
              return NavigationDecision.prevent;
            } else if (url.contains('status_code=201') || url.contains('transaction_status=pending')) {
              widget.onPending();
              return NavigationDecision.prevent;
            } else if (url.contains('status_code=202') || url.contains('transaction_status=deny') || url.contains('transaction_status=expire') || url.contains('transaction_status=cancel')) {
              widget.onError();
              return NavigationDecision.prevent;
            } else if (url.contains('cancel') || url.contains('close')) {
              widget.onCancel();
              return NavigationDecision.prevent;
            }
            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.redirectUrl));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pembayaran Snap'),
        backgroundColor: const Color(0xFFF7F5F0),
        foregroundColor: const Color(0xFF1E1E1E),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: widget.onCancel,
        ),
      ),
      body: WebViewWidget(controller: _controller),
    );
  }
}
```
