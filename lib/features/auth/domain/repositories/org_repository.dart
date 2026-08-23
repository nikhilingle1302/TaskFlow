import '../entities/org_member.dart';
import '../entities/user.dart';
import '../../../projects/domain/entities/organization.dart';

abstract class OrgRepository {
  Future<Organization?> getOrganization(String orgId);

  Future<List<User>> getMembers(String orgId);

  Future<List<User>> getEligibleUsers(String orgId);

  Future<OrgMember?> getMembership({
    required String orgId,
    required String userId,
  });

  Future<void> addMember({
    required String orgId,
    required String userId,
    required String role,
  });

  Future<void> removeMember({
    required String orgId,
    required String userId,
    required String role,
  });

  bool isUserInOrg({required String orgId, required String userId});
}
