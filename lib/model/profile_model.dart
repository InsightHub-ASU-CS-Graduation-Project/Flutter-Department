import 'package:insight_hub/core/utils/safe_parser.dart';

class ProfileModel {
  final String email;
  final String userName;
  final String firstName;
  final String lastName;
  final int? gender;
  final String collage;
  final bool isEmployed;
  final int? yearsExperience;
  final String trackName;
  final bool hasCompletedAssessment;

  const ProfileModel({
    required this.email,
    required this.userName,
    required this.firstName,
    required this.lastName,
    required this.gender,
    required this.collage,
    required this.isEmployed,
    required this.yearsExperience,
    required this.trackName,
    required this.hasCompletedAssessment,
  });

  factory ProfileModel.fromJson(Map<String, dynamic> json) {
    return ProfileModel(
      email: SafeParser.getString(json, 'email'),
      userName: SafeParser.getString(json, 'userName'),
      firstName: SafeParser.getString(json, 'firstName'),
      lastName: SafeParser.getString(json, 'lastName'),
      gender: SafeParser.getInt(json, 'gender'),
      collage: SafeParser.getString(json, 'collage'),
      isEmployed: SafeParser.getBool(json, 'isEmployed'),
      yearsExperience: SafeParser.getInt(json, 'yearsExperience'),
      trackName: SafeParser.getString(json, 'trackName'),
      hasCompletedAssessment: SafeParser.getBool(json, 'hasCompletedAssessment'),
    );
  }
}


