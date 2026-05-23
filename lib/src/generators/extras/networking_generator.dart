import 'extras_generator.dart';

class NetworkingGenerator extends ExtrasGenerator {
  NetworkingGenerator({
    required super.config,
    required super.fileWriter,
  });

  @override
  Future<void> generate() async {
    await fileWriter.createDirectory('lib/core/network/interceptors');

    await fileWriter.writeFile(
      'lib/core/network/dio_client.dart',
      _dioClientContent(),
    );
    await fileWriter.writeFile(
      'lib/core/network/interceptors/logger_interceptor.dart',
      _loggerInterceptorContent(),
    );
    await fileWriter.writeFile(
      'lib/core/network/interceptors/auth_interceptor.dart',
      _authInterceptorContent(),
    );
  }

  String _dioClientContent() => '''
import 'package:dio/dio.dart';

import 'interceptors/auth_interceptor.dart';
import 'interceptors/logger_interceptor.dart';

class DioClient {
  DioClient({String? baseUrl}) {
    _dio = Dio(
      BaseOptions(
        baseUrl: baseUrl ?? 'https://api.example.com',
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 15),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    _dio.interceptors.addAll([
      AuthInterceptor(),
      LoggerInterceptor(),
    ]);
  }

  late final Dio _dio;

  Dio get instance => _dio;

  Future<Response<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) {
    return _dio.get<T>(path, queryParameters: queryParameters, options: options);
  }

  Future<Response<T>> post<T>(
    String path, {
    Object? data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) {
    return _dio.post<T>(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
    );
  }

  Future<Response<T>> put<T>(
    String path, {
    Object? data,
    Options? options,
  }) {
    return _dio.put<T>(path, data: data, options: options);
  }

  Future<Response<T>> delete<T>(
    String path, {
    Object? data,
    Options? options,
  }) {
    return _dio.delete<T>(path, data: data, options: options);
  }
}
''';

  String _loggerInterceptorContent() => '''
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

class LoggerInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    if (kDebugMode) {
      debugPrint('==> \${options.method} \${options.uri}');
      if (options.data != null) debugPrint('Body: \${options.data}');
    }
    handler.next(options);
  }

  @override
 void onResponse(Response<dynamic> response, ResponseInterceptorHandler handler) {
    if (kDebugMode) {
      debugPrint('<== \${response.statusCode} \${response.requestOptions.uri}');
    }
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (kDebugMode) {
      debugPrint('xx \${err.requestOptions.uri} \${err.message}');
    }
    handler.next(err);
  }
}
''';

  String _authInterceptorContent() => '''
import 'package:dio/dio.dart';

class AuthInterceptor extends Interceptor {
  // TODO: inject your token source (e.g. secure storage) and read it here.
  String? _token;

    set token(String? value) => _token = value;

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    if (_token != null && _token!.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer \$_token';
    }
    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (err.response?.statusCode == 401) {
      // TODO: handle token refresh or sign-out.
    }
    handler.next(err);
  }
}
''';
}