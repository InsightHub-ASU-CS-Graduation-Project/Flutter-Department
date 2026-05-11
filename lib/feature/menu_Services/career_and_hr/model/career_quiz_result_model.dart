
/// يمثل الاستجابة الكاملة القادمة من endpoints الخاصة بـ **Career Quiz**:
/// - `POST /CareerQuiz/full-match` (بعد إرسال إجابات الـ quiz مباشرة)
/// - `GET  /CareerQuiz/result`     (جلب آخر نتيجة محفوظة للمستخدم)
///
/// ## شكل JSON (مختصر)
/// ```json
/// {
///   "topTracks": [ { "track": {...}, "trackSimilarityScore": 80.4, "combinedScore": 88.2,
///                   "similarityMessage": "...", "marketInsights": {...} } ],
///   "message": "Top recommendation: Mobile Dev."
/// }
/// ```
///
/// ## لماذا هذا model منفصل؟
/// لأن الـ backend يرجّع شكل JSON مختلف تمامًا عن employed flow (employee match).
class CareerQuizResultModel {
  final List<TrackMatch> topTracks;
  final String message;

  const CareerQuizResultModel({
    required this.topTracks,
    required this.message,
  });

  factory CareerQuizResultModel.fromJson(Map<String, dynamic> json) {
    final tracksRaw = (json['topTracks'] as List<dynamic>? ?? const []);
    print("CareerQuizResultModel: Parsing ${tracksRaw.length} tracks from JSON");
    
    final parsedTracks = tracksRaw
        .whereType<Map>()
        .map((item) => TrackMatch.fromJson(Map<String, dynamic>.from(item)))
        .toList();
        
    print("CareerQuizResultModel: Successfully parsed ${parsedTracks.length} tracks");

    return CareerQuizResultModel(
      topTracks: parsedTracks,
      message: (json['message'] ?? '').toString(),
    );
  }

  factory CareerQuizResultModel.dummy() {
    return CareerQuizResultModel(
      topTracks: [
        TrackMatch(
          track: TrackInfo(
            trackId: 1,
            trackName: 'Software Engineering',
            description: 'Designing, developing, and maintaining software systems.',
            requiredSkills: 'Dart, Flutter, UI/UX, Firebase, REST APIs, Git, Teamwork, Problem Solving, Clean Code, Architecture',
            score: 95,
            maxScore: 100,
            percentage: 95,
          ),
          trackSimilarityScore: 90,
          combinedScore: 92,
          similarityMessage: 'Great match!',
          marketInsights: MarketInsights(
            totalEmployeesInTrack: 15000,
            avgTechnicalLevel: 4.5,
            avgSoftSkills: 4.2,
            avgSalarySatisfaction: 4.0,
            avgWorkLifeBalance: 3.8,
            mostCommonEnvironment: 'Hybrid',
            mostCommonCompanySize: 'Enterprise',
            avgYearsExperience: 5.5,
            avgConsistency: 4.0,
            avgAdaptability: 4.2,
            avgTeamwork: 4.5,
            avgProblemSolving: 4.6,
            avgLearningProactivity: 4.4,
            avgCommunication: 4.1,
            avgPrioritization: 4.0,
            avgOwnership: 4.3,
            avgCollaboration: 4.4,
            avgResilience: 4.2,
          ),
        ),
      ],
      message: 'Loading your best matches...',
    );
  }
}

class TrackMatch {
  /// معلومات المسار نفسه (Nested model).
  ///
  /// لماذا Nested؟
  /// لأن `TrackInfo` يُستخدم كـ "وحدة بيانات" مستقلة ممكن تتكرر/تُشارك
  /// بين endpoints مختلفة بدون تكرار نفس الحقول داخل كذا model.
  final TrackInfo track;

  /// مقياس تشابه (عادة 0..100) يعبّر عن "كم هذا المسار قريب من المستخدم".
  final double trackSimilarityScore;

  /// **Primary score** المقترح عرضه بشكل بارز في UI.
  ///
  /// سبب وجوده:
  /// - يجمع بين score مختلفة داخل backend (مثلاً aptitude + preference alignment)
  /// - يعطي ranking أفضل من الاعتماد على percentage وحدها
  final double combinedScore;

  /// جملة تفسيرية موجهة للمستخدم: "لماذا هذا المسار مناسب لك؟"
  final String similarityMessage;

  /// Insights سوق العمل والـ metrics (Nested model).
  ///
  /// لماذا Nested؟
  /// لأن هذه المجموعة من الحقول كبيرة، ولها منطق عرض مختلف تمامًا عن
  /// Track overview / Skills، وبالتالي فصلها يحسن الصيانة ووضوح الـ UI.
  final MarketInsights marketInsights;

  const TrackMatch({
    required this.track,
    required this.trackSimilarityScore,
    required this.combinedScore,
    required this.similarityMessage,
    required this.marketInsights,
  });

  factory TrackMatch.fromJson(Map<String, dynamic> json) {
    return TrackMatch(
      track: TrackInfo.fromJson(Map<String, dynamic>.from(json['track'] ?? {})),
      trackSimilarityScore: _toDouble(json['trackSimilarityScore']),
      combinedScore: _toDouble(json['combinedScore']),
      similarityMessage: (json['similarityMessage'] ?? '').toString(),
      marketInsights: MarketInsights.fromJson(
          Map<String, dynamic>.from(json['marketInsights'] ?? {})),
    );
  }

  static double _toDouble(dynamic value) {
    if (value is double) return value;
    if (value is int) return value.toDouble();
    return double.tryParse('$value') ?? 0;
  }
}

class TrackInfo {
  /// معرف المسار من الـ backend.
  final int trackId;

  /// اسم المسار (مثل: Mobile Dev).
  final String trackName;

