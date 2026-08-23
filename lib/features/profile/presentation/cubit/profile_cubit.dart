import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../auth/domain/entities/auth_session.dart';
import '../../../auth/domain/repositories/org_repository.dart';
import 'profile_state.dart';

export 'profile_state.dart';

class ProfileCubit extends Cubit<ProfileState> {
  ProfileCubit({
    required OrgRepository orgRepository,
    required AuthSession session,
  })  : _orgRepository = orgRepository,
        _session = session,
        super(const ProfileInitial()) {
    load();
  }

  final OrgRepository _orgRepository;
  final AuthSession _session;

  Future<void> load() async {
    emit(const ProfileLoading());
    try {
      final org = await _orgRepository.getOrganization(_session.orgId);
      emit(
        ProfileLoaded(
          session: _session,
          orgName: org?.name ?? 'Organization',
        ),
      );
    } catch (_) {
      emit(const ProfileFailure(message: 'Could not load profile.'));
    }
  }
}
