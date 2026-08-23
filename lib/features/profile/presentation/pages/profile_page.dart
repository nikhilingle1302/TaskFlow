import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../injection.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../cubit/profile_cubit.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final authState = context.read<AuthBloc>().state;
    if (authState is! AuthAuthenticated) {
      return const SizedBox.shrink();
    }

    return BlocProvider(
      create: (_) => ProfileCubit(
        orgRepository: sl(),
        session: authState.session,
      ),
      child: const _ProfileView(),
    );
  }
}

class _ProfileView extends StatelessWidget {
  const _ProfileView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Profile', style: AppTypography.screenTitle()),
      ),
      body: BlocBuilder<ProfileCubit, ProfileState>(
        builder: (context, state) {
          if (state is ProfileLoading || state is ProfileInitial) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is ProfileFailure) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(state.message, style: AppTypography.body()),
                  SizedBox(height: AppSpacing.lg.h),
                  FilledButton(
                    onPressed: () => context.read<ProfileCubit>().load(),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          if (state is! ProfileLoaded) {
            return const SizedBox.shrink();
          }

          final session = state.session;
          final initial =
              session.name.isNotEmpty ? session.name[0].toUpperCase() : '?';

          return ListView(
            padding: EdgeInsets.all(AppSpacing.screenHorizontal.w),
            children: [
              SizedBox(height: AppSpacing.lg.h),
              Center(
                child: CircleAvatar(
                  radius: 40.r,
                  backgroundColor: AppColors.primaryLight,
                  child: Text(
                    initial,
                    style: AppTypography.largeHeading(color: AppColors.primary),
                  ),
                ),
              ),
              SizedBox(height: AppSpacing.lg.h),
              Center(
                child: Text(session.name, style: AppTypography.screenTitle()),
              ),
              SizedBox(height: AppSpacing.xs.h),
              Center(
                child: Text(
                  session.email,
                  style: AppTypography.body(color: AppColors.textSecondary),
                ),
              ),
              SizedBox(height: AppSpacing.xxl.h),
              Text(
                'Personal Information',
                style: AppTypography.label(color: AppColors.textSecondary),
              ),
              SizedBox(height: AppSpacing.md.h),
              _ProfileSection(
                children: [
                  _ProfileRow(label: 'Name', value: session.name),
                  _ProfileRow(label: 'Email', value: session.email),
                  _ProfileRow(label: 'Role', value: state.roleLabel),
                ],
              ),
              SizedBox(height: AppSpacing.xxl.h),
              Text(
                'Organization',
                style: AppTypography.label(color: AppColors.textSecondary),
              ),
              SizedBox(height: AppSpacing.md.h),
              _ProfileSection(
                children: [
                  _ProfileRow(label: 'Organization', value: state.orgName),
                  _ProfileRow(label: 'Org ID', value: session.orgId),
                ],
              ),
              SizedBox(height: AppSpacing.xxl.h),
              AppButton(
                label: 'Log out',
                onPressed: () {
                  context.read<AuthBloc>().add(const AuthLogoutRequested());
                },
              ),
              SizedBox(height: AppSpacing.lg.h),
            ],
          );
        },
      ),
    );
  }
}

class _ProfileSection extends StatelessWidget {
  const _ProfileSection({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(AppSpacing.lg.w),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg.r),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          for (var i = 0; i < children.length; i++) ...[
            if (i > 0) Divider(height: AppSpacing.lg.h),
            children[i],
          ],
        ],
      ),
    );
  }
}

class _ProfileRow extends StatelessWidget {
  const _ProfileRow({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 104.w,
          child: Text(
            label,
            style: AppTypography.caption(color: AppColors.textSecondary),
          ),
        ),
        Expanded(
          child: Text(value, style: AppTypography.body()),
        ),
      ],
    );
  }
}
