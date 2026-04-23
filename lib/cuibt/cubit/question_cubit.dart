import 'package:bloc/bloc.dart';
import 'package:insight_hub/model/question_model.dart';
import 'package:insight_hub/services/api_service.dart';
import 'package:meta/meta.dart';

@immutable
sealed class QuestionState {
  const QuestionState();
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
  final Map<int, dynamic> answers;
  final bool isSubmitting;
  final bool didSubmitSucceed;
  final String? validationMessage;
  const QuestionLoaded({
    required this.questions,
    this.answers = const {},
    this.isSubmitting = false,
    this.didSubmitSucceed = false,
    this.validationMessage,
  });

  bool isAnswered(int questionId) => answers.containsKey(questionId);

  bool get canSubmit =>
      questions.isNotEmpty && questions.every((question) => isAnswered(question.id));

  QuestionLoaded copyWith({
    List<QuestionModel>? questions,
    Map<int, dynamic>? answers,
    bool? isSubmitting,
    bool? didSubmitSucceed,
    String? validationMessage,
    bool clearValidationMessage = false,
  }) {
    return QuestionLoaded(
      questions: questions ?? this.questions,
      answers: answers ?? this.answers,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      didSubmitSucceed: didSubmitSucceed ?? this.didSubmitSucceed,
      validationMessage: clearValidationMessage
          ? null
          : validationMessage ?? this.validationMessage,
    );
  }
}

class QuestionCubit extends Cubit<QuestionState> {
  final ApiService _apiService;

  QuestionCubit({ApiService? apiService})
      : _apiService = apiService ?? ApiService(),
        super(const QuestionLoading());

  Future<void> fetchQuestions(String target) async {
    emit(const QuestionLoading());

    try {
      final questions = await _apiService.fetchQuestions(target: target);

      if (questions.isEmpty) {
        emit(const QuestionError('No questions are available right now.'));
        return;
      }

      emit(QuestionLoaded(questions: questions));
    } catch (error) {
      emit(QuestionError(_messageFrom(error)));
    }
  }

  void answerQuestion(int questionId, dynamic value) {
      print("Q:$questionId → value:$value");
    final currentState = state;
    if (currentState is! QuestionLoaded) {
      return;
    }

    final updatedAnswers = Map<int, dynamic>.from(currentState.answers)
      ..[questionId] = value;

    emit(
      currentState.copyWith(
        answers: updatedAnswers,
        didSubmitSucceed: false,
        clearValidationMessage: true,
      ),
    );
  }

  Future<void> submitAnswers() async {
    final currentState = state;
    if (currentState is! QuestionLoaded) {
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
      await _apiService.submitAnswers(answers: currentState.answers);

      emit(
        currentState.copyWith(
          isSubmitting: false,
          didSubmitSucceed: true,
          clearValidationMessage: true,
        ),
      );
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
    emit(const QuestionLoading());
  }
}
