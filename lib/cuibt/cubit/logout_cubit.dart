import 'package:bloc/bloc.dart';
import 'package:insight_hub/constant/labor_list.dart';
import 'package:insight_hub/services/endpoints.dart';
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
      await _apiService.post(Endpoints.logout);

      await SecureStorage.deleteData(key: tokenKey);

      emit(LogoutSuccess());
    } catch (e) {
      await SecureStorage.deleteData(key: tokenKey);
      emit(LogoutSuccess());
    }
  }
}
