import 'package:bloc/bloc.dart';

import 'package:insight_hub/services/api_service.dart';
import 'package:meta/meta.dart';

@immutable
sealed class MatchState {
  const MatchState();
}

final class MatchInitial extends MatchState {
  const MatchInitial();
}

final class MatchLoading extends MatchState {
  const MatchLoading();
}

final class MatchLoaded extends MatchState {
  final dynamic result;

  const MatchLoaded(this.result);
}

final class MatchError extends MatchState {
  final String message;

  const MatchError(this.message);
}

class MatchCubit extends Cubit<MatchState> {
  final ApiService _apiService;

  MatchCubit({ApiService? apiService})
    : _apiService = apiService ?? ApiService(),
      super(const MatchInitial());

  void reset() {
    emit(const MatchInitial());
  }

  void emitResult(dynamic result) {
    emit(MatchLoaded(result));
  }

  Future<bool> fetchResult({bool forceRefresh = false}) async {
    if (state is MatchLoading) return false;
    if (!forceRefresh && state is MatchLoaded) return true;

    emit(const MatchLoading());

    try {
      final result = await _apiService.fetchCareerQuizResult();

      if (result == null) {
        emit(const MatchError('No results found. Please complete the quiz.'));
        return false;
      }

      emit(MatchLoaded(result));
      return true;
    } catch (error) {
      emit(MatchError(_errorMessage(error)));
      return false;
    }
  }

  String _errorMessage(Object error) {
    final message = error.toString();
    if (message.startsWith('Exception: ')) {
      return message.replaceFirst('Exception: ', '');
    }

    return message;
  }
}
