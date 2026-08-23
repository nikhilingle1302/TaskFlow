import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/error/app_exception.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../injection.dart';
import '../../../../shared/widgets/loading_state.dart';
import '../../../../shared/widgets/priority_chip.dart';
import '../../../../shared/widgets/status_chip.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/domain/entities/user.dart';
import '../cubit/task_detail_cubit.dart';
import 'task_form_page.dart';

class TaskDetailPage extends StatelessWidget {
  const TaskDetailPage({super.key, required this.taskId});

  final String taskId;

  @override
  Widget build(BuildContext context) {
    final authState = context.read<AuthBloc>().state;
    if (authState is! AuthAuthenticated) {
      return const SizedBox.shrink();
    }

    final session = authState.session;

    return BlocProvider(
      create: (_) => TaskDetailCubit(
        taskRepository: sl(),
        projectRepository: sl(),
        orgRepository: sl(),
        taskId: taskId,
        orgId: session.orgId,
        userId: session.userId,
      )..load(),
      child: const _TaskDetailView(),
    );
  }
}

class _TaskDetailView extends StatefulWidget {
  const _TaskDetailView();

  @override
  State<_TaskDetailView> createState() => _TaskDetailViewState();
}

class _TaskDetailViewState extends State<_TaskDetailView> {
  final _commentController = TextEditingController();

  static const _statuses = [
    ('todo', 'To Do'),
    ('in_progress', 'In Progress'),
    ('review', 'Review'),
    ('done', 'Done'),
  ];

