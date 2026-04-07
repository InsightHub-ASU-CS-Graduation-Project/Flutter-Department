import 'dart:convert';

import 'package:bloc/bloc.dart';
import 'package:dio/dio.dart';
import 'package:insight_hub/constant/labor_list.dart';
import 'package:insight_hub/services/secure_storege.dart';
// ignore: depend_on_referenced_packages
import 'package:meta/meta.dart';
import 'package:insight_hub/model/register_model.dart';
import 'package:insight_hub/model/jop_year.dart';
import 'package:insight_hub/model/app_error.dart';
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


  /// Submit Register
  Future<void> submitRegister() async {


    emit(RegisterLoading());

    final model = buildModel();

    try {
      final response = await dio.post(
        Endpoints.register,
        data: model.toJson(),
        options: Options(
          headers: {'Content-Type': 'application/json'},
        ),
      );
    var token = response.data["token"];
    if (token != null) {
        // Store the token securely, e.g., using flutter_secure_storage
        // await FlutterSecureStorage().write(key: tokenKey, value: token);
        await SecureStorage.writeData(key: tokenKey, value: token);
        print('Token received: $token');
      }

      emit(RegisterSuccess({
        'success': true,
        'statusCode': response.statusCode,
        'data': response.data,
      }));
    } on DioException catch (e) {
      String errorMessage = 'Unknown error';
      final responseData = e.response?.data;

      if (responseData != null) {
        if (responseData is Map<String, dynamic>) {
          final appError = AppError.fromJson(responseData);
          errorMessage = appError.getErrorMessage();
        } else if (responseData is String) {
          try {
            final decoded = jsonDecode(responseData);
            if (decoded is Map<String, dynamic>) {
              final appError = AppError.fromJson(decoded);
              errorMessage = appError.getErrorMessage();
            } else if (decoded is List) {
              errorMessage = decoded.join(', ');
            } else {
              errorMessage = responseData;
            }
          } catch (_) {
            errorMessage = responseData;
          }
        } else if (responseData is List) {
          errorMessage = responseData.join(', ');
        } else {
          errorMessage = responseData.toString();
        }
      } else {
        errorMessage = 'Network error';
      }

      emit(RegisterFailure(errorMessage));
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











