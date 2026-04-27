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

  Future<void> getMatch() async {
    // Persistent behavior: If already loaded, don't fetch again
    if (state is MatchLoaded || state is MatchLoading) {
      return;
    }

    emit(const MatchLoading());

    try {
      final result = await _apiService.findMatch();
      emit(MatchLoaded(result));
    } catch (error) {
      emit(MatchError(_errorMessage(error)));
    }
  }

  void reset() {
    emit(const MatchInitial());
  }

  void emitResult(dynamic result) {
    emit(MatchLoaded(result));
  }

  String _errorMessage(Object error) {
    final message = error.toString();
    if (message.startsWith('Exception: ')) {
      return message.replaceFirst('Exception: ', '');
    }

    return message;
  }
}
