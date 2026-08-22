import 'package:json_annotation/json_annotation.dart';

part 'org_member_model.g.dart';

@JsonSerializable()
class OrgMemberModel {
  @JsonKey(name: 'org_id')
  final String orgId;
  @JsonKey(name: 'user_id')
  final String userId;
  final String role;

  const OrgMemberModel({
    required this.orgId,
    required this.userId,
    required this.role,
  });

  factory OrgMemberModel.fromJson(Map<String, dynamic> json) =>
      _$OrgMemberModelFromJson(json);

  Map<String, dynamic> toJson() => _$OrgMemberModelToJson(this);
}
