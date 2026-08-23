import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../cubit/project_state.dart';

class ProjectListCard extends StatelessWidget {
  const ProjectListCard({
    super.key,
    required this.item,
    required this.onTap,
  });

  final ProjectListItem item;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final project = item.project;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.lg.r),
      child: Container(
        margin: EdgeInsets.only(bottom: AppSpacing.lg.h),
        padding: EdgeInsets.all(AppSpacing.lg.w),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadius.lg.r),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 40.w,
                  height: 40.w,
                  decoration: BoxDecoration(
                    color: AppColors.primaryLight,
                    borderRadius: BorderRadius.circular(AppRadius.md.r),
                  ),
                  child: Icon(
                    Icons.folder_outlined,
                    color: AppColors.primary,
                    size: 22.sp,
                  ),
                ),
                SizedBox(width: AppSpacing.md.w),
                Expanded(
                  child: Text(project.name, style: AppTypography.cardTitle()),
                ),
                Text(
                  '${item.progressPercent}%',
                  style: AppTypography.label(color: AppColors.primary),
                ),
              ],
            ),
            SizedBox(height: AppSpacing.sm.h),
            Text(
              project.description,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: AppTypography.body(color: AppColors.textSecondary),
            ),
            SizedBox(height: AppSpacing.sm.h),
            Text(
              '${item.totalCount} tasks',
              style: AppTypography.caption(),
            ),
            SizedBox(height: AppSpacing.md.h),
            ClipRRect(
              borderRadius: BorderRadius.circular(AppRadius.full.r),
              child: LinearProgressIndicator(
                value: item.progress,
                minHeight: 6.h,
                backgroundColor: AppColors.border,
                color: AppColors.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
