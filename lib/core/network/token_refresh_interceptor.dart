import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class TokenRefreshInterceptor extends QueuedInterceptorsWrapper {
  final Dio dioClient;
  final _secureStorage = const FlutterSecureStorage();

  TokenRefreshInterceptor({required this.dioClient});

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    final token = await _secureStorage.read(key: 'access_token');
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    // Pastikan header ngrok selalu ada
    options.headers['ngrok-skip-browser-warning'] = 'true';
    return handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    if (err.response?.statusCode == 401) {
      final refreshToken = await _secureStorage.read(key: 'refresh_token');
      if (refreshToken == null) {
        return handler.next(err);
      }

      try {
        // Gunakan baseUrl dari dioClient (sudah di-set oleh ApiService)
        final refreshResponse = await dioClient.post(
          '/api/auth/refresh-token',
          data: {'refresh_token': refreshToken},
        );

        if (refreshResponse.statusCode == 200) {
          final data = refreshResponse.data;
          // Safe parsing: data bisa Map atau bukan
          if (data is Map<String, dynamic>) {
            final newAccessToken = data['data']?['token'];
            if (newAccessToken != null) {
              await _secureStorage.write(key: 'access_token', value: newAccessToken.toString());

              final options = err.requestOptions;
              options.headers['Authorization'] = 'Bearer $newAccessToken';

              final cloneRequest = await dioClient.request(
                options.path,
                options: Options(
                  method: options.method,
                  headers: options.headers,
                ),
                data: options.data,
                queryParameters: options.queryParameters,
              );

              return handler.resolve(cloneRequest);
            }
          }
        }
      } catch (refreshError) {
        // Refresh gagal — hapus semua token
        await _secureStorage.delete(key: 'access_token');
        await _secureStorage.delete(key: 'refresh_token');
        await _secureStorage.delete(key: 'user_name');
        await _secureStorage.delete(key: 'user_role');
      }
    }
    return handler.next(err);
  }
}
