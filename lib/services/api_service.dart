import 'package:dio/dio.dart';
import 'package:insight_hub/constant/labor_list.dart';
import 'package:insight_hub/services/secure_storege.dart';

class ApiService {
  static final ApiService _instance = ApiService._internal();
  late final Dio _dio;

  factory ApiService() {
    return _instance;
  }

  ApiService._internal() {
    _dio = Dio(
      BaseOptions(
        baseUrl: 'https://saccharinely-hormonal-annelle.ngrok-free.dev/api',
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
        headers: {
          'Content-Type': 'application/json',
        },
      ),
    );

    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          // Automatically add token if available
          final token = await SecureStorage.readData(key: tokenKey);
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          return handler.next(options);
        },
        onError: (DioException e, handler) {
          // Centralized error handling
          return handler.next(e);
        },
      ),
    );
  }

  Future<Map<String, dynamic>> _handleRequest(Future<Response> request) async {
    try {
      final response = await request;
      return {
        'success': true,
        'statusCode': response.statusCode,
        'data': response.data,
      };
    } on DioException catch (e) {
      String errorMessage = 'Something went wrong';

      if (e.type == DioExceptionType.connectionTimeout) {
        errorMessage = 'Connection timeout';
      } else if (e.type == DioExceptionType.badResponse) {
        final data = e.response?.data;
        if (data is Map<String, dynamic> && data.containsKey('message')) {
          errorMessage = data['message'];
        } else if (data is String) {
          errorMessage = data;
        }
      } else {
        errorMessage = 'Network error';
      }

      return {
        'success': false,
        'statusCode': e.response?.statusCode,
        'error': errorMessage,
        'data': e.response?.data,
      };
    } catch (e) {
      return {
        'success': false,
        'error': 'Unexpected error: $e',
      };
    }
  }

  Future<Map<String, dynamic>> get(String endpoint, {Map<String, dynamic>? queryParameters}) {
    return _handleRequest(_dio.get(endpoint, queryParameters: queryParameters));
  }

  Future<Map<String, dynamic>> post(String endpoint, {Map<String, dynamic>? data}) {
    return _handleRequest(_dio.post(endpoint, data: data));
  }

  Future<Map<String, dynamic>> put(String endpoint, {Map<String, dynamic>? data}) {
    return _handleRequest(_dio.put(endpoint, data: data));
  }

  Future<Map<String, dynamic>> delete(String endpoint) {
    return _handleRequest(_dio.delete(endpoint));
  }
}