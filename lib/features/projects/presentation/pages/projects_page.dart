import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../injection.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../cubit/project_cubit.dart';
import '../widgets/project_list_card.dart';
import 'project_form_page.dart';

class ProjectsPage extends StatelessWidget {
  const ProjectsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final authState = context.read<AuthBloc>().state;
    if (authState is! AuthAuthenticated) {
      return const SizedBox.shrink();
    }

    final session = authState.session;

    return BlocProvider(
      create: (_) => ProjectCubit(
        projectRepository: sl(),
        taskRepository: sl(),
        orgId: session.orgId,
        role: session.role,
      )..load(),
      child: const _ProjectsView(),
    );
  }
}

class _ProjectsView extends StatefulWidget {
  const _ProjectsView();

  @override
  State<_ProjectsView> createState() => _ProjectsViewState();
}

class _ProjectsViewState extends State<_ProjectsView> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _openCreateForm() async {
    final created = await Navigator.of(context).push<bool>(
      MaterialPageRoute<bool>(
        builder: (_) => BlocProvider.value(
          value: context.read<ProjectCubit>(),
          child: const ProjectFormPage(),
        ),
      ),
    );
    if (created == true && mounted) {
      context.read<ProjectCubit>().load();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Projects', style: AppTypography.screenTitle()),
        actions: [
          IconButton(
            onPressed: _openCreateForm,
            icon: Icon(Icons.add, size: 24.sp),
          ),
        ],
      ),
      body: BlocConsumer<ProjectCubit, ProjectState>(
        listener: (context, state) {
          if (state is ProjectActionFailure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          }
        },
        builder: (context, state) {
          if (state is ProjectLoading || state is ProjectInitial) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is ProjectFailure) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(state.message, style: AppTypography.body()),
                  SizedBox(height: AppSpacing.lg.h),
                  FilledButton(
                    onPressed: () => context.read<ProjectCubit>().load(),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          final isEmpty = state is ProjectEmpty;
          final loaded = state is ProjectLoaded ? state : null;

          return RefreshIndicator(
            onRefresh: () => context.read<ProjectCubit>().load(),
            child: ListView(
              padding: EdgeInsets.all(AppSpacing.screenHorizontal.w),
              children: [
                TextField(
                  controller: _searchController,
                  onChanged: context.read<ProjectCubit>().search,
                  decoration: InputDecoration(
                    hintText: 'Search projects',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: IconButton(
                      onPressed: () {},
                      icon: const Icon(Icons.tune),
                    ),
                  ),
                ),
                SizedBox(height: AppSpacing.lg.h),
                if (isEmpty)
                  Padding(
                    padding: EdgeInsets.only(top: 48.h),
                    child: Center(
                      child: Text(
                        'No projects yet. Tap + to create one.',
                        style: AppTypography.body(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                  )
                else if (loaded != null)
                  ...loaded.filtered.map(
                    (item) => ProjectListCard(
                      item: item,
                      onTap: () {
                        context.push(
                          AppRoutes.projectDetailPath(item.project.id),
                        );
                      },
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
