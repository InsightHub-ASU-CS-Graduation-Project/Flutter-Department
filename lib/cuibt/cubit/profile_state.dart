part of 'profile_cubit.dart';

@immutable
sealed class ProfileState {
  const ProfileState();
}

final class ProfileInitial extends ProfileState {}

final class ProfileLoading extends ProfileState {}

final class ProfileSuccess extends ProfileState {
  final ProfileModel profile;

  const ProfileSuccess(this.profile);
}

final class ProfileFailure extends ProfileState {
  final String message;

  const ProfileFailure(this.message);
}
