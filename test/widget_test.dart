import 'package:flutter_test/flutter_test.dart';
import 'package:taskflow/app.dart';
import 'package:taskflow/injection.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    await configureDependencies();
  });

  testWidgets('app boots into splash or login', (tester) async {
    await tester.pumpWidget(const TaskFlowApp());
    await tester.pump();
    expect(find.textContaining('TaskFlow'), findsWidgets);
  });
}
