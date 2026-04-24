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
  });

  factory ProfileModel.fromJson(Map<String, dynamic> json) {
    return ProfileModel(
      email: (json['email'] ?? '').toString(),
      userName: (json['userName'] ?? '').toString(),
      firstName: (json['firstName'] ?? '').toString(),
      lastName: (json['lastName'] ?? '').toString(),
      gender: json['gender'] is int
          ? json['gender'] as int
          : int.tryParse('${json['gender']}'),
      collage: (json['collage'] ?? '').toString(),
      isEmployed: json['isEmployed'] == true,
      yearsExperience: json['yearsExperience'] is int
          ? json['yearsExperience'] as int
          : int.tryParse('${json['yearsExperience']}'),
      trackName: (json['trackName'] ?? '').toString(),
    );
  }
}
