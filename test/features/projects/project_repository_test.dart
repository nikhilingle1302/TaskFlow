import 'package:flutter_test/flutter_test.dart';
import 'package:taskflow/core/error/app_exception.dart';
import 'package:taskflow/features/projects/data/repositories/project_repository_impl.dart';
import 'package:taskflow/features/projects/domain/entities/project.dart';

import '../../helpers/test_data.dart';

void main() {
  late ProjectRepositoryImpl repository;

  setUp(() async {
    final env = await createTestEnvironment();
    repository = ProjectRepositoryImpl(env.store, env.preferences, env.cache);
  });

  group('ProjectRepositoryImpl', () {
    test('deleteProject blocks non-admin users', () async {
      expect(
        () => repository.deleteProject(
          orgId: 'org_a1b2c3',
          projectId: 'proj_1001',
          role: 'member',
        ),
        throwsA(isA<ForbiddenException>()),
      );
    });

    test('getProjects returns only projects for the org', () async {
      final projects = await repository.getProjects('org_a1b2c3');

      expect(projects, isNotEmpty);
      expect(projects.every((p) => p.orgId == 'org_a1b2c3'), isTrue);
    });

    test('getProjects serves cached data when offline', () async {
      final env = await createTestEnvironment();
      final repo = ProjectRepositoryImpl(env.store, env.preferences, env.cache);
      await repo.getProjects('org_a1b2c3');

      await env.preferences.setOfflineMode(true);
      final offlineProjects = await repo.getProjects('org_a1b2c3');

      expect(offlineProjects, isNotEmpty);
      expect(env.cache.lastSyncAt, isNotNull);
    });

    test('getProjectById throws timeout for force id', () async {
      expect(
        () => repository.getProjectById(
          orgId: 'org_a1b2c3',
          projectId: 'proj_force_timeout',
        ),
        throwsA(isA<TimeoutException>()),
      );
    });

    test('getProjectById rejects a project from another org', () async {
      expect(
        () => repository.getProjectById(
          orgId: 'org_a1b2c3',
          projectId: 'proj_1003',
        ),
        throwsA(isA<ForbiddenException>()),
      );
    });

    test('updateProject rejects a project from another org', () async {
      expect(
        () => repository.updateProject(
          orgId: 'org_a1b2c3',
          project: Project(
            id: 'proj_1003',
            orgId: 'org_a1b2c3',
            name: 'Hacked',
            description: 'Should fail',
            taskCount: 0,
            status: 'active',
            createdAt: DateTime.utc(2026, 1, 1),
          ),
        ),
        throwsA(isA<ForbiddenException>()),
      );
    });

    test('deleteProject rejects a project from another org', () async {
      expect(
        () => repository.deleteProject(
          orgId: 'org_a1b2c3',
          projectId: 'proj_1003',
          role: 'org_admin',
        ),
        throwsA(isA<ForbiddenException>()),
      );
    });
  });
}
