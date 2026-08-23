import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../auth/domain/entities/user.dart';
import '../../../projects/domain/entities/project.dart';

class TaskFilterResult {
  const TaskFilterResult({
    this.priority,
    this.projectId,
    this.assigneeId,
  });

  final String? priority;
  final String? projectId;
  final String? assigneeId;
}

Future<TaskFilterResult?> showTaskFilterSheet({
  required BuildContext context,
  required List<Project> projects,
  required List<User> members,
  String? initialPriority,
  String? initialProjectId,
  String? initialAssigneeId,
}) {
  return showModalBottomSheet<TaskFilterResult>(
    context: context,
    isScrollControlled: true,
    backgroundColor: AppColors.surface,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
    ),
    builder: (context) {
      return _TaskFilterSheet(
        projects: projects,
        members: members,
        initialPriority: initialPriority,
        initialProjectId: initialProjectId,
        initialAssigneeId: initialAssigneeId,
      );
    },
  );
}

class _TaskFilterSheet extends StatefulWidget {
  const _TaskFilterSheet({
    required this.projects,
    required this.members,
    this.initialPriority,
    this.initialProjectId,
    this.initialAssigneeId,
  });

  final List<Project> projects;
  final List<User> members;
  final String? initialPriority;
  final String? initialProjectId;
  final String? initialAssigneeId;

  @override
  State<_TaskFilterSheet> createState() => _TaskFilterSheetState();
}

class _TaskFilterSheetState extends State<_TaskFilterSheet> {
  String? _priority;
  String? _projectId;
  String? _assigneeId;

  @override
  void initState() {
    super.initState();
    _priority = widget.initialPriority;
    _projectId = widget.initialProjectId;
    _assigneeId = widget.initialAssigneeId;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: AppSpacing.screenHorizontal.w,
        right: AppSpacing.screenHorizontal.w,
        top: AppSpacing.lg.h,
        bottom: MediaQuery.viewInsetsOf(context).bottom + AppSpacing.lg.h,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('Filter tasks', style: AppTypography.screenTitle()),
          SizedBox(height: AppSpacing.lg.h),
          DropdownButtonFormField<String?>(
            value: _priority,
            decoration: const InputDecoration(labelText: 'Priority'),
            items: const [
              DropdownMenuItem(value: null, child: Text('Any priority')),
              DropdownMenuItem(value: 'low', child: Text('Low')),
              DropdownMenuItem(value: 'medium', child: Text('Medium')),
              DropdownMenuItem(value: 'high', child: Text('High')),
              DropdownMenuItem(value: 'urgent', child: Text('Urgent')),
            ],
            onChanged: (value) => setState(() => _priority = value),
          ),
          SizedBox(height: AppSpacing.md.h),
          DropdownButtonFormField<String?>(
            value: _projectId,
            decoration: const InputDecoration(labelText: 'Project'),
            items: [
              const DropdownMenuItem(value: null, child: Text('Any project')),
              ...widget.projects.map(
                (project) => DropdownMenuItem(
                  value: project.id,
                  child: Text(project.name),
                ),
              ),
            ],
            onChanged: (value) => setState(() => _projectId = value),
          ),
          SizedBox(height: AppSpacing.md.h),
          DropdownButtonFormField<String?>(
            value: _assigneeId,
            decoration: const InputDecoration(labelText: 'Assignee'),
            items: [
              const DropdownMenuItem(value: null, child: Text('Anyone')),
              ...widget.members.map(
                (member) => DropdownMenuItem(
                  value: member.id,
                  child: Text(member.name),
                ),
              ),
            ],
            onChanged: (value) => setState(() => _assigneeId = value),
          ),
          SizedBox(height: AppSpacing.xl.h),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    Navigator.pop(
                      context,
                      const TaskFilterResult(),
                    );
                  },
                  child: const Text('Clear'),
                ),
              ),
              SizedBox(width: AppSpacing.md.w),
              Expanded(
                child: FilledButton(
                  onPressed: () {
                    Navigator.pop(
                      context,
                      TaskFilterResult(
                        priority: _priority,
                        projectId: _projectId,
                        assigneeId: _assigneeId,
                      ),
                    );
                  },
                  child: const Text('Apply'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
