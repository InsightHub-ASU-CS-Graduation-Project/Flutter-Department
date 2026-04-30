import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:insight_hub/constant/labor_list.dart';
import 'package:insight_hub/model/app_error.dart';
import 'package:insight_hub/model/match_model.dart';
import 'package:insight_hub/model/career_quiz_result_model.dart';
import 'package:insight_hub/model/question_model.dart';
import 'package:insight_hub/services/endpoints.dart';
import 'package:insight_hub/services/secure_storege.dart';

class ApiService {
  static final ApiService _instance = ApiService._internal();
  static final ValueNotifier<int> unauthorizedNotifier = ValueNotifier<int>(0);
  late final Dio _dio;
  bool _isHandlingUnauthorized = false;

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
        headers: {'Content-Type': 'application/json'},
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
      await _handleUnauthorized(e);
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

  Future<void> _handleUnauthorized(DioException e) async {
    final statusCode = e.response?.statusCode;
    final requestPath = e.requestOptions.path.toLowerCase();
    final hasAuthHeader =
        e.requestOptions.headers['Authorization']?.toString().isNotEmpty ==
        true;

    final isAuthRequest =
        requestPath == Endpoints.login.toLowerCase() ||
        requestPath == Endpoints.register.toLowerCase();

    final isSessionError = statusCode == 401;

    if (!isSessionError || !hasAuthHeader || isAuthRequest) {
      return;
    }

    if (_isHandlingUnauthorized) {
      return;
    }

    _isHandlingUnauthorized = true;

    try {
      await SecureStorage.deleteData(key: tokenKey);
      unauthorizedNotifier.value++;
    } finally {
      _isHandlingUnauthorized = false;
    }
  }

  String _parseErrorMessage(DioException e) {
    final responseData = e.response?.data;
    final statusCode = e.response?.statusCode;

    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout ||
        e.type == DioExceptionType.sendTimeout) {
      return 'The server is not responding right now. Please try again in a moment.';
    }

    if (e.type == DioExceptionType.connectionError) {
      return 'Unable to connect. Please check your internet or try again later.';
    }

    if (statusCode == 401) {
      if (responseData is Map<String, dynamic>) {
        final apiMessage = AppError.fromJson(responseData).getErrorMessage();
        if (apiMessage.isNotEmpty &&
            apiMessage.toLowerCase() != 'unauthorized' &&
            apiMessage.toLowerCase() != 'unauthenticated' &&
            apiMessage.toLowerCase() != 'unknown error') {
          return apiMessage;
        }
      }

      return 'The email or password is invalid.';
    }

    if (e.type == DioExceptionType.badResponse &&
        responseData is Map<String, dynamic>) {
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
    print("ApiService: GET request to $endpoint, params: $queryParameters");
    return _handleRequest(
      _dio.get(endpoint, queryParameters: queryParameters, options: options),
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

  Future<List<QuestionModel>> fetchQuestions({required bool isEmployed}) async {
    final endpoint = isEmployed ? Endpoints.questions : Endpoints.careerQuizQuestions;
    
    print("ApiService: fetchQuestions called for ${isEmployed ? 'employed' : 'non-employed'} using endpoint: $endpoint");

    // For the existing employee flow, we keep the 'target' query parameter if it was used.
    // For the new career quiz flow, we hit the endpoint directly.
    final result = await get(
      endpoint,
      queryParameters: isEmployed ? {'target': 'employed'} : null,
    );

    print("ApiService: fetchQuestions result success: ${result['success']}");

    if (result['success'] != true) {
      throw Exception(result['error']?.toString() ?? 'Failed to load questions.');
    }

    final items = _extractQuestionList(result['data']);

    return items
        .map((item) => QuestionModel.fromJson(Map<String, dynamic>.from(item)))
        .toList();
  }

  Future<dynamic> submitAnswers({
    required Map<int, dynamic> answers,
    required bool isEmployed,
  }) async {
    final payload = {
      'answers': answers.entries
          .map(
            (entry) => {
              'questionId': entry.key,
              'answerValue': entry.value is int
                  ? entry.value
                  : int.tryParse('${entry.value}') ?? 0,
            },
          )
          .toList(),
    };

    final endpoint = isEmployed ? Endpoints.answers : Endpoints.careerQuizFullMatch;
    final result = await post(endpoint, data: payload);

    if (result['success'] != true) {
      throw Exception(result['error']?.toString() ?? 'Failed to submit answers.');
    }

    if (!isEmployed && result['data'] != null) {
      return CareerQuizResultModel.fromJson(
        Map<String, dynamic>.from(result['data']),
      );
    }
    
    return null;
  }

  Future<CareerQuizResultModel?> fetchCareerQuizResult() async {
    final result = await get(Endpoints.careerQuizResult);

    if (result['success'] != true) {
      throw Exception(result['error']?.toString() ?? 'Failed to load result.');
    }

    if (result['data'] == null) {
      return null;
    }

    return CareerQuizResultModel.fromJson(
      Map<String, dynamic>.from(result['data']),
    );
  }


  List<Map<String, dynamic>> _extractQuestionList(dynamic data) {
    if (data is List) {
      return data
          .whereType<Map>()
          .map((item) => Map<String, dynamic>.from(item))
          .toList();
    }

    if (data is Map<String, dynamic>) {
      final nestedList = data['data'] ?? data['questions'] ?? data['items'];
      if (nestedList is List) {
        return nestedList
            .whereType<Map>()
            .map((item) => Map<String, dynamic>.from(item))
            .toList();
      }
    }

    return const [];
  }
}
