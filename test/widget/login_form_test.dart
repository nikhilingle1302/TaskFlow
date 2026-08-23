import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:taskflow/core/utils/validators.dart';
import 'package:taskflow/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:taskflow/shared/widgets/app_button.dart';
import 'package:taskflow/shared/widgets/app_text_field.dart';

import '../helpers/fakes.dart';
import '../helpers/test_app.dart';

class _LoginFormHarness extends StatefulWidget {
  const _LoginFormHarness();

  @override
  State<_LoginFormHarness> createState() => _LoginFormHarnessState();
}

class _LoginFormHarnessState extends State<_LoginFormHarness> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _submit() {
    _formKey.currentState!.validate();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Form(
        key: _formKey,
        child: Column(
          children: [
            AppTextField(
              label: 'Email',
              controller: _emailController,
              validator: Validators.email,
            ),
            AppTextField(
              label: 'Password',
              controller: _passwordController,
              obscureText: true,
              validator: Validators.password,
            ),
            AppButton(label: 'Sign In', onPressed: _submit),
          ],
        ),
      ),
    );
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('login form shows validation errors for empty fields',
      (tester) async {
    await tester.pumpWidget(
      wrapWithScreenUtil(
        BlocProvider<AuthBloc>(
          create: (_) => AuthBloc(FakeAuthRepository()),
          child: const _LoginFormHarness(),
        ),
      ),
    );

    await tester.tap(find.text('Sign In'));
    await tester.pump();

    expect(find.text('Email is required'), findsOneWidget);
    expect(find.text('Password is required'), findsOneWidget);
  });

  testWidgets('login form shows invalid email message', (tester) async {
    await tester.pumpWidget(
      wrapWithScreenUtil(
        BlocProvider<AuthBloc>(
          create: (_) => AuthBloc(FakeAuthRepository()),
          child: const _LoginFormHarness(),
        ),
      ),
    );

    await tester.enterText(find.byType(TextFormField).at(0), 'bad-email');
    await tester.enterText(find.byType(TextFormField).at(1), 'Password123!');
    await tester.tap(find.text('Sign In'));
    await tester.pump();

    expect(find.text('Enter a valid email address'), findsOneWidget);
  });
}
