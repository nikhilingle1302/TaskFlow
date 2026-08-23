import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import 'core/constants/app_constants.dart';
import 'core/router/app_router.dart';
import 'core/router/app_routes.dart';
import 'core/settings/app_settings_cubit.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/presentation/bloc/auth_bloc.dart';
import 'injection.dart';
import 'shared/widgets/offline_banner.dart';

class TaskFlowApp extends StatefulWidget {
  const TaskFlowApp({super.key});

  @override
  State<TaskFlowApp> createState() => _TaskFlowAppState();
}

class _TaskFlowAppState extends State<TaskFlowApp> {
  late final AuthBloc _authBloc;
  late final GoRouter _router;

  @override
  void initState() {
    super.initState();
    _authBloc = AuthBloc(sl())..add(const AuthStarted());
    _router = AppRouter.create(_authBloc);
  }

  @override
  void dispose() {
    _authBloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(
        AppConstants.designWidth,
        AppConstants.designHeight,
      ),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return MultiBlocProvider(
          providers: [
            BlocProvider.value(value: _authBloc),
            BlocProvider(
              create: (_) => AppSettingsCubit(sl())..load(),
            ),
          ],
          child: BlocListener<AuthBloc, AuthState>(
            listenWhen: (previous, current) {
              return current is AuthAuthenticated ||
                  current is AuthUnauthenticated;
            },
            listener: (context, state) {
              if (state is AuthAuthenticated) {
                _router.go(AppRoutes.home);
              } else if (state is AuthUnauthenticated) {
                _router.go(AppRoutes.login);
              }
            },
            child: MaterialApp.router(
              title: AppConstants.appName,
              debugShowCheckedModeBanner: false,
              theme: AppTheme.light(),
              routerConfig: _router,
              builder: (context, child) {
                return Column(
                  children: [
                    const OfflineBanner(),
                    Expanded(child: child ?? const SizedBox.shrink()),
                  ],
                );
              },
            ),
          ),
        );
      },
    );
  }
}
