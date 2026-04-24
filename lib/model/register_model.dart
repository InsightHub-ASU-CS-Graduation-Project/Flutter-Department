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
  final int trackId;
  final int yearsExperience;

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
    required this.trackId,
    required this.yearsExperience,
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
      "trackId": trackId,
      "yearsExperience": yearsExperience,
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
      confirmPassword: json["confirmPassword"] ?? '',
      trackId: json["trackId"] ?? 0,
      yearsExperience: json["yearsExperience"] ?? 0,
    );
  }
}
