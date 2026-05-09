import 'package:bloc/bloc.dart';
import 'package:InsightHub/core/constant/labor_list.dart';
import 'package:InsightHub/core/services/endpoints.dart';
import 'package:InsightHub/core/services/api_service.dart';
import 'package:InsightHub/core/services/secure_storege.dart';
import 'package:meta/meta.dart';
import 'package:InsightHub/feature/auth/models/register_model.dart';
part 'register_state.dart';

class RegisterCubit extends Cubit<RegisterState> {
  final ApiService _apiService = ApiService();

  RegisterCubit() : super(RegisterInitial());

  String? firstName;
  String? lastName;
  int? gender;
  DateTime? birthDate;
  String? collage;
  bool? isEmployed;
  String? email;
  String? password;
  String? confirmPassword;
  int? trackId;
  int? yearsExperience;

  /// Save Email
  void saveEmail(String value) {
    email = value;
  }

  /// Save Password
  void savePassword(String value) {
    password = value;
    confirmPassword = value; // Since they match, use same value
  }

  /// Save Name
  void saveName(String first, String last) {
    firstName = first;
    lastName = last;
  }

  /// Save Gender
  void saveGender(int value) {
    gender = value;
  }

  /// Save Birth Date
  void saveBirthDate(DateTime value) {
    birthDate = value;
  }

  /// Save Collage
  void saveCollage(String value) {
    collage = value;
  }

  /// Save Employment Status
  void saveEmployment(bool value) {
    isEmployed = value;
  }

  /// Save Labor Info
  void saveLaborInfo(int track, int exp) {
    trackId = track;
    yearsExperience = exp;
  }


  /// Submit Register
  Future<void> submitRegister() async {
    emit(RegisterLoading());

    final model = buildModel();

    try {
      final result = await _apiService.post(
        Endpoints.register,
        data: model.toJson(),
      );

      if (result['success'] == true) {
        final data = result['data'];
        final token = data is Map<String, dynamic> ? data['token'] : null;
        if (token != null) {
          await SecureStorage.writeData(key: tokenKey, value: token.toString());
        }

        emit(RegisterSuccess(result));
      } else {
        emit(RegisterFailure(result['error']?.toString() ?? 'Registration failed'));
      }
    } catch (e) {
      emit(RegisterFailure('Unexpected error: $e'));
    }
  }

  // Build RegisterModel
  RegisterModel buildModel() {
    return RegisterModel(
      firstName: firstName!,
      lastName: lastName!,
      gender: gender!,
      birthDate: birthDate!,
      collage: collage!,
      isEmployed: isEmployed!,
      email: email!,
      password: password!,
      confirmPassword: confirmPassword!,
      trackId: trackId,
      yearsExperience: yearsExperience,
    );
  }

  void reset() {
    firstName = null;
    lastName = null;
    gender = null;
    birthDate = null;
    collage = null;
    isEmployed = null;
    email = null;
    password = null;
    confirmPassword = null;
    trackId = null;
    yearsExperience = null;
    emit(RegisterInitial());
  }
}











