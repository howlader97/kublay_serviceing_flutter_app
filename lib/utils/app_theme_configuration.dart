import 'package:flutter/material.dart';
import 'package:belwork/constant/app_colors.dart';
import 'package:belwork/constant/app_constant.dart';

class AppThemeConfiguration {
  ////////////// constructor
  AppThemeConfiguration._privateConstructor();
  static final AppThemeConfiguration _instance = AppThemeConfiguration._privateConstructor();
  static AppThemeConfiguration get instance => _instance;

  ThemeData lightThemeData = ThemeData.light(useMaterial3: true).copyWith(
    scaffoldBackgroundColor: AppColors.instance.white50,

    dividerColor: AppColors.instance.transparent,
    primaryColor: AppColors.instance.white50,
    primaryColorLight: AppColors.instance.white50,
    splashColor: AppColors.instance.transparent,
    hoverColor: AppColors.instance.transparent,
    appBarTheme: AppBarTheme(elevation: 5, surfaceTintColor: AppColors.instance.white50, backgroundColor: AppColors.instance.white50),
    textTheme: TextTheme(
      bodyLarge: TextStyle(fontFamily: AppConstant.instance.font),
      bodyMedium: TextStyle(fontFamily: AppConstant.instance.font),
      bodySmall: TextStyle(fontFamily: AppConstant.instance.font),
      displayLarge: TextStyle(fontFamily: AppConstant.instance.font),
      displayMedium: TextStyle(fontFamily: AppConstant.instance.font),
      displaySmall: TextStyle(fontFamily: AppConstant.instance.font),
      headlineLarge: TextStyle(fontFamily: AppConstant.instance.font),
      headlineMedium: TextStyle(fontFamily: AppConstant.instance.font),
      headlineSmall: TextStyle(fontFamily: AppConstant.instance.font),
      labelLarge: TextStyle(fontFamily: AppConstant.instance.font),
      labelMedium: TextStyle(fontFamily: AppConstant.instance.font),
      labelSmall: TextStyle(fontFamily: AppConstant.instance.font),
      titleLarge: TextStyle(fontFamily: AppConstant.instance.font),
      titleMedium: TextStyle(fontFamily: AppConstant.instance.font),
      titleSmall: TextStyle(fontFamily: AppConstant.instance.font),
    ),
    focusColor: AppColors.instance.blue500,

    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: AppColors.instance.gray200),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: AppColors.instance.gray200),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: AppColors.instance.gray200),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: AppColors.instance.error),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: AppColors.instance.error),
      ),
    ),
  );

  ThemeData darkThemeData = ThemeData.dark(useMaterial3: true);
}
