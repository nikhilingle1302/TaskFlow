import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../injection.dart';
import '../../../../shared/widgets/empty_state.dart';
import '../../../../shared/widgets/error_state.dart';
import '../../../../shared/widgets/loading_state.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../cubit/task_cubit.dart';
import '../pages/task_form_page.dart';
import '../widgets/task_filter_sheet.dart';
import '../widgets/task_list_tile.dart';

class TasksPage extends StatelessWidget {
  const TasksPage({super.key});

  @override
  Widget build(BuildContext context) {
    final authState = context.read<AuthBloc>().state;
    if (authState is! AuthAuthenticated) {
      return const SizedBox.shrink();
    }

    final session = authState.session;

    return BlocProvider(
      create: (_) => TaskCubit(
        taskRepository: sl(),
        projectRepository: sl(),
        orgRepository: sl(),
        orgId: session.orgId,
      )..load(),
      child: const _TasksView(),
    );
  }
}

class _TasksView extends StatefulWidget {
  const _TasksView();

  @override
  State<_TasksView> createState() => _TasksViewState();
}

class _TasksViewState extends State<_TasksView> {
  final _searchController = TextEditingController();

  static const _statusOptions = [
    (value: null, label: 'All'),
    (value: 'todo', label: 'To Do'),
    (value: 'in_progress', label: 'In Progress'),
    (value: 'review', label: 'Review'),
    (value: 'done', label: 'Done'),
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _openFilters(TaskLoaded state) async {
    final result = await showTaskFilterSheet(
      context: context,
      projects: state.projects,
      members: state.members,
      initialPriority: state.priority,
      initialProjectId: state.projectId,
      initialAssigneeId: state.assigneeId,
      initialDueFrom: state.dueFrom,
      initialDueTo: state.dueTo,
    );

    if (!mounted || result == null) return;

    if (result.priority == null &&
        result.projectId == null &&
        result.assigneeId == null &&
        result.dueFrom == null &&
        result.dueTo == null) {
      context.read<TaskCubit>().clearFilters();
    } else {
      context.read<TaskCubit>().applyFilters(
            priority: result.priority,
            projectId: result.projectId,
            assigneeId: result.assigneeId,
            dueFrom: result.dueFrom,
            dueTo: result.dueTo,
          );
    }
  }

  Future<void> _openCreateForm() async {
    final cubit = context.read<TaskCubit>();
    final state = cubit.state;
    final projects = state is TaskLoaded
        ? state.projects
        : state is TaskEmpty
            ? state.projects
            : const [];

    if (projects.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Create a project before adding tasks.')),
      );
      return;
    }

    final taskId = await Navigator.of(context).push<String>(
      MaterialPageRoute<String>(
        builder: (_) => BlocProvider.value(
          value: cubit,
          child: const TaskFormPage(),
        ),
      ),
    );

    if (taskId != null && mounted) {
      cubit.load();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Tasks', style: AppTypography.screenTitle()),
        actions: [
          IconButton(
            onPressed: _openCreateForm,
            icon: Icon(Icons.add, size: 24.sp),
          ),
        ],
      ),
      body: BlocConsumer<TaskCubit, TaskState>(
        listener: (context, state) {
          if (state is TaskActionFailure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          }
        },
        builder: (context, state) {
          if (state is TaskLoading || state is TaskInitial) {
            return const LoadingState(listStyle: true);
          }

          if (state is TaskFailure) {
            return ErrorState(
              message: state.message,
              icon: state.message.toLowerCase().contains('offline')
                  ? Icons.cloud_off
                  : Icons.error_outline,
              onRetry: () => context.read<TaskCubit>().load(),
            );
          }

          if (state is TaskEmpty) {
            return RefreshIndicator(
              onRefresh: () => context.read<TaskCubit>().load(),
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: const [
                  EmptyState(
                    icon: Icons.task_alt_outlined,
                    title: 'No tasks yet',
                    subtitle: 'Tap + to create your first task.',
                  ),
                ],
              ),
            );
          }

          if (state is! TaskLoaded) {
            return const SizedBox.shrink();
          }

          final hasResults = state.useSections
              ? state.sections.isNotEmpty
              : state.flatItems.isNotEmpty;

          return RefreshIndicator(
            onRefresh: () => context.read<TaskCubit>().load(),
            child: ListView(
              padding: EdgeInsets.all(AppSpacing.screenHorizontal.w),
              children: [
                TextField(
                  controller: _searchController,
                  onChanged: context.read<TaskCubit>().search,
                  decoration: InputDecoration(
                    hintText: 'Search tasks',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: Badge(
                      isLabelVisible: state.activeFilterCount > 0,
                      label: Text('${state.activeFilterCount}'),
                      child: IconButton(
                        onPressed: () => _openFilters(state),
                        icon: const Icon(Icons.tune),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: AppSpacing.md.h),
                SizedBox(
                  height: 36.h,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: _statusOptions.length,
                    separatorBuilder: (_, __) => SizedBox(width: AppSpacing.sm.w),
                    itemBuilder: (context, index) {
                      final option = _statusOptions[index];
                      final selected = state.status == option.value;

                      return FilterChip(
                        label: Text(option.label),
                        selected: selected,
                        onSelected: (_) {
                          context.read<TaskCubit>().setStatus(option.value);
                        },
                        selectedColor: AppColors.primaryLight,
                        checkmarkColor: AppColors.primary,
                        labelStyle: AppTypography.caption(
                          color: selected
                              ? AppColors.primary
                              : AppColors.textSecondary,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppRadius.full.r),
                          side: BorderSide(
                            color: selected
                                ? AppColors.primary
                                : AppColors.border,
                          ),
                        ),
                      );
                    },
                  ),
                ),
                SizedBox(height: AppSpacing.lg.h),
                if (!hasResults)
                  Padding(
                    padding: EdgeInsets.only(top: 48.h),
                    child: Center(
                      child: Text(
                        'No tasks match your filters.',
                        style: AppTypography.body(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                  )
                else if (state.useSections)
                  ...state.sections.expand((group) {
                    return [
                      Padding(
                        padding: EdgeInsets.only(bottom: AppSpacing.sm.h),
                        child: Text(
                          group.title,
                          style: AppTypography.label(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ),
                      ...group.items.map(
                        (item) => TaskListTile(
                          item: item,
                          onTap: () => context.push(
                            AppRoutes.taskDetailPath(item.task.id),
                          ),
                        ),
                      ),
                      SizedBox(height: AppSpacing.lg.h),
                    ];
                  })
                else
                  ...state.flatItems.map(
                    (item) => TaskListTile(
                      item: item,
                      onTap: () => context.push(
                        AppRoutes.taskDetailPath(item.task.id),
                      ),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}
