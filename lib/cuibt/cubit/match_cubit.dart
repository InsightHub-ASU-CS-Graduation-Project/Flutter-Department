import 'package:bloc/bloc.dart';
import 'package:insight_hub/core/services/api_service.dart';
import 'package:insight_hub/core/services/endpoints.dart';
import 'package:insight_hub/model/profile_model.dart';
import 'package:meta/meta.dart';

enum NavigationTarget {
  questions,
  result,
  thankYou,
}

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

  Future<NavigationTarget> decideNavigation() async {
    emit(const MatchLoading());

    try {
      final profileResult = await _apiService.post(Endpoints.profile);
      
      if (profileResult['success'] != true || profileResult['data'] == null) {
        throw Exception(profileResult['error']?.toString() ?? 'Failed to load profile.');
      }

      final profile = ProfileModel.fromJson(profileResult['data'] as Map<String, dynamic>);

      if (!profile.hasCompletedAssessment) {
        emit(const MatchInitial());
        return NavigationTarget.questions;
      } else {
        if (profile.isEmployed) {
          emit(const MatchInitial());
          return NavigationTarget.thankYou;
        } else {
          final result = await _apiService.fetchCareerQuizResult();
          
          if (result == null) {
            throw Exception('No results found. Please complete the quiz.');
          }
          
          emit(MatchLoaded(result));
          return NavigationTarget.result;
        }
      }
    } catch (error) {
      emit(MatchError(_errorMessage(error)));
      rethrow;
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
