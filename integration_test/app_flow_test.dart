import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:taskflow/app.dart';
import 'package:taskflow/injection.dart';

Future<void> _login(WidgetTester tester) async {
  final emailField = find.byType(TextFormField);
  if (emailField.evaluate().isEmpty) {
    await tester.pumpAndSettle(const Duration(seconds: 2));
  }

  await tester.enterText(emailField.first, 'ava.admin@nimbusdigital.test');
  await tester.enterText(emailField.at(1), 'Password123!');
  await tester.tap(find.text('Sign In'));
  await tester.pumpAndSettle(const Duration(seconds: 4));
}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await configureDependencies();
  });

  testWidgets('login flow with mock credentials', (tester) async {
    await tester.pumpWidget(const TaskFlowApp());
    await tester.pumpAndSettle(const Duration(seconds: 3));

    await _login(tester);

    expect(find.textContaining('Good'), findsOneWidget);
  });

  testWidgets('projects tab lists organization projects', (tester) async {
    await tester.pumpWidget(const TaskFlowApp());
    await tester.pumpAndSettle(const Duration(seconds: 3));

    await _login(tester);

    await tester.tap(find.text('Projects'));
    await tester.pumpAndSettle(const Duration(seconds: 3));

    expect(find.text('Website Relaunch'), findsOneWidget);
  });

  testWidgets('tasks tab lists organization tasks', (tester) async {
    await tester.pumpWidget(const TaskFlowApp());
    await tester.pumpAndSettle(const Duration(seconds: 3));

    await _login(tester);

    await tester.tap(find.text('Tasks'));
    await tester.pumpAndSettle(const Duration(seconds: 3));

    expect(find.text('Tasks'), findsWidgets);
    expect(find.byType(ListView), findsWidgets);
  });
}
