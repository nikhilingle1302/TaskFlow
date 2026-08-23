import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../shared/widgets/priority_chip.dart';
import '../../../../shared/widgets/status_chip.dart';
import '../../domain/entities/task_item.dart';
import '../cubit/task_state.dart';

class TaskListTile extends StatelessWidget {
  const TaskListTile({
    super.key,
    required this.item,
    this.onTap,
  });

  final TaskListItem item;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final task = item.task;
    final dueLabel = _dueLabel(task.dueDate);
    final assignee = item.assignee;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.lg.r),
      child: Container(
        margin: EdgeInsets.only(bottom: AppSpacing.sm.h),
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
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(task.title, style: AppTypography.cardTitle()),
                ),
                if (assignee != null) ...[
                  SizedBox(width: AppSpacing.sm.w),
                  CircleAvatar(
                    radius: 14.r,
                    backgroundColor: AppColors.primaryLight,
                    child: Text(
                      assignee.name.isNotEmpty
                          ? assignee.name[0].toUpperCase()
                          : '?',
                      style: AppTypography.caption(color: AppColors.primary),
                    ),
                  ),
                ],
              ],
            ),
            SizedBox(height: AppSpacing.xs.h),
            Text(
              item.projectName,
              style: AppTypography.caption(color: AppColors.textSecondary),
            ),
            SizedBox(height: AppSpacing.sm.h),
            Wrap(
              spacing: AppSpacing.sm.w,
              runSpacing: AppSpacing.xs.h,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                StatusChip(status: task.status),
                PriorityChip(priority: task.priority),
                if (dueLabel != null)
                  Text(
                    dueLabel,
                    style: AppTypography.caption(
                      color: _isOverdue(task)
                          ? AppColors.error
                          : AppColors.textSecondary,
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String? _dueLabel(DateTime? dueDate) {
    if (dueDate == null) return null;

    final local = dueDate.toLocal();
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final dueDay = DateTime(local.year, local.month, local.day);

    if (dueDay == today) return 'Due today';
    if (dueDay.isBefore(today)) {
      return 'Due ${DateFormat('MMM d').format(local)}';
    }
    return 'Due ${DateFormat('MMM d').format(local)}';
  }

  bool _isOverdue(TaskItem task) {
    if (task.status == 'done') return false;
    final due = task.dueDate;
    if (due == null) return false;

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final dueDay = DateTime(due.year, due.month, due.day);
    return dueDay.isBefore(today);
  }
}
