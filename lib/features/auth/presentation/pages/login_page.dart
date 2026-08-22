import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/validators.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/app_text_field.dart';
import '../bloc/auth_bloc.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _rememberMe = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    context.read<AuthBloc>().add(
          AuthLoginRequested(
            email: _emailController.text.trim(),
            password: _passwordController.text,
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: BlocBuilder<AuthBloc, AuthState>(
          builder: (context, state) {
            final isLoading = state is AuthLoading;
            final error =
                state is AuthUnauthenticated ? state.message : null;

            return SingleChildScrollView(
              padding: EdgeInsets.symmetric(
                horizontal: AppSpacing.screenHorizontal.w,
                vertical: AppSpacing.xxl.h,
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: AppSpacing.xl.h),
                    Row(
                      children: [
                        Container(
                          width: 40.w,
                          height: 40.w,
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            borderRadius: BorderRadius.circular(AppRadius.md.r),
                          ),
                          child: Icon(
                            Icons.check_rounded,
                            color: AppColors.surface,
                            size: 24.sp,
                          ),
                        ),
                        SizedBox(width: AppSpacing.sm.w),
                        Text('TaskFlow', style: AppTypography.cardTitle()),
                      ],
                    ),
                    SizedBox(height: AppSpacing.xxxl.h),
                    Text(
                      'Welcome Back! 👋',
                      style: AppTypography.largeHeading(),
                    ),
                    SizedBox(height: AppSpacing.sm.h),
                    Text(
                      'Sign in to continue managing your projects.',
                      style: AppTypography.body(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    SizedBox(height: AppSpacing.xxl.h),
                    if (error != null) ...[
                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.all(AppSpacing.md.w),
                        decoration: BoxDecoration(
                          color: AppColors.priorityUrgentBg,
                          borderRadius: BorderRadius.circular(AppRadius.md.r),
                        ),
                        child: Text(
                          error,
                          style: AppTypography.body(color: AppColors.error),
                        ),
                      ),
                      SizedBox(height: AppSpacing.lg.h),
                    ],
                    AppTextField(
                      label: 'Email',
                      controller: _emailController,
                      hint: 'Enter your email',
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                      validator: Validators.email,
                    ),
                    SizedBox(height: AppSpacing.lg.h),
                    AppTextField(
                      label: 'Password',
                      controller: _passwordController,
                      hint: 'Enter your password',
                      obscureText: _obscurePassword,
                      textInputAction: TextInputAction.done,
                      validator: Validators.password,
                      suffixIcon: IconButton(
                        onPressed: () {
                          setState(() => _obscurePassword = !_obscurePassword);
                        },
                        icon: Icon(
                          _obscurePassword
                              ? Icons.visibility_outlined
                              : Icons.visibility_off_outlined,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                    SizedBox(height: AppSpacing.md.h),
                    Row(
                      children: [
                        SizedBox(
                          height: 24.h,
                          width: 24.w,
                          child: Checkbox(
                            value: _rememberMe,
                            onChanged: (value) {
                              setState(() => _rememberMe = value ?? false);
                            },
                          ),
                        ),
                        SizedBox(width: AppSpacing.sm.w),
                        Text('Remember me', style: AppTypography.body()),
                        const Spacer(),
                        TextButton(
                          onPressed: () {},
                          child: Text(
                            'Forgot Password?',
                            style: AppTypography.label(
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: AppSpacing.xxl.h),
                    AppButton(
                      label: 'Sign In',
                      isLoading: isLoading,
                      onPressed: _submit,
                    ),
                    SizedBox(height: AppSpacing.xxl.h),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Don't have an account? ",
                          style: AppTypography.body(
                            color: AppColors.textSecondary,
                          ),
                        ),
                        GestureDetector(
                          onTap: isLoading
                              ? null
                              : () => context.push(AppRoutes.register),
                          child: Text(
                            'Sign Up',
                            style: AppTypography.label(
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
