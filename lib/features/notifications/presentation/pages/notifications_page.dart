import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../shared/widgets/empty_state.dart';
import '../../../../shared/widgets/error_state.dart';
import '../../../../shared/widgets/loading_state.dart';
import '../cubit/notification_cubit.dart';
import '../widgets/notification_list_tile.dart';

class NotificationsPage extends StatelessWidget {
  const NotificationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Notifications', style: AppTypography.screenTitle()),
      ),
      body: BlocBuilder<NotificationCubit, NotificationState>(
        builder: (context, state) {
          if (state is NotificationLoading || state is NotificationInitial) {
            return const LoadingState(listStyle: true);
          }

          if (state is NotificationFailure) {
            return ErrorState(
              message: state.message,
              icon: state.message.toLowerCase().contains('offline')
                  ? Icons.cloud_off
                  : Icons.error_outline,
              onRetry: () => context.read<NotificationCubit>().load(),
            );
          }

          if (state is NotificationEmpty) {
            return const EmptyState(
              icon: Icons.notifications_none_outlined,
              title: 'No notifications yet',
              subtitle: 'Updates about your tasks will show up here.',
            );
          }

          if (state is! NotificationLoaded) {
            return const SizedBox.shrink();
          }

          return RefreshIndicator(
            onRefresh: () => context.read<NotificationCubit>().load(),
            child: ListView(
              padding: EdgeInsets.all(AppSpacing.screenHorizontal.w),
              children: state.notifications
                  .map(
                    (notification) => NotificationListTile(
                      notification: notification,
                      onTap: () async {
                        final cubit = context.read<NotificationCubit>();
                        if (!notification.read) {
                          await cubit.markAsRead(notification.id);
                        }
                        if (context.mounted && notification.taskId.isNotEmpty) {
                          context.push(
                            AppRoutes.taskDetailPath(notification.taskId),
                          );
                        }
                      },
                    ),
                  )
                  .toList(),
            ),
          );
        },
      ),
    );
  }
}
