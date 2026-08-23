import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:taskflow/shared/widgets/empty_state.dart';
import 'package:taskflow/shared/widgets/error_state.dart';
import 'package:taskflow/shared/widgets/loading_state.dart';
import 'package:taskflow/shared/widgets/status_chip.dart';

import '../helpers/test_app.dart';

void main() {
  group('Task UI widgets', () {
    testWidgets('LoadingState shows a progress indicator', (tester) async {
      await tester.pumpWidget(wrapWithScreenUtil(const LoadingState()));

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('EmptyState shows title and subtitle', (tester) async {
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

    testWidgets('ErrorState shows retry button', (tester) async {
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

    testWidgets('StatusChip shows readable in-progress label', (tester) async {
      await tester.pumpWidget(
        wrapWithScreenUtil(
          const StatusChip(status: 'in_progress'),
        ),
      );

      expect(find.text('In Progress'), findsOneWidget);
    });
  });
}
