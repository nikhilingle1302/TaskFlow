import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/auth_bloc.dart';
import 'auth_success_page.dart';
import 'login_page.dart';
import 'splash_page.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      buildWhen: (previous, current) {
        if (current is AuthLoading && previous is AuthUnauthenticated) {
          return false;
        }
        return true;
      },
      builder: (context, state) {
        if (state is AuthAuthenticated) {
          return AuthSuccessPage(session: state.session);
        }
        if (state is AuthUnauthenticated) {
          return const LoginPage();
        }
        return const SplashPage();
      },
    );
  }
}
