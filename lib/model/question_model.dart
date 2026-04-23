enum QuestionType {
  singleChoice,
  scale;

  static QuestionType fromApi(String value) {
    final normalized = value.trim().toLowerCase();
    if (normalized == 'singlechoice' || normalized == 'single_choice') {
      return QuestionType.singleChoice;
    }

    return QuestionType.scale;
  }
}

class OptionModel {
  final int id;
  final String text;
  final int numericValue;

  const OptionModel({
    required this.id,
    required this.text,
    required this.numericValue,
  });

  factory OptionModel.fromJson(Map<String, dynamic> json) {
    return OptionModel(
      id: _readInt(json['id'] ?? json['value']),
      text: (json['text'] ?? json['label'] ?? '').toString(),
      numericValue: _readInt(json['numericValue'] ?? json['value'] ?? json['id']),
    );
  }

  static int _readInt(dynamic value) {
    if (value is int) {
      return value;
    }

    return int.tryParse('$value') ?? 0;
  }
}

class QuestionModel {
  final int id;
  final String text;
  final QuestionType type;
  final List<OptionModel> options;

  const QuestionModel({
    required this.id,
    required this.text,
    required this.type,
    required this.options,
  });

  factory QuestionModel.fromJson(Map<String, dynamic> json) {
    final rawOptions = (json['options'] as List<dynamic>? ?? const []);

    return QuestionModel(
      id: _readInt(json['id']),
      text: (json['text'] ?? '').toString(),
      type: QuestionType.fromApi((json['type'] ?? '').toString()),
      options: rawOptions
          .whereType<Map>()
          .map((option) => OptionModel.fromJson(Map<String, dynamic>.from(option)))
          .toList(),
    );
  }

  static int _readInt(dynamic value) {
    if (value is int) {
      return value;
    }

    return int.tryParse('$value') ?? 0;
  }
}
