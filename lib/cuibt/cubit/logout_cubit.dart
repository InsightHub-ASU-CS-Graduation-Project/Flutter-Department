import 'package:bloc/bloc.dart';
import 'package:insight_hub/constant/labor_list.dart';
import 'package:insight_hub/services/api_service.dart';
import 'package:insight_hub/services/secure_storege.dart';
import 'package:meta/meta.dart';

part 'logout_state.dart';

class LogoutCubit extends Cubit<LogoutState> {
  final ApiService _apiService = ApiService();

  LogoutCubit() : super(LogoutInitial());

  Future<void> logout() async {
    emit(LogoutLoading());
    try {
      // Call the logout endpoint
      final result = await _apiService.post('/account/logout');

      // Always delete the local token, even if API call fails
      await SecureStorage.deleteData(key: tokenKey);

      if (result['success']) {
        emit(LogoutSuccess());
      } else {
        // Still emit success since token is deleted locally
        emit(LogoutSuccess());
      }
    } catch (e) {
      // Still delete token and emit success
      await SecureStorage.deleteData(key: tokenKey);
      emit(LogoutSuccess());
    }
  }
}