  /// وصف مختصر للمسار.
  final String description;

  /// المهارات المطلوبة كما تأتي من الـ backend (سلسلة مفصولة بفواصل).
  ///
  /// ملاحظة UX:
  /// - لا نعرضها كسطر نصي طويل.
  /// - نحولها في UI إلى Chips/Tags باستخدام `requiredSkillsList`.
  final String requiredSkills;

  /// score الداخلي (حسب أسئلة الـ quiz) — عادة يكون أقل معنى للمستخدم من combinedScore.
  final double score;

  /// الحد الأقصى للـ score.
  final double maxScore;

  /// نسبة مئوية (0..100) — metric ثانوية مقارنة بـ combinedScore.
  final double percentage;

  const TrackInfo({
    required this.trackId,
    required this.trackName,
    required this.description,
    required this.requiredSkills,
    required this.score,
    required this.maxScore,
    required this.percentage,
  });

  /// Parsed skills as clean list of chips/tags.
  List<String> get requiredSkillsList => requiredSkills
      .split(',')
      .map((s) => s.trim())
      .where((s) => s.isNotEmpty)
      .toList(growable: false);

  factory TrackInfo.fromJson(Map<String, dynamic> json) {
    return TrackInfo(
      trackId: _toInt(json['trackId']),
      trackName: (json['trackName'] ?? '').toString(),
      description: (json['description'] ?? '').toString(),
      requiredSkills: (json['requiredSkills'] ?? '').toString(),
      score: _toDouble(json['score']),
      maxScore: _toDouble(json['maxScore']),
      percentage: _toDouble(json['percentage']),
    );
  }

  static int _toInt(dynamic value) {
    if (value is int) return value;
    return int.tryParse('$value') ?? 0;
  }

  static double _toDouble(dynamic value) {
    if (value is double) return value;
    if (value is int) return value.toDouble();
    return double.tryParse('$value') ?? 0;
  }
}

class MarketInsights {
  /// إجمالي عدد الموظفين/المحترفين داخل هذا المسار في البيانات (للـ context السوقي).
  final int totalEmployeesInTrack;

  /// متوسط المستوى التقني (عادة scale من 1..5).
  final double avgTechnicalLevel;

  /// متوسط الـ soft skills.
  final double avgSoftSkills;

  /// رضا الرواتب.
  final double avgSalarySatisfaction;

  /// توازن الحياة والعمل.
  final double avgWorkLifeBalance;

  /// بيئة العمل الأكثر شيوعًا (Office / Remote / Hybrid).
  final String mostCommonEnvironment;

  /// حجم الشركة الأكثر شيوعًا.
  final String mostCommonCompanySize;

  /// متوسط سنوات الخبرة.
  final double avgYearsExperience;
  
  /// Metrics سلوكية/أداء (1..5).
  final double avgConsistency;
  final double avgAdaptability;
  final double avgTeamwork;
  final double avgProblemSolving;
  final double avgLearningProactivity;
  final double avgCommunication;
  final double avgPrioritization;
  final double avgOwnership;
  final double avgCollaboration;
  final double avgResilience;

  const MarketInsights({
    required this.totalEmployeesInTrack,
    required this.avgTechnicalLevel,
    required this.avgSoftSkills,
    required this.avgSalarySatisfaction,
    required this.avgWorkLifeBalance,
    required this.mostCommonEnvironment,
    required this.mostCommonCompanySize,
    required this.avgYearsExperience,
    required this.avgConsistency,
    required this.avgAdaptability,
    required this.avgTeamwork,
    required this.avgProblemSolving,
    required this.avgLearningProactivity,
    required this.avgCommunication,
    required this.avgPrioritization,
    required this.avgOwnership,
    required this.avgCollaboration,
    required this.avgResilience,
  });

  factory MarketInsights.fromJson(Map<String, dynamic> json) {
    return MarketInsights(
      totalEmployeesInTrack: _toInt(json['totalEmployeesInTrack']),
      avgTechnicalLevel: _toDouble(json['avgTechnicalLevel']),
      avgSoftSkills: _toDouble(json['avgSoftSkills']),
      // Backend key sometimes arrives with different casing.
      // We support both: avgSalarySatisfaction / avgSalarysatisfaction
      avgSalarySatisfaction: _toDouble(
        json['avgSalarySatisfaction'] ?? json['avgSalarysatisfaction'],
      ),
      avgWorkLifeBalance: _toDouble(json['avgWorkLifeBalance']),
      mostCommonEnvironment: (json['mostCommonEnvironment'] ?? '').toString(),
      mostCommonCompanySize: (json['mostCommonCompanySize'] ?? '').toString(),
      avgYearsExperience: _toDouble(json['avgYearsExperience']),
      avgConsistency: _toDouble(json['avgConsistency']),
      avgAdaptability: _toDouble(json['avgAdaptability']),
      avgTeamwork: _toDouble(json['avgTeamwork']),
      avgProblemSolving: _toDouble(json['avgProblemSolving']),
      avgLearningProactivity: _toDouble(json['avgLearningProactivity']),
      avgCommunication: _toDouble(json['avgCommunication']),
      avgPrioritization: _toDouble(json['avgPrioritization']),
      avgOwnership: _toDouble(json['avgOwnership']),
      avgCollaboration: _toDouble(json['avgCollaboration']),
      avgResilience: _toDouble(json['avgResilience']),
    );
  }

  static int _toInt(dynamic value) {
    if (value is int) return value;
    return int.tryParse('$value') ?? 0;
  }

  static double _toDouble(dynamic value) {
    if (value is double) return value;
    if (value is int) return value.toDouble();
    return double.tryParse('$value') ?? 0;
  }
}
