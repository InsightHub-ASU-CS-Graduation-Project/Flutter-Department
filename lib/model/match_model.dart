class AnswerModel {
  final String question;
  final int answer;
  final String answerText;

  const AnswerModel({
    required this.question,
    required this.answer,
    required this.answerText,
  });

  factory AnswerModel.fromJson(Map<String, dynamic> json) {
    return AnswerModel(
      question: (json['question'] ?? '').toString(),
      answer: _toInt(json['answer']),
      answerText: (json['answerText'] ?? '').toString(),
    );
  }

  static int _toInt(dynamic value) {
    if (value is int) {
      return value;
    }

    return int.tryParse('$value') ?? 0;
  }
}

class MatchResultModel {
  final String matchedUserName;
  final List<String> jobs;
  final int totalYearsExperience;
  final double similarityScore;
  final List<AnswerModel> employedAnswers;

  const MatchResultModel({
    required this.matchedUserName,
    required this.jobs,
    required this.totalYearsExperience,
    required this.similarityScore,
    required this.employedAnswers,
  });

  factory MatchResultModel.fromJson(Map<String, dynamic> json) {
    final answers = (json['employedAnswers'] as List<dynamic>? ?? const []);
    final jobs = (json['jobs'] as List<dynamic>? ?? const []);

    return MatchResultModel(
      matchedUserName: (json['matchedUserName'] ?? '').toString(),
      jobs: jobs.map((job) => job.toString()).toList(),
      totalYearsExperience: _toInt(json['totalYearsExperience']),
      similarityScore: _toDouble(json['similarityScore']),
      employedAnswers: answers
          .whereType<Map>()
          .map((item) => AnswerModel.fromJson(Map<String, dynamic>.from(item)))
          .toList(),
    );
  }

  static int _toInt(dynamic value) {
    if (value is int) {
      return value;
    }

    return int.tryParse('$value') ?? 0;
  }

  static double _toDouble(dynamic value) {
    if (value is double) {
      return value;
    }

    if (value is int) {
      return value.toDouble();
    }

    return double.tryParse('$value') ?? 0;
  }
}
