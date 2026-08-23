import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_radius.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';

class PriorityChip extends StatelessWidget {
  const PriorityChip({super.key, required this.priority});

  final String priority;

  @override
  Widget build(BuildContext context) {
    final colors = _colorsFor(priority);
    final label = priority[0].toUpperCase() + priority.substring(1);

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

  static ({Color foreground, Color background}) _colorsFor(String priority) {
    switch (priority) {
      case 'low':
        return (
          foreground: AppColors.priorityLow,
          background: AppColors.priorityLowBg,
        );
      case 'medium':
        return (
          foreground: AppColors.priorityMedium,
          background: AppColors.priorityMediumBg,
        );
      case 'high':
        return (
          foreground: AppColors.priorityHigh,
          background: AppColors.priorityHighBg,
        );
      case 'urgent':
        return (
          foreground: AppColors.priorityUrgent,
          background: AppColors.priorityUrgentBg,
        );
      default:
        return (
          foreground: AppColors.textSecondary,
          background: AppColors.priorityLowBg,
        );
    }
  }
}
