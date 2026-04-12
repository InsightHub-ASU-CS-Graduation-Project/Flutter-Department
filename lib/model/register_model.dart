import 'package:insight_hub/model/jop_year.dart';

class RegisterModel {
  final String firstName;
  final String lastName;
  final int gender;
  final DateTime birthDate;
  final String collage;
  final bool isEmployed;
  final String email;
  final String password;
  final String confirmPassword;
  final List<SelectedJob> selectedJobs;

  const RegisterModel({
    required this.firstName,
    required this.lastName,
    required this.gender,
    required this.birthDate,
    required this.collage,
    required this.isEmployed,
    required this.email,
    required this.password,
    required this.confirmPassword,
    required this.selectedJobs,
  });

  Map<String, dynamic> toJson() {
    return {
      "firstName": firstName,
      "lastName": lastName,
      "gender": gender,
      "birthDate":  birthDate.toUtc().toIso8601String(),
      "collage": collage,
      "isEmployed": isEmployed,
      "email": email,
      "password": password,
      "confirmPassword": confirmPassword,
      "selectedJobs": selectedJobs.map((e) => e.toJson()).toList(),
    };
  }

  factory RegisterModel.fromJson(Map<String, dynamic> json) {
    return RegisterModel(
      firstName: json["firstName"],
      lastName: json["lastName"],
      gender: json["gender"],
      birthDate: DateTime.parse(json["birthDate"]),
      collage: json["collage"],
      isEmployed: json["isEmployed"],
      email: json["email"],
      password: json["password"],
      selectedJobs: (json["selectedJobs"] as List)
          .map((e) => SelectedJob.fromJson(e))
          .toList(), confirmPassword: '',
    
    );
  }
}
