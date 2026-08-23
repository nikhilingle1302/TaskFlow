import 'package:equatable/equatable.dart';

import '../../../auth/domain/entities/auth_session.dart';

abstract class ProfileState extends Equatable {
  const ProfileState();

  @override
  List<Object?> get props => [];
}

class ProfileInitial extends ProfileState {
  const ProfileInitial();
}

class ProfileLoading extends ProfileState {
  const ProfileLoading();
}

class ProfileLoaded extends ProfileState {
  const ProfileLoaded({
    required this.session,
    required this.orgName,
  });

  final AuthSession session;
  final String orgName;

  String get roleLabel {
    switch (session.role) {
      case 'org_admin':
        return 'Organization Admin';
      default:
        return 'Member';
    }
  }

  @override
  List<Object?> get props => [session.userId, orgName];
}

class ProfileFailure extends ProfileState {
  const ProfileFailure({required this.message});

  final String message;

  @override
  List<Object?> get props => [message];
}
