import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../domain/entities/app_notification.dart';

class NotificationListTile extends StatelessWidget {
  const NotificationListTile({
    super.key,
    required this.notification,
    required this.onTap,
  });

  final AppNotification notification;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final formatter = DateFormat('MMM d, h:mm a');

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.lg.r),
      child: Container(
        margin: EdgeInsets.only(bottom: AppSpacing.sm.h),
        padding: EdgeInsets.all(AppSpacing.lg.w),
        decoration: BoxDecoration(
          color: notification.read
              ? AppColors.surface
              : AppColors.primaryLight.withValues(alpha: 0.45),
          borderRadius: BorderRadius.circular(AppRadius.lg.r),
          border: Border.all(
            color: notification.read ? AppColors.border : AppColors.primary,
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 40.w,
              height: 40.w,
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(AppRadius.md.r),
              ),
              child: Icon(
                _iconFor(notification.type),
                color: AppColors.primary,
                size: 22.sp,
              ),
            ),
            SizedBox(width: AppSpacing.md.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(notification.message, style: AppTypography.body()),
                  SizedBox(height: AppSpacing.xs.h),
                  Text(
                    formatter.format(notification.createdAt.toLocal()),
                    style: AppTypography.caption(),
                  ),
                ],
              ),
            ),
            if (!notification.read) ...[
              SizedBox(width: AppSpacing.sm.w),
              Container(
                width: 8.w,
                height: 8.w,
                decoration: const BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  IconData _iconFor(String type) {
    switch (type) {
      case 'task_assigned':
        return Icons.person_add_alt_1_outlined;
      default:
        return Icons.notifications_outlined;
    }
  }
}
