import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:insight_hub/model/register_model.dart';
import 'package:insight_hub/model/jop_year.dart';
import 'package:insight_hub/services/Dio.dart';

part 'register_state.dart';

class RegisterCubit extends Cubit<RegisterState> {
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


  /// Register User
  Future<Map<String, dynamic>> register() async {
    final model = buildModel();
    return await registerUser(model);
  }

  /// ld RegisterModel
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