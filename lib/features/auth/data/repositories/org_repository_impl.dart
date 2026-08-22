import '../../../../core/network/mock_data_store.dart';
import '../../../projects/domain/entities/organization.dart';
import '../../domain/entities/org_member.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/org_repository.dart';
import '../models/org_member_model.dart';
import '../models/user_model.dart';

class OrgRepositoryImpl implements OrgRepository {
  OrgRepositoryImpl(this._store);

  final MockDataStore _store;

  @override
  Future<Organization?> getOrganization(String orgId) async {
    await _store.ensureLoaded();
    try {
      final model = _store.organizations.firstWhere((o) => o.id == orgId);
      return Organization(
        id: model.id,
        name: model.name,
        createdAt: model.createdAt,
      );
    } catch (_) {
      return null;
    }
  }

  @override
  Future<List<User>> getMembers(String orgId) async {
    await _store.ensureLoaded();
    final memberIds = _store.orgMembers
        .where((m) => m.orgId == orgId)
        .map((m) => m.userId)
        .toSet();

    return _store.users
        .where((u) => memberIds.contains(u.id))
        .map(_toUser)
        .toList();
  }

  @override
  Future<OrgMember?> getMembership({
    required String orgId,
    required String userId,
  }) async {
    await _store.ensureLoaded();
    try {
      final model = _store.orgMembers.firstWhere(
        (m) => m.orgId == orgId && m.userId == userId,
      );
      return _toMember(model);
    } catch (_) {
      return null;
    }
  }

  @override
  bool isUserInOrg({required String orgId, required String userId}) {
    return _store.orgMembers.any(
      (m) => m.orgId == orgId && m.userId == userId,
    );
  }

  User _toUser(UserModel model) {
    return User(
      id: model.id,
      name: model.name,
      email: model.email,
      avatarUrl: model.avatarUrl,
    );
  }

  OrgMember _toMember(OrgMemberModel model) {
    return OrgMember(
      orgId: model.orgId,
      userId: model.userId,
      role: model.role,
    );
  }
}
