import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/error/app_exception.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../auth/domain/entities/user.dart';
import '../../../projects/domain/entities/project.dart';
import '../../domain/entities/task_item.dart';
import '../cubit/task_cubit.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/app_text_field.dart';

class TaskFormPage extends StatefulWidget {
  const TaskFormPage({
    super.key,
    this.task,
    this.initialProjectId,
    this.projects,
    this.members,
    this.onSave,
  });

  final TaskItem? task;
  final String? initialProjectId;
  final List<Project>? projects;
  final List<User>? members;
  final Future<void> Function(TaskItem task)? onSave;

  bool get isEditing => task != null;

  @override
  State<TaskFormPage> createState() => _TaskFormPageState();
}

class _TaskFormPageState extends State<TaskFormPage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _descriptionController;

  late String? _projectId;
  late String? _assigneeId;
  late String _status;
  late String _priority;
  DateTime? _dueDate;

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
  void initState() {
    super.initState();
    final task = widget.task;
    _titleController = TextEditingController(text: task?.title ?? '');
    _descriptionController =
        TextEditingController(text: task?.description ?? '');
    _projectId = task?.projectId ?? widget.initialProjectId;
    _assigneeId = task?.assigneeId;
    _status = task?.status ?? 'todo';
    _priority = task?.priority ?? 'medium';
    _dueDate = task?.dueDate;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  List<Project> _projectsFromCubit(TaskState state) {
    if (state is TaskLoaded) return state.projects;
    if (state is TaskEmpty) return state.projects;
    return const [];
  }

  List<User> _membersFromCubit(TaskState state) {
    if (state is TaskLoaded) return state.members;
    if (state is TaskEmpty) return state.members;
    return const [];
  }

  String? _resolveProjectId(List<Project> projects) {
    if (projects.isEmpty) return null;
    if (_projectId != null && projects.any((p) => p.id == _projectId)) {
      return _projectId;
    }
    return projects.first.id;
  }

  String? _resolveAssigneeId(List<User> members) {
    if (_assigneeId == null) return null;
    if (members.any((m) => m.id == _assigneeId)) return _assigneeId;
    return null;
  }

  Future<void> _pickDueDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _dueDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() => _dueDate = picked);
    }
  }

  Future<void> _submit(
    List<Project> projects,
    List<User> members,
  ) async {
    if (!_formKey.currentState!.validate()) return;

    final projectId = _resolveProjectId(projects);
    if (projectId == null) return;

    final title = _titleController.text.trim();
    final description = _descriptionController.text.trim();
    final assigneeId = _resolveAssigneeId(members);

    if (widget.isEditing) {
      final task = widget.task!.copyWith(
        projectId: projectId,
        title: title,
        description: description,
        status: _status,
        priority: _priority,
        assigneeId: assigneeId,
        dueDate: _dueDate,
        clearAssignee: assigneeId == null,
        clearDueDate: _dueDate == null,
      );

      try {
        if (widget.onSave != null) {
          await widget.onSave!(task);
        } else {
          await context.read<TaskCubit>().updateTask(task: task);
        }
        if (mounted) Navigator.of(context).pop(true);
      } on AppException catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(e.message)),
          );
        }
      }
    } else {
      final taskId = await context.read<TaskCubit>().createTask(
            projectId: projectId,
            title: title,
            description: description,
            status: _status,
            priority: _priority,
            assigneeId: assigneeId,
            dueDate: _dueDate,
          );
      if (mounted && taskId != null) {
        Navigator.of(context).pop(taskId);
      }
    }
  }

  Widget _buildForm(List<Project> projects, List<User> members) {
    final projectId = _resolveProjectId(projects);
    final assigneeId = _resolveAssigneeId(members);

    return SafeArea(
      child: Form(
        key: _formKey,
        child: ListView(
          padding: EdgeInsets.all(AppSpacing.screenHorizontal.w),
          children: [
            AppTextField(
              label: 'Title',
              controller: _titleController,
              hint: 'Update landing page copy',
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Task title is required';
                }
                return null;
              },
            ),
            SizedBox(height: AppSpacing.lg.h),
            DropdownButtonFormField<String>(
              value: projectId,
              decoration: const InputDecoration(labelText: 'Project'),
              items: projects
                  .map(
                    (project) => DropdownMenuItem(
                      value: project.id,
                      child: Text(project.name),
                    ),
                  )
                  .toList(),
              onChanged: projects.isEmpty
                  ? null
                  : (value) => setState(() => _projectId = value),
              validator: (value) {
                if (value == null) return 'Project is required';
                return null;
              },
            ),
            SizedBox(height: AppSpacing.lg.h),
            AppTextField(
              label: 'Description',
              controller: _descriptionController,
              hint: 'What needs to be done?',
            ),
            SizedBox(height: AppSpacing.lg.h),
            DropdownButtonFormField<String?>(
              value: assigneeId,
              decoration: const InputDecoration(labelText: 'Assignee'),
              items: [
                const DropdownMenuItem(
                  value: null,
                  child: Text('Unassigned'),
                ),
                ...members.map(
                  (member) => DropdownMenuItem(
                    value: member.id,
                    child: Text(member.name),
                  ),
                ),
              ],
              onChanged: (value) => setState(() => _assigneeId = value),
            ),
            SizedBox(height: AppSpacing.lg.h),
            DropdownButtonFormField<String>(
              value: _priority,
              decoration: const InputDecoration(labelText: 'Priority'),
              items: _priorities
                  .map(
                    (item) => DropdownMenuItem(
                      value: item.$1,
                      child: Text(item.$2),
                    ),
                  )
                  .toList(),
              onChanged: (value) {
                if (value != null) setState(() => _priority = value);
              },
            ),
            SizedBox(height: AppSpacing.lg.h),
            DropdownButtonFormField<String>(
              value: _status,
              decoration: const InputDecoration(labelText: 'Status'),
              items: _statuses
                  .map(
                    (item) => DropdownMenuItem(
                      value: item.$1,
                      child: Text(item.$2),
                    ),
                  )
                  .toList(),
              onChanged: (value) {
                if (value != null) setState(() => _status = value);
              },
            ),
            SizedBox(height: AppSpacing.lg.h),
            Text('Due date', style: AppTypography.label()),
            SizedBox(height: AppSpacing.sm.h),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: _pickDueDate,
                    child: Text(
                      _dueDate == null
                          ? 'Pick a date'
                          : '${_dueDate!.year}-${_dueDate!.month.toString().padLeft(2, '0')}-${_dueDate!.day.toString().padLeft(2, '0')}',
                    ),
                  ),
                ),
                if (_dueDate != null) ...[
                  SizedBox(width: AppSpacing.sm.w),
                  IconButton(
                    onPressed: () => setState(() => _dueDate = null),
                    icon: const Icon(Icons.clear),
                  ),
                ],
              ],
            ),
            SizedBox(height: AppSpacing.xxl.h),
            AppButton(
              label: widget.isEditing ? 'Save changes' : 'Create task',
              onPressed:
                  projects.isEmpty ? null : () => _submit(projects, members),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final hasLocalData =
        widget.projects != null && widget.members != null;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          widget.isEditing ? 'Edit Task' : 'New Task',
          style: AppTypography.screenTitle(),
        ),
      ),
      body: hasLocalData
          ? _buildForm(widget.projects!, widget.members!)
          : BlocBuilder<TaskCubit, TaskState>(
              builder: (context, state) {
                if (state is TaskLoading || state is TaskInitial) {
                  return const Center(child: CircularProgressIndicator());
                }

                final projects = _projectsFromCubit(state);
                final members = _membersFromCubit(state);

                if (projects.isEmpty) {
                  return Center(
                    child: Text(
                      'No projects available.',
                      style: AppTypography.body(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  );
                }

                return _buildForm(projects, members);
              },
            ),
    );
  }
}
