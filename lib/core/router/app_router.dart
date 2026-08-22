import 'package:go_router/go_router.dart';

import '../../features/auth/presentation/bloc/auth_bloc.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/pages/register_page.dart';
import '../../features/auth/presentation/pages/splash_page.dart';
import 'app_routes.dart';
import 'main_shell.dart';

class AppRouter {
  AppRouter._();

  static GoRouter create(AuthBloc authBloc) {
    return GoRouter(
      initialLocation: AppRoutes.splash,
      redirect: (context, state) {
        final authState = authBloc.state;
        final location = state.matchedLocation;
        final isPublic = location == AppRoutes.splash ||
            location == AppRoutes.login ||
            location == AppRoutes.register;

        if (authState is AuthAuthenticated && isPublic) {
          return AppRoutes.home;
        }

        if (authState is AuthUnauthenticated && !isPublic) {
          return AppRoutes.login;
        }

        return null;
      },
      routes: [
        GoRoute(
          path: AppRoutes.splash,
          builder: (context, state) => const SplashPage(),
        ),
        GoRoute(
          path: AppRoutes.login,
          builder: (context, state) => const LoginPage(),
        ),
        GoRoute(
          path: AppRoutes.register,
          builder: (context, state) => const RegisterPage(),
        ),
        GoRoute(
          path: AppRoutes.home,
          builder: (context, state) => const MainShell(),
        ),
      ],
    );
  }
}
