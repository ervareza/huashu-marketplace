import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'token_refresh_interceptor.dart';

/// Centralized API service singleton.
/// Semua screen menggunakan instance ini agar:
/// - Base URL cukup diganti di SATU tempat
/// - Token interceptor otomatis terpasang
/// - Timeout & error handling konsisten
class ApiService {
  // ═══════════════════════════════════════════════════
  // GANTI URL INI JIKA TEMAN ANDA RESTART NGROK
  // ═══════════════════════════════════════════════════
  static const String baseUrl =
      'https://96a3-2404-c0-b301-8af6-a587-34e-b9b3-3cba.ngrok-free.app';

  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;

  late final Dio dio;
  final FlutterSecureStorage secureStorage = const FlutterSecureStorage();

  ApiService._internal() {
    dio = Dio(BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 15),
      sendTimeout: const Duration(seconds: 15),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        // Header ini mencegah ngrok mengembalikan halaman HTML warning
        'ngrok-skip-browser-warning': 'true',
      },
    ));

    // Pasang token refresh interceptor
    dio.interceptors.add(TokenRefreshInterceptor(dioClient: dio));
  }

  /// Mengekstrak pesan error dari DioException secara aman.
  /// Handle kasus di mana response.data bisa berupa:
  /// - Map (JSON normal) → ambil field 'message'
  /// - String (HTML dari ngrok / plain text) → tampilkan pesan fallback
  /// - null → tampilkan pesan fallback
  static String extractErrorMessage(DioException e, {String fallback = 'Terjadi kesalahan. Harap coba lagi.'}) {
    try {
      // Cek apakah ada response dari server
      final response = e.response;
      if (response == null) {
        // Tidak ada response (timeout, no internet, dll)
        return _getConnectionErrorMessage(e);
      }

      final data = response.data;

      // Jika data adalah Map (JSON response normal)
      if (data is Map<String, dynamic>) {
        return data['message']?.toString() ?? fallback;
      }

      // Jika data adalah String (HTML dari ngrok, plain text error)
      if (data is String) {
        // Cek apakah ini HTML dari ngrok
        if (data.contains('ngrok') || data.contains('<!DOCTYPE')) {
          return 'Server sedang tidak aktif. Hubungi admin backend.';
        }
        // Mungkin plain text error message
        if (data.length < 200) {
          return data;
        }
      }

      return fallback;
    } catch (_) {
      return fallback;
    }
  }

  /// Pesan error spesifik berdasarkan jenis koneksi error
  static String _getConnectionErrorMessage(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
        return 'Koneksi timeout. Server terlalu lambat merespons.';
      case DioExceptionType.sendTimeout:
        return 'Gagal mengirim data. Periksa koneksi internet Anda.';
      case DioExceptionType.receiveTimeout:
        return 'Server tidak merespons tepat waktu.';
      case DioExceptionType.connectionError:
        return 'Tidak dapat terhubung ke server. Periksa koneksi internet.';
      case DioExceptionType.cancel:
        return 'Permintaan dibatalkan.';
      default:
        return 'Koneksi ke server gagal. Harap coba lagi.';
    }
  }

  /// Helper untuk parsing response data secara aman
  static T? safeGet<T>(Map<String, dynamic>? data, String key) {
    if (data == null) return null;
    final value = data[key];
    if (value is T) return value;
    return null;
  }

  /// Safely parse dynamic ID (bisa int atau String dari API)
  static int parseId(dynamic value) {
    if (value is int) return value;
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }

  /// Safely parse price (bisa int, double, atau String "Rp 50.000")
  static double parsePrice(dynamic value) {
    if (value == null) return 0.0;
    if (value is int) return value.toDouble();
    if (value is double) return value;
    if (value is String) {
      final cleaned = value
          .replaceAll('Rp ', '')
          .replaceAll('Rp', '')
          .replaceAll('.', '')
          .replaceAll(',', '.')
          .trim();
      return double.tryParse(cleaned) ?? 0.0;
    }
    return 0.0;
  }

  /// Format harga ke string "Rp 50.000"
  static String formatPrice(double price) {
    final intPrice = price.toInt();
    final formatted = intPrice.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]}.',
    );
    return 'Rp $formatted';
  }
}
