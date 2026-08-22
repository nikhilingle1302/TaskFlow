import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../domain/entities/auth_session.dart';
import '../bloc/auth_bloc.dart';

class AuthSuccessPage extends StatelessWidget {
  const AuthSuccessPage({super.key, required this.session});

  final AuthSession session;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(AppSpacing.screenHorizontal.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: AppSpacing.xxxl.h),
              Text('You are signed in', style: AppTypography.largeHeading()),
              SizedBox(height: AppSpacing.sm.h),
              Text(
                'Home shell and navigation come in the next milestone.',
                style: AppTypography.body(color: AppColors.textSecondary),
              ),
              SizedBox(height: AppSpacing.xxl.h),
              Text(session.name, style: AppTypography.cardTitle()),
              SizedBox(height: AppSpacing.xs.h),
              Text(
                session.email,
                style: AppTypography.body(color: AppColors.textSecondary),
              ),
              SizedBox(height: AppSpacing.xs.h),
              Text(
                '${session.role} · ${session.orgId}',
                style: AppTypography.caption(),
              ),
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
      ),
    );
  }
}
