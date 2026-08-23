import 'package:flutter_test/flutter_test.dart';
import 'package:taskflow/core/error/app_exception.dart';
import 'package:taskflow/features/auth/data/repositories/org_repository_impl.dart';

import '../../helpers/test_data.dart';

void main() {
  late OrgRepositoryImpl repository;

  setUp(() async {
    final store = await createTestStore();
    repository = OrgRepositoryImpl(store);
  });

  group('OrgRepositoryImpl member management', () {
    test('admin can add a valid user', () async {
      await repository.addMember(
        orgId: 'org_a1b2c3',
        userId: 'user_004',
        role: 'org_admin',
      );

      final members = await repository.getMembers('org_a1b2c3');
      expect(members.any((m) => m.id == 'user_004'), isTrue);
    });

    test('admin can remove a member', () async {
      await repository.removeMember(
        orgId: 'org_a1b2c3',
        userId: 'user_003',
        role: 'org_admin',
      );

      final members = await repository.getMembers('org_a1b2c3');
      expect(members.any((m) => m.id == 'user_003'), isFalse);
    });

    test('member cannot add a member', () async {
      expect(
        () => repository.addMember(
          orgId: 'org_a1b2c3',
          userId: 'user_004',
          role: 'member',
        ),
        throwsA(isA<ForbiddenException>()),
      );
    });

    test('member cannot remove a member', () async {
      expect(
        () => repository.removeMember(
          orgId: 'org_a1b2c3',
          userId: 'user_003',
          role: 'member',
        ),
        throwsA(isA<ForbiddenException>()),
      );
    });

    test('duplicate member cannot be added', () async {
      expect(
        () => repository.addMember(
          orgId: 'org_a1b2c3',
          userId: 'user_002',
          role: 'org_admin',
        ),
        throwsA(isA<ValidationException>()),
      );
    });

    test('non-existing user cannot be added', () async {
      expect(
        () => repository.addMember(
          orgId: 'org_a1b2c3',
          userId: 'user_missing',
          role: 'org_admin',
        ),
        throwsA(isA<NotFoundException>()),
      );
    });

    test('cross-organization member mutation is rejected', () async {
      expect(
        () => repository.addMember(
          orgId: 'org_missing',
          userId: 'user_004',
          role: 'org_admin',
        ),
        throwsA(isA<NotFoundException>()),
      );

      expect(
        () => repository.removeMember(
          orgId: 'org_a1b2c3',
          userId: 'user_005',
          role: 'org_admin',
        ),
        throwsA(isA<NotFoundException>()),
      );
    });

    test('invalid member removal is rejected', () async {
      expect(
        () => repository.removeMember(
          orgId: 'org_a1b2c3',
          userId: 'user_missing',
          role: 'org_admin',
        ),
        throwsA(isA<NotFoundException>()),
      );
    });

    test('eligible users exclude current members', () async {
      final eligible = await repository.getEligibleUsers('org_a1b2c3');

      expect(eligible.any((u) => u.id == 'user_001'), isFalse);
      expect(eligible.any((u) => u.id == 'user_002'), isFalse);
      expect(eligible.any((u) => u.id == 'user_004'), isTrue);
    });
  });
}
