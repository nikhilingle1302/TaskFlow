import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

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
  });

  final TaskItem? task;
  final String? initialProjectId;

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

  List<Project> _projects(TaskState state) {
    if (state is TaskLoaded) return state.projects;
    if (state is TaskEmpty) return state.projects;
    return const [];
  }

  List<User> _members(TaskState state) {
    if (state is TaskLoaded) return state.members;
    if (state is TaskEmpty) return state.members;
    return const [];
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

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final cubit = context.read<TaskCubit>();
    final state = cubit.state;
    final projects = _projects(state);
    final projectId = _projectId ??
        (projects.isNotEmpty ? projects.first.id : null);
    if (projectId == null) return;
    final title = _titleController.text.trim();
    final description = _descriptionController.text.trim();

    if (widget.isEditing) {
      final task = widget.task!.copyWith(
        projectId: _projectId,
        title: title,
        description: description,
        status: _status,
        priority: _priority,
        assigneeId: _assigneeId,
        dueDate: _dueDate,
        clearAssignee: _assigneeId == null,
        clearDueDate: _dueDate == null,
      );
      try {
        await cubit.updateTask(task: task);
        if (mounted) Navigator.of(context).pop(true);
      } catch (_) {}
    } else {
      final taskId = await cubit.createTask(
        projectId: projectId,
        title: title,
        description: description,
        status: _status,
        priority: _priority,
        assigneeId: _assigneeId,
        dueDate: _dueDate,
      );
      if (mounted && taskId != null) {
        Navigator.of(context).pop(taskId);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          widget.isEditing ? 'Edit Task' : 'New Task',
          style: AppTypography.screenTitle(),
        ),
      ),
      body: BlocBuilder<TaskCubit, TaskState>(
        builder: (context, state) {
          final projects = _projects(state);
          final members = _members(state);
          final projectId = _projectId ??
              (projects.isNotEmpty ? projects.first.id : null);

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
                    value: _assigneeId,
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
                    onPressed: projects.isEmpty ? null : _submit,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
