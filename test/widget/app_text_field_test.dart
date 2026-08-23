import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:taskflow/core/utils/validators.dart';
import 'package:taskflow/shared/widgets/app_text_field.dart';

import '../helpers/test_app.dart';

void main() {
  testWidgets('AppTextField shows email validation on submit', (tester) async {
    final formKey = GlobalKey<FormState>();
    final controller = TextEditingController();
    addTearDown(controller.dispose);

    await tester.pumpWidget(
      wrapWithScreenUtil(
        Scaffold(
          body: Form(
            key: formKey,
            child: Column(
              children: [
                AppTextField(
                  label: 'Email',
                  controller: controller,
                  validator: Validators.email,
                ),
                ElevatedButton(
                  onPressed: () => formKey.currentState!.validate(),
                  child: const Text('Submit'),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Submit'));
    await tester.pump();

    expect(find.text('Email is required'), findsOneWidget);
  });
}
