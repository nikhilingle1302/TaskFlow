import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../injection.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../cubit/home_cubit.dart';
import '../widgets/home_project_card.dart';
import '../widgets/home_summary_card.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  String _greetingName(String fullName) {
    final parts = fullName.trim().split(' ');
    return parts.isEmpty ? fullName : parts.first;
  }

  String _greetingTime() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning';
    if (hour < 17) return 'Good afternoon';
    return 'Good evening';
  }

  @override
  Widget build(BuildContext context) {
    final authState = context.read<AuthBloc>().state;
    if (authState is! AuthAuthenticated) {
      return const SizedBox.shrink();
    }

    final session = authState.session;

    return BlocProvider(
      create: (_) => HomeCubit(
        projectRepository: sl(),
        taskRepository: sl(),
        orgId: session.orgId,
        userName: session.name,
      )..load(),
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
          child: BlocBuilder<HomeCubit, HomeState>(
            builder: (context, state) {
              if (state is HomeLoading || state is HomeInitial) {
                return const Center(child: CircularProgressIndicator());
              }

              if (state is HomeFailure) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(state.message, style: AppTypography.body()),
                      SizedBox(height: AppSpacing.lg.h),
                      FilledButton(
                        onPressed: () => context.read<HomeCubit>().load(),
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                );
              }

              final userName = switch (state) {
                HomeLoaded(:final userName) => userName,
                HomeEmpty(:final userName) => userName,
                _ => session.name,
              };

              return RefreshIndicator(
                onRefresh: () => context.read<HomeCubit>().load(),
                child: ListView(
                  padding: EdgeInsets.symmetric(
                    horizontal: AppSpacing.screenHorizontal.w,
                    vertical: AppSpacing.lg.h,
                  ),
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${_greetingTime()}, ${_greetingName(userName)} 👋',
                                style: AppTypography.largeHeading(),
                              ),
                              SizedBox(height: AppSpacing.xs.h),
                              Text(
                                'Here is what is happening in your workspace.',
                                style: AppTypography.body(
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          onPressed: () {},
                          icon: Icon(
                            Icons.notifications_outlined,
                            size: 24.sp,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: AppSpacing.xxl.h),
                    if (state is HomeLoaded) ...[
                      Row(
                        children: [
                          HomeSummaryCard(
                            label: 'Projects',
                            value: '${state.projectCount}',
                            icon: Icons.folder_outlined,
                            iconColor: AppColors.primary,
                            iconBg: AppColors.primaryLight,
                          ),
                          SizedBox(width: AppSpacing.md.w),
                          HomeSummaryCard(
                            label: 'Tasks',
                            value: '${state.taskCount}',
                            icon: Icons.task_alt_outlined,
                            iconColor: AppColors.info,
                            iconBg: AppColors.statusInProgressBg,
                          ),
                          SizedBox(width: AppSpacing.md.w),
                          HomeSummaryCard(
                            label: 'Overdue',
                            value: '${state.overdueCount}',
                            icon: Icons.warning_amber_rounded,
                            iconColor: AppColors.error,
                            iconBg: AppColors.priorityUrgentBg,
                          ),
                        ],
                      ),
                      SizedBox(height: AppSpacing.xxl.h),
                      Text('My Projects', style: AppTypography.screenTitle()),
                      SizedBox(height: AppSpacing.lg.h),
                      ...state.projects.map(
                        (item) => HomeProjectCard(item: item),
                      ),
                    ] else if (state is HomeEmpty) ...[
                      SizedBox(height: 48.h),
                      Center(
                        child: Text(
                          'No projects yet for your organization.',
                          style: AppTypography.body(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
