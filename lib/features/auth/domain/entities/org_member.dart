class OrgMember {
  final String orgId;
  final String userId;
  final String role;

  const OrgMember({
    required this.orgId,
    required this.userId,
    required this.role,
  });

  bool get isAdmin => role == 'org_admin';
}
