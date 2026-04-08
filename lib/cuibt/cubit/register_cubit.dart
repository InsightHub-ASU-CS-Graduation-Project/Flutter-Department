import 'package:bloc/bloc.dart';
import 'package:insight_hub/constant/labor_list.dart';
import 'package:insight_hub/services/api_service.dart';
import 'package:insight_hub/services/secure_storege.dart';
import 'package:meta/meta.dart';
import 'package:insight_hub/model/register_model.dart';
import 'package:insight_hub/model/jop_year.dart';
part 'register_state.dart';

class RegisterCubit extends Cubit<RegisterState> {
  final ApiService _apiService = ApiService();

  RegisterCubit() : super(RegisterInitial());

  String? firstName;
  String? lastName;
  int? gender;
  DateTime? birthDate;
  String? collage;
  bool? isGraduated;
  String? email;
  String? password;
  String? confirmPassword;
  List<SelectedJob> selectedJobs = [];

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

  /// Save Graduation Status
  void saveGraduation(bool value) {
    isGraduated = value;
  }

  /// Save Selected Jobs
  void saveJobs(List<SelectedJob> jobs) {
    selectedJobs = jobs;
  }


  /// Submit Register
  Future<void> submitRegister() async {
    emit(RegisterLoading());

    final model = buildModel();

    try {
      final result = await _apiService.post(
        '/Account/register',
        data: model.toJson(),
      );

      if (result['success']) {
        final token = result['data']['token'];
        if (token != null) {
          await SecureStorage.writeData(key: tokenKey, value: token);
        }

        emit(RegisterSuccess(result));
      } else {
        emit(RegisterFailure(result['error']));
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
      isGraduated: isGraduated!,
      email: email!,
      password: password!,
      confirmPassword: confirmPassword!,
      selectedJobs: selectedJobs,
    );
  }
}











