import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:taskflow/app.dart';
import 'package:taskflow/injection.dart';

Future<void> _bootstrap() async {
  await sl.reset();
  SharedPreferences.setMockInitialValues({});
  FlutterSecureStorage.setMockInitialValues({});
  await configureDependencies();
}

Future<void> _login(WidgetTester tester) async {
  await tester.pumpAndSettle(const Duration(seconds: 3));

  final emailField = find.byType(TextFormField);
  expect(emailField, findsWidgets);

  await tester.enterText(emailField.first, 'ava.admin@nimbusdigital.test');
  await tester.enterText(emailField.at(1), 'Password123!');
  await tester.tap(find.text('Sign In'));
  await tester.pumpAndSettle(const Duration(seconds: 4));
}

Future<void> _openTasks(WidgetTester tester) async {
  await tester.tap(find.text('Tasks'));
  await tester.pumpAndSettle(const Duration(seconds: 3));
}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    await _bootstrap();
  });

  testWidgets('login flow with mock credentials', (tester) async {
    await tester.pumpWidget(const TaskFlowApp());
    await _login(tester);

    expect(find.textContaining('Good'), findsOneWidget);
  });

  testWidgets('projects tab lists organization projects', (tester) async {
    await tester.pumpWidget(const TaskFlowApp());
    await _login(tester);

    await tester.tap(find.text('Projects'));
    await tester.pumpAndSettle(const Duration(seconds: 3));

    expect(find.text('Website Relaunch'), findsOneWidget);
  });

  testWidgets('tasks tab lists organization tasks', (tester) async {
    await tester.pumpWidget(const TaskFlowApp());
    await _login(tester);
    await _openTasks(tester);

    expect(find.text('Tasks'), findsWidgets);
    expect(find.text('Set up design tokens in Figma'), findsOneWidget);
  });

  testWidgets('create task flow', (tester) async {
    await tester.pumpWidget(const TaskFlowApp());
    await _login(tester);
    await _openTasks(tester);

    await tester.tap(find.byIcon(Icons.add));
    await tester.pumpAndSettle(const Duration(seconds: 2));

    expect(find.text('Create task'), findsWidgets);

    final fields = find.byType(TextFormField);
    await tester.enterText(fields.first, 'Integration created task');
    await tester.enterText(fields.at(1), 'Created by integration test');
    await tester.tap(find.text('Create task').last);
    await tester.pumpAndSettle(const Duration(seconds: 4));

    expect(find.text('Integration created task'), findsOneWidget);
  });

  testWidgets('update task status and assign member', (tester) async {
    await tester.pumpWidget(const TaskFlowApp());
    await _login(tester);
    await _openTasks(tester);

    await tester.tap(find.text('Set up design tokens in Figma'));
    await tester.pumpAndSettle(const Duration(seconds: 3));

    expect(find.text('Set up design tokens in Figma'), findsOneWidget);
    expect(find.text('Assignee'), findsOneWidget);

    await tester.tap(find.text('In Progress'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Done').last);
    await tester.pumpAndSettle(const Duration(seconds: 3));

    expect(find.text('Done'), findsWidgets);

    await tester.tap(find.textContaining('Unassigned').hitTestable().first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Marcus Lee').last);
    await tester.pumpAndSettle(const Duration(seconds: 3));

    expect(find.text('Marcus Lee'), findsWidgets);
  });
}
