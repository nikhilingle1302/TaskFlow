import '../../../../core/error/app_exception.dart';
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
  Future<List<User>> getEligibleUsers(String orgId) async {
    await _store.ensureLoaded();
    _requireOrganization(orgId);

    final memberIds = _store.orgMembers
        .where((m) => m.orgId == orgId)
        .map((m) => m.userId)
        .toSet();

    return _store.users
        .where((u) => !memberIds.contains(u.id))
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
  Future<void> addMember({
    required String orgId,
    required String userId,
    required String role,
  }) async {
    await _store.ensureLoaded();
    _requireAdmin(role);
    _requireOrganization(orgId);
    _requireUser(userId);

    final alreadyMember = _store.orgMembers.any(
      (m) => m.orgId == orgId && m.userId == userId,
    );
    if (alreadyMember) {
      throw const ValidationException(
        'User is already a member of this organization.',
      );
    }

    _store.orgMembers = [
      ..._store.orgMembers,
      OrgMemberModel(orgId: orgId, userId: userId, role: 'member'),
    ];
  }

  @override
  Future<void> removeMember({
    required String orgId,
    required String userId,
    required String role,
  }) async {
    await _store.ensureLoaded();
    _requireAdmin(role);
    _requireOrganization(orgId);

    final index = _store.orgMembers.indexWhere(
      (m) => m.orgId == orgId && m.userId == userId,
    );
    if (index < 0) {
      throw const NotFoundException(
        'Member was not found in this organization.',
      );
    }

    final list = [..._store.orgMembers];
    list.removeAt(index);
    _store.orgMembers = list;
  }

  @override
  bool isUserInOrg({required String orgId, required String userId}) {
    return _store.orgMembers.any(
      (m) => m.orgId == orgId && m.userId == userId,
    );
  }

  void _requireAdmin(String role) {
    if (role != 'org_admin') {
      throw const ForbiddenException(
        'Only organization admins can manage members.',
      );
    }
  }

  void _requireOrganization(String orgId) {
    final exists = _store.organizations.any((o) => o.id == orgId);
    if (!exists) {
      throw NotFoundException('Organization $orgId was not found.');
    }
  }

  void _requireUser(String userId) {
    final exists = _store.users.any((u) => u.id == userId);
    if (!exists) {
      throw NotFoundException('User $userId was not found.');
    }
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
