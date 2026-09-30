import 'package:flutter/material.dart';
import 'package:belwork/constant/app_colors.dart';
import 'package:belwork/routes/app_routes.dart';
import 'package:belwork/routes/app_routes_key.dart';
import 'package:belwork/utils/gap.dart';
import 'package:belwork/widgets/buttons/app_button.dart';
import 'package:belwork/widgets/texts/app_text.dart';

void showLoginRequiredDialog(BuildContext context, {String? message}) {
  showAdaptiveDialog(
    context: context,
    barrierDismissible: true,
    builder: (context) => Material(
      color: Colors.transparent,
      child: Center(
        child: LoginRequiredDialog(message: message),
      ),
    ),
  );
}

class LoginRequiredDialog extends StatelessWidget {
  final String? message;

  const LoginRequiredDialog({super.key, this.message});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 22),
        decoration: BoxDecoration(
          color: AppColors.instance.background,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: AppColors.instance.gray200.withValues(alpha: 0.3),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.15),
              blurRadius: 24,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Align(
              alignment: Alignment.topRight,
              child: GestureDetector(
                onTap: () {
                  Navigator.of(context).pop();
                },
                child: Icon(
                  Icons.close,
                  size: 22,
                  color: AppColors.instance.textColor,
                ),
              ),
            ),
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: AppColors.instance.primary.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.lock_outline_rounded,
                size: 28,
                color: AppColors.instance.primary,
              ),
            ),
            const Gap(height: 14),
            AppText(
              text: "You need to login",
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.instance.textColor,
              textAlign: TextAlign.center,
            ),
            const Gap(height: 8),
            AppText(
              text: message ?? "Please log in to continue and access this feature.",
              fontSize: 13,
              fontWeight: FontWeight.w400,
              color: AppColors.instance.textColor.withValues(alpha: 0.7),
              textAlign: TextAlign.center,
            ),
            const Gap(height: 22),
            Row(
              children: [
                Expanded(
                  child: AppButton(
                    onTap: () {
                      Navigator.of(context).pop();
                    },
                    title: "Cancel",
                    backgroundColor: Colors.transparent,
                    borderColor: AppColors.instance.gray200.withValues(alpha: 0.8),
                    titleColor: AppColors.instance.textColor,
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    height: 44,
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                const Gap(width: 12),
                Expanded(
                  child: AppButton(
                    onTap: () {
                      Navigator.of(context).pop();
                      AppRoutes.instance.go(
                        AppRoutesKey.instance.signInScreen,
                      );
                    },
                    title: "Log In",
                    backgroundColor: AppColors.instance.primary,
                    titleColor: AppColors.instance.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    height: 44,
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
