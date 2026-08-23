import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:taskflow/features/tasks/presentation/cubit/task_state.dart';
import 'package:taskflow/features/tasks/presentation/widgets/task_list_tile.dart';
import 'package:taskflow/shared/widgets/empty_state.dart';
import 'package:taskflow/shared/widgets/error_state.dart';
import 'package:taskflow/shared/widgets/loading_state.dart';
import 'package:taskflow/shared/widgets/priority_chip.dart';
import 'package:taskflow/shared/widgets/status_chip.dart';

import '../helpers/fakes.dart';
import '../helpers/test_app.dart';

void main() {
  group('Task list UI states', () {
    testWidgets('loading state shows progress indicator', (tester) async {
      await tester.pumpWidget(wrapWithScreenUtil(const LoadingState()));

      expect(find.byType(LinearProgressIndicator), findsOneWidget);
    });

    testWidgets('empty state shows title and subtitle', (tester) async {
      await tester.pumpWidget(
        wrapWithScreenUtil(
          const EmptyState(
            icon: Icons.task_alt_outlined,
            title: 'No tasks yet',
            subtitle: 'Tap + to create your first task.',
          ),
        ),
      );

      expect(find.text('No tasks yet'), findsOneWidget);
      expect(find.text('Tap + to create your first task.'), findsOneWidget);
    });

    testWidgets('error state shows retry button', (tester) async {
      var retried = false;

      await tester.pumpWidget(
        wrapWithScreenUtil(
          ErrorState(
            message: 'Could not load tasks.',
            onRetry: () => retried = true,
          ),
        ),
      );

      expect(find.text('Could not load tasks.'), findsOneWidget);
      await tester.tap(find.text('Retry'));
      expect(retried, isTrue);
    });

    testWidgets('success state renders task list tile', (tester) async {
      final item = TaskListItem(
        task: sampleTasks.first,
        projectName: sampleProjects.first.name,
        assignee: sampleMembers.last,
      );

      await tester.pumpWidget(
        wrapWithScreenUtil(
          Scaffold(
            body: TaskListTile(item: item),
          ),
        ),
      );

      expect(find.text('Write copy'), findsOneWidget);
      expect(find.text('Website Relaunch'), findsOneWidget);
      expect(find.text('M'), findsOneWidget);
      expect(find.byType(StatusChip), findsOneWidget);
      expect(find.byType(PriorityChip), findsOneWidget);
    });

    testWidgets('status chip shows readable in-progress label', (tester) async {
      await tester.pumpWidget(
        wrapWithScreenUtil(
          const StatusChip(status: 'in_progress'),
        ),
      );

      expect(find.text('In Progress'), findsOneWidget);
    });

    testWidgets('status update UI exposes selectable Done label', (tester) async {
      await tester.pumpWidget(
        wrapWithScreenUtil(
          Scaffold(
            body: PopupMenuButton<String>(
              itemBuilder: (context) => const [
                PopupMenuItem(value: 'todo', child: Text('To Do')),
                PopupMenuItem(value: 'done', child: Text('Done')),
              ],
              child: const StatusChip(status: 'todo'),
            ),
          ),
        ),
      );

      await tester.tap(find.text('To Do'));
      await tester.pumpAndSettle();

      expect(find.text('Done'), findsOneWidget);
    });
  });
}
