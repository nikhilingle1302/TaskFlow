import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'app_colors.dart';

class AppTypography {
  AppTypography._();

  static const String fontFamily = 'Poppins';

  static TextStyle largeHeading({Color? color}) {
    return TextStyle(
      fontFamily: fontFamily,
      fontSize: 24.sp,
      height: 32 / 24,
      fontWeight: FontWeight.w700,
      color: color ?? AppColors.textPrimary,
    );
  }

  static TextStyle screenTitle({Color? color}) {
    return TextStyle(
      fontFamily: fontFamily,
      fontSize: 20.sp,
      height: 28 / 20,
      fontWeight: FontWeight.w600,
      color: color ?? AppColors.textPrimary,
    );
  }

  static TextStyle cardTitle({Color? color}) {
    return TextStyle(
      fontFamily: fontFamily,
      fontSize: 16.sp,
      height: 24 / 16,
      fontWeight: FontWeight.w600,
      color: color ?? AppColors.textPrimary,
    );
  }

  static TextStyle body({Color? color, FontWeight weight = FontWeight.w400}) {
    return TextStyle(
      fontFamily: fontFamily,
      fontSize: 14.sp,
      height: 20 / 14,
      fontWeight: weight,
      color: color ?? AppColors.textPrimary,
    );
  }

  static TextStyle label({Color? color}) {
    return TextStyle(
      fontFamily: fontFamily,
      fontSize: 14.sp,
      height: 20 / 14,
      fontWeight: FontWeight.w500,
      color: color ?? AppColors.textPrimary,
    );
  }

  static TextStyle caption({Color? color}) {
    return TextStyle(
      fontFamily: fontFamily,
      fontSize: 12.sp,
      height: 16 / 12,
      fontWeight: FontWeight.w400,
      color: color ?? AppColors.textSecondary,
    );
  }

  static TextStyle button({Color? color}) {
    return TextStyle(
      fontFamily: fontFamily,
      fontSize: 14.sp,
      height: 20 / 14,
      fontWeight: FontWeight.w600,
      color: color ?? AppColors.surface,
    );
  }
}
