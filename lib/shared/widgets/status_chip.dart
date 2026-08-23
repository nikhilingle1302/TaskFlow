import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_radius.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';

class StatusChip extends StatelessWidget {
  const StatusChip({super.key, required this.status});

  final String status;

  @override
  Widget build(BuildContext context) {
    final colors = _colorsFor(status);
    final label = _labelFor(status);

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: AppSpacing.sm.w,
        vertical: AppSpacing.xs.h,
      ),
      decoration: BoxDecoration(
        color: colors.background,
        borderRadius: BorderRadius.circular(AppRadius.full.r),
      ),
      child: Text(
        label,
        style: AppTypography.caption(color: colors.foreground),
      ),
    );
  }

  static String _labelFor(String status) {
    switch (status) {
      case 'todo':
        return 'To Do';
      case 'in_progress':
        return 'In Progress';
      case 'review':
        return 'Review';
      case 'done':
        return 'Done';
      default:
        return status.replaceAll('_', ' ');
    }
  }

  static ({Color foreground, Color background}) _colorsFor(String status) {
    switch (status) {
      case 'todo':
        return (
          foreground: AppColors.statusTodo,
          background: AppColors.statusTodoBg,
        );
      case 'in_progress':
        return (
          foreground: AppColors.statusInProgress,
          background: AppColors.statusInProgressBg,
        );
      case 'review':
        return (
          foreground: AppColors.statusReview,
          background: AppColors.statusReviewBg,
        );
      case 'done':
        return (
          foreground: AppColors.statusDone,
          background: AppColors.statusDoneBg,
        );
      default:
        return (
          foreground: AppColors.textSecondary,
          background: AppColors.statusTodoBg,
        );
    }
  }
}
