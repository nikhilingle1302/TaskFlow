import 'package:flutter_test/flutter_test.dart';
import 'package:taskflow/core/error/app_exception.dart';
import 'package:taskflow/features/tasks/data/repositories/task_repository_impl.dart';
import 'package:taskflow/features/tasks/domain/entities/task_item.dart';

import '../../helpers/test_data.dart';

void main() {
  late TaskRepositoryImpl repository;

  setUp(() async {
    final env = await createTestEnvironment();
    repository = TaskRepositoryImpl(env.store, env.preferences, env.cache);
  });

  group('TaskRepositoryImpl', () {
    test('assignTask rejects a user outside the current org', () async {
      expect(
        () => repository.assignTask(
          orgId: 'org_a1b2c3',
          taskId: 'task_2001',
          userId: 'user_004',
        ),
        throwsA(isA<ValidationException>()),
      );
    });

    test('assignTask allows a user from the same org', () async {
      final updated = await repository.assignTask(
        orgId: 'org_a1b2c3',
        taskId: 'task_2001',
        userId: 'user_002',
      );

      expect(updated.assigneeId, 'user_002');
    });

    test('createTask rejects empty title', () async {
      expect(
        () => repository.createTask(
          orgId: 'org_a1b2c3',
          projectId: 'proj_1001',
          title: '   ',
          description: 'Test',
          status: 'todo',
          priority: 'low',
        ),
        throwsA(isA<ValidationException>()),
      );
    });

    test('getTaskById throws not found for force id', () async {
      expect(
        () => repository.getTaskById(
          orgId: 'org_a1b2c3',
          taskId: 'task_force_404',
        ),
        throwsA(isA<NotFoundException>()),
      );
    });

    test('getTaskById rejects a task from another org', () async {
      expect(
        () => repository.getTaskById(
          orgId: 'org_a1b2c3',
          taskId: 'task_2012',
        ),
        throwsA(isA<ForbiddenException>()),
      );
    });

    test('updateTask rejects a task from another org', () async {
      expect(
        () => repository.updateTask(
          orgId: 'org_a1b2c3',
          task: TaskItem(
            id: 'task_2012',
            projectId: 'proj_1003',
            title: 'Hacked',
            description: 'Should fail',
            status: 'todo',
            priority: 'low',
            assigneeId: null,
            dueDate: null,
            createdAt: DateTime.utc(2026, 1, 1),
          ),
        ),
        throwsA(isA<ForbiddenException>()),
      );
    });

    test('deleteTask rejects a task from another org', () async {
      expect(
        () => repository.deleteTask(
          orgId: 'org_a1b2c3',
          taskId: 'task_2012',
        ),
        throwsA(isA<ForbiddenException>()),
      );
    });

    test('assignTask rejects a task from another org', () async {
      expect(
        () => repository.assignTask(
          orgId: 'org_a1b2c3',
          taskId: 'task_2012',
          userId: 'user_002',
        ),
        throwsA(isA<ForbiddenException>()),
      );
    });

    test('getTasks rejects a projectId from another org', () async {
      expect(
        () => repository.getTasks(
          orgId: 'org_a1b2c3',
          projectId: 'proj_1003',
        ),
        throwsA(isA<ForbiddenException>()),
      );
    });
  });
}
