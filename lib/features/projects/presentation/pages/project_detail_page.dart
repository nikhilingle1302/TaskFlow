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
import '../../../../core/router/app_routes.dart';
import '../../../../injection.dart';
import '../../../../shared/widgets/loading_state.dart';
import '../../../auth/domain/entities/user.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../tasks/domain/entities/comment.dart';
import '../../../tasks/domain/entities/task_item.dart';
import '../cubit/project_cubit.dart';
import '../cubit/project_detail_cubit.dart';
import 'project_form_page.dart';

class ProjectDetailPage extends StatelessWidget {
  const ProjectDetailPage({super.key, required this.projectId});

  final String projectId;

  @override
  Widget build(BuildContext context) {
    final authState = context.read<AuthBloc>().state;
    if (authState is! AuthAuthenticated) {
      return const SizedBox.shrink();
    }

    final session = authState.session;

    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => ProjectDetailCubit(
            projectRepository: sl(),
            taskRepository: sl(),
            orgRepository: sl(),
            projectId: projectId,
            orgId: session.orgId,
            role: session.role,
          )..load(),
        ),
        BlocProvider(
          create: (_) => ProjectCubit(
            projectRepository: sl(),
            taskRepository: sl(),
            orgId: session.orgId,
            role: session.role,
          ),
        ),
      ],
      child: const _ProjectDetailView(),
    );
  }
}

class _ProjectDetailView extends StatefulWidget {
  const _ProjectDetailView();

  @override
  State<_ProjectDetailView> createState() => _ProjectDetailViewState();
}

class _ProjectDetailViewState extends State<_ProjectDetailView>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _confirmDelete(BuildContext context, String projectId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete project?'),
        content: const Text(
          'This will remove the project and its tasks from this session.',
        ),
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

    if (confirmed == true && context.mounted) {
      try {
        await context.read<ProjectCubit>().deleteProject(projectId);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Project deleted')),
          );
          context.pop();
        }
      } on AppException catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(e.message)),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ProjectCubit, ProjectState>(
      listener: (context, state) {
        if (state is ProjectActionFailure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message)),
          );
        }
      },
      builder: (context, projectListState) {
        return BlocConsumer<ProjectDetailCubit, ProjectDetailState>(
          listener: (context, state) {
            if (state is ProjectDetailActionFailure) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.message)),
              );
            }
          },
          builder: (context, state) {
            if (state is ProjectDetailLoading ||
                state is ProjectDetailInitial) {
              return Scaffold(
                appBar: AppBar(),
                body: const LoadingState(),
              );
            }

            if (state is ProjectDetailFailure) {
              return Scaffold(
                appBar: AppBar(),
                body: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(state.message, style: AppTypography.body()),
                      SizedBox(height: AppSpacing.lg.h),
                      FilledButton(
                        onPressed: () =>
                            context.read<ProjectDetailCubit>().load(),
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                ),
              );
            }

            if (state is! ProjectDetailLoaded) {
              return const SizedBox.shrink();
            }

            final data = state.data;
            final project = data.project;

            return Scaffold(
              backgroundColor: AppColors.background,
              appBar: AppBar(
                title: Text(project.name, style: AppTypography.screenTitle()),
                actions: [
                  PopupMenuButton<String>(
                    onSelected: (value) async {
                      if (value == 'edit') {
                        final updated = await Navigator.of(context).push<bool>(
                          MaterialPageRoute<bool>(
                            builder: (_) => BlocProvider.value(
                              value: context.read<ProjectCubit>(),
                              child: ProjectFormPage(
                                projectId: project.id,
                                initialName: project.name,
                                initialDescription: project.description,
                              ),
                            ),
                          ),
                        );
                        if (updated == true && context.mounted) {
                          context.read<ProjectDetailCubit>().load();
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Project updated')),
                          );
                        }
                      } else if (value == 'delete') {
                        await _confirmDelete(context, project.id);
                      }
                    },
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'edit',
                        child: Text('Edit'),
                      ),
                      if (data.isAdmin)
                        const PopupMenuItem(
                          value: 'delete',
                          child: Text('Delete'),
                        ),
                    ],
                  ),
                ],
                bottom: TabBar(
                  controller: _tabController,
                  isScrollable: true,
                  labelColor: AppColors.primary,
                  unselectedLabelColor: AppColors.textSecondary,
                  indicatorColor: AppColors.primary,
                  tabs: const [
                    Tab(text: 'Overview'),
                    Tab(text: 'Tasks'),
                    Tab(text: 'Members'),
                    Tab(text: 'Activity'),
                  ],
                ),
              ),
              body: Stack(
                children: [
                  TabBarView(
                    controller: _tabController,
                    children: [
                      _OverviewTab(data: data),
                      _TasksTab(tasks: data.tasks),
                      _MembersTab(
                        members: data.members,
                        isAdmin: data.isAdmin,
                        isMutating: data.isMutating,
                      ),
                      _ActivityTab(comments: data.comments),
                    ],
                  ),
                  if (data.isMutating)
                    const Positioned(
                      top: 0,
                      left: 0,
                      right: 0,
                      child: LinearProgressIndicator(minHeight: 2),
                    ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

class _OverviewTab extends StatelessWidget {
  const _OverviewTab({required this.data});

  final ProjectDetailData data;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: EdgeInsets.all(AppSpacing.screenHorizontal.w),
      children: [
        Text('Progress', style: AppTypography.cardTitle()),
        SizedBox(height: AppSpacing.sm.h),
        Row(
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(AppRadius.full.r),
                child: LinearProgressIndicator(
                  value: data.progress,
                  minHeight: 8.h,
                ),
              ),
            ),
            SizedBox(width: AppSpacing.md.w),
            Text('${data.progressPercent}%', style: AppTypography.label()),
          ],
        ),
        SizedBox(height: AppSpacing.xxl.h),
        Text('Task summary', style: AppTypography.cardTitle()),
        SizedBox(height: AppSpacing.md.h),
        Wrap(
          spacing: AppSpacing.sm.w,
          runSpacing: AppSpacing.sm.h,
          children: data.taskSummary.entries.map((entry) {
            return _SummaryChip(label: entry.key, count: entry.value);
          }).toList(),
        ),
        SizedBox(height: AppSpacing.xxl.h),
        Text('Description', style: AppTypography.cardTitle()),
        SizedBox(height: AppSpacing.sm.h),
        Text(
          data.project.description,
          style: AppTypography.body(color: AppColors.textSecondary),
        ),
        SizedBox(height: AppSpacing.xxl.h),
        Text('Members', style: AppTypography.cardTitle()),
        SizedBox(height: AppSpacing.md.h),
        ...data.members.take(4).map(
              (member) => Padding(
                padding: EdgeInsets.only(bottom: AppSpacing.sm.h),
                child: Text(member.name, style: AppTypography.body()),
              ),
            ),
      ],
    );
  }
}

