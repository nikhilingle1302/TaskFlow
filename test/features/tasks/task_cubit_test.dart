import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:taskflow/features/tasks/presentation/cubit/task_cubit.dart';

import '../../helpers/fakes.dart';

void main() {
  group('TaskCubit', () {
    blocTest<TaskCubit, TaskState>(
      'loads tasks for the organization',
      build: () => TaskCubit(
        taskRepository: FakeTaskRepository(sampleTasks),
        projectRepository: FakeProjectRepository(sampleProjects),
        orgRepository: FakeOrgRepository(sampleMembers),
        orgId: 'org_a1b2c3',
      ),
      act: (cubit) => cubit.load(),
      expect: () => [
        const TaskLoading(),
        isA<TaskLoaded>(),
      ],
      verify: (cubit) {
        final state = cubit.state as TaskLoaded;
        expect(state.allItems.length, 2);
      },
    );

    blocTest<TaskCubit, TaskState>(
      'filters tasks by status',
      build: () => TaskCubit(
        taskRepository: FakeTaskRepository(sampleTasks),
        projectRepository: FakeProjectRepository(sampleProjects),
        orgRepository: FakeOrgRepository(sampleMembers),
        orgId: 'org_a1b2c3',
      ),
      act: (cubit) async {
        await cubit.load();
        cubit.setStatus('todo');
      },
      verify: (cubit) {
        final state = cubit.state as TaskLoaded;
        expect(state.flatItems.length, 1);
        expect(state.flatItems.first.task.status, 'todo');
      },
    );

    blocTest<TaskCubit, TaskState>(
      'search filters tasks by title',
      build: () => TaskCubit(
        taskRepository: FakeTaskRepository(sampleTasks),
        projectRepository: FakeProjectRepository(sampleProjects),
        orgRepository: FakeOrgRepository(sampleMembers),
        orgId: 'org_a1b2c3',
      ),
      act: (cubit) async {
        await cubit.load();
        cubit.search('Ship');
      },
      verify: (cubit) {
        final state = cubit.state as TaskLoaded;
        final titles = state.sections
            .expand((group) => group.items)
            .map((item) => item.task.title)
            .toList();
        expect(titles, contains('Ship feature'));
      },
    );

    blocTest<TaskCubit, TaskState>(
      'filters tasks by due date range',
      build: () => TaskCubit(
        taskRepository: FakeTaskRepository(sampleTasks),
        projectRepository: FakeProjectRepository(sampleProjects),
        orgRepository: FakeOrgRepository(sampleMembers),
        orgId: 'org_a1b2c3',
      ),
      act: (cubit) async {
        await cubit.load();
        cubit.applyFilters(
          dueFrom: DateTime(2026, 1, 1),
          dueTo: DateTime(2026, 12, 31),
        );
      },
      verify: (cubit) {
        final state = cubit.state as TaskLoaded;
        final titles = state.sections
            .expand((group) => group.items)
            .map((item) => item.task.title)
            .toList();
        expect(titles, contains('Write copy'));
        expect(titles, isNot(contains('Ship feature')));
      },
    );

    blocTest<TaskCubit, TaskState>(
      'emits empty when organization has no tasks',
      build: () => TaskCubit(
        taskRepository: FakeTaskRepository([]),
        projectRepository: FakeProjectRepository(sampleProjects),
        orgRepository: FakeOrgRepository(sampleMembers),
        orgId: 'org_a1b2c3',
      ),
      act: (cubit) => cubit.load(),
      expect: () => [
        const TaskLoading(),
        isA<TaskEmpty>(),
      ],
    );
  });
}
