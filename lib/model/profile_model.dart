class ProfileModel {
  final String email;
  final String userName;
  final String firstName;
  final String lastName;
  final int? gender;
  final String collage;
  final bool isGraduated;
  final List<ProfileJob> jobs;

  const ProfileModel({
    required this.email,
    required this.userName,
    required this.firstName,
    required this.lastName,
    required this.gender,
    required this.collage,
    required this.isGraduated,
    required this.jobs,
  });

  factory ProfileModel.fromJson(Map<String, dynamic> json) {
    return ProfileModel(
      email: (json['email'] ?? '').toString(),
      userName: (json['userName'] ?? '').toString(),
      firstName: (json['firstName'] ?? '').toString(),
      lastName: (json['lastName'] ?? '').toString(),
      gender: json['gender'] is int ? json['gender'] as int : int.tryParse('${json['gender']}'),
      collage: (json['collage'] ?? '').toString(),
      isGraduated: json['isGraduated'] == true,
      jobs: (json['jobs'] as List<dynamic>? ?? [])
          .whereType<Map<String, dynamic>>()
          .map(ProfileJob.fromJson)
          .toList(),
    );
  }
}

class ProfileJob {
  final String jobName;
  final int? yearsExperience;

  const ProfileJob({
    required this.jobName,
    required this.yearsExperience,
  });

  factory ProfileJob.fromJson(Map<String, dynamic> json) {
    return ProfileJob(
      jobName: (json['jobName'] ?? '').toString(),
      yearsExperience: json['yearsExperience'] is int
          ? json['yearsExperience'] as int
          : int.tryParse('${json['yearsExperience']}'),
    );
  }
}
