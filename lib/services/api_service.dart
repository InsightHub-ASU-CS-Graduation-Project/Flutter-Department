import 'package:dio/dio.dart';
import 'package:insight_hub/constant/labor_list.dart';
import 'package:insight_hub/model/app_error.dart';
import 'package:insight_hub/services/endpoints.dart';
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
        baseUrl: Endpoints.baseUrl,
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
        sendTimeout: const Duration(seconds: 10),
        responseType: ResponseType.json,
        headers: {
          'Content-Type': 'application/json',
        },
      ),
    );

    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await SecureStorage.readData(key: tokenKey);
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          return handler.next(options);
        },
      ),
    );
  }

  Future<Map<String, dynamic>> _handleRequest(
    Future<Response<dynamic>> request,
  ) async {
    try {
      final response = await request;
      return {
        'success': true,
        'statusCode': response.statusCode,
        'data': response.data,
        'error': null,
      };
    } on DioException catch (e) {
      final errorMessage = _parseErrorMessage(e);

      return {
        'success': false,
        'statusCode': e.response?.statusCode,
        'data': e.response?.data,
        'error': errorMessage,
      };
    } catch (e) {
      return {
        'success': false,
        'statusCode': null,
        'data': null,
        'error': 'Unexpected error: $e',
      };
    }
  }

  String _parseErrorMessage(DioException e) {
    final responseData = e.response?.data;

    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout ||
        e.type == DioExceptionType.sendTimeout) {
      return 'The server is not responding right now. Please try again in a moment.';
    }

    if (e.type == DioExceptionType.connectionError) {
      return 'Unable to connect. Please check your internet or try again later.';
    }

    if (e.type == DioExceptionType.badResponse && responseData is Map<String, dynamic>) {
      return AppError.fromJson(responseData).getErrorMessage();
    }

    final responseText = responseData?.toString() ?? '';
    if (responseText.contains('ERR_NGROK_3200')) {
      return 'The server is currently offline. Please try again later.';
    }

    return e.message ?? 'Something went wrong. Please try again.';
  }

  Future<Map<String, dynamic>> get(
    String endpoint, {
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) {
    return _handleRequest(
      _dio.get(
        endpoint,
        queryParameters: queryParameters,
        options: options,
      ),
    );
  }

  Future<Map<String, dynamic>> post(
    String endpoint, {
    dynamic data,
    Options? options,
    Map<String, dynamic>? queryParameters,
  }) {
    return _handleRequest(
      _dio.post(
        endpoint,
        data: data,
        queryParameters: queryParameters,
        options: options,
      ),
    );
  }

  Future<Map<String, dynamic>> put(
    String endpoint, {
    dynamic data,
    Options? options,
    Map<String, dynamic>? queryParameters,
  }) {
    return _handleRequest(
      _dio.put(
        endpoint,
        data: data,
        queryParameters: queryParameters,
        options: options,
      ),
    );
  }

  Future<Map<String, dynamic>> delete(
    String endpoint, {
    dynamic data,
    Options? options,
    Map<String, dynamic>? queryParameters,
  }) {
    return _handleRequest(
      _dio.delete(
        endpoint,
        data: data,
        queryParameters: queryParameters,
        options: options,
      ),
    );
  }
}












