import 'dart:convert';

import 'package:bloc/bloc.dart';
import 'package:dio/dio.dart';
import 'package:insight_hub/constant/labor_list.dart';
import 'package:insight_hub/model/app_error.dart';
import 'package:insight_hub/services/Dio.dart';
import 'package:insight_hub/services/secure_storege.dart';
import 'package:meta/meta.dart';

part 'login_state.dart';

class LoginCubit extends Cubit<LoginState> {
  LoginCubit() : super(LoginInitial());

  
  Future<void> login(String email, String password) async {
    emit(LoginLoading());
    try {
        final response =await dio.post(
          Endpoints.login,
          data: {
            'email': email,
            'password': password,
          },
          options: Options(
            headers: {'Content-Type': 'application/json'},
          ),
        );
        //check if response contains token and store it securely
        var token = response.data["token"];
        if (token != null) {
          await SecureStorage.writeData(key: tokenKey, value: token);
          print('Token received: $token');
        }

     
      emit(LoginSuccess({
        'success': true,
        'statusCode': response.statusCode,
        'data': response.data,
      
      }));
    } on DioException catch (e) {
    String errorMessage = 'Something went wrong';

    if (e.type == DioExceptionType.connectionTimeout) {
      errorMessage = 'Connection timeout';
    } else if (e.type == DioExceptionType.badResponse) {
      final data = e.response?.data;

      if (data is Map<String, dynamic>) {
        errorMessage = AppError.fromJson(data).getErrorMessage();
      } else if (data is String) {
        try {
          final decoded = jsonDecode(data);
          if (decoded is Map<String, dynamic>) {
            errorMessage =
                AppError.fromJson(decoded).getErrorMessage();
          }
        } catch (_) {
          errorMessage = data;
        }
      }
    } else {
      errorMessage = 'Network error';
    }

    emit(LoginFailure(errorMessage));
  } catch (e) {
    emit(LoginFailure('Unexpected error'));
  }}
}
