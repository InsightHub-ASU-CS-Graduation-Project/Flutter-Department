import 'package:bloc/bloc.dart';
import 'package:insight_hub/model/profile_model.dart';
import 'package:insight_hub/services/api_service.dart';
import 'package:insight_hub/services/endpoints.dart';
import 'package:meta/meta.dart';

part 'profile_state.dart';

class ProfileCubit extends Cubit<ProfileState> {
  ProfileCubit() : super(ProfileInitial());

  final ApiService _apiService = ApiService();

  Future<void> fetchProfile() async {
    emit(ProfileLoading());

    try {
      final result = await _loadProfile();

      if (result['success'] == true && result['data'] is Map<String, dynamic>) {
        final profile = ProfileModel.fromJson(
          result['data'] as Map<String, dynamic>,
        );
        emit(ProfileSuccess(profile));
        return;
      }

      emit(
        ProfileFailure(
          result['error']?.toString() ?? 'Failed to load profile.',
        ),
      );
    } catch (_) {
      emit(const ProfileFailure('Failed to load profile.'));
    }
  }

Future<Map<String, dynamic>> _loadProfile() async {
  return await _apiService.post(Endpoints.profile);
}
}
