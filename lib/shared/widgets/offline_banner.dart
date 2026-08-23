import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';

import '../../core/settings/app_settings_cubit.dart';
import '../../core/storage/offline_cache.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';
import '../../injection.dart';

class OfflineBanner extends StatelessWidget {
  const OfflineBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AppSettingsCubit, AppSettingsState>(
      builder: (context, state) {
        if (state is! AppSettingsLoaded || !state.offlineMode) {
          return const SizedBox.shrink();
        }

        final lastSync = sl<OfflineCache>().lastSyncAt;
        final syncLabel = lastSync == null
            ? 'Showing cached data. Last sync unknown.'
            : 'Showing cached data from ${DateFormat('MMM d, h:mm a').format(lastSync.toLocal())}.';

        return Material(
          color: AppColors.warning,
          child: SafeArea(
            bottom: false,
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: AppSpacing.screenHorizontal.w,
                vertical: AppSpacing.sm.h,
              ),
              child: Row(
                children: [
                  Icon(Icons.cloud_off, color: AppColors.surface, size: 18.sp),
                  SizedBox(width: AppSpacing.sm.w),
                  Expanded(
                    child: Text(
                      syncLabel,
                      style: AppTypography.caption(color: AppColors.surface),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
