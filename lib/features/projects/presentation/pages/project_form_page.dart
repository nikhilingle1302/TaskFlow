import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/app_text_field.dart';
import '../cubit/project_cubit.dart';

class ProjectFormPage extends StatefulWidget {
  const ProjectFormPage({
    super.key,
    this.projectId,
    this.initialName = '',
    this.initialDescription = '',
  });

  final String? projectId;
  final String initialName;
  final String initialDescription;

  bool get isEditing => projectId != null;

  @override
  State<ProjectFormPage> createState() => _ProjectFormPageState();
}

class _ProjectFormPageState extends State<ProjectFormPage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _descriptionController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.initialName);
    _descriptionController =
        TextEditingController(text: widget.initialDescription);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final cubit = context.read<ProjectCubit>();
    final name = _nameController.text.trim();
    final description = _descriptionController.text.trim();

    if (widget.isEditing) {
      await cubit.updateProject(
        projectId: widget.projectId!,
        name: name,
        description: description,
      );
    } else {
      await cubit.createProject(name: name, description: description);
    }

    if (mounted) {
      Navigator.of(context).pop(true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          widget.isEditing ? 'Edit Project' : 'New Project',
          style: AppTypography.screenTitle(),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(AppSpacing.screenHorizontal.w),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                AppTextField(
                  label: 'Project name',
                  controller: _nameController,
                  hint: 'Website Relaunch',
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Project name is required';
                    }
                    return null;
                  },
                ),
                SizedBox(height: AppSpacing.lg.h),
                AppTextField(
                  label: 'Description',
                  controller: _descriptionController,
                  hint: 'What is this project about?',
                ),
                const Spacer(),
                AppButton(
                  label: widget.isEditing ? 'Save changes' : 'Create project',
                  onPressed: _submit,
                ),
                SizedBox(height: AppSpacing.lg.h),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
