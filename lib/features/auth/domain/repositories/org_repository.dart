import '../entities/org_member.dart';
import '../entities/user.dart';
import '../../../projects/domain/entities/organization.dart';

abstract class OrgRepository {
  Future<Organization?> getOrganization(String orgId);

  Future<List<User>> getMembers(String orgId);

  Future<OrgMember?> getMembership({
    required String orgId,
    required String userId,
  });

  bool isUserInOrg({required String orgId, required String userId});
}
