import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../injection.dart';
import '../../../../shared/widgets/priority_chip.dart';
import '../../../../shared/widgets/status_chip.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../cubit/task_detail_cubit.dart';

class TaskDetailPage extends StatelessWidget {
  const TaskDetailPage({super.key, required this.taskId});

  final String taskId;

  @override
  Widget build(BuildContext context) {
    final authState = context.read<AuthBloc>().state;
    if (authState is! AuthAuthenticated) {
      return const SizedBox.shrink();
    }

    return BlocProvider(
      create: (_) => TaskDetailCubit(
        taskRepository: sl(),
        projectRepository: sl(),
        orgRepository: sl(),
        taskId: taskId,
        orgId: authState.session.orgId,
      )..load(),
      child: const _TaskDetailView(),
    );
  }
}

class _TaskDetailView extends StatelessWidget {
  const _TaskDetailView();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TaskDetailCubit, TaskDetailState>(
      builder: (context, state) {
        if (state is TaskDetailLoading || state is TaskDetailInitial) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (state is TaskDetailFailure) {
          return Scaffold(
            appBar: AppBar(),
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(state.message, style: AppTypography.body()),
                  SizedBox(height: AppSpacing.lg.h),
                  FilledButton(
                    onPressed: () => context.read<TaskDetailCubit>().load(),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            ),
          );
        }

        if (state is! TaskDetailLoaded) {
          return const SizedBox.shrink();
        }

        final data = state.data;
        final task = data.task;
        final dateFormat = DateFormat('MMM d, yyyy');

        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            title: Text('Task details', style: AppTypography.screenTitle()),
          ),
          body: ListView(
            padding: EdgeInsets.all(AppSpacing.screenHorizontal.w),
            children: [
              Text(task.title, style: AppTypography.largeHeading()),
              SizedBox(height: AppSpacing.md.h),
              Wrap(
                spacing: AppSpacing.sm.w,
                runSpacing: AppSpacing.sm.h,
                children: [
                  StatusChip(status: task.status),
                  PriorityChip(priority: task.priority),
                ],
              ),
              SizedBox(height: AppSpacing.xxl.h),
              _DetailCard(
                children: [
                  _InfoRow(
                    label: 'Project',
                    value: data.project.name,
                  ),
                  _InfoRow(
                    label: 'Assignee',
                    value: data.assignee?.name ?? 'Unassigned',
                  ),
                  _InfoRow(
                    label: 'Due date',
                    value: task.dueDate == null
                        ? 'No due date'
                        : dateFormat.format(task.dueDate!.toLocal()),
                  ),
                ],
              ),
              SizedBox(height: AppSpacing.xxl.h),
              Text('Description', style: AppTypography.cardTitle()),
              SizedBox(height: AppSpacing.sm.h),
              Text(
                task.description.isEmpty
                    ? 'No description provided.'
                    : task.description,
                style: AppTypography.body(color: AppColors.textSecondary),
              ),
              SizedBox(height: AppSpacing.xxl.h),
              Text('Comments', style: AppTypography.cardTitle()),
              SizedBox(height: AppSpacing.md.h),
              if (data.comments.isEmpty)
                Text(
                  'No comments yet.',
                  style: AppTypography.body(color: AppColors.textSecondary),
                )
              else
                ...data.comments.map(
                  (item) => _CommentTile(item: item),
                ),
            ],
          ),
        );
      },
    );
  }
}

class _DetailCard extends StatelessWidget {
  const _DetailCard({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(AppSpacing.lg.w),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg.r),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          for (var i = 0; i < children.length; i++) ...[
            if (i > 0) Divider(height: AppSpacing.lg.h),
            children[i],
          ],
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 96.w,
          child: Text(
            label,
            style: AppTypography.caption(color: AppColors.textSecondary),
          ),
        ),
        Expanded(
          child: Text(value, style: AppTypography.body()),
        ),
      ],
    );
  }
}

class _CommentTile extends StatelessWidget {
  const _CommentTile({required this.item});

  final TaskCommentItem item;

  @override
  Widget build(BuildContext context) {
    final formatter = DateFormat('MMM d, h:mm a');

    return Container(
      margin: EdgeInsets.only(bottom: AppSpacing.sm.h),
      padding: EdgeInsets.all(AppSpacing.lg.w),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg.r),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 16.r,
            backgroundColor: AppColors.primaryLight,
            child: Text(
              item.author.name.isNotEmpty
                  ? item.author.name[0].toUpperCase()
                  : '?',
              style: AppTypography.caption(color: AppColors.primary),
            ),
          ),
          SizedBox(width: AppSpacing.md.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        item.author.name,
                        style: AppTypography.label(),
                      ),
                    ),
                    Text(
                      formatter.format(item.comment.createdAt.toLocal()),
                      style: AppTypography.caption(),
                    ),
                  ],
                ),
                SizedBox(height: AppSpacing.xs.h),
                Text(item.comment.body, style: AppTypography.body()),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
