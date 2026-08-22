import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final session = context.select(
      (AuthBloc bloc) => bloc.state is AuthAuthenticated
          ? (bloc.state as AuthAuthenticated).session
          : null,
    );

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Profile', style: AppTypography.screenTitle()),
      ),
      body: Padding(
        padding: EdgeInsets.all(AppSpacing.screenHorizontal.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: AppSpacing.lg.h),
            Text(
              session?.name ?? 'User',
              style: AppTypography.largeHeading(),
            ),
            SizedBox(height: AppSpacing.xs.h),
            Text(
              session?.email ?? '',
              style: AppTypography.body(color: AppColors.textSecondary),
            ),
            SizedBox(height: AppSpacing.xs.h),
            Text(
              session == null ? '' : '${session.role} · ${session.orgId}',
              style: AppTypography.caption(),
            ),
            SizedBox(height: AppSpacing.sm.h),

            const Spacer(),
            AppButton(
              label: 'Log out',
              onPressed: () {
                context.read<AuthBloc>().add(const AuthLogoutRequested());
              },
            ),
            SizedBox(height: AppSpacing.lg.h),
          ],
        ),
      ),
    );
  }
}