  static const _priorities = [
    ('low', 'Low'),
    ('medium', 'Medium'),
    ('high', 'High'),
    ('urgent', 'Urgent'),
  ];

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _openEdit(TaskDetailData data) async {
    final detailCubit = context.read<TaskDetailCubit>();
    final updated = await Navigator.of(context).push<bool>(
      MaterialPageRoute<bool>(
        builder: (_) => TaskFormPage(
          task: data.task,
          projects: data.projects,
          members: data.members,
          onSave: detailCubit.updateTask,
        ),
      ),
    );
    if (updated == true && mounted) {
      detailCubit.load();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Task updated')),
      );
    }
  }

  Future<void> _confirmDelete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete task?'),
        content: const Text('This will remove the task and its comments.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      try {
        await context.read<TaskDetailCubit>().delete();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Task deleted')),
          );
          context.pop();
        }
      } on AppException catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(e.message)),
          );
        }
      }
    }
  }

  Future<void> _changeStatus(String status) async {
    try {
      await context.read<TaskDetailCubit>().updateStatus(status);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Status updated')),
        );
      }
    } on AppException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.message)),
        );
      }
    }
  }

  Future<void> _changePriority(String priority) async {
    try {
      await context.read<TaskDetailCubit>().updatePriority(priority);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Priority updated')),
        );
      }
    } on AppException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.message)),
        );
      }
    }
  }

  Future<void> _changeAssignee(String? userId) async {
    try {
      await context.read<TaskDetailCubit>().assign(userId);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              userId == null ? 'Assignee cleared' : 'Assignee updated',
            ),
          ),
        );
      }
    } on AppException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.message)),
        );
      }
    }
  }

  Future<void> _submitComment() async {
    final body = _commentController.text.trim();
    if (body.isEmpty) return;

    try {
      await context.read<TaskDetailCubit>().addComment(body);
      _commentController.clear();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Comment added')),
        );
      }
    } on AppException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.message)),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TaskDetailCubit, TaskDetailState>(
      builder: (context, state) {
        if (state is TaskDetailLoading || state is TaskDetailInitial) {
          return Scaffold(
            appBar: AppBar(),
            body: const LoadingState(),
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
            actions: [
              PopupMenuButton<String>(
                onSelected: (value) async {
                  if (value == 'edit') {
                    await _openEdit(data);
                  } else if (value == 'delete') {
                    await _confirmDelete();
                  }
                },
                itemBuilder: (context) => const [
                  PopupMenuItem(value: 'edit', child: Text('Edit')),
                  PopupMenuItem(value: 'delete', child: Text('Delete')),
                ],
              ),
            ],
          ),
          body: Column(
            children: [
              Expanded(
                child: ListView(
                  padding: EdgeInsets.all(AppSpacing.screenHorizontal.w),
                  children: [
                    Text(task.title, style: AppTypography.largeHeading()),
                    SizedBox(height: AppSpacing.md.h),
                    Wrap(
                      spacing: AppSpacing.sm.w,
                      runSpacing: AppSpacing.sm.h,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        PopupMenuButton<String>(
                          onSelected: _changeStatus,
                          itemBuilder: (context) => _statuses
                              .map(
                                (item) => PopupMenuItem(
                                  value: item.$1,
                                  child: Text(item.$2),
                                ),
                              )
                              .toList(),
                          child: StatusChip(status: task.status),
                        ),
                        PopupMenuButton<String>(
                          onSelected: _changePriority,
                          itemBuilder: (context) => _priorities
                              .map(
                                (item) => PopupMenuItem(
                                  value: item.$1,
                                  child: Text(item.$2),
                                ),
                              )
                              .toList(),
                          child: PriorityChip(priority: task.priority),
                        ),
                      ],
                    ),
                    SizedBox(height: AppSpacing.xxl.h),
                    _DetailCard(
                      children: [
                        _InfoRow(
                          label: 'Project',
                          value: data.project.name,
                        ),
                        _AssigneeRow(
                          assigneeName: data.assignee?.name ?? 'Unassigned',
                          members: data.members,
                          onAssign: _changeAssignee,
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
                        style: AppTypography.body(
                          color: AppColors.textSecondary,
                        ),
                      )
                    else
                      ...data.comments.map(
                        (item) => _CommentTile(item: item),
                      ),
                  ],
                ),
              ),
              Container(
                padding: EdgeInsets.fromLTRB(
                  AppSpacing.screenHorizontal.w,
                  AppSpacing.sm.h,
                  AppSpacing.screenHorizontal.w,
                  AppSpacing.lg.h,
                ),
                decoration: const BoxDecoration(
                  color: AppColors.surface,
                  border: Border(top: BorderSide(color: AppColors.border)),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _commentController,
                        decoration: const InputDecoration(
                          hintText: 'Add a comment...',
                          border: OutlineInputBorder(),
                          isDense: true,
                        ),
                        textInputAction: TextInputAction.send,
                        onSubmitted: (_) => _submitComment(),
                      ),
                    ),
                    SizedBox(width: AppSpacing.sm.w),
                    IconButton(
                      onPressed: _submitComment,
                      icon: const Icon(Icons.send_rounded),
                      color: AppColors.primary,
                    ),
                  ],
                ),
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

class _AssigneeRow extends StatelessWidget {
  const _AssigneeRow({
    required this.assigneeName,
    required this.members,
    required this.onAssign,
  });

  final String assigneeName;
  final List<User> members;
  final Future<void> Function(String? userId) onAssign;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 96.w,
          child: Text(
            'Assignee',
            style: AppTypography.caption(color: AppColors.textSecondary),
          ),
        ),
        Expanded(
          child: PopupMenuButton<String?>(
            onSelected: onAssign,
            itemBuilder: (context) => [
              const PopupMenuItem(value: null, child: Text('Unassigned')),
              ...members.map(
                (member) => PopupMenuItem(
                  value: member.id,
                  child: Text(member.name),
                ),
              ),
            ],
            child: Row(
              children: [
                Text(assigneeName, style: AppTypography.body()),
                SizedBox(width: AppSpacing.xs.w),
                Icon(Icons.expand_more, size: 18.sp, color: AppColors.textSecondary),
              ],
            ),
          ),
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