class _SummaryChip extends StatelessWidget {
  const _SummaryChip({required this.label, required this.count});

  final String label;
  final int count;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: AppSpacing.md.w,
        vertical: AppSpacing.sm.h,
      ),
      decoration: BoxDecoration(
        color: AppColors.primaryLight,
        borderRadius: BorderRadius.circular(AppRadius.full.r),
      ),
      child: Text(
        '${label.replaceAll('_', ' ')}: $count',
        style: AppTypography.caption(color: AppColors.primary),
      ),
    );
  }
}

class _TasksTab extends StatelessWidget {
  const _TasksTab({required this.tasks});

  final List<TaskItem> tasks;

  @override
  Widget build(BuildContext context) {
    if (tasks.isEmpty) {
      return Center(
        child: Text(
          'No tasks in this project yet.',
          style: AppTypography.body(color: AppColors.textSecondary),
        ),
      );
    }

    return ListView.separated(
      padding: EdgeInsets.all(AppSpacing.screenHorizontal.w),
      itemCount: tasks.length,
      separatorBuilder: (_, __) => SizedBox(height: AppSpacing.sm.h),
      itemBuilder: (context, index) {
        final task = tasks[index];
        return InkWell(
          onTap: () => context.push(AppRoutes.taskDetailPath(task.id)),
          borderRadius: BorderRadius.circular(AppRadius.lg.r),
          child: Container(
            padding: EdgeInsets.all(AppSpacing.lg.w),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(AppRadius.lg.r),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(task.title, style: AppTypography.cardTitle()),
                SizedBox(height: AppSpacing.xs.h),
                Text(
                  '${task.status} · ${task.priority}',
                  style: AppTypography.caption(),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _MembersTab extends StatelessWidget {
  const _MembersTab({
    required this.members,
    required this.isAdmin,
    required this.isMutating,
  });

  final List<User> members;
  final bool isAdmin;
  final bool isMutating;

  Future<void> _addMember(BuildContext context) async {
    final cubit = context.read<ProjectDetailCubit>();
    final eligible = await cubit.eligibleUsers();
    if (!context.mounted) return;

    if (eligible.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No eligible users to add.')),
      );
      return;
    }

    final selected = await showDialog<User>(
      context: context,
      builder: (context) {
        return SimpleDialog(
          title: const Text('Add member'),
          children: eligible
              .map(
                (user) => SimpleDialogOption(
                  onPressed: () => Navigator.pop(context, user),
                  child: ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(user.name, style: AppTypography.body()),
                    subtitle: Text(user.email, style: AppTypography.caption()),
                  ),
                ),
              )
              .toList(),
        );
      },
    );

    if (selected != null && context.mounted) {
      final messenger = ScaffoldMessenger.of(context);
      final added = await cubit.addMember(selected.id);
      if (added) {
        messenger.showSnackBar(
          SnackBar(content: Text('${selected.name} added to organization')),
        );
      }
    }
  }

  Future<void> _confirmRemove(BuildContext context, User member) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Remove member?'),
        content: Text(
          'Remove ${member.name} from this organization?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Remove'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      final messenger = ScaffoldMessenger.of(context);
      final removed =
          await context.read<ProjectDetailCubit>().removeMember(member.id);
      if (removed) {
        messenger.showSnackBar(
          SnackBar(content: Text('${member.name} removed')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (isAdmin)
          Padding(
            padding: EdgeInsets.fromLTRB(
              AppSpacing.screenHorizontal.w,
              AppSpacing.md.h,
              AppSpacing.screenHorizontal.w,
              0,
            ),
            child: Align(
              alignment: Alignment.centerRight,
              child: FilledButton.icon(
                onPressed: isMutating ? null : () => _addMember(context),
                icon: Icon(Icons.person_add_outlined, size: 18.sp),
                label: const Text('Add member'),
              ),
            ),
          ),
        Expanded(
          child: members.isEmpty
              ? Center(
                  child: Text(
                    'No members yet.',
                    style: AppTypography.body(color: AppColors.textSecondary),
                  ),
                )
              : ListView.separated(
                  padding: EdgeInsets.all(AppSpacing.screenHorizontal.w),
                  itemCount: members.length,
                  separatorBuilder: (_, __) =>
                      SizedBox(height: AppSpacing.sm.h),
                  itemBuilder: (context, index) {
                    final member = members[index];
                    return ListTile(
                      tileColor: AppColors.surface,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppRadius.lg.r),
                        side: const BorderSide(color: AppColors.border),
                      ),
                      title: Text(member.name, style: AppTypography.body()),
                      subtitle:
                          Text(member.email, style: AppTypography.caption()),
                      trailing: isAdmin
                          ? PopupMenuButton<String>(
                              onSelected: (value) {
                                if (value == 'remove') {
                                  _confirmRemove(context, member);
                                }
                              },
                              itemBuilder: (context) => const [
                                PopupMenuItem(
                                  value: 'remove',
                                  child: Text('Remove'),
                                ),
                              ],
                            )
                          : null,
                    );
                  },
                ),
        ),
      ],
    );
  }
}

class _ActivityTab extends StatelessWidget {
  const _ActivityTab({required this.comments});

  final List<Comment> comments;

  @override
  Widget build(BuildContext context) {
    if (comments.isEmpty) {
      return Center(
        child: Text(
          'No activity yet.',
          style: AppTypography.body(color: AppColors.textSecondary),
        ),
      );
    }

    final formatter = DateFormat('MMM d, h:mm a');

    return ListView.separated(
      padding: EdgeInsets.all(AppSpacing.screenHorizontal.w),
      itemCount: comments.length,
      separatorBuilder: (_, __) => SizedBox(height: AppSpacing.sm.h),
      itemBuilder: (context, index) {
        final comment = comments[index];
        return Container(
          padding: EdgeInsets.all(AppSpacing.lg.w),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(AppRadius.lg.r),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(comment.body, style: AppTypography.body()),
              SizedBox(height: AppSpacing.xs.h),
              Text(
                formatter.format(comment.createdAt.toLocal()),
                style: AppTypography.caption(),
              ),
            ],
          ),
        );
      },
    );
  }
}
