import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class TokenRefreshInterceptor extends QueuedInterceptorsWrapper {
  final Dio dioClient;
  final _secureStorage = const FlutterSecureStorage();
  final String _authBaseUrl = 'https://d04a-2404-c0-b301-8af6-a587-34e-b9b3-3cba.ngrok-free.app';

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
    if (err.response?.statusCode == 401) {
      final refreshToken = await _secureStorage.read(key: 'refresh_token');
      if (refreshToken == null) {
        return handler.next(err);
      }

      try {
        final refreshResponse = await dioClient.post(
          '$_authBaseUrl/api/auth/refresh-token',
          data: {'refresh_token': refreshToken},
        );

        if (refreshResponse.statusCode == 200) {
          final newAccessToken = refreshResponse.data['data']['token'];
          
          await _secureStorage.write(key: 'access_token', value: newAccessToken);

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
      } catch (refreshError) {
        await _secureStorage.delete(key: 'access_token');
        await _secureStorage.delete(key: 'refresh_token');
      }
    }
    return handler.next(err);
  }
}
