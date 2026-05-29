import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'auth_helper.dart';

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
        // Gunakan instance Dio baru tanpa interceptor ini agar tidak terjadi infinite loop
        final refreshDio = Dio(BaseOptions(
          baseUrl: dioClient.options.baseUrl,
          connectTimeout: dioClient.options.connectTimeout,
          receiveTimeout: dioClient.options.receiveTimeout,
        ));
        
        final refreshResponse = await refreshDio.post(
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
        // Refresh gagal — hapus semua token dan paksa logout
        await AuthHelper.forceLogoutAndRedirect('Sesi kedaluwarsa, silakan login kembali.');
      }
    }
    return handler.next(err);
  }
}
