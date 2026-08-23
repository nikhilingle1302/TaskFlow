import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../injection.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../cubit/task_cubit.dart';
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
    );

    if (!mounted || result == null) return;

    if (result.priority == null &&
        result.projectId == null &&
        result.assigneeId == null) {
      context.read<TaskCubit>().clearFilters();
    } else {
      context.read<TaskCubit>().applyFilters(
            priority: result.priority,
            projectId: result.projectId,
            assigneeId: result.assigneeId,
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Tasks', style: AppTypography.screenTitle()),
      ),
      body: BlocBuilder<TaskCubit, TaskState>(
        builder: (context, state) {
          if (state is TaskLoading || state is TaskInitial) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is TaskFailure) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(state.message, style: AppTypography.body()),
                  SizedBox(height: AppSpacing.lg.h),
                  FilledButton(
                    onPressed: () => context.read<TaskCubit>().load(),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          if (state is TaskEmpty) {
            return Center(
              child: Text(
                'No tasks yet.',
                style: AppTypography.body(color: AppColors.textSecondary),
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
                        (item) => TaskListTile(item: item),
                      ),
                      SizedBox(height: AppSpacing.lg.h),
                    ];
                  })
                else
                  ...state.flatItems.map(
                    (item) => TaskListTile(item: item),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}
