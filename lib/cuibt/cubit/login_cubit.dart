import 'package:bloc/bloc.dart';
import 'package:insight_hub/constant/labor_list.dart';
import 'package:insight_hub/services/api_service.dart';
import 'package:insight_hub/services/secure_storege.dart';
import 'package:meta/meta.dart';

part 'login_state.dart';

class LoginCubit extends Cubit<LoginState> {
  final ApiService _apiService = ApiService();

  LoginCubit() : super(LoginInitial());

  Future<void> login(String email, String password) async {
    emit(LoginLoading());
    try {
      final result = await _apiService.post(
        '/account/login',
        data: {
          'email': email,
          'password': password,
        },
      );

      if (result['success']) {
        // Check if response contains token and store it securely
        final token = result['data']['token'];
        if (token != null) {
          await SecureStorage.writeData(key: tokenKey, value: token);
        }

        emit(LoginSuccess(result));
      } else {
        emit(LoginFailure(result['error']));
      }
    } catch (e) {
      emit(LoginFailure('Unexpected error'));
    }
  }
}
