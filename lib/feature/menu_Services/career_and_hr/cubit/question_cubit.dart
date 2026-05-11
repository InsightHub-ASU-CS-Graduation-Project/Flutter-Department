import 'package:bloc/bloc.dart';
import 'package:InsightHub/feature/menu_Services/career_and_hr/model/question_model.dart';
import 'package:InsightHub/core/services/api_service.dart';
import 'package:InsightHub/feature/menu_Services/career_and_hr/model/career_quiz_result_model.dart';
import 'package:meta/meta.dart';

/// Questions + submission for **both** employment paths.
///
/// ═══════════════════════════════════════════════════════════════════════════
/// **Non-employed (career quiz)**
/// `QuestionScreen` → `submitAnswers()` → `submitCareerQuizAnswers()` →
/// `CareerQuizResultModel` → navigate to `CareerResultScreen` (with optional
/// pre-parsed result as route args).
///
/// ═══════════════════════════════════════════════════════════════════════════
/// **Employed**
/// `QuestionScreen` → `submitAnswers()` → `submitEmployedSurveyAnswers()` →
/// HTTP success only → navigate to `SurveyThankYouScreen`.
///
/// Employed users intentionally have **no** result screen, **no** match UI, and
/// **no** client-side parsing of a “match” payload—product flow ends at thank-you.
@immutable
sealed class QuestionState {
  const QuestionState();
}

final class QuestionInitial extends QuestionState {
  const QuestionInitial();
}

final class QuestionLoading extends QuestionState {
  const QuestionLoading();
}

final class QuestionError extends QuestionState {
  final String message;

  const QuestionError(this.message);
}

final class QuestionLoaded extends QuestionState {
  final List<QuestionModel> questions;
  final Map<int, int> answers;
  final bool isSubmitting;
  final bool didSubmitSucceed;
  final String? validationMessage;
  /// Only set when [isEmployed] is false and submit succeeded.
  final CareerQuizResultModel? careerResult;
  final bool isEmployed;

  const QuestionLoaded({
    required this.questions,
    required this.isEmployed,
    this.answers = const {},
    this.isSubmitting = false,
    this.didSubmitSucceed = false,
    this.validationMessage,
    this.careerResult,
  });

  bool isAnswered(int questionId) => answers.containsKey(questionId);

  bool get canSubmit =>
      questions.isNotEmpty &&
      questions.every((question) => isAnswered(question.id));

  QuestionLoaded copyWith({
    List<QuestionModel>? questions,
    Map<int, int>? answers,
    bool? isSubmitting,
    bool? didSubmitSucceed,
    String? validationMessage,
    CareerQuizResultModel? careerResult,
    bool? isEmployed,
    bool clearValidationMessage = false,
    bool clearCareerResult = false,
  }) {
    return QuestionLoaded(
      questions: questions ?? this.questions,
      isEmployed: isEmployed ?? this.isEmployed,
      answers: answers ?? this.answers,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      didSubmitSucceed: didSubmitSucceed ?? this.didSubmitSucceed,
      validationMessage: clearValidationMessage
          ? null
          : validationMessage ?? this.validationMessage,
      careerResult:
          clearCareerResult ? null : careerResult ?? this.careerResult,
    );
  }
}

class QuestionCubit extends Cubit<QuestionState> {
  final ApiService _apiService;

  QuestionCubit({ApiService? apiService})
    : _apiService = apiService ?? ApiService(),
      super(const QuestionInitial());

  Future<void> fetchQuestions({required bool isEmployed}) async {
    await fetchQuestionsAsync(isEmployed: isEmployed);
  }

  Future<bool> fetchQuestionsAsync({required bool isEmployed}) async {
    print(
      "QuestionCubit: fetchQuestionsAsync called (isEmployed: $isEmployed), current state: $state",
    );
    if (state is QuestionLoading) {
      print("QuestionCubit: Already loading, skipping request.");
      return false;
    }
    emit(const QuestionLoading());

    try {
      final questions = await _apiService.fetchQuestions(
        isEmployed: isEmployed,
      );

      if (questions.isEmpty) {
        emit(const QuestionError('No questions are available right now.'));
        return false;
      }

      emit(QuestionLoaded(questions: questions, isEmployed: isEmployed));
      return true;
    } catch (error) {
      emit(QuestionError(_messageFrom(error)));
      return false;
    }
  }

  void answerQuestion(int questionId, Object? value) {
    final normalized = value is int ? value : int.tryParse('$value') ?? 0;
    print("Q:$questionId → value:$value (normalized=$normalized)");
    final currentState = state;
    if (currentState is! QuestionLoaded) {
      return;
    }

    final updatedAnswers = Map<int, int>.from(currentState.answers)
      ..[questionId] = normalized;

    emit(
      currentState.copyWith(
        answers: updatedAnswers,
        didSubmitSucceed: false,
        clearCareerResult: true,
        clearValidationMessage: true,
      ),
    );
  }

  Future<void> submitAnswers() async {
    final currentState = state;
    if (currentState is! QuestionLoaded) {
      return;
    }

    if (currentState.isSubmitting) {
      return;
    }

    if (!currentState.canSubmit) {
      emit(
        currentState.copyWith(
          validationMessage: 'Please answer every question before submitting.',
          didSubmitSucceed: false,
        ),
      );
      return;
    }

    emit(
      currentState.copyWith(
        isSubmitting: true,
        didSubmitSucceed: false,
        clearValidationMessage: true,
      ),
    );

    try {
      if (currentState.isEmployed) {
        await _apiService.submitEmployedSurveyAnswers(
          answers: currentState.answers,
        );

        emit(
          currentState.copyWith(
            isSubmitting: false,
            didSubmitSucceed: true,
            clearValidationMessage: true,
            clearCareerResult: true,
          ),
        );
      } else {
        final career = await _apiService.submitCareerQuizAnswers(
          answers: currentState.answers,
        );

        emit(
          currentState.copyWith(
            isSubmitting: false,
            didSubmitSucceed: true,
            clearValidationMessage: true,
            careerResult: career,
          ),
        );
      }
    } catch (error) {
      emit(
        currentState.copyWith(
          isSubmitting: false,
          didSubmitSucceed: false,
          validationMessage: _messageFrom(error),
        ),
      );
    }
  }

  String _messageFrom(Object error) {
    final message = error.toString();
    if (message.startsWith('Exception: ')) {
      return message.replaceFirst('Exception: ', '');
    }

    return message;
  }

  void reset() {
    emit(const QuestionInitial());
  }
}
