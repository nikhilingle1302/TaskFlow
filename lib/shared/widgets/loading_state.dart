import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_radius.dart';
import '../../core/theme/app_spacing.dart';

class LoadingState extends StatelessWidget {
  const LoadingState({super.key, this.listStyle = false});

  final bool listStyle;

  @override
  Widget build(BuildContext context) {
    if (!listStyle) {
      return const Center(child: CircularProgressIndicator());
    }

    return ListView(
      padding: EdgeInsets.all(AppSpacing.screenHorizontal.w),
      children: List.generate(3, (index) => _SkeletonCard(key: ValueKey(index))),
    );
  }
}

class _SkeletonCard extends StatelessWidget {
  const _SkeletonCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
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
          Container(
            width: 160.w,
            height: 14.h,
            decoration: BoxDecoration(
              color: AppColors.border,
              borderRadius: BorderRadius.circular(AppRadius.sm.r),
            ),
          ),
          SizedBox(height: AppSpacing.sm.h),
          Container(
            width: double.infinity,
            height: 12.h,
            decoration: BoxDecoration(
              color: AppColors.border,
              borderRadius: BorderRadius.circular(AppRadius.sm.r),
            ),
          ),
          SizedBox(height: AppSpacing.xs.h),
          Container(
            width: 220.w,
            height: 12.h,
            decoration: BoxDecoration(
              color: AppColors.border,
              borderRadius: BorderRadius.circular(AppRadius.sm.r),
            ),
          ),
        ],
      ),
    );
  }
}
